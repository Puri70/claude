# Warum es so ist · Prozess-Doku Buchhaltung

Stand: 2026-10-17 · Version: 0.1

> Diese Datei wird bei jeder größeren Änderung als Erstes mitgegeben.
> Sie hält Entscheidungen fest, keinen Arbeitsstand.

## Intent

Eine externe Person mit SAP-Zugang soll die Buchhaltungs-Kernprozesse in SAP anhand der Doku durchführen können, ohne dass ich ihr etwas erklären muss.
Erfolg = Kernprozesse ohne Rückfrage durchführbar: 0 % → ≥ 80 % in 6 Wochen.
Details: [intents/INTENT-01.md](intents/INTENT-01.md)

## Datenweg

| Baustein | Einstufung | Begründung |
|---|---|---|
| SAP-Schwärzer (PowerShell, lokal) | Grün | Läuft offline, nichts verlässt den Rechner |
| Prozess-Interviewer (Copilot Chat) | Rot | Geschwärzte Screenshots und Beschreibungen aus dem Produktivmandanten gehen in den M365-Tenant |

Der Schwärzer ist die **Schutzschranke vor dem roten Datenweg**. Er muss deshalb mit einem Testsatz geprüft sein, bevor andere ihn nutzen.
Zuletzt geprüft: 2026-10-17

## Fachliche Sonderregeln

| Regel | Warum |
|---|---|
| Geschwärzt wird **lokal, bevor** ein Screenshot in Copilot eingefügt wird | Sonst sind Kundendaten schon im Tenant, bevor sie geschwärzt sind |
| Schwärzen per fest programmiertem Verfahren, **nie per generativer KI** | Generative KI malt Bilder neu: nicht nachvollziehbar, nicht verlässlich |
| **Positivliste:** lesbar bleibt nur, was bekannt ist (Feldbezeichnungen, Spaltenköpfe, Titelleiste mit T-Code, Buttons) | Unbekanntes wird schwarz. Ein Fehler führt zu „zu viel geschwärzt“, nie zu einem Datenleck. |
| Unkritische Werte (Buchungskreis, Belegart, Währung) dürfen auf die Positivliste | Sie helfen der Leserin und sind keine Kundendaten |
| **Feste schwarze Balken**, kein Weichzeichner | Weichgezeichneter Text lässt sich teilweise zurückrechnen |
| Wo möglich **leere Masken und Selektionsbilder** fotografieren | Zeigen alle Feldnamen ohne Kundendaten. Der Schwärzer ist Sicherheitsnetz, nicht die einzige Maßnahme. |
| Handbuch **gegliedert nach Prozessen**, nicht nach Transaktionen | Eine Transaktion (z. B. FB50) kommt in mehreren Prozessen vor. Neue Kolleginnen suchen nach Aufgaben, nicht nach T-Codes. |
| **Ein Handbuch** für Verfahrensdokumentation und QM, gegliedert nach den vier GoBD-Teilen plus Lenkung und IKS | Prüfer und neue Kolleginnen lesen dieselben Arbeitsanweisungen. Doppelte Pflege führt zu zwei Wahrheiten. |
| Jede freigegebene Fassung bleibt als PDF erhalten, **mindestens 10 Jahre** | GoBD verlangt, dass Änderungen der Verfahrensdokumentation historisch nachvollziehbar sind |
| Technische System- und Betriebsdokumentation **liefert die IT**, die Buchhaltung verweist nur | Die Buchhaltung kennt Datensicherung und Transporte nicht aus erster Hand. Selbst geschrieben wäre es geraten. |
| Rechtsangaben (Randziffern, Fristen) vor der Freigabe **von Steuerberatung/WP gegenlesen** lassen | Recherche stützt sich auf Fachbeiträge, nicht auf den Volltext der BMF-Schreiben |
| Ein Kernprozess zählt erst als „dokumentiert“, wenn der **Praxistest bestanden** ist | „Anleitung existiert“ sagt nichts darüber, ob jemand damit arbeiten kann |
| Nach jedem Screenshot **Vorschau mit Häkchen** „Kundendaten schwärzen“ (vorab an) | Im Monatsabschluss müssen Eingabewerte (Periode, Geschäftsjahr …) sichtbar sein, Kundendaten nicht. Die Entscheidung trifft die Kollegin pro Bild. |
| Einzelne Balken **per Klick freigeben** statt Werte in die Feldliste schreiben | Ein Wert in der Feldliste wäre in *jedem* Bild lesbar. Die Freigabe per Klick gilt nur für dieses eine Bild. |
| Screenshot wird **sofort** aus der Zwischenablage genommen, erst nach „Übernehmen“ zurückgelegt | So kann das Original nicht versehentlich eingefügt werden, auch nicht während die Texterkennung läuft |
| Bei Fehlern wird die Zwischenablage **geleert** | Lieber den Screenshot wiederholen als ein ungeschwärztes Bild weitergeben |
| Nur **reine Bilder** werden geprüft, keine Kopien mit Text | Excel, Word und Browser legen beim Kopieren von Text zusätzlich ein Bild ab. Diese Kopien dürfen nicht zerstört werden. |
| Dunkle, **farblose** Schrift ohne Texterkennung wird geschwärzt, farbige nicht | Fängt Werte ab, die die Texterkennung übersieht, ohne Symbole und Schaltflächen zu schwärzen |
| Übernommene Bilder werden **nummeriert gespeichert** (Bild-01 …), Originale nie | Die Bilder werden später in Word gebraucht. Der Interviewer verweist auf die Nummern. |
| Der Interviewer **erfindet nichts** und übernimmt keine Kundendaten in die Doku | Plausibel klingende, aber falsche Transaktionen oder Werte wären schlimmer als eine offene Lücke |

## Getroffene Entscheidungen

| Datum | Entscheidung | Begründung | Verworfene Alternative |
|---|---|---|---|
| 2026-10-17 | Erfassung über **Copilot Chat** (alle haben es) | Nur wenige haben eine M365-Copilot-Lizenz | Copilot in Word/OneNote für alle (Lizenzkosten) |
| 2026-10-17 | Prozess-Interviewer als Agent **ohne Zugriff auf Firmendaten** | Agenten nur mit Anweisungen sind in Copilot Chat ohne Zusatzkosten | Agent mit SharePoint-Zugriff (Abrechnung pro Nachricht) |
| 2026-10-17 | Übernahme in die Word-Vorlage **per Copy-Paste**, keine automatische Ablage | Keine Zusatzkosten, kein Power Automate nötig | Ablage in SharePoint per Power Automate |
| 2026-10-17 | Schwärzer **nur mit Bordmitteln** (Windows PowerShell + Windows-Texterkennung) | Auf den PCs darf nichts installiert werden | Greenshot/ShareX, eigenes .exe, SAP UI Data Protection Masking |
| 2026-10-17 | Schwärzer ist **Pflicht** | Es gibt nur den Produktivmandanten, keinen Testmandanten | Screenshots im Testmandanten |
| 2026-10-17 | Pilot: Abteilungsleitung + 1–2 Kolleginnen, Freigabe durch Abteilungsleitung | Kleiner, kontrollierter Kreis | Sofort ganze Buchhaltung |
| 2026-10-17 | Diagramme über Schritt-Tabelle → Excel → Visio Data Visualizer | Bleibt in Office, bearbeitbar | Mermaid (schneller, aber weniger Office-nah) |
| 2026-10-17 | Kernlogik in C# (per Add-Type geladen), Oberfläche in PowerShell | Pixelarbeit ist in reinem PowerShell zu langsam. Der C#-Teil ist ohne Windows testbar. | Alles in PowerShell |
| 2026-10-17 | Pilotprozess: **Monatsabschluss**, dokumentiert von der Abteilungsleitung selbst | Erst selbst erleben, was funktioniert, bevor Kolleginnen es nutzen | Sofort mit einer Kollegin starten |
| 2026-10-17 | Schwärzen **pro Screenshot wählbar** (Häkchen + Klick-Freigabe) | Wunsch aus dem Monatsabschluss: Eingabewerte müssen sichtbar sein | Immer alles schwärzen |
| 2026-10-17 | Verfahrensdokumentation und QM-Handbuch **in einem** Handbuch | Gleiche Inhalte, eine Pflege. Interviewer fragt dafür zusätzlich nach Belegen, Ablage und Kontrollnachweis. | Zwei getrennte Werke |
| 2026-10-17 | Prozesslandkarte zuerst als **Vorschlag** mit typischen SAP-Prozessen, Abteilungsleitung passt an | Schneller als bei null anfangen; legt zugleich den Nenner für INTENT-01 fest | Liste erst im Interview erheben |
| 2026-10-17 | Einsprechen mit **`Win+H`** (Windows-Spracheingabe), Regel: nur Ablauf, keine Kundendaten | Funktioniert auf den Firmen-PCs (von der IT nicht per Richtlinie gesperrt) und in jedem Eingabefeld. Die Sprache geht an den Windows-Spracherkennungsdienst außerhalb des M365-Vertrags. Darum keine Kundendaten. | Word „Diktieren“ mit Umweg über Copy-Paste |

## Bewusste Grenzen

- **Kein Ausrollen an die ganze Buchhaltung ohne Datenschutz.** Vor dem Ausweiten über den Pilot hinaus die oder den Datenschutzbeauftragten einbinden (Kundendaten aus dem Produktivmandanten).
- **Texterkennung ist nicht perfekt.** Dunkle Schrift, die sie nicht findet, wird vorsichtshalber geschwärzt. Farbige Schrift (rote Fehlermeldungen, blaue Links) und weiße Schrift auf dunklem Grund nur, wenn sie erkannt wird. Deshalb: Vorschau immer ansehen, helles SAP-Design nutzen, Testsatz (`schwaerzer/TESTSATZ.md`) vor der Weitergabe abarbeiten.
- **Originale außerhalb des Schwärzers:** Das Snipping Tool kann Originale selbst speichern, der Zwischenablage-Verlauf (`Win+V`) kann sie behalten. Beides liegt außerhalb des Werkzeugs und steht in der Anleitung.
- **Kein Windows-Test aus der Entwicklungsumgebung:** Kernlogik und Skript-Syntax sind automatisch getestet, Texterkennung, Zwischenablage und Fenster nur auf einem echten Windows-PC. Der erste Lauf am Firmen-PC ist deshalb Teil des Tests.
- **Keine Screenshots aus Videos.** Mit Bordmitteln nicht zuverlässig machbar. Screenshots kommen per `Win+Shift+S`.
- **Keine automatische Ablage.** Bewusst Copy-Paste, siehe Entscheidungen.

## Aufgetretene Fehler

| Datum | Fehler | Ursache | Als Testfall aufgenommen |
|---|---|---|---|
| – | – | – | – |

---

**Gehört hier nicht hinein:** Beschreibungen dessen, was der Code ohnehin zeigt;
echte Daten, Schlüssel oder Personenbezug; alles, was sich mit jeder Version
ändert.
