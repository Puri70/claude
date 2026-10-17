<#
.SYNOPSIS
    SAP-Schwärzer: schwärzt Kundendaten in Screenshots, bevor sie eingefügt werden.

.DESCRIPTION
    Läuft unten rechts als Schild-Symbol. Sobald ein Screenshot (Win+Shift+S) in der
    Zwischenablage liegt, wird er sofort aus der Zwischenablage genommen, lokal mit der
    Windows-Texterkennung gelesen und geschwärzt. Lesbar bleibt nur, was in Feldnamen.txt steht.
    Ein Fenster zeigt die Vorschau: Häkchen "Kundendaten schwärzen" an oder aus, einzelne
    Balken per Klick ein- oder ausblenden. Nach "Übernehmen" liegt das Bild in der
    Zwischenablage und kann mit Strg+V eingefügt werden.

    Originale und erkannte Texte werden nie gespeichert. Übernommene Bilder werden auf Wunsch
    nummeriert unter Dokumente\SAP-Schwaerzer\<Datum> abgelegt. Nichts verlässt den Rechner.

.PARAMETER Pruefen
    Prüft nur, ob alle Voraussetzungen erfüllt sind, und zeigt das Ergebnis an.

.PARAMETER Datei
    Schwärzt Bilddateien und speichert das Ergebnis als <Name>_geschwaerzt.png daneben.
    Gedacht für den Testsatz.
#>
[CmdletBinding()]
param(
    [switch]$Pruefen,
    [string[]]$Datei
)

$ErrorActionPreference = 'Stop'
$script:Version = '0.1'
$script:FeldlistePfad = Join-Path $PSScriptRoot 'Feldnamen.txt'
$script:KernPfad = Join-Path $PSScriptRoot 'Schwaerzer.cs'
$script:AnleitungPfad = Join-Path $PSScriptRoot 'LIESMICH.md'
$script:Markierung = 'SAP-Schwaerzer.geschwaerzt'
$script:AblageWurzel = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'SAP-Schwaerzer'
$script:Beschaeftigt = $false

# ---------------------------------------------------------------------------
# Laden
# ---------------------------------------------------------------------------

function Initialize-Kern {
    if (-not ('SapSchwaerzer.Kern' -as [type])) {
        $quelle = [System.IO.File]::ReadAllText($script:KernPfad, [System.Text.Encoding]::UTF8)
        Add-Type -TypeDefinition $quelle -Language CSharp
    }
}

function Initialize-Feldliste {
    $zeilen = [System.IO.File]::ReadAllLines($script:FeldlistePfad, [System.Text.Encoding]::UTF8)
    $script:Feldliste = [SapSchwaerzer.Feldliste]::AusZeilen([string[]]$zeilen)
}

function Initialize-Texterkennung {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime]
    $null = [Windows.Media.Ocr.OcrResult, Windows.Foundation, ContentType = WindowsRuntime]
    $null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Foundation, ContentType = WindowsRuntime]
    $null = [Windows.Graphics.Imaging.SoftwareBitmap, Windows.Foundation, ContentType = WindowsRuntime]
    $null = [Windows.Globalization.Language, Windows.Foundation, ContentType = WindowsRuntime]

    $script:AlsTask = [System.WindowsRuntimeSystemExtensions].GetMethods() |
        Where-Object {
            $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
            $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
        } |
        Select-Object -First 1

    $deutsch = New-Object Windows.Globalization.Language 'de-DE'
    if ([Windows.Media.Ocr.OcrEngine]::IsLanguageSupported($deutsch)) {
        $script:Texterkennung = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($deutsch)
    }
    if (-not $script:Texterkennung) {
        throw 'Die Windows-Texterkennung für Deutsch ist nicht installiert.'
    }
}

function Wait-WinRt($Vorgang, [Type]$Typ) {
    $task = $script:AlsTask.MakeGenericMethod($Typ).Invoke($null, @($Vorgang))
    [void]$task.Wait(-1)
    $task.Result
}

# ---------------------------------------------------------------------------
# Voraussetzungen
# ---------------------------------------------------------------------------

function Test-Voraussetzungen {
    $ergebnis = New-Object System.Collections.Generic.List[object]
    $neu = { param($pruefung, $ok, $hinweis) $ergebnis.Add([pscustomobject]@{ Pruefung = $pruefung; OK = $ok; Hinweis = $hinweis }) }

    $desktop = $PSVersionTable.PSEdition -eq 'Desktop' -or -not $PSVersionTable.PSEdition
    & $neu 'Windows PowerShell 5.1' $desktop $(if ($desktop) { "Version $($PSVersionTable.PSVersion)" } else { 'Bitte mit "Windows PowerShell" starten, nicht mit PowerShell 7.' })

    $voll = $ExecutionContext.SessionState.LanguageMode -eq 'FullLanguage'
    & $neu 'Voller Sprachmodus' $voll $(if ($voll) { 'FullLanguage' } else { "Eingeschränkt ($($ExecutionContext.SessionState.LanguageMode)). Das legt die IT fest, bitte dort fragen." })

    $richtlinien = Get-ExecutionPolicy -List | Where-Object { $_.ExecutionPolicy -ne 'Undefined' } |
        ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }
    & $neu 'Skriptausführung' $true $(if ($richtlinien) { $richtlinien -join ', ' } else { 'keine Richtlinie gesetzt' })

    try { Initialize-Kern; & $neu 'Kernlogik' $true 'geladen' }
    catch { & $neu 'Kernlogik' $false "Schwaerzer.cs konnte nicht geladen werden: $($_.Exception.Message)" }

    if (Test-Path $script:FeldlistePfad) {
        try { Initialize-Feldliste; & $neu 'Feldnamen.txt' $true "$($script:Feldliste.Anzahl) Einträge" }
        catch { & $neu 'Feldnamen.txt' $false $_.Exception.Message }
    }
    else { & $neu 'Feldnamen.txt' $false "Datei fehlt: $script:FeldlistePfad" }

    if ($desktop -and $voll) {
        try { Initialize-Texterkennung; & $neu 'Texterkennung Deutsch' $true 'verfügbar' }
        catch {
            $sprachen = ''
            try { $sprachen = ([Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages | ForEach-Object { $_.LanguageTag }) -join ', ' } catch { }
            & $neu 'Texterkennung Deutsch' $false "$($_.Exception.Message) Verfügbar: $sprachen. Abhilfe: Einstellungen > Zeit und Sprache > Sprache > Deutsch > Optionen > Optische Zeichenerkennung."
        }
    }
    else { & $neu 'Texterkennung Deutsch' $false 'nicht geprüft (siehe oben)' }

    try { Add-Type -AssemblyName System.Windows.Forms, System.Drawing; & $neu 'Zwischenablage und Symbol' $true 'verfügbar' }
    catch { & $neu 'Zwischenablage und Symbol' $false $_.Exception.Message }

    , $ergebnis
}

# ---------------------------------------------------------------------------
# Bildverarbeitung
# ---------------------------------------------------------------------------

# Kopiert ein beliebiges Bild in ein deckendes 32-Bit-Bild in Originalgröße.
function ConvertTo-Arbeitsbild([System.Drawing.Image]$Bild) {
    $neu = New-Object System.Drawing.Bitmap $Bild.Width, $Bild.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($neu)
    try {
        $g.Clear([System.Drawing.Color]::White)
        $g.DrawImage($Bild, 0, 0, $Bild.Width, $Bild.Height)
    }
    finally { $g.Dispose() }
    $neu
}

function Get-Pixel([System.Drawing.Bitmap]$Bild) {
    $flaeche = New-Object System.Drawing.Rectangle 0, 0, $Bild.Width, $Bild.Height
    $daten = $Bild.LockBits($flaeche, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $pixel = New-Object int[] ($Bild.Width * $Bild.Height)
        [System.Runtime.InteropServices.Marshal]::Copy($daten.Scan0, $pixel, 0, $pixel.Length)
    }
    finally { $Bild.UnlockBits($daten) }
    , $pixel
}

function New-BildAusPixeln([int[]]$Pixel, [int]$Breite, [int]$Hoehe) {
    $bild = New-Object System.Drawing.Bitmap $Breite, $Hoehe, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $flaeche = New-Object System.Drawing.Rectangle 0, 0, $Breite, $Hoehe
    $daten = $bild.LockBits($flaeche, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try { [System.Runtime.InteropServices.Marshal]::Copy($Pixel, 0, $daten.Scan0, $Pixel.Length) }
    finally { $bild.UnlockBits($daten) }
    $bild
}

# Liest die Wörter mit der Windows-Texterkennung. Kleine Bilder werden vorher vergrößert,
# weil SAP-Schrift sonst oft zu klein für die Erkennung ist.
function Get-Woerter([System.Drawing.Bitmap]$Bild) {
    $faktor = 1
    if ([Math]::Max($Bild.Width, $Bild.Height) * 2 -le [Windows.Media.Ocr.OcrEngine]::MaxImageDimension) { $faktor = 2 }

    $vorlage = $Bild
    if ($faktor -gt 1) {
        $vorlage = New-Object System.Drawing.Bitmap ($Bild.Width * $faktor), ($Bild.Height * $faktor), ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($vorlage)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.DrawImage($Bild, 0, 0, $vorlage.Width, $vorlage.Height)
        }
        finally { $g.Dispose() }
    }

    $speicher = New-Object System.IO.MemoryStream
    try {
        $vorlage.Save($speicher, [System.Drawing.Imaging.ImageFormat]::Png)
        $speicher.Position = 0
        $strom = [System.IO.WindowsRuntimeStreamExtensions]::AsRandomAccessStream($speicher)
        $decoder = Wait-WinRt ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($strom)) ([Windows.Graphics.Imaging.BitmapDecoder])
        $softwareBild = Wait-WinRt ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
        $erkannt = Wait-WinRt ($script:Texterkennung.RecognizeAsync($softwareBild)) ([Windows.Media.Ocr.OcrResult])
    }
    finally {
        $speicher.Dispose()
        if ($faktor -gt 1) { $vorlage.Dispose() }
    }

    $woerter = New-Object 'System.Collections.Generic.List[SapSchwaerzer.Wort]'
    $zeileNr = 0
    foreach ($zeile in $erkannt.Lines) {
        foreach ($wort in $zeile.Words) {
            $r = $wort.BoundingRect
            $x = [int][Math]::Floor($r.X / $faktor)
            $y = [int][Math]::Floor($r.Y / $faktor)
            $b = [int][Math]::Ceiling(($r.X + $r.Width) / $faktor) - $x
            $h = [int][Math]::Ceiling(($r.Y + $r.Height) / $faktor) - $y
            $woerter.Add([SapSchwaerzer.Wort]::new($wort.Text, $zeileNr, $x, $y, $b, $h))
        }
        $zeileNr++
    }
    , $woerter
}

# Liest das Bild und bestimmt alle schwärzbaren Bereiche. Zunächst sind alle geschwärzt.
function Get-Vorgang([System.Drawing.Image]$Original) {
    $arbeitsbild = ConvertTo-Arbeitsbild $Original
    try {
        $woerter = Get-Woerter $arbeitsbild
        $pixel = Get-Pixel $arbeitsbild
        $analyse = [SapSchwaerzer.Kern]::Analysiere($pixel, $arbeitsbild.Width, $arbeitsbild.Height, $woerter, $script:Feldliste, $null)
        [pscustomobject]@{ Pixel = $pixel; Analyse = $analyse }
    }
    finally { $arbeitsbild.Dispose() }
}

function New-Ausgabebild($Vorgang, [bool]$Schwaerzen) {
    $pixel = $Vorgang.Pixel
    if ($Schwaerzen) { $pixel = [SapSchwaerzer.Kern]::Zeichne($Vorgang.Pixel, $Vorgang.Analyse) }
    New-BildAusPixeln $pixel $Vorgang.Analyse.Breite $Vorgang.Analyse.Hoehe
}

function Format-Ergebnis($Vorgang) {
    $z = [SapSchwaerzer.Kern]::Zaehle($Vorgang.Analyse)
    "$($z.GeschwaerzteWoerter) Wörter und $($z.BloeckeOhneTexterkennung) weitere Bereiche geschwärzt, $($z.LesbareWoerter) Feldnamen lesbar."
}

# Zeigt die Vorschau. Häkchen = schwärzen; Klick auf einen Balken blendet ihn ein oder aus.
# Gibt das gewählte Bild zurück oder $null, wenn verworfen wurde.
function Show-Auswahl($Vorgang) {
    $breite = $Vorgang.Analyse.Breite
    $hoehe = $Vorgang.Analyse.Hoehe
    $flaeche = [System.Windows.Forms.Screen]::FromPoint([System.Windows.Forms.Cursor]::Position).WorkingArea
    $skala = [Math]::Min(1.0, [Math]::Min(($flaeche.Width * 0.8) / $breite, ($flaeche.Height * 0.7) / $hoehe))
    $bildBreite = [Math]::Max(480, [int]($breite * $skala))
    $bildHoehe = [Math]::Max(120, [int]($hoehe * $skala))

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'SAP-Schwärzer – Screenshot prüfen'
    $form.TopMost = $true
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.MinimizeBox = $false
    $form.ShowIcon = $false
    $form.Font = New-Object System.Drawing.Font 'Segoe UI', 10
    $form.ClientSize = New-Object System.Drawing.Size $bildBreite, ($bildHoehe + 84)

    $bildfeld = New-Object System.Windows.Forms.PictureBox
    $bildfeld.Dock = [System.Windows.Forms.DockStyle]::Fill
    $bildfeld.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $bildfeld.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
    $bildfeld.Cursor = [System.Windows.Forms.Cursors]::Hand

    $leiste = New-Object System.Windows.Forms.Panel
    $leiste.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $leiste.Height = 84
    $leiste.Padding = New-Object System.Windows.Forms.Padding 10, 6, 10, 6

    $haken = New-Object System.Windows.Forms.CheckBox
    $haken.Text = 'Kundendaten schwärzen'
    $haken.Checked = $true
    $haken.AutoSize = $true
    $haken.Location = New-Object System.Drawing.Point 10, 8

    $status = New-Object System.Windows.Forms.Label
    $status.AutoSize = $true
    $status.ForeColor = [System.Drawing.Color]::DimGray
    $status.Location = New-Object System.Drawing.Point 10, 36

    $hinweis = New-Object System.Windows.Forms.Label
    $hinweis.AutoSize = $true
    $hinweis.ForeColor = [System.Drawing.Color]::DimGray
    $hinweis.Text = 'Klick auf einen schwarzen Balken blendet ihn ein oder aus, z. B. Werte, die eingegeben werden müssen.'
    $hinweis.Location = New-Object System.Drawing.Point 10, 58

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = 'Übernehmen (Enter)'
    $ok.AutoSize = $true
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $ok.Anchor = [System.Windows.Forms.AnchorStyles]'Top, Right'

    $nein = New-Object System.Windows.Forms.Button
    $nein.Text = 'Verwerfen (Esc)'
    $nein.AutoSize = $true
    $nein.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $nein.Anchor = [System.Windows.Forms.AnchorStyles]'Top, Right'

    $leiste.Controls.AddRange(@($haken, $status, $hinweis, $ok, $nein))
    $form.Controls.Add($bildfeld)
    $form.Controls.Add($leiste)
    $form.AcceptButton = $ok
    $form.CancelButton = $nein

    $platziereKnoepfe = {
        $ok.Location = New-Object System.Drawing.Point ($leiste.ClientSize.Width - $ok.Width - 10), 6
        $nein.Location = New-Object System.Drawing.Point ($ok.Left - $nein.Width - 8), 6
    }
    $aktualisiere = {
        $alt = $bildfeld.Image
        $bildfeld.Image = New-Ausgabebild $Vorgang $haken.Checked
        if ($alt) { $alt.Dispose() }
        if ($haken.Checked) { $status.Text = Format-Ergebnis $Vorgang }
        else { $status.Text = 'Ohne Schwärzung: das Original wird übernommen.' }
    }

    $haken.add_CheckedChanged($aktualisiere)
    $leiste.add_Resize($platziereKnoepfe)
    $bildfeld.add_MouseClick({
        param($quelle, $ereignis)
        if (-not $haken.Checked) { return }
        $faktor = [Math]::Min($bildfeld.ClientSize.Width / $breite, $bildfeld.ClientSize.Height / $hoehe)
        $randX = ($bildfeld.ClientSize.Width - $breite * $faktor) / 2
        $randY = ($bildfeld.ClientSize.Height - $hoehe * $faktor) / 2
        $x = [int][Math]::Floor(($ereignis.X - $randX) / $faktor)
        $y = [int][Math]::Floor(($ereignis.Y - $randY) / $faktor)
        $index = [SapSchwaerzer.Kern]::FindeBereich($Vorgang.Analyse, $x, $y)
        if ($index -lt 0) { return }
        $bereich = $Vorgang.Analyse.Bereiche[$index]
        $bereich.Geschwaerzt = -not $bereich.Geschwaerzt
        & $aktualisiere
    })

    $form.add_Shown({ $form.Activate() })
    & $aktualisiere
    & $platziereKnoepfe
    try {
        $antwort = $form.ShowDialog()
        if ($antwort -ne [System.Windows.Forms.DialogResult]::OK) { return $null }
        $auswahl = $bildfeld.Image
        $bildfeld.Image = $null
        return $auswahl
    }
    finally {
        if ($bildfeld.Image) { $bildfeld.Image.Dispose() }
        $form.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Zwischenablage
# ---------------------------------------------------------------------------

# Nur reine Bilder: Excel, Word und Browser legen beim Kopieren von Text oder Zellen
# zusätzlich ein Bild ab. Diese Kopien bleiben unangetastet.
function Test-NeuerScreenshot {
    try {
        $daten = [System.Windows.Forms.Clipboard]::GetDataObject()
        if (-not $daten) { return $false }
        if ($daten.GetDataPresent($script:Markierung)) { return $false }
        $istBild = $daten.GetDataPresent([System.Windows.Forms.DataFormats]::Bitmap) -or $daten.GetDataPresent('PNG')
        if (-not $istBild) { return $false }
        $hatText = $daten.GetDataPresent([System.Windows.Forms.DataFormats]::UnicodeText) -or
                   $daten.GetDataPresent([System.Windows.Forms.DataFormats]::Html) -or
                   $daten.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)
        return -not $hatText
    }
    catch { return $false }
}

function Get-BildAusZwischenablage {
    $daten = [System.Windows.Forms.Clipboard]::GetDataObject()
    if ($daten.GetDataPresent('PNG')) {
        $strom = $daten.GetData('PNG')
        if ($strom -is [System.IO.Stream]) {
            $bild = [System.Drawing.Image]::FromStream($strom)
            try { return ConvertTo-Arbeitsbild $bild }
            finally { $bild.Dispose(); $strom.Dispose() }
        }
    }
    $bild = [System.Windows.Forms.Clipboard]::GetImage()
    if (-not $bild) { throw 'Kein Bild in der Zwischenablage.' }
    try { ConvertTo-Arbeitsbild $bild }
    finally { $bild.Dispose() }
}

function Set-BildInZwischenablage([System.Drawing.Bitmap]$Bild) {
    $daten = New-Object System.Windows.Forms.DataObject
    $daten.SetImage($Bild)
    $png = New-Object System.IO.MemoryStream
    $Bild.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)
    $daten.SetData('PNG', $false, $png)
    $daten.SetData($script:Markierung, $false, $script:Version)
    [System.Windows.Forms.Clipboard]::SetDataObject($daten, $true, 10, 100)
}

# Legt das übernommene Bild nummeriert im Tagesordner ab, damit es später in Word
# eingefügt werden kann. Gespeichert wird nur die Fassung, die übernommen wurde.
function Save-Ablage([System.Drawing.Bitmap]$Bild) {
    $ordner = Join-Path $script:AblageWurzel (Get-Date -Format 'yyyy-MM-dd')
    if (-not (Test-Path $ordner)) { [void](New-Item -ItemType Directory -Path $ordner) }
    $nummer = 1
    while (Test-Path (Join-Path $ordner ('Bild-{0:00}.png' -f $nummer))) { $nummer++ }
    $name = 'Bild-{0:00}' -f $nummer
    $Bild.Save((Join-Path $ordner "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $name
}

function Clear-Zwischenablage {
    for ($versuch = 0; $versuch -lt 10; $versuch++) {
        try { [System.Windows.Forms.Clipboard]::Clear(); return $true }
        catch { Start-Sleep -Milliseconds 50 }
    }
    $false
}

function Show-Meldung([string]$Text, [System.Windows.Forms.ToolTipIcon]$Art = [System.Windows.Forms.ToolTipIcon]::Info) {
    $script:Symbol.ShowBalloonTip(4000, 'SAP-Schwärzer', $Text, $Art)
}

function Set-Status([string]$Text) {
    $voll = "SAP-Schwärzer – $Text"
    if ($voll.Length -gt 63) { $voll = $voll.Substring(0, 63) }
    $script:Symbol.Text = $voll
}

# Wird alle 250 ms aufgerufen. Ein neuer Screenshot wird sofort aus der Zwischenablage
# entfernt, damit das Original nicht versehentlich eingefügt werden kann. Erst nach
# "Übernehmen" liegt das gewählte Bild wieder in der Zwischenablage.
function Invoke-Pruefschleife {
    if ($script:Beschaeftigt -or -not $script:AktivEintrag.Checked) { return }
    if (-not (Test-NeuerScreenshot)) { return }

    $script:Beschaeftigt = $true
    $original = $null
    $auswahl = $null
    try {
        $original = Get-BildAusZwischenablage
        if (-not (Clear-Zwischenablage)) { throw 'Die Zwischenablage ist blockiert.' }
        Set-Status 'liest den Screenshot …'
        $vorgang = Get-Vorgang $original
        Set-Status 'aktiv'
        $auswahl = Show-Auswahl $vorgang
        if ($auswahl) {
            Set-BildInZwischenablage $auswahl
            if ($script:AblageEintrag.Checked) {
                $name = Save-Ablage $auswahl
                Show-Meldung "Bereit. Jetzt mit Strg+V einfügen.`nGespeichert als $name."
            }
            else { Show-Meldung 'Bereit. Jetzt mit Strg+V einfügen.' }
        }
    }
    catch {
        [void](Clear-Zwischenablage)
        Set-Status 'aktiv'
        Show-Meldung "Fehler, die Zwischenablage wurde geleert. Bitte den Screenshot erneut machen.`n$($_.Exception.Message)" ([System.Windows.Forms.ToolTipIcon]::Error)
    }
    finally {
        if ($original) { $original.Dispose() }
        if ($auswahl) { $auswahl.Dispose() }
        $script:Beschaeftigt = $false
    }
}

# ---------------------------------------------------------------------------
# Betriebsarten
# ---------------------------------------------------------------------------

function Invoke-Dateien([string[]]$Pfade) {
    foreach ($pfad in $Pfade) {
        $voll = (Resolve-Path $pfad).Path
        $ziel = Join-Path (Split-Path $voll -Parent) ([System.IO.Path]::GetFileNameWithoutExtension($voll) + '_geschwaerzt.png')
        $bild = [System.Drawing.Image]::FromFile($voll)
        try { $vorgang = Get-Vorgang $bild }
        finally { $bild.Dispose() }
        $ausgabe = New-Ausgabebild $vorgang $true
        try { $ausgabe.Save($ziel, [System.Drawing.Imaging.ImageFormat]::Png) }
        finally { $ausgabe.Dispose() }
        "$([System.IO.Path]::GetFileName($ziel)): $(Format-Ergebnis $vorgang)"
    }
}

function Start-Ueberwachung {
    $mutex = New-Object System.Threading.Mutex($false, 'Local\SAP-Schwaerzer')
    if (-not $mutex.WaitOne(0)) {
        [void][System.Windows.Forms.MessageBox]::Show('Der SAP-Schwärzer läuft bereits (Schild-Symbol unten rechts).', 'SAP-Schwärzer')
        return
    }
    try {
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $script:Symbol = New-Object System.Windows.Forms.NotifyIcon
        $script:Symbol.Icon = [System.Drawing.SystemIcons]::Shield
        $script:Symbol.Visible = $true
        Set-Status 'aktiv'

        $menue = New-Object System.Windows.Forms.ContextMenuStrip
        $script:AktivEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Aktiv'
        $script:AktivEintrag.CheckOnClick = $true
        $script:AktivEintrag.Checked = $true
        $script:AktivEintrag.add_CheckedChanged({ if ($script:AktivEintrag.Checked) { Set-Status 'aktiv' } else { Set-Status 'pausiert' } })
        [void]$menue.Items.Add($script:AktivEintrag)

        $script:AblageEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Bilder nummeriert speichern'
        $script:AblageEintrag.CheckOnClick = $true
        $script:AblageEintrag.Checked = $true
        [void]$menue.Items.Add($script:AblageEintrag)

        $ordnerEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Bilder-Ordner öffnen'
        $ordnerEintrag.add_Click({
            if (-not (Test-Path $script:AblageWurzel)) { [void](New-Item -ItemType Directory -Path $script:AblageWurzel) }
            Start-Process explorer.exe -ArgumentList "`"$script:AblageWurzel`""
        })
        [void]$menue.Items.Add($ordnerEintrag)
        [void]$menue.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

        $dateiEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Bilddatei schwärzen …'
        $dateiEintrag.add_Click({
            $dialog = New-Object System.Windows.Forms.OpenFileDialog
            $dialog.Filter = 'Bilder (*.png;*.jpg;*.bmp)|*.png;*.jpg;*.jpeg;*.bmp'
            $dialog.Multiselect = $true
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                try { Show-Meldung ((Invoke-Dateien $dialog.FileNames) -join "`n") }
                catch { Show-Meldung $_.Exception.Message ([System.Windows.Forms.ToolTipIcon]::Error) }
            }
        })
        [void]$menue.Items.Add($dateiEintrag)

        $listeEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Feldnamen bearbeiten'
        $listeEintrag.add_Click({ Start-Process notepad.exe -ArgumentList "`"$script:FeldlistePfad`"" })
        [void]$menue.Items.Add($listeEintrag)

        $ladenEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Feldnamen neu laden'
        $ladenEintrag.add_Click({
            try { Initialize-Feldliste; Show-Meldung "$($script:Feldliste.Anzahl) Feldnamen geladen." }
            catch { Show-Meldung $_.Exception.Message ([System.Windows.Forms.ToolTipIcon]::Error) }
        })
        [void]$menue.Items.Add($ladenEintrag)

        $hilfeEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Anleitung'
        $hilfeEintrag.add_Click({ Start-Process notepad.exe -ArgumentList "`"$script:AnleitungPfad`"" })
        [void]$menue.Items.Add($hilfeEintrag)

        [void]$menue.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

        $endeEintrag = New-Object System.Windows.Forms.ToolStripMenuItem 'Beenden'
        $endeEintrag.add_Click({ $script:Zeitgeber.Stop(); [System.Windows.Forms.Application]::Exit() })
        [void]$menue.Items.Add($endeEintrag)

        $script:Symbol.ContextMenuStrip = $menue

        $script:Zeitgeber = New-Object System.Windows.Forms.Timer
        $script:Zeitgeber.Interval = 250
        $script:Zeitgeber.add_Tick({ Invoke-Pruefschleife })
        $script:Zeitgeber.Start()

        Show-Meldung "Aktiv. Screenshots mit Win+Shift+S werden ab jetzt geschwärzt.`nRechtsklick auf das Schild-Symbol für Pause und Einstellungen."
        [System.Windows.Forms.Application]::Run()
    }
    finally {
        if ($script:Symbol) { $script:Symbol.Visible = $false; $script:Symbol.Dispose() }
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Start
# ---------------------------------------------------------------------------

$pruefung = Test-Voraussetzungen
$allesOk = -not ($pruefung | Where-Object { -not $_.OK })

if ($Pruefen) {
    foreach ($p in $pruefung) {
        $zeichen = if ($p.OK) { '[OK]  ' } else { '[FEHLT]' }
        $farbe = if ($p.OK) { 'Green' } else { 'Red' }
        Write-Host ("{0} {1,-26} {2}" -f $zeichen, $p.Pruefung, $p.Hinweis) -ForegroundColor $farbe
    }
    if ($allesOk) { Write-Host "`nAlles bereit. Der SAP-Schwärzer kann gestartet werden." -ForegroundColor Green }
    else { Write-Host "`nNoch nicht bereit. Bitte die rot markierten Punkte klären." -ForegroundColor Red }
    return
}

if (-not $allesOk) {
    $text = ($pruefung | Where-Object { -not $_.OK } | ForEach-Object { "• $($_.Pruefung): $($_.Hinweis)" }) -join "`n"
    if ('System.Windows.Forms.MessageBox' -as [type]) {
        [void][System.Windows.Forms.MessageBox]::Show("Der SAP-Schwärzer kann nicht starten:`n`n$text", 'SAP-Schwärzer')
    }
    else { Write-Error "Der SAP-Schwärzer kann nicht starten:`n$text" }
    exit 1
}

if ($Datei) {
    Invoke-Dateien $Datei
    return
}

Start-Ueberwachung
