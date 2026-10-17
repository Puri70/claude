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
| Ein Kernprozess zählt erst als „dokumentiert“, wenn der **Praxistest bestanden** ist | „Anleitung existiert“ sagt nichts darüber, ob jemand damit arbeiten kann |

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

## Bewusste Grenzen

- **Kein Ausrollen an die ganze Buchhaltung ohne Datenschutz.** Vor dem Ausweiten über den Pilot hinaus die oder den Datenschutzbeauftragten einbinden (Kundendaten aus dem Produktivmandanten).
- **Texterkennung ist nicht perfekt.** Text, den sie nicht erkennt, lässt sich nicht gezielt behandeln. Deshalb gilt der Grundsatz „im Zweifel schwärzen“, und der Testsatz muss genau solche Fälle enthalten (kleine Schrift, Zoom, Tabellen).
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
