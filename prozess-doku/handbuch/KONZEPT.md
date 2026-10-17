# Verfahrensdokumentation als QM-Handbuch · Konzept und Recherche

Stand: 2026-10-17 · Version: 0.1 · Status: Entwurf

## Kurzantwort: Geht das?

**Ja.** Verfahrensdokumentation (GoBD) und QM-Handbuch (ISO 9001) verlangen im Kern dasselbe:
beschriebene Prozesse, klare Verantwortung, Kontrollen und eine gelenkte, versionierte Ablage.
Ein gemeinsames Handbuch spart die doppelte Pflege. Voraussetzung ist eine Gliederung, die
**beide Leser** bedient:

| Leser | Sucht | Bekommt im Handbuch |
|---|---|---|
| Neue Kollegin, Vertretung (INTENT-01) | „Wie mache ich das?“ | Arbeitsanweisungen je Prozess (Teil 2) |
| Betriebsprüfung, Wirtschaftsprüfung | „Ist die Buchführung nachvollziehbar und unveränderbar?“ | Teil 1–5 vollständig, Versionen lückenlos |
| QM / Geschäftsführung | „Sind Prozesse beherrscht und werden sie verbessert?“ | Prozesslandkarte, Rollen, Kontrollen, Änderungshistorie |

Umsetzung ohne eigene Werkzeuge: Prozess in Teams aufnehmen und dabei erzählen, Copilot Chat macht aus dem
Transkript die Arbeitsanweisung, Screenshots werden in Paint geschwärzt. Siehe [ANLEITUNG.md](ANLEITUNG.md).
Ergebnis ist zuerst ein Word-Handbuch ([Vorlage](Handbuch-Buchhaltung-Vorlage.docx)), später SharePoint.

## Was die GoBD verlangen

Rechtsgrundlage: §§ 145–147 AO und die GoBD (BMF-Schreiben vom 28.11.2019, geändert am
11.03.2024 und am 14.07.2025). Zur Verfahrensdokumentation (GoBD Rz. 151–155):

- Für jedes DV-System muss eine übersichtlich gegliederte Verfahrensdokumentation vorliegen,
  aus der Inhalt, Aufbau, Ablauf und Ergebnisse des Verfahrens vollständig und schlüssig
  ersichtlich sind.
- Sie besteht in der Regel aus **vier Teilen**: allgemeine Beschreibung,
  Anwenderdokumentation, technische Systemdokumentation, Betriebsdokumentation.
- Sie muss zeigen, wie das **interne Kontrollsystem** (IKS, GoBD Rz. 100 ff.) die
  Ordnungsmäßigkeit sicherstellt.
- **Änderungen müssen historisch nachvollziehbar** sein. Alte Fassungen werden aufbewahrt,
  solange die Unterlagen aufzubewahren sind, zu deren Verständnis sie nötig sind.
  Als Organisationsunterlage gilt für die Verfahrensdokumentation selbst die 10-Jahres-Frist
  (§ 147 Abs. 1 Nr. 1, Abs. 3 AO).
- Eine fehlende oder lückenhafte Verfahrensdokumentation ist für sich allein kein Grund,
  die Buchführung zu verwerfen, solange sie nachvollziehbar ist (Rz. 155). Sie ist aber
  im Streitfall das wichtigste Beweismittel des Unternehmens.

Neu seit 2025, für das Handbuch relevant:

| Thema | Was sich ändert | Wo im Handbuch |
|---|---|---|
| **E-Rechnung** (Pflicht zum Empfang seit 01.01.2025) | Empfang, Prüfung, Weiterverarbeitung und Archivierung von XRechnung/ZUGFeRD müssen beschrieben sein. Der strukturierte Datensatz ist das Original und wird unverändert aufbewahrt. GoBD-Änderung vom 14.07.2025, BMF-Schreiben zur E-Rechnung vom 15.10.2024 und 15.10.2025. | Teil 2 (Rechnungseingang), Teil 5 (Archiv) |
| **Aufbewahrung Buchungsbelege** | 8 statt 10 Jahre (BEG IV, § 147 Abs. 3 AO, seit 01.01.2025). Bücher, Abschlüsse und Organisationsunterlagen weiter 10 Jahre. | Teil 5, Aufbewahrungstabelle |

> **Vor der Freigabe prüfen lassen:** Die Recherche stützt sich auf Fachbeiträge von
> Kanzleien und Kammern, nicht auf den Volltext der BMF-Schreiben. Die Randziffern und
> Fristen bitte von Steuerberatung oder Wirtschaftsprüfung gegenlesen lassen, bevor das
> Handbuch als Verfahrensdokumentation freigegeben wird.

## Was ISO 9001 zusätzlich bringt

ISO 9001 schreibt kein „Handbuch“ vor, aber sie verlangt **gelenkte dokumentierte
Information** (Abschnitt 7.5): eindeutige Kennzeichnung, Version, Freigabe, Verteilung,
Schutz vor unbeabsichtigter Änderung, Umgang mit veralteten Fassungen. Das deckt sich fast
vollständig mit der GoBD-Forderung nach historischer Nachvollziehbarkeit.

Was die GoBD nicht verlangt, das QM aber nützlich macht:

- **Prozesslandkarte** (4.4): alle ca. 40 Prozesse auf einen Blick, Kernprozesse markiert
- **Rollen und Verantwortung** (5.3): wer führt aus, wer prüft, wer gibt frei
- **Kennzahlen und Überwachung** (9.1): z. B. Rückfragen im Praxistest (INTENT-01), Abschlussdauer
- **Verbesserung** (10.3): Fehler und Rückfragen führen zu einer neuen Version

## Wo welche Forderung abgedeckt ist

| Forderung | Abgedeckt durch |
|---|---|
| Anwenderdokumentation inkl. Belege und Ablage | Arbeitsanweisungen in Teil 2, erzeugt nach [ANLEITUNG.md](ANLEITUNG.md) |
| IKS mit Nachweis der Kontrollen | Abschnitt 7 jeder Arbeitsanweisung → Kontrollmatrix in Teil 3 |
| Allgemeine Beschreibung | Teil 1, einmalig durch Abteilungsleitung |
| Technische Systemdoku, Betriebsdoku | Teil 4 und 5, **Zulieferung IT**, Frageliste in der Vorlage |
| Lenkung (Version, Freigabe, alte Fassungen) | Teil 0 |
| Prozesslandkarte | Kapitel 2.1, Vorschlag aus [PROZESSLANDKARTE.md](PROZESSLANDKARTE.md) |

## Vorgehen

1. **Prozesslandkarte festlegen** (Abteilungsleitung, ca. 1 Stunde): Vorschlag anpassen,
   Kernprozesse markieren. Das legt zugleich den Nenner für INTENT-01 fest.
2. **Pilot Monatsabschluss** nach [ANLEITUNG.md](ANLEITUNG.md): aufnehmen, Transkript, Copilot Chat,
   Screenshots, Word, Praxistest.
3. **Teil 1 schreiben** (allgemeine Beschreibung, einmalig).
4. **IT-Abfrage** für Teil 4 und 5 verschicken (Liste in der Gliederung).
5. Kernprozesse nacheinander dokumentieren, jeweils mit Praxistest.
6. **Gegenlesen** durch Steuerberatung/WP, **Freigabe** durch die Geschäftsführung
   (die Verantwortung für die Ordnungsmäßigkeit liegt bei ihr).
7. Danach: jährliche Durchsicht und Pflege bei jeder Prozess- oder SAP-Änderung.

## Quellen

- GoBD-Fassung und Änderungen 2024/2025: [Ecovis](https://ecovis-kso.com/blog/gobd-aenderung-wegen-e-rechnung-was-unternehmen-ab-2025-beachten-muessen/), [KPMG](https://kpmg.com/de/de/themen/2025/07/bmf-gobd-zweite-aenderung.html), [EY](https://www.ey.com/de_de/technical/steuernachrichten/konkretisierung-der-gobd-mit-blick-auf-e-rechnungen)
- E-Rechnung und GoBD, Rz. 151 ff.: [Deloitte Tax News](https://www.deloitte-tax-news.de/steuern/indirekte-steuern-zoll/die-e-rechnung-im-kontext-der-grundsaetze-ordnungsgemaesser-buchfuehrung-und-des-datenzugriffs-uebersicht-zur-aktuellen-anwendung-teil-ii.html)
- Zweites E-Rechnungs-Schreiben vom 15.10.2025: [IHK Hannover](https://www.ihk.de/hannover/hauptnavigation/recht/aktuell3/bmf-veroeffentlicht-zweites-anwendungsschreiben-zur-e-rechnung-6797148), [IHK Köln](https://www.ihk.de/koeln/hauptnavigation/recht-steuern/steuern/bmf-schreiben-zur-e-rechnung-vom-15-10-2025-6774012)
- Vier Teile der Verfahrensdokumentation, AWV-Muster: [Haufe](https://www.haufe.de/steuern/steuerwissen-tipps/muster-verfahrensdokumentation-zur-belegablage_170_325034.html), [Deubner](https://www.deubner-steuern.de/themen/gobd/gobd-muster-verfahrensdokumentation-zur-belegablage.html)
- Primärquelle für die Endprüfung: BMF-Schreiben auf bundesfinanzministerium.de
