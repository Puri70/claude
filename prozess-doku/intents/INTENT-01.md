---
id: INTENT-01
status: active
created: 2026-10-17
---

# INTENT-01 — Kernprozesse ohne Erklärung durchführbar

## 1. Problem-Story

**Neue Kollegin, März 2026:** Die Einarbeitung in die Buchhaltung dauerte mindestens einen Monat und war für sie „sehr verwirrend“. Es gab keine durchgängige Dokumentation. Anleitungen entstehen bisher nur vereinzelt und von Hand in Word, und viel läuft über mündliches Erklären durch die Abteilungsleitung.

Weitere Leser, die heute dasselbe Problem haben: Kolleginnen, die einen Prozess noch nicht kennen (z. B. als Vertretung), Geschäftsführung, Betriebs- und Wirtschaftsprüfer.

## 2. Baseline (Istzustand)

| Metrik | Aktueller Wert | Quelle | Erhebungsdatum |
|--------|----------------|--------|----------------|
| Kernprozesse, die eine externe Person ohne Rückfrage durchführen kann | 0 % | Einschätzung Abteilungsleitung | 2026-10-17 |
| Einarbeitungszeit neue Kollegin | ≥ 1 Monat | Einarbeitung März 2026 | 2026-10-17 |
| Prozesse der Buchhaltung gesamt | ca. 40 (davon 5–10 Kernprozesse) | Schätzung Abteilungsleitung | 2026-10-17 |
| Geschwärzte Screenshots in Anleitungen | keine (es wird nicht geschwärzt) | Ist-Praxis | 2026-10-17 |

## 3. Intent-Drafts

### Draft A
> Nach 6 Wochen liegt uns ein QM-Prozesshandbuch vor, so dass z. B. neue Kolleginnen sich schnell einarbeiten können.

### Draft B
> Nach 6 Wochen haben wir 80 % der Transaktionen dokumentiert.

### Draft C
> Eine externe Person soll 80 % der Prozessdokumentationen sich erarbeiten können, ohne dass ich ihr etwas erklären muss. Erfolg ist, wenn sie sich das zu 80 % eigenständig erarbeiten kann.

Getroffene Entscheidungen auf dem Weg zur finalen Fassung:
- Umfang: die 5–10 **Kernprozesse**, die rund 80 % der täglichen Arbeit abdecken, nicht alle 40 Prozesse.
- „Dokumentiert“ zählt erst, wenn der **Praxistest bestanden** ist, nicht schon, wenn eine Anleitung existiert.
- Gemeint ist eine Person **mit SAP-Zugang**, die den Prozess **durchführt**, nicht nur nachvollzieht.

## 4. Self-Check

Vollständiger Self-Check: siehe [INTENT-01.validation.md](INTENT-01.validation.md).

**Status:** grün

**Kurzfassung:** Linter ohne Treffer, keine offenen Soulkiller-Fragen. Offen sind nur Festlegungen für die Messung (Liste der Kernprozesse, Startdatum, Bestanden-Kriterium), keine Mängel des Satzes selbst.

## 5. Erfolgsmetrik

| Metrik | Istwert | Zielwert | Zeitrahmen | Messverfahren |
|--------|---------|----------|------------|---------------|
| Anteil Kernprozesse, die eine externe Person mit SAP-Zugang anhand der Doku ohne Rückfrage durchführt | 0 % | ≥ 80 % | 6 Wochen ab Projektstart (Datum offen) | Praxistest je Kernprozess, Strichliste der Rückfragen. Bestanden = 0 Rückfragen. |
| *Folgemetrik:* Einarbeitungszeit der nächsten neuen Kollegin für die Kernprozesse | ≥ 1 Monat | 2 Wochen | bei der nächsten Neueinstellung | Datum Start → Datum „bearbeitet Kernprozesse selbstständig“ |

## Intent-Statement (final)

> **Eine externe Person mit SAP-Zugang soll die Buchhaltungs-Kernprozesse in SAP anhand der Doku durchführen können, ohne dass ich ihr etwas erklären muss. Erfolg = Nach 6 Wochen schafft sie ≥ 80 % der Kernprozesse ohne Rückfrage (heute: 0 %).**
