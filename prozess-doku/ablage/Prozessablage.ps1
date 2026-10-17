<#
.SYNOPSIS
    Prozessablage: Prozesshandbuch mit Rohdaten, Bearbeitung und zweistufiger Freigabe.

.DESCRIPTION
    Zeigt alle Prozesse und Entwürfe mit Status. Pro Entwurf gibt es drei Ordner:
    1_Rohdaten (Transkript, Screenshots), 2_KI-Ausgabe (Antwort von Copilot), 3_Bearbeitet (Arbeitsanweisung).
    Ablauf: Rohdaten abschließen -> fachlich freigeben (Kollegin) -> final freigeben (Leitung).
    Jeder Schritt wird mit Person, Zeit und Prüfsummen protokolliert.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Ablage.psm1') -Force
Add-Type -AssemblyName System.Windows.Forms, System.Drawing, Microsoft.VisualBasic

$script:KonfigPfad = Join-Path $PSScriptRoot 'Prozessablage.config.json'
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)
$script:S = Get-AblageStatus
$script:Ich = Get-AktuellerBenutzer

# ---------------------------------------------------------------------------
# Einstellungen
# ---------------------------------------------------------------------------

# Beim ersten Start wird die Person, die das Werkzeug startet, für die finale Freigabe eingetragen.
function Get-Konfig {
    if (-not (Test-Path $script:KonfigPfad)) {
        $neu = [pscustomobject]@{
            Wurzel                = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Prozesshandbuch Buchhaltung')
            FinaleFreigabe        = @($script:Ich)
            AusnahmeOhneVierAugen = $true
        }
        [System.IO.File]::WriteAllText($script:KonfigPfad, ($neu | ConvertTo-Json), $script:Utf8)
    }
    $k = [System.IO.File]::ReadAllText($script:KonfigPfad, $script:Utf8) | ConvertFrom-Json
    $k.FinaleFreigabe = @($k.FinaleFreigabe)
    $k
}

# ---------------------------------------------------------------------------
# Hilfen für Dialoge
# ---------------------------------------------------------------------------

function Show-Info([string]$Text, [string]$Titel = 'Prozessablage') {
    [void][System.Windows.Forms.MessageBox]::Show($script:Fenster, $Text, $Titel, 'OK', 'Information')
}

function Show-Fehler([string]$Text) {
    [void][System.Windows.Forms.MessageBox]::Show($script:Fenster, $Text, 'Prozessablage', 'OK', 'Warning')
}

function Confirm-Frage([string]$Text, [string]$Titel = 'Prozessablage') {
    [System.Windows.Forms.MessageBox]::Show($script:Fenster, $Text, $Titel, 'YesNo', 'Question') -eq [System.Windows.Forms.DialogResult]::Yes
}

function Read-Eingabe([string]$Frage, [string]$Titel, [string]$Vorgabe = '') {
    [Microsoft.VisualBasic.Interaction]::InputBox($Frage, $Titel, $Vorgabe)
}

function Show-Text([string]$Titel, [string]$Text) {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = $Titel
    $f.Size = New-Object System.Drawing.Size 760, 520
    $f.StartPosition = 'CenterParent'
    $f.Font = $script:Fenster.Font
    $box = New-Object System.Windows.Forms.TextBox
    $box.Multiline = $true
    $box.ReadOnly = $true
    $box.ScrollBars = 'Both'
    $box.WordWrap = $false
    $box.Dock = 'Fill'
    $box.Font = New-Object System.Drawing.Font 'Consolas', 10
    $box.Text = $Text
    $f.Controls.Add($box)
    [void]$f.ShowDialog($script:Fenster)
    $f.Dispose()
}

function Open-Ordner([string]$Pfad) {
    if ($Pfad -and (Test-Path $Pfad)) { Start-Process explorer.exe -ArgumentList "`"$Pfad`"" }
}

# Word 2016 und neuer können PDF speichern. Fehlt Word, bleibt es bei der Word-Datei.
function ConvertTo-Pdf([string[]]$Dateien) {
    $word = @($Dateien | Where-Object { $_ -match '\.docx?$' })
    if ($word.Count -eq 0) { return @() }
    try { $app = New-Object -ComObject Word.Application } catch { return @() }
    $pdfs = @()
    try {
        $app.Visible = $false
        foreach ($d in $word) {
            $pdf = [System.IO.Path]::ChangeExtension($d, '.pdf')
            $doc = $app.Documents.Open($d, $false, $true)
            try { $doc.SaveAs2($pdf, 17) } finally { $doc.Close($false) }
            (Get-Item $pdf).IsReadOnly = $true
            $pdfs += $pdf
        }
    }
    finally {
        $app.Quit()
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($app)
    }
    $pdfs
}

# ---------------------------------------------------------------------------
# Liste
# ---------------------------------------------------------------------------

$script:Hinweise = @{
    'kein Entwurf'           = 'Noch kein Entwurf. "Neuer Entwurf" legt die Ordner an.'
    'Entwurf'                = 'Transkript und Screenshots in 1_Rohdaten, Antwort von Copilot in 2_KI-Ausgabe ablegen. Dann "Rohdaten abschließen".'
    'Rohdaten abgeschlossen' = 'Arbeitsanweisung in 3_Bearbeitet ablegen. Die Kollegin prüft sie und klickt "Fachlich freigeben".'
    'In Überarbeitung'       = 'Zurückgewiesen. Arbeitsanweisung in 3_Bearbeitet überarbeiten (Grund siehe "Verlauf"), dann erneut "Fachlich freigeben".'
    'Fachlich freigegeben'   = 'Wartet auf die finale Freigabe. "Final freigeben" oder mit Begründung "Zurückweisen".'
    'Final freigegeben'      = 'Freigegeben. Die Fassung liegt im Ordner "Freigegeben" des Prozesses. Für Änderungen einen neuen Entwurf anlegen.'
}

function Get-Auswahl {
    if ($script:Liste.SelectedItems.Count -eq 0) { return $null }
    $script:Liste.SelectedItems[0].Tag
}

function Update-Knoepfe {
    $a = Get-Auswahl
    $status = if ($a) { $a.status } else { '' }
    $script:K.NeuerEntwurf.Enabled = [bool]$a
    $script:K.Ordner.Enabled = [bool]$a
    $script:K.Rohdaten.Enabled = $status -eq $script:S.Entwurf
    $script:K.Fachlich.Enabled = @($script:S.Rohdaten, $script:S.Ueberarbeitung) -contains $status
    $script:K.Zurueck.Enabled = $status -eq $script:S.Fachlich
    $script:K.Final.Enabled = $status -eq $script:S.Fachlich
    $script:K.Pruefen.Enabled = $a -and $a.entwurfPfad
    $script:K.Verlauf.Enabled = $a -and $a.entwurfPfad
    if ($a -and $script:Hinweise.ContainsKey($status)) { $script:Hinweis.Text = $script:Hinweise[$status] }
    elseif ($a) { $script:Hinweis.Text = '' }
    else { $script:Hinweis.Text = 'Prozess auswählen oder mit "Neuer Prozess" anlegen.' }
}

function Update-Liste([string]$Auswahl = '') {
    $script:Liste.BeginUpdate()
    $script:Liste.Items.Clear()
    $entwuerfe = @(Get-Entwurf -Wurzel $script:Konfig.Wurzel)
    foreach ($p in @(Get-Prozess -Wurzel $script:Konfig.Wurzel)) {
        $eigene = @($entwuerfe | Where-Object { $_.pfad -like "$($p.pfad)*" })
        if ($eigene.Count -eq 0) {
            $item = New-Object System.Windows.Forms.ListViewItem "$($p.nr) $($p.name)"
            foreach ($t in '–', 'kein Entwurf', '', '', '', '') { [void]$item.SubItems.Add($t) }
            $item.Tag = [pscustomobject]@{ prozessPfad = $p.pfad; entwurfPfad = $null; status = 'kein Entwurf' }
            [void]$script:Liste.Items.Add($item)
            continue
        }
        foreach ($e in $eigene) {
            $item = New-Object System.Windows.Forms.ListViewItem $e.prozess
            foreach ($t in $e.entwurf, $e.status, [string]$e.version, $e.aktion, $e.von, ($e.am -replace 'T', ' ')) { [void]$item.SubItems.Add([string]$t) }
            $item.Tag = [pscustomobject]@{ prozessPfad = $p.pfad; entwurfPfad = $e.pfad; status = $e.status }
            if ($e.status -eq $script:S.Final) { $item.ForeColor = [System.Drawing.Color]::DarkGreen }
            elseif ($e.status -eq $script:S.Fachlich) { $item.ForeColor = [System.Drawing.Color]::DarkGoldenrod }
            elseif ($e.status -eq $script:S.Ueberarbeitung) { $item.ForeColor = [System.Drawing.Color]::Firebrick }
            if ($Auswahl -and $e.pfad -eq $Auswahl) { $item.Selected = $true }
            [void]$script:Liste.Items.Add($item)
        }
    }
    $script:Liste.EndUpdate()
    Update-Knoepfe
}

# Führt eine Aktion aus, zeigt Fehler verständlich an und aktualisiert die Liste.
function Invoke-Aktion([scriptblock]$Aktion) {
    $a = Get-Auswahl
    try {
        $ziel = & $Aktion $a
        if ($ziel -is [string]) { Update-Liste $ziel }
        elseif ($a) { Update-Liste $a.entwurfPfad }
        else { Update-Liste }
    }
    catch { Show-Fehler $_.Exception.Message; Update-Liste $(if ($a) { $a.entwurfPfad } else { '' }) }
}

# ---------------------------------------------------------------------------
# Aktionen
# ---------------------------------------------------------------------------

$script:Aktionen = @{
    NeuerProzess = {
        $name = Read-Eingabe 'Name des Prozesses, z. B. "Monatsabschluss":' 'Neuer Prozess'
        if (-not $name.Trim()) { return }
        $p = New-Prozess -Wurzel $script:Konfig.Wurzel -Name $name
        $e = New-Entwurf -ProzessPfad $p.pfad
        if (Confirm-Frage "Prozess $($p.nr) $($p.name) mit Entwurf-01 angelegt.`n`nOrdner jetzt öffnen, um Transkript und Screenshots abzulegen?") { Open-Ordner (Join-Path $e '1_Rohdaten') }
        $e
    }
    NeuerEntwurf = {
        param($a)
        $offen = @(Get-Entwurf -Wurzel $script:Konfig.Wurzel | Where-Object { $_.pfad -like "$($a.prozessPfad)*" -and $_.status -ne $script:S.Final })
        if ($offen.Count -gt 0 -and -not (Confirm-Frage "Für diesen Prozess ist noch $($offen[0].entwurf) offen ($($offen[0].status)).`n`nTrotzdem einen weiteren Entwurf anlegen?")) { return }
        $e = New-Entwurf -ProzessPfad $a.prozessPfad
        if (Confirm-Frage "$(Split-Path $e -Leaf) angelegt.`n`nOrdner jetzt öffnen?") { Open-Ordner (Join-Path $e '1_Rohdaten') }
        $e
    }
    Ordner = {
        param($a)
        if ($a.entwurfPfad) { Open-Ordner $a.entwurfPfad } else { Open-Ordner $a.prozessPfad }
    }
    Rohdaten = {
        param($a)
        $roh = @(Get-ChildItem -LiteralPath (Join-Path $a.entwurfPfad '1_Rohdaten') -File -Recurse)
        $ki = @(Get-ChildItem -LiteralPath (Join-Path $a.entwurfPfad '2_KI-Ausgabe') -File -Recurse)
        $text = "Rohdaten abschließen?`n`n1_Rohdaten: $($roh.Count) Dateien`n2_KI-Ausgabe: $($ki.Count) Dateien`n`nDanach sind diese Dateien schreibgeschützt und mit Prüfsummen festgehalten. Fehlt noch etwas, später einen neuen Entwurf anlegen."
        if ($ki.Count -eq 0) { $text += "`n`nHinweis: 2_KI-Ausgabe ist leer. Die Antwort von Copilot gehört zur Nachvollziehbarkeit dazu." }
        if (-not (Confirm-Frage $text)) { return }
        [void](Close-Rohdaten -EntwurfPfad $a.entwurfPfad)
    }
    Fachlich = {
        param($a)
        $dateien = @(Get-ChildItem -LiteralPath (Join-Path $a.entwurfPfad '3_Bearbeitet') -File | ForEach-Object { $_.Name })
        if ($dateien.Count -eq 0) { throw 'In 3_Bearbeitet liegt noch keine Arbeitsanweisung.' }
        if (-not (Confirm-Frage "Fachlich freigeben als $script:Ich?`n`n$($dateien -join "`n")`n`nDu bestätigst: Der Ablauf ist so richtig beschrieben.")) { return }
        $kommentar = Read-Eingabe 'Kommentar (optional):' 'Fachlich freigeben'
        [void](Grant-FachlicheFreigabe -EntwurfPfad $a.entwurfPfad -Kommentar $kommentar)
    }
    Zurueck = {
        param($a)
        $grund = Read-Eingabe 'Was soll überarbeitet werden?' 'Zurückweisen'
        if (-not $grund.Trim()) { return }
        [void](Deny-Freigabe -EntwurfPfad $a.entwurfPfad -Kommentar $grund)
    }
    Final = {
        param($a)
        $pruefung = Test-FinaleFreigabe -EntwurfPfad $a.entwurfPfad -Berechtigte $script:Konfig.FinaleFreigabe
        if (@($pruefung.fehler).Count -gt 0) { throw (@($pruefung.fehler) -join "`n`n") }
        $vierAugen = $true
        $begruendung = ''
        if ($pruefung.gleichePerson) {
            if (-not $script:Konfig.AusnahmeOhneVierAugen) { throw 'Du hast diesen Entwurf auch fachlich freigegeben. Die finale Freigabe muss eine zweite Person geben.' }
            if (-not (Confirm-Frage "Du hast diesen Entwurf auch fachlich freigegeben.`n`nOhne zweite Person final freigeben? Das wird im Protokoll vermerkt." 'Vier-Augen-Prinzip')) { return }
            $begruendung = Read-Eingabe 'Begründung:' 'Ohne Vier-Augen-Prinzip' 'Pilot: Erstellerin und Freigebende identisch'
            if (-not $begruendung.Trim()) { return }
            $vierAugen = $false
        }
        elseif (-not (Confirm-Frage "Final freigeben als $script:Ich?`n`nFachlich freigegeben von: $($pruefung.fachlichVon)`n`nDie Arbeitsanweisung wird als neue Version in den Ordner ""Freigegeben"" kopiert und schreibgeschützt.")) { return }
        $kommentar = Read-Eingabe 'Kommentar (optional):' 'Final freigeben'
        $erg = Grant-FinaleFreigabe -EntwurfPfad $a.entwurfPfad -Kommentar $kommentar -Berechtigte $script:Konfig.FinaleFreigabe -VierAugen $vierAugen -BegruendungOhneVierAugen $begruendung
        $pdfHinweis = ''
        try {
            $pdfs = @(ConvertTo-Pdf $erg.dateien)
            if ($pdfs.Count -gt 0) { $pdfHinweis = "`nZusätzlich als PDF gespeichert." }
        }
        catch { $pdfHinweis = "`nPDF konnte nicht erzeugt werden ($($_.Exception.Message)). Die Word-Datei ist freigegeben." }
        Show-Info "Version $($erg.version) freigegeben.$pdfHinweis"
        Open-Ordner (Split-Path $erg.dateien[0] -Parent)
    }
    Pruefen = {
        param($a)
        $abw = Test-Entwurf -EntwurfPfad $a.entwurfPfad
        if ($abw.Count -eq 0) { Show-Info 'Alles unverändert: Rohdaten und freigegebene Dateien entsprechen den Prüfsummen im Protokoll.' 'Prüfen' }
        else { Show-Fehler ("Abweichungen gefunden:`n`n" + (($abw | ForEach-Object { "$($_.bereich): $($_.pfad) ($($_.art))" }) -join "`n")) }
    }
    Verlauf = {
        param($a)
        $p = Get-EntwurfProtokoll $a.entwurfPfad
        $zeilen = @("$($p.prozess) / $($p.entwurf)", "Status: $($p.status)$(if ($p.version) { ", Version $($p.version)" })", '')
        foreach ($v in @($p.verlauf)) {
            $zeile = '{0}  {1,-34} {2}' -f ($v.am -replace 'T', ' '), $v.aktion, $v.von
            if ($v.kommentar) { $zeile += "  – $($v.kommentar)" }
            $zeilen += $zeile
        }
        if ($p.rohdaten) {
            $zeilen += '', 'Prüfsummen Rohdaten (SHA-256):'
            foreach ($d in @($p.rohdaten.dateien)) { $zeilen += "  $($d.sha256.Substring(0, 16))…  $($d.pfad)" }
        }
        Show-Text 'Verlauf' ($zeilen -join "`r`n")
    }
}

# ---------------------------------------------------------------------------
# Fenster
# ---------------------------------------------------------------------------

function Start-Fenster {
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $script:Konfig = Get-Konfig
    [void](Initialize-Ablage $script:Konfig.Wurzel)

    $f = New-Object System.Windows.Forms.Form
    $script:Fenster = $f
    $f.Text = 'Prozessablage – Prozesshandbuch Buchhaltung'
    $f.Size = New-Object System.Drawing.Size 1180, 640
    $f.MinimumSize = New-Object System.Drawing.Size 760, 420
    $f.StartPosition = 'CenterScreen'
    $f.Font = New-Object System.Drawing.Font 'Segoe UI', 10

    $kopf = New-Object System.Windows.Forms.Panel
    $kopf.Dock = 'Top'
    $kopf.Height = 40
    $ablage = New-Object System.Windows.Forms.LinkLabel
    $ablage.AutoSize = $true
    $ablage.Location = New-Object System.Drawing.Point 12, 11
    $ablage.Text = "Ablage: $($script:Konfig.Wurzel)    Angemeldet: $script:Ich"
    $ablage.LinkArea = New-Object System.Windows.Forms.LinkArea 8, $script:Konfig.Wurzel.Length
    $ablage.add_LinkClicked({ Open-Ordner $script:Konfig.Wurzel })
    $kopf.Controls.Add($ablage)

    $script:Liste = New-Object System.Windows.Forms.ListView
    $script:Liste.Dock = 'Fill'
    $script:Liste.View = 'Details'
    $script:Liste.FullRowSelect = $true
    $script:Liste.MultiSelect = $false
    $script:Liste.HideSelection = $false
    foreach ($spalte in @(@('Prozess', 230), @('Entwurf', 170), @('Status', 180), @('Version', 70), @('Letzte Aktion', 230), @('Von', 140), @('Am', 140))) {
        [void]$script:Liste.Columns.Add($spalte[0], $spalte[1])
    }
    $script:Liste.add_SelectedIndexChanged({ Update-Knoepfe })
    $script:Liste.add_DoubleClick({ Invoke-Aktion $script:Aktionen.Ordner })

    $script:Hinweis = New-Object System.Windows.Forms.Label
    $script:Hinweis.Dock = 'Bottom'
    $script:Hinweis.Height = 34
    $script:Hinweis.Padding = New-Object System.Windows.Forms.Padding 12, 8, 12, 0
    $script:Hinweis.ForeColor = [System.Drawing.Color]::DimGray

    $leiste = New-Object System.Windows.Forms.FlowLayoutPanel
    $leiste.Dock = 'Bottom'
    $leiste.AutoSize = $true
    $leiste.Padding = New-Object System.Windows.Forms.Padding 8, 6, 8, 8

    $script:K = @{}
    $knopfListe = @(
        @('NeuerProzess', 'Neuer Prozess …'), @('NeuerEntwurf', 'Neuer Entwurf'), @('Ordner', 'Ordner öffnen'),
        @('Rohdaten', '1  Rohdaten abschließen'), @('Fachlich', '2  Fachlich freigeben'), @('Final', '3  Final freigeben'),
        @('Zurueck', 'Zurückweisen …'), @('Pruefen', 'Prüfen'), @('Verlauf', 'Verlauf')
    )
    foreach ($eintrag in $knopfListe) {
        $knopf = New-Object System.Windows.Forms.Button
        $knopf.Text = $eintrag[1]
        $knopf.AutoSize = $true
        $knopf.Padding = New-Object System.Windows.Forms.Padding 6, 2, 6, 2
        $knopf.Tag = $eintrag[0]
        $knopf.add_Click({ param($quelle) Invoke-Aktion $script:Aktionen[$quelle.Tag] })
        $script:K[$eintrag[0]] = $knopf
        [void]$leiste.Controls.Add($knopf)
    }

    $f.Controls.Add($script:Liste)
    $f.Controls.Add($script:Hinweis)
    $f.Controls.Add($leiste)
    $f.Controls.Add($kopf)
    # Beim Zurückkehren ins Fenster neu einlesen, z. B. nachdem Dateien im Explorer abgelegt wurden.
    $f.add_Activated({ $a = Get-Auswahl; Update-Liste $(if ($a) { $a.entwurfPfad } else { '' }) })

    Update-Liste
    [void]$f.ShowDialog()
}

try { Start-Fenster }
catch { [void][System.Windows.Forms.MessageBox]::Show("Die Prozessablage konnte nicht starten:`n`n$($_.Exception.Message)", 'Prozessablage', 'OK', 'Error') }
