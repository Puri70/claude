# Prozess-Doku Buchhaltung

Ziel ([INTENT-01](intents/INTENT-01.md)): Eine externe Person mit SAP-Zugang führt die Buchhaltungs-Kernprozesse
anhand der Doku durch, ohne dass ihr jemand etwas erklären muss. Nach 6 Wochen ≥ 80 % der Kernprozesse ohne Rückfrage (heute 0 %).

| Baustein | Wozu | Einstieg |
|---|---|---|
| **SAP-Schwärzer** | Schwärzt Kundendaten in Screenshots lokal, bevor sie eingefügt werden. Pro Bild wählbar, einzelne Werte per Klick freigebbar. | [schwaerzer/LIESMICH.md](schwaerzer/LIESMICH.md) |
| **Prozess-Interviewer** | Agent in Copilot Chat: fragt nach, bis die Doku vollständig ist, und gibt Arbeitsanweisung und Diagramm-Tabelle aus | [interviewer/EINRICHTEN.md](interviewer/EINRICHTEN.md) |
| **Handbuch** | Verfahrensdokumentation (GoBD) und QM-Handbuch in einem: Konzept, Gliederung, Prozesslandkarte | [handbuch/KONZEPT.md](handbuch/KONZEPT.md) |
| Intent und Prüfbericht | Maßstab für jede Funktion | [intents/](intents/) |
| Warum es so ist | Entscheidungen, Regeln, Grenzen. Bei jeder Änderung zuerst lesen. | [WARUM.md](WARUM.md) |

## Ablauf einer Dokumentation

```
SAP  ──Win+Shift+S──▶  Schwärzer (Vorschau, Häkchen, Klick-Freigabe)  ──Strg+V──▶  Prozess-Interviewer (Copilot Chat)
                              │                                                          │
                              ▼                                                          ▼
              Dokumente\SAP-Schwaerzer\<Datum>\Bild-NN.png          Arbeitsanweisung + Diagramm-Tabelle
                              └──────────────────────┬───────────────────────────────────┘
                                                     ▼
                                Word-Vorlage  +  Excel → Visio Data Visualizer
                                                     ▼
                                Handbuch Teil 2 (Gliederung siehe handbuch/)
                                                     ▼
                                Praxistest mit externer Person (Rückfragen zählen)
```

## Tests der Kernlogik (Entwicklung)

```
dotnet run --project schwaerzer/tests
```

Kompiliert mit C# 5, wie Windows PowerShell 5.1 auf den Arbeitsplätzen.
