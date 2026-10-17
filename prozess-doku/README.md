# Prozess-Doku Buchhaltung

Ziel ([INTENT-01](intents/INTENT-01.md)): Eine externe Person mit SAP-Zugang führt die Buchhaltungs-Kernprozesse
anhand der Doku durch, ohne dass ihr jemand etwas erklären muss. Nach 6 Wochen ≥ 80 % der Kernprozesse ohne Rückfrage (heute 0 %).

Ergebnis: ein **Handbuch Buchhaltung** in Word, das zugleich Verfahrensdokumentation (GoBD) und
QM-Handbuch ist. Später wird es nach SharePoint übertragen.

| Baustein | Wozu | Einstieg |
|---|---|---|
| **Handbuch-Vorlage** | Word-Vorlage mit Lenkung, Allgemeinem Teil, Muster-Arbeitsanweisung, IKS, IT-Fragen, Anhang | [handbuch/Handbuch-Buchhaltung-Vorlage.docx](handbuch/Handbuch-Buchhaltung-Vorlage.docx) |
| **Anleitung** | So entsteht eine Arbeitsanweisung: Teams-Aufnahme, Transkript, Copilot Chat, Screenshots in Paint schwärzen, Praxistest | [handbuch/ANLEITUNG.md](handbuch/ANLEITUNG.md) |
| Text für Copilot Chat | Macht aus dem Transkript Arbeitsanweisung, Bildliste und Rückfragen | [handbuch/PROMPT-TRANSKRIPT.txt](handbuch/PROMPT-TRANSKRIPT.txt) |
| Konzept und Recherche | Was GoBD und ISO 9001 verlangen, mit Quellen | [handbuch/KONZEPT.md](handbuch/KONZEPT.md) |
| Prozesslandkarte | Vorschlag zum Anpassen | [handbuch/PROZESSLANDKARTE.md](handbuch/PROZESSLANDKARTE.md) |
| Warum es so ist | Entscheidungen, Regeln, Grenzen. Bei jeder Änderung zuerst lesen. | [WARUM.md](WARUM.md) |

## Ablauf einer Dokumentation

```
Teams: Prozess durchführen und erzählen ──▶ Transkript ──▶ Copilot Chat: Arbeitsanweisung + Bildliste + Rückfragen
                 │                                                           │
                 ▼                                                           ▼
     Video: an die Bild-Stellen springen ──▶ Paint: schwärzen, PNG ──▶ Word: Kapitel 2 ──▶ Praxistest ──▶ Freigabe
```

## Ruht: eigene Werkzeuge

SAP-Schwärzer ([schwaerzer/](schwaerzer/)) und Prozess-Interviewer ([interviewer/](interviewer/)) wurden gebaut,
aber nie eingesetzt. Sie ruhen, bis sich in der Praxis zeigt, dass das Schwärzen in Paint oder das
Erzeugen aus dem Transkript nicht reicht.

Die Word-Vorlage wird mit `node handbuch/vorlage-erzeugen.js <Ziel.docx>` erzeugt (npm-Paket `docx`).
