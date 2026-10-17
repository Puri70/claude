# Prozess-Doku Buchhaltung

Ziel ([INTENT-01](intents/INTENT-01.md)): Eine externe Person mit SAP-Zugang führt die Buchhaltungs-Kernprozesse
anhand der Doku durch, ohne dass ihr jemand etwas erklären muss. Nach 6 Wochen ≥ 80 % der Kernprozesse ohne Rückfrage (heute 0 %).

| Baustein | Wozu | Einstieg |
|---|---|---|
| **SAP-Schwärzer** | Schwärzt Kundendaten in Screenshots lokal, bevor sie eingefügt werden. Pro Bild wählbar, einzelne Werte per Klick freigebbar. | [schwaerzer/LIESMICH.md](schwaerzer/LIESMICH.md) |
| **Prozess-Interviewer** | Agent in Copilot Chat: fragt nach, bis die Doku vollständig ist, und gibt Arbeitsanweisung und Diagramm-Tabelle aus | [interviewer/EINRICHTEN.md](interviewer/EINRICHTEN.md) |
| **Prozessablage** | Rohdaten, KI-Ausgabe und Bearbeitung je Entwurf, Prüfsummen, zweistufige Freigabe, Versionen. Zunächst lokal, später in SharePoint. | [ablage/LIESMICH.md](ablage/LIESMICH.md) |
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
                                Praxistest mit externer Person (Rückfragen zählen)
```

## Tests der Kernlogik (Entwicklung)

```
dotnet run --project schwaerzer/tests
pwsh -File ablage/tests/Ablage.Tests.ps1
```

Kompiliert mit C# 5, wie Windows PowerShell 5.1 auf den Arbeitsplätzen.
