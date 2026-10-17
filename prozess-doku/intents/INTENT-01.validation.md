---
intent_ref: INTENT-01
status: gruen
validated_at: 2026-10-17
---

# Validation-Report INTENT-01

Bezugs-Datei: [INTENT-01.md](INTENT-01.md)

Geprüfte Fassung:
> Eine externe Person mit SAP-Zugang soll die Buchhaltungs-Kernprozesse in SAP anhand der Doku durchführen können, ohne dass ich ihr etwas erklären muss. Erfolg = Nach 6 Wochen schafft sie ≥ 80 % der Kernprozesse ohne Rückfrage (heute: 0 %).

## Stufe 1 — Linter

| Pattern | Status | Treffer-Zitat | Vorschlag |
|---------|--------|---------------|-----------|
| Fehler 1 — Versteckter Feature-Intent | [OK] | – | Kein Technik- oder Werkzeugwort. „Doku“ ist das Mittel, aber offen in der Form. |
| Fehler 2 — Nicht messbarer Intent | [OK] | – | Zahl (≥ 80 %), Ausgangswert (0 %), Zeitrahmen (6 Wochen), Messverfahren (Rückfragen zählen) vorhanden. |
| Fehler 3 — Unternehmens-Intent | [OK] | – | Beginnt mit der Nutzerin, nicht mit „wir“. |
| Fehler 4 — Mega-Intent | [OK] | – | Ca. 35 Wörter, eine primäre Metrik. Einarbeitungszeit bewusst als Folgemetrik ausgelagert. |
| Fehler 5 — Copy-Paste-Intent | [OK] | – | Kontextspezifisch: „Buchhaltungs-Kernprozesse in SAP“, „ohne dass ich ihr etwas erklären muss“. |

**Befund Stufe 1:** 0 Treffer.

Verlauf: Draft C hatte Treffer bei Fehler 2 (Erfolg wiederholte das Ziel, doppelte 80 %, kein Zeitrahmen) und weich bei Fehler 5 („Prozessdokumentationen“ branchenneutral). Beides in der finalen Fassung behoben.

## Stufe 2 — Stresstest

| Soulkiller | Status | Begründung |
|------------|--------|------------|
| Tech-Trap | [OK] | Der Intent gilt unverändert auch ohne KI. Die Technik (Copilot, Schwärzer) ist austauschbar. |
| Process-Trap | [OK] | Ziel ist Selbstständigkeit der Leserin, nicht schnelleres Schreiben der Anleitungen. |
| Experience-Trap | [OK] | Konkretes Erlebnis: Eine Person ohne Vorwissen erledigt den Prozess ohne Erklärung. |

**Befund Stufe 2:** Alle 3 OK. Meine Einschätzung wurde vorgelegt, die Nutzerin hat nicht widersprochen und die Fassung übernommen.

## Goldstandard-Vergleich

Vergleich mit dem Beispiel des Londoner Teams (Beschwerde-Management): gleiche Struktur. Nutzergruppe eingegrenzt, Reibung benannt („ohne dass ich ihr etwas erklären muss“ ↔ „ohne mehrmals nachfragen zu müssen“), harte Zahl mit Zeitrahmen. Der Entwurf ist nahe am Goldstandard.

Verfeinerungen für die Messung, nicht für den Satz:

1. **Bestanden-Kriterium schärfen:** Heute zählt nur „0 Rückfragen“. Ein Prozess, der ohne Rückfrage, aber *falsch* gebucht wird, würde als Erfolg zählen. Vorschlag: bestanden = 0 Rückfragen **und** Ergebnis von der Abteilungsleitung als korrekt bestätigt.
2. **Nenner festlegen:** Die Liste der 5–10 Kernprozesse vor Start fixieren, sonst sind die 80 % nicht prüfbar. ST03N (Transaktionsprofil der Buchhaltungs-User) kann belegen, welche Prozesse ca. 80 % der täglichen Arbeit ausmachen.
3. **Startdatum festlegen:** „Nach 6 Wochen“ braucht einen Tag X.

## Empfehlung

**Status:** grün

**Begründung:** Der Satz ist messbar, nutzerzentriert, frei von Technik und spezifisch für die Buchhaltung in SAP. Besonders stark ist die Wahl einer externen Person als Prüfmaßstab: Wer von außen ohne Erklärung klarkommt, für den kommt eine neue Kollegin erst recht klar. Die drei Verfeinerungen oben betreffen die Messung und sollten vor Projektstart geklärt werden.

**Nächster Schritt:** INTENT-01 ist Maßstab für alle Bausteine (Prozess-Interviewer in Copilot Chat, lokaler SAP-Schwärzer, Word-Vorlage, Diagramme). Jede neue Funktion muss auf diesen Satz einzahlen.
