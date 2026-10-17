# Tests der Ablage-Regeln, ohne Oberfläche. Aufruf: pwsh -File tests/Ablage.Tests.ps1
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Ablage.psm1') -Force

$script:fehler = 0
$script:geprueft = 0
function Pruefe([bool]$Bedingung, [string]$Beschreibung) {
    $script:geprueft++
    if (-not $Bedingung) { $script:fehler++; Write-Host "FEHLER: $Beschreibung" }
}
function Wirft([scriptblock]$Block, [string]$Muster, [string]$Beschreibung) {
    $script:geprueft++
    try { & $Block; $script:fehler++; Write-Host "FEHLER (keine Ausnahme): $Beschreibung" }
    catch {
        if ($_.Exception.Message -notmatch $Muster) { $script:fehler++; Write-Host "FEHLER (falsche Meldung '$($_.Exception.Message)'): $Beschreibung" }
    }
}
function Schreibe([string]$Pfad, [string]$Text) {
    $item = Get-Item $Pfad -ErrorAction SilentlyContinue
    if ($item -and $item.IsReadOnly) { $item.IsReadOnly = $false }
    [System.IO.File]::WriteAllText($Pfad, $Text)
}

$wurzel = Join-Path ([System.IO.Path]::GetTempPath()) ("ablage-test-" + [guid]::NewGuid())
$S = Get-AblageStatus
try {
    # Prozesse anlegen und nummerieren
    $p1 = New-Prozess -Wurzel $wurzel -Name 'Monatsabschluss' -Von 'melanie'
    $p2 = New-Prozess -Wurzel $wurzel -Name 'Eingangsrechnung Kreditor' -Von 'melanie'
    Pruefe ($p1.nr -eq 'P01' -and $p2.nr -eq 'P02') 'Prozesse werden fortlaufend nummeriert'
    Pruefe (Test-Path (Join-Path $p1.pfad 'Freigegeben')) 'Ordner Freigegeben wird angelegt'
    Wirft { New-Prozess -Wurzel $wurzel -Name 'Monatsabschluss' } 'gibt es schon' 'doppelter Prozessname wird abgelehnt'
    Wirft { New-Prozess -Wurzel $wurzel -Name 'A/B' } 'Zeichen' 'ungültige Zeichen werden abgelehnt'
    Pruefe (@(Get-Prozess -Wurzel $wurzel).Count -eq 2) 'Prozesse werden gelistet'

    # Entwurf anlegen
    $e1 = New-Entwurf -ProzessPfad $p1.pfad -Von 'melanie'
    Pruefe ((Split-Path $e1 -Leaf) -match '^Entwurf-01 \d{4}-\d{2}-\d{2}$') 'Entwurf heißt Entwurf-01 mit Datum'
    foreach ($u in '1_Rohdaten', '2_KI-Ausgabe', '3_Bearbeitet') { Pruefe (Test-Path (Join-Path $e1 $u)) "Unterordner $u angelegt" }
    $prot = Get-EntwurfProtokoll $e1
    Pruefe ($prot.status -eq $S.Entwurf) 'neuer Entwurf hat Status Entwurf'
    Pruefe ($prot.prozess -eq 'P01 Monatsabschluss') 'Protokoll kennt den Prozess'

    # Falsche Reihenfolge wird abgelehnt
    Wirft { Grant-FachlicheFreigabe -EntwurfPfad $e1 -Von 'anna' } 'nicht möglich' 'fachliche Freigabe vor Rohdaten-Abschluss abgelehnt'
    Wirft { Close-Rohdaten -EntwurfPfad $e1 -Von 'melanie' } 'noch nichts' 'leere Rohdaten können nicht abgeschlossen werden'

    # Rohdaten abschließen
    Schreibe (Join-Path $e1 '1_Rohdaten/Transkript-01.txt') 'Am 3. Arbeitstag OB52 aufrufen ...'
    Schreibe (Join-Path $e1 '1_Rohdaten/Bild-01.png') 'bild'
    Schreibe (Join-Path $e1 '2_KI-Ausgabe/Copilot-Antwort.md') '# Arbeitsanweisung'
    $prot = Close-Rohdaten -EntwurfPfad $e1 -Von 'melanie'
    Pruefe ($prot.status -eq $S.Rohdaten) 'Status Rohdaten abgeschlossen'
    Pruefe (@($prot.rohdaten.dateien).Count -eq 3) 'Prüfsummen für drei Dateien'
    Pruefe ((Get-Item (Join-Path $e1 '1_Rohdaten/Transkript-01.txt')).IsReadOnly) 'Rohdaten sind schreibgeschützt'
    Pruefe (@($prot.rohdaten.dateien | Where-Object { $_.pfad -eq '1_Rohdaten/Transkript-01.txt' }).Count -eq 1) 'Pfade relativ mit Schrägstrich'

    # Fachliche Freigabe braucht eine Arbeitsanweisung
    Wirft { Grant-FachlicheFreigabe -EntwurfPfad $e1 -Von 'anna' } 'keine Arbeitsanweisung' 'ohne Arbeitsanweisung keine Freigabe'
    Schreibe (Join-Path $e1 '3_Bearbeitet/Arbeitsanweisung.docx') 'Fassung 1'

    # Manipulierte Rohdaten blockieren die Freigabe
    Schreibe (Join-Path $e1 '1_Rohdaten/Transkript-01.txt') 'nachträglich geändert'
    Wirft { Grant-FachlicheFreigabe -EntwurfPfad $e1 -Von 'anna' } 'verändert' 'geänderte Rohdaten blockieren'
    $abw = Test-Entwurf -EntwurfPfad $e1
    Pruefe (@($abw | Where-Object { $_.bereich -eq 'Rohdaten' -and $_.art -eq 'geändert' }).Count -eq 1) 'Prüfung meldet geänderte Rohdaten'
    Schreibe (Join-Path $e1 '1_Rohdaten/Transkript-01.txt') 'Am 3. Arbeitstag OB52 aufrufen ...'
    $abw = Test-Entwurf -EntwurfPfad $e1
    Pruefe ($abw.Count -eq 0) 'nach Wiederherstellung keine Abweichung'

    # Fachliche Freigabe
    $prot = Grant-FachlicheFreigabe -EntwurfPfad $e1 -Von 'anna' -Kommentar 'stimmt so'
    Pruefe ($prot.status -eq $S.Fachlich) 'Status fachlich freigegeben'

    # Änderung nach fachlicher Freigabe blockiert die finale Freigabe
    Schreibe (Join-Path $e1 '3_Bearbeitet/Arbeitsanweisung.docx') 'Fassung 2'
    $t = Test-FinaleFreigabe -EntwurfPfad $e1 -Von 'melanie'
    Pruefe (@($t.fehler).Count -eq 1 -and $t.fehler[0] -match 'Seit der fachlichen Freigabe') 'Änderung nach fachlicher Freigabe erkannt'
    Wirft { Grant-FinaleFreigabe -EntwurfPfad $e1 -Von 'melanie' } 'Seit der fachlichen Freigabe' 'finale Freigabe blockiert'

    # Zurückweisen und erneut freigeben
    Wirft { Deny-Freigabe -EntwurfPfad $e1 -Von 'melanie' -Kommentar '  ' } 'begründen' 'Zurückweisen ohne Begründung abgelehnt'
    $prot = Deny-Freigabe -EntwurfPfad $e1 -Von 'melanie' -Kommentar 'Schritt 4 fehlt'
    Pruefe ($prot.status -eq $S.Ueberarbeitung) 'Status in Überarbeitung'
    $prot = Grant-FachlicheFreigabe -EntwurfPfad $e1 -Von 'anna' -Kommentar 'ergänzt'
    Pruefe (@($prot.freigaben).Count -eq 2) 'zweite fachliche Freigabe protokolliert'

    # Berechtigung und Vier-Augen-Prinzip
    Wirft { Grant-FinaleFreigabe -EntwurfPfad $e1 -Von 'anna' -Berechtigte @('melanie') -VierAugen $true } 'nicht für die finale' 'Nicht-Berechtigte wird abgelehnt'
    Wirft { Grant-FinaleFreigabe -EntwurfPfad $e1 -Von 'anna' -Berechtigte @() -VierAugen $true } 'zwei verschiedenen' 'gleiche Person bei Vier-Augen abgelehnt'

    # Finale Freigabe
    $erg = Grant-FinaleFreigabe -EntwurfPfad $e1 -Von 'melanie' -Berechtigte @('melanie') -Kommentar 'passt'
    Pruefe ($erg.version -eq '1.0') 'erste Version ist 1.0'
    Pruefe (@($erg.dateien).Count -eq 1 -and (Split-Path $erg.dateien[0] -Leaf) -eq 'P01 Monatsabschluss - Version 1.0.docx') 'Kopie in Freigegeben mit Versionsnamen'
    Pruefe ((Get-Item $erg.dateien[0]).IsReadOnly) 'freigegebene Datei schreibgeschützt'
    Pruefe ((Get-EntwurfProtokoll $e1).status -eq $S.Final) 'Status final freigegeben'
    Wirft { Grant-FinaleFreigabe -EntwurfPfad $e1 -Von 'melanie' } 'Status ist' 'zweite finale Freigabe desselben Entwurfs abgelehnt'

    # Pilotfall: dieselbe Person für beide Stufen, bewusst ohne Vier-Augen-Prinzip
    $e2 = New-Entwurf -ProzessPfad $p1.pfad -Von 'melanie'
    Pruefe ((Split-Path $e2 -Leaf) -match '^Entwurf-02 ') 'zweiter Entwurf heißt Entwurf-02'
    Schreibe (Join-Path $e2 '1_Rohdaten/Transkript-01.txt') 'neu'
    Schreibe (Join-Path $e2 '3_Bearbeitet/Arbeitsanweisung.docx') 'Fassung 3'
    [void](Close-Rohdaten -EntwurfPfad $e2 -Von 'melanie')
    [void](Grant-FachlicheFreigabe -EntwurfPfad $e2 -Von 'melanie')
    Pruefe ((Test-FinaleFreigabe -EntwurfPfad $e2 -Von 'melanie').gleichePerson) 'gleiche Person wird erkannt'
    Wirft { Grant-FinaleFreigabe -EntwurfPfad $e2 -Von 'melanie' -VierAugen $false } 'Begründung' 'ohne Begründung abgelehnt'
    $erg2 = Grant-FinaleFreigabe -EntwurfPfad $e2 -Von 'melanie' -VierAugen $false -BegruendungOhneVierAugen 'Pilot'
    Pruefe ($erg2.version -eq '2.0') 'zweite Version ist 2.0'
    $letzte = @($erg2.protokoll.freigaben) | Select-Object -Last 1
    Pruefe ($letzte.ohneVierAugen -and $letzte.kommentar -match 'Pilot') 'Ausnahme ist im Protokoll vermerkt'

    # Übersicht und Gesamtprotokoll
    $liste = @(Get-Entwurf -Wurzel $wurzel)
    Pruefe ($liste.Count -eq 2) 'Übersicht zeigt zwei Entwürfe'
    Pruefe (($liste | Where-Object { $_.entwurf -like 'Entwurf-01*' }).version -eq '1.0') 'Übersicht zeigt Version'
    $csv = [System.IO.File]::ReadAllLines((Join-Path $wurzel 'Freigabeprotokoll.csv'))
    Pruefe ($csv[0] -like 'Zeitpunkt;Prozess;*') 'Gesamtprotokoll hat Kopfzeile'
    Pruefe (@($csv | Where-Object { $_ -match 'Zurückgewiesen' -and $_ -match 'Schritt 4 fehlt' }).Count -eq 1) 'Zurückweisung im Gesamtprotokoll'
    Pruefe (@($csv).Count -eq 11) "Gesamtprotokoll hat 10 Einträge (ist: $(@($csv).Count - 1))"
}
finally {
    if (Test-Path $wurzel) {
        Get-ChildItem $wurzel -Recurse -File | ForEach-Object { $_.IsReadOnly = $false }
        Remove-Item $wurzel -Recurse -Force
    }
}

Write-Host "$script:geprueft Pruefungen, $script:fehler Fehler"
if ($script:fehler -gt 0) { exit 1 }
