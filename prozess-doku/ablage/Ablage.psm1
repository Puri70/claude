# Prozessablage: Ordnerstruktur, Protokoll und Freigaben.
# Ohne Oberfläche, damit die Regeln auch außerhalb von Windows getestet werden können.
# Läuft unter Windows PowerShell 5.1 und PowerShell 7.

Set-StrictMode -Version 2.0

$script:Utf8 = New-Object System.Text.UTF8Encoding($false)

$script:Status = @{
    Entwurf       = 'Entwurf'
    Rohdaten      = 'Rohdaten abgeschlossen'
    Fachlich      = 'Fachlich freigegeben'
    Ueberarbeitung = 'In Überarbeitung'
    Final         = 'Final freigegeben'
}

$script:Unterordner = @('1_Rohdaten', '2_KI-Ausgabe', '3_Bearbeitet')
$script:FreigabeOrdner = 'Freigegeben'
$script:ProtokollDatei = 'protokoll.json'
$script:ProzessDatei = 'prozess.json'
$script:Gesamtprotokoll = 'Freigabeprotokoll.csv'

function Get-AblageStatus { $script:Status.Clone() }

function Get-AktuellerBenutzer {
    if ($env:USERDOMAIN) { return "$env:USERDOMAIN\$env:USERNAME" }
    if ($env:USERNAME) { return $env:USERNAME }
    return [Environment]::UserName
}

function Get-Zeitstempel { (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss') }

function Read-Json([string]$Pfad) {
    [System.IO.File]::ReadAllText($Pfad, $script:Utf8) | ConvertFrom-Json
}

function Write-Json([string]$Pfad, $Objekt) {
    $text = $Objekt | ConvertTo-Json -Depth 12
    $schreibgeschuetzt = (Test-Path $Pfad) -and (Get-Item $Pfad).IsReadOnly
    if ($schreibgeschuetzt) { (Get-Item $Pfad).IsReadOnly = $false }
    [System.IO.File]::WriteAllText($Pfad, $text, $script:Utf8)
}

# Pfade werden relativ zum Entwurfsordner und mit "/" gespeichert, damit das Protokoll
# nach einem Umzug (z. B. nach SharePoint) gültig bleibt.
function Get-Pruefsummen([string]$Basis, [string[]]$Ordner) {
    $liste = @()
    foreach ($o in $Ordner) {
        $voll = Join-Path $Basis $o
        if (-not (Test-Path $voll)) { continue }
        $dateien = @(Get-ChildItem -LiteralPath $voll -File -Recurse | Sort-Object FullName)
        foreach ($d in $dateien) {
            $relativ = $d.FullName.Substring($Basis.TrimEnd('\', '/').Length + 1).Replace('\', '/')
            $liste += [pscustomobject]@{ pfad = $relativ; sha256 = (Get-FileHash -LiteralPath $d.FullName -Algorithm SHA256).Hash }
        }
    }
    , $liste
}

function Set-Schreibschutz([string]$Basis, [string[]]$Ordner) {
    foreach ($o in $Ordner) {
        $voll = Join-Path $Basis $o
        if (-not (Test-Path $voll)) { continue }
        Get-ChildItem -LiteralPath $voll -File -Recurse | ForEach-Object { $_.IsReadOnly = $true }
    }
}

# Vergleicht gespeicherte Prüfsummen mit dem aktuellen Stand.
# Gibt eine Liste von Abweichungen zurück: geändert, fehlt oder neu.
function Compare-Pruefsummen([string]$Basis, $Gespeichert, [string[]]$Ordner) {
    $aktuell = Get-Pruefsummen $Basis $Ordner
    $abweichungen = @()
    $aktuellNachPfad = @{}
    foreach ($a in $aktuell) { $aktuellNachPfad[$a.pfad] = $a.sha256 }
    $gespeichertNachPfad = @{}
    foreach ($g in @($Gespeichert)) {
        if ($null -eq $g) { continue }
        $gespeichertNachPfad[$g.pfad] = $g.sha256
        if (-not $aktuellNachPfad.ContainsKey($g.pfad)) { $abweichungen += [pscustomobject]@{ pfad = $g.pfad; art = 'fehlt' } }
        elseif ($aktuellNachPfad[$g.pfad] -ne $g.sha256) { $abweichungen += [pscustomobject]@{ pfad = $g.pfad; art = 'geändert' } }
    }
    foreach ($a in $aktuell) {
        if (-not $gespeichertNachPfad.ContainsKey($a.pfad)) { $abweichungen += [pscustomobject]@{ pfad = $a.pfad; art = 'neu' } }
    }
    , $abweichungen
}

function Add-Gesamtprotokoll([string]$Wurzel, $Protokoll, [string]$Aktion, [string]$Von, [string]$Kommentar) {
    $pfad = Join-Path $Wurzel $script:Gesamtprotokoll
    if (-not (Test-Path $pfad)) {
        [System.IO.File]::WriteAllText($pfad, "Zeitpunkt;Prozess;Entwurf;Aktion;Von;Kommentar`r`n", $script:Utf8)
    }
    $felder = @((Get-Zeitstempel), $Protokoll.prozess, $Protokoll.entwurf, $Aktion, $Von, $Kommentar) |
        ForEach-Object { '"' + ([string]$_).Replace('"', '""').Replace("`r", ' ').Replace("`n", ' ') + '"' }
    [System.IO.File]::AppendAllText($pfad, ($felder -join ';') + "`r`n", $script:Utf8)
}

function Add-Verlauf($Protokoll, [string]$Aktion, [string]$Von, [string]$Kommentar) {
    $eintrag = [pscustomobject]@{ am = (Get-Zeitstempel); von = $Von; aktion = $Aktion; kommentar = $Kommentar }
    $Protokoll.verlauf = @($Protokoll.verlauf) + $eintrag
}

function Get-EntwurfProtokoll([string]$EntwurfPfad) {
    $pfad = Join-Path $EntwurfPfad $script:ProtokollDatei
    if (-not (Test-Path $pfad)) { throw "Kein Protokoll in $EntwurfPfad gefunden." }
    Read-Json $pfad
}

function Save-EntwurfProtokoll([string]$EntwurfPfad, $Protokoll) {
    Write-Json (Join-Path $EntwurfPfad $script:ProtokollDatei) $Protokoll
}

function Assert-Status($Protokoll, [string[]]$Erlaubt, [string]$Aktion) {
    if ($Erlaubt -notcontains $Protokoll.status) {
        throw "'$Aktion' ist im Status '$($Protokoll.status)' nicht möglich. Erlaubt: $($Erlaubt -join ', ')."
    }
}

# ---------------------------------------------------------------------------
# Anlegen
# ---------------------------------------------------------------------------

function Initialize-Ablage([string]$Wurzel) {
    if (-not (Test-Path $Wurzel)) { [void](New-Item -ItemType Directory -Path $Wurzel) }
    (Resolve-Path $Wurzel).Path
}

function New-Prozess {
    param([Parameter(Mandatory)][string]$Wurzel, [Parameter(Mandatory)][string]$Name, [string]$Von = (Get-AktuellerBenutzer))
    $name = $Name.Trim()
    if (-not $name) { throw 'Bitte einen Prozessnamen angeben.' }
    if ($name -match '[\\/:*?"<>|]') { throw 'Der Prozessname darf keines dieser Zeichen enthalten: \ / : * ? " < > |' }
    $Wurzel = Initialize-Ablage $Wurzel
    $vorhanden = @(Get-Prozess -Wurzel $Wurzel)
    foreach ($p in $vorhanden) {
        if ($p.name -eq $name) { throw "Den Prozess '$name' gibt es schon ($($p.nr))." }
    }
    $nummer = 1
    foreach ($p in $vorhanden) {
        $n = [int]$p.nr.Substring(1)
        if ($n -ge $nummer) { $nummer = $n + 1 }
    }
    $nr = 'P{0:00}' -f $nummer
    $ordner = Join-Path $Wurzel "$nr $name"
    [void](New-Item -ItemType Directory -Path $ordner)
    [void](New-Item -ItemType Directory -Path (Join-Path $ordner $script:FreigabeOrdner))
    $prozess = [pscustomobject]@{ nr = $nr; name = $name; angelegt = (Get-Zeitstempel); von = $Von; letzteVersion = 0 }
    Write-Json (Join-Path $ordner $script:ProzessDatei) $prozess
    $prozess | Add-Member -NotePropertyName pfad -NotePropertyValue $ordner -PassThru
}

function Get-Prozess {
    param([Parameter(Mandatory)][string]$Wurzel)
    if (-not (Test-Path $Wurzel)) { return }
    foreach ($ordner in @(Get-ChildItem -LiteralPath $Wurzel -Directory | Sort-Object Name)) {
        $datei = Join-Path $ordner.FullName $script:ProzessDatei
        if (-not (Test-Path $datei)) { continue }
        Read-Json $datei | Add-Member -NotePropertyName pfad -NotePropertyValue $ordner.FullName -PassThru
    }
}

function New-Entwurf {
    param([Parameter(Mandatory)][string]$ProzessPfad, [string]$Von = (Get-AktuellerBenutzer))
    $prozess = Read-Json (Join-Path $ProzessPfad $script:ProzessDatei)
    $nummer = 1
    foreach ($e in @(Get-ChildItem -LiteralPath $ProzessPfad -Directory | Where-Object { $_.Name -match '^Entwurf-(\d+) ' })) {
        $n = [int]([regex]::Match($e.Name, '^Entwurf-(\d+) ').Groups[1].Value)
        if ($n -ge $nummer) { $nummer = $n + 1 }
    }
    $name = 'Entwurf-{0:00} {1}' -f $nummer, (Get-Date -Format 'yyyy-MM-dd')
    $pfad = Join-Path $ProzessPfad $name
    [void](New-Item -ItemType Directory -Path $pfad)
    foreach ($u in $script:Unterordner) { [void](New-Item -ItemType Directory -Path (Join-Path $pfad $u)) }
    $protokoll = [pscustomobject]@{
        prozess   = "$($prozess.nr) $($prozess.name)"
        entwurf   = $name
        status    = $script:Status.Entwurf
        angelegt  = [pscustomobject]@{ am = (Get-Zeitstempel); von = $Von }
        rohdaten  = $null
        freigaben = @()
        version   = $null
        verlauf   = @()
    }
    Add-Verlauf $protokoll 'Entwurf angelegt' $Von ''
    Save-EntwurfProtokoll $pfad $protokoll
    Add-Gesamtprotokoll (Split-Path $ProzessPfad -Parent) $protokoll 'Entwurf angelegt' $Von ''
    $pfad
}

function Get-Entwurf {
    param([Parameter(Mandatory)][string]$Wurzel)
    foreach ($p in @(Get-Prozess -Wurzel $Wurzel)) {
        foreach ($e in @(Get-ChildItem -LiteralPath $p.pfad -Directory | Where-Object { $_.Name -match '^Entwurf-\d+ ' } | Sort-Object Name)) {
            $prot = Get-EntwurfProtokoll $e.FullName
            $letzter = @($prot.verlauf) | Select-Object -Last 1
            [pscustomobject]@{
                prozess  = $prot.prozess
                entwurf  = $prot.entwurf
                status   = $prot.status
                version  = $prot.version
                aktion   = if ($letzter) { $letzter.aktion } else { '' }
                von      = if ($letzter) { $letzter.von } else { '' }
                am       = if ($letzter) { $letzter.am } else { '' }
                pfad     = $e.FullName
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Schritte
# ---------------------------------------------------------------------------

# Rohdaten und KI-Ausgabe werden schreibgeschützt und mit Prüfsummen festgehalten.
function Close-Rohdaten {
    param([Parameter(Mandatory)][string]$EntwurfPfad, [string]$Von = (Get-AktuellerBenutzer))
    $p = Get-EntwurfProtokoll $EntwurfPfad
    Assert-Status $p @($script:Status.Entwurf) 'Rohdaten abschließen'
    $roh = @(Get-ChildItem -LiteralPath (Join-Path $EntwurfPfad '1_Rohdaten') -File -Recurse)
    if ($roh.Count -eq 0) { throw 'In 1_Rohdaten liegt noch nichts. Bitte zuerst Transkript und Screenshots ablegen.' }
    $summen = Get-Pruefsummen $EntwurfPfad @('1_Rohdaten', '2_KI-Ausgabe')
    Set-Schreibschutz $EntwurfPfad @('1_Rohdaten', '2_KI-Ausgabe')
    $p.rohdaten = [pscustomobject]@{ am = (Get-Zeitstempel); von = $Von; dateien = $summen }
    $p.status = $script:Status.Rohdaten
    Add-Verlauf $p 'Rohdaten abgeschlossen' $Von "$($summen.Count) Dateien"
    Save-EntwurfProtokoll $EntwurfPfad $p
    Add-Gesamtprotokoll (Split-Path (Split-Path $EntwurfPfad -Parent) -Parent) $p 'Rohdaten abgeschlossen' $Von "$($summen.Count) Dateien"
    $p
}

function Grant-FachlicheFreigabe {
    param([Parameter(Mandatory)][string]$EntwurfPfad, [string]$Von = (Get-AktuellerBenutzer), [string]$Kommentar = '')
    $p = Get-EntwurfProtokoll $EntwurfPfad
    Assert-Status $p @($script:Status.Rohdaten, $script:Status.Ueberarbeitung) 'Fachlich freigeben'
    $roh = Compare-Pruefsummen $EntwurfPfad $p.rohdaten.dateien @('1_Rohdaten', '2_KI-Ausgabe')
    if ($roh.Count -gt 0) {
        throw "Die Rohdaten wurden nach dem Abschließen verändert: $(($roh | ForEach-Object { "$($_.pfad) ($($_.art))" }) -join ', '). Bitte einen neuen Entwurf anlegen."
    }
    $bearbeitet = Get-Pruefsummen $EntwurfPfad @('3_Bearbeitet')
    if ($bearbeitet.Count -eq 0) { throw 'In 3_Bearbeitet liegt noch keine Arbeitsanweisung.' }
    $freigabe = [pscustomobject]@{ stufe = 'fachlich'; am = (Get-Zeitstempel); von = $Von; kommentar = $Kommentar; dateien = $bearbeitet; ohneVierAugen = $false }
    $p.freigaben = @($p.freigaben) + $freigabe
    $p.status = $script:Status.Fachlich
    Add-Verlauf $p 'Fachlich freigegeben' $Von $Kommentar
    Save-EntwurfProtokoll $EntwurfPfad $p
    Add-Gesamtprotokoll (Split-Path (Split-Path $EntwurfPfad -Parent) -Parent) $p 'Fachlich freigegeben' $Von $Kommentar
    $p
}

function Deny-Freigabe {
    param([Parameter(Mandatory)][string]$EntwurfPfad, [Parameter(Mandatory)][string]$Kommentar, [string]$Von = (Get-AktuellerBenutzer))
    if (-not $Kommentar.Trim()) { throw 'Bitte begründen, was überarbeitet werden soll.' }
    $p = Get-EntwurfProtokoll $EntwurfPfad
    Assert-Status $p @($script:Status.Fachlich) 'Zurückweisen'
    $p.status = $script:Status.Ueberarbeitung
    Add-Verlauf $p 'Zurückgewiesen' $Von $Kommentar
    Save-EntwurfProtokoll $EntwurfPfad $p
    Add-Gesamtprotokoll (Split-Path (Split-Path $EntwurfPfad -Parent) -Parent) $p 'Zurückgewiesen' $Von $Kommentar
    $p
}

# Prüft alles, was eine finale Freigabe verhindern würde, ohne etwas zu ändern.
# Ergebnis: Fehler (blockieren) und ob die Vier-Augen-Regel verletzt wäre.
function Test-FinaleFreigabe {
    param([Parameter(Mandatory)][string]$EntwurfPfad, [string]$Von = (Get-AktuellerBenutzer), [string[]]$Berechtigte = @())
    $p = Get-EntwurfProtokoll $EntwurfPfad
    $fehler = @()
    if ($p.status -ne $script:Status.Fachlich) { $fehler += "Status ist '$($p.status)', nötig ist '$($script:Status.Fachlich)'." }
    if ($Berechtigte.Count -gt 0 -and $Berechtigte -notcontains $Von) { $fehler += "$Von ist nicht für die finale Freigabe eingetragen." }
    $fachlich = @($p.freigaben) | Where-Object { $_.stufe -eq 'fachlich' } | Select-Object -Last 1
    $gleichePerson = $false
    if ($fachlich) {
        $gleichePerson = $fachlich.von -eq $Von
        $aenderungen = Compare-Pruefsummen $EntwurfPfad $fachlich.dateien @('3_Bearbeitet')
        if ($aenderungen.Count -gt 0) {
            $fehler += "Seit der fachlichen Freigabe geändert: $(($aenderungen | ForEach-Object { "$($_.pfad) ($($_.art))" }) -join ', '). Bitte erneut fachlich freigeben lassen."
        }
    }
    if ($p.rohdaten) {
        $roh = Compare-Pruefsummen $EntwurfPfad $p.rohdaten.dateien @('1_Rohdaten', '2_KI-Ausgabe')
        if ($roh.Count -gt 0) { $fehler += 'Die Rohdaten wurden nach dem Abschließen verändert.' }
    }
    [pscustomobject]@{ fehler = $fehler; gleichePerson = $gleichePerson; fachlichVon = if ($fachlich) { $fachlich.von } else { '' } }
}

function Grant-FinaleFreigabe {
    param(
        [Parameter(Mandatory)][string]$EntwurfPfad,
        [string]$Von = (Get-AktuellerBenutzer),
        [string]$Kommentar = '',
        [string[]]$Berechtigte = @(),
        [bool]$VierAugen = $true,
        [string]$BegruendungOhneVierAugen = ''
    )
    $pruefung = Test-FinaleFreigabe -EntwurfPfad $EntwurfPfad -Von $Von -Berechtigte $Berechtigte
    if ($pruefung.fehler.Count -gt 0) { throw ($pruefung.fehler -join "`n") }
    $ohneVierAugen = $false
    if ($pruefung.gleichePerson) {
        if ($VierAugen) { throw 'Fachliche und finale Freigabe müssen von zwei verschiedenen Personen kommen.' }
        if (-not $BegruendungOhneVierAugen.Trim()) { throw 'Ohne zweite Person bitte eine Begründung angeben.' }
        $ohneVierAugen = $true
    }

    $p = Get-EntwurfProtokoll $EntwurfPfad
    $prozessPfad = Split-Path $EntwurfPfad -Parent
    $prozessDatei = Join-Path $prozessPfad $script:ProzessDatei
    $prozess = Read-Json $prozessDatei
    $version = '{0}.0' -f ([int]$prozess.letzteVersion + 1)

    $ziel = Join-Path $prozessPfad $script:FreigabeOrdner
    if (-not (Test-Path $ziel)) { [void](New-Item -ItemType Directory -Path $ziel) }
    $kopien = @()
    foreach ($d in @(Get-ChildItem -LiteralPath (Join-Path $EntwurfPfad '3_Bearbeitet') -File)) {
        $neu = Join-Path $ziel ('{0} {1} - Version {2}{3}' -f $prozess.nr, $prozess.name, $version, $d.Extension)
        if (Test-Path $neu) { $neu = Join-Path $ziel ('{0} {1} - Version {2} - {3}' -f $prozess.nr, $prozess.name, $version, $d.Name) }
        Copy-Item -LiteralPath $d.FullName -Destination $neu
        (Get-Item $neu).IsReadOnly = $true
        $kopien += $neu
    }
    Set-Schreibschutz $EntwurfPfad @('3_Bearbeitet')

    $kommentarVoll = $Kommentar
    if ($ohneVierAugen) { $kommentarVoll = (@($Kommentar, "Ohne Vier-Augen-Prinzip: $BegruendungOhneVierAugen") | Where-Object { $_ }) -join ' | ' }
    $freigabe = [pscustomobject]@{
        stufe = 'final'; am = (Get-Zeitstempel); von = $Von; kommentar = $kommentarVoll
        dateien = (Get-Pruefsummen $EntwurfPfad @('3_Bearbeitet')); ohneVierAugen = $ohneVierAugen
    }
    $p.freigaben = @($p.freigaben) + $freigabe
    $p.status = $script:Status.Final
    $p.version = $version
    Add-Verlauf $p "Final freigegeben, Version $version" $Von $kommentarVoll
    Save-EntwurfProtokoll $EntwurfPfad $p
    (Get-Item (Join-Path $EntwurfPfad $script:ProtokollDatei)).IsReadOnly = $true

    $prozess.letzteVersion = [int]$prozess.letzteVersion + 1
    Write-Json $prozessDatei $prozess
    Add-Gesamtprotokoll (Split-Path $prozessPfad -Parent) $p "Final freigegeben, Version $version" $Von $kommentarVoll
    [pscustomobject]@{ version = $version; dateien = $kopien; protokoll = $p }
}

# Prüft für einen Entwurf, ob alle festgehaltenen Dateien unverändert sind.
function Test-Entwurf {
    param([Parameter(Mandatory)][string]$EntwurfPfad)
    $p = Get-EntwurfProtokoll $EntwurfPfad
    $ergebnis = @()
    if ($p.rohdaten) {
        foreach ($a in (Compare-Pruefsummen $EntwurfPfad $p.rohdaten.dateien @('1_Rohdaten', '2_KI-Ausgabe'))) {
            $ergebnis += [pscustomobject]@{ bereich = 'Rohdaten'; pfad = $a.pfad; art = $a.art }
        }
    }
    $letzte = @($p.freigaben) | Select-Object -Last 1
    if ($letzte) {
        foreach ($a in (Compare-Pruefsummen $EntwurfPfad $letzte.dateien @('3_Bearbeitet'))) {
            $ergebnis += [pscustomobject]@{ bereich = "seit Freigabe ($($letzte.stufe))"; pfad = $a.pfad; art = $a.art }
        }
    }
    , $ergebnis
}

Export-ModuleMember -Function Get-AblageStatus, Get-AktuellerBenutzer, Initialize-Ablage, New-Prozess, Get-Prozess,
    New-Entwurf, Get-Entwurf, Get-EntwurfProtokoll, Close-Rohdaten, Grant-FachlicheFreigabe, Deny-Freigabe,
    Test-FinaleFreigabe, Grant-FinaleFreigabe, Test-Entwurf
