# Prozessablage – Anleitung

Die Prozessablage verwaltet das Prozesshandbuch: Rohdaten, KI-Ausgabe, bearbeitete Arbeitsanweisung
und die zweistufige Freigabe. Sie braucht nur Windows. Word (ab 2016) ist optional für das PDF.

## Starten

1. Den Ordner `ablage` auf den PC kopieren.
2. Doppelklick auf **`Prozessablage starten.cmd`**.
   Kommt „… ist nicht digital signiert“: Rechtsklick auf `Prozessablage.ps1` und `Ablage.psm1` → Eigenschaften → **„Zulassen“** → OK.
3. Beim ersten Start entsteht `Prozessablage.config.json`. Wer das Werkzeug zum ersten Mal startet, ist für die **finale Freigabe** eingetragen.
   Die Ablage liegt zunächst unter `Dokumente\Prozesshandbuch Buchhaltung`.

## Ablauf

| Schritt | Wer | Was |
|---|---|---|
| **Neuer Prozess** | Ersteller/in | Name eingeben, z. B. „Monatsabschluss“. Prozess P01 mit Entwurf-01 wird angelegt. |
| Dateien ablegen | Ersteller/in | `1_Rohdaten`: Transkript (.txt), Screenshots. `2_KI-Ausgabe`: Antwort von Copilot. |
| **1  Rohdaten abschließen** | Ersteller/in | Dateien werden schreibgeschützt und mit Prüfsummen festgehalten. |
| Bearbeiten | Ersteller/in | Arbeitsanweisung (Word) und Ablaufdiagramm in `3_Bearbeitet` ablegen. |
| **2  Fachlich freigeben** | Kollegin | „Der Ablauf ist so richtig beschrieben.“ |
| **3  Final freigeben** | Leitung | Arbeitsanweisung wird als **Version 1.0** in `Freigegeben` kopiert, schreibgeschützt, wenn Word da ist auch als PDF. |
| **Zurückweisen …** | Leitung | Mit Begründung zurück in „In Überarbeitung“. Danach erneut fachlich freigeben. |

Unten im Fenster steht immer, was im ausgewählten Status als Nächstes zu tun ist. Doppelklick auf eine Zeile öffnet den Ordner.

**Änderungen an einer freigegebenen Fassung:** „Neuer Entwurf“ anlegen. Die nächste finale Freigabe wird Version 2.0.

## Ordner

```
Prozesshandbuch Buchhaltung
├── Freigabeprotokoll.csv          alle Schritte aller Prozesse
└── P01 Monatsabschluss
    ├── prozess.json
    ├── Freigegeben                P01 Monatsabschluss - Version 1.0.docx / .pdf
    └── Entwurf-01 2026-10-20
        ├── 1_Rohdaten
        ├── 2_KI-Ausgabe
        ├── 3_Bearbeitet
        └── protokoll.json         Status, Verlauf, Freigaben, Prüfsummen
```

## Schutz vor Änderungen

- Nach „Rohdaten abschließen“ und nach jeder Freigabe werden Prüfsummen (SHA-256) gespeichert.
- **„Prüfen“** zeigt, ob seitdem eine Datei geändert, gelöscht oder hinzugefügt wurde.
- Wurde eine Arbeitsanweisung nach der fachlichen Freigabe geändert, **verweigert** die finale Freigabe. Die Kollegin muss die geänderte Fassung erneut freigeben.
- **Vier-Augen-Prinzip:** Fachliche und finale Freigabe sollen von zwei Personen kommen. Für den Pilot darf eine Person beides, wenn sie eine Begründung angibt. Das steht dann im Protokoll.
  Streng machen: in `Prozessablage.config.json` `"AusnahmeOhneVierAugen": false` setzen.

## Grenzen der lokalen Version

- **Auf einem einzelnen PC gibt es nur eine Person.** Die zweistufige Freigabe lässt sich hier nur durchspielen, echt wird sie erst in einer gemeinsamen Ablage.
- **Schreibschutz und Prüfsummen erkennen Änderungen, verhindern sie aber nicht.** Wer Zugriff auf den Ordner hat, kann den Schreibschutz aufheben. „Prüfen“ deckt es auf. Echte Sperren gibt es erst mit SharePoint-Rechten.
- **Privater PC:** nur mit Fantasiedaten testen, keine echten SAP-Screenshots oder Firmendaten.

## Umzug nach SharePoint

In `Prozessablage.config.json` bei `"Wurzel"` den per OneDrive synchronisierten SharePoint-Ordner eintragen und den Inhalt dorthin kopieren.
Die Protokolle speichern Pfade relativ und bleiben gültig. Weitere Personen für die finale Freigabe kommen in `"FinaleFreigabe"`
(Schreibweise wie oben im Fenster bei „Angemeldet“).
