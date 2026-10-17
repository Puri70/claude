# Gliederung · Handbuch Buchhaltung (Verfahrensdokumentation und QM)

Stand: 2026-10-17 · Version: 0.1 · Status: Entwurf

Die Gliederung folgt den vier Teilen der GoBD (Rz. 151 ff.), ergänzt um Lenkung (Teil 0)
und IKS (Teil 3). Die Spalte **„Liefert“** sagt, wer den Inhalt beisteuert.

| Teil | Inhalt | GoBD | ISO 9001 | Liefert |
|---|---|---|---|---|
| 0 | Lenkung des Handbuchs | Rz. 154 | 7.5 | Abteilungsleitung |
| 1 | Allgemeine Beschreibung | Rz. 151–153 | 4.4, 5.3 | Abteilungsleitung |
| 2 | Prozesse (Anwenderdokumentation) | Rz. 151–153 | 8.1 | Prozess-Interviewer + Kolleginnen |
| 3 | Internes Kontrollsystem | Rz. 100 ff. | 9.1 | Abteilungsleitung, aus Teil 2 |
| 4 | Technische Systemdokumentation | Rz. 151–153 | 7.1.3 | IT |
| 5 | Betriebsdokumentation | Rz. 103 ff., 151–153 | 7.5.3 | IT + Abteilungsleitung |
| A | Anhang | – | – | alle |

---

## Teil 0 · Lenkung des Handbuchs

Steht vorn, weil Prüfer zuerst danach fragen.

- **0.1 Geltungsbereich:** welche Gesellschaft(en), welche Buchungskreise, welche Systeme
- **0.2 Aufbau und Kennzeichnung:** jedes Dokument hat eine Prozess-ID (siehe Prozesslandkarte),
  Version, „gültig ab“, Ersteller, Prüfer, Freigabe
- **0.3 Versionsregel:**
  - `0.x` = Entwurf, nicht verbindlich
  - `1.0` = nach bestandenem Praxistest und Freigabe
  - kleine Korrektur (Tippfehler, Bild ersetzt) → `1.1`; geänderter Ablauf → `2.0`
- **0.4 Freigabe:** Arbeitsanweisungen durch die Abteilungsleitung, Teil 1 und das Handbuch
  insgesamt durch die Geschäftsführung
- **0.5 Ablage und alte Fassungen:** gültige Fassung an *einem* Ort [OFFEN: SharePoint-Bibliothek?];
  jede freigegebene Fassung zusätzlich als PDF in einen Ordner „Archiv“, **nicht löschen,
  mindestens 10 Jahre** aufbewahren
- **0.6 Überprüfung:** jährlich zum [OFFEN: Monat] und außerplanmäßig bei Änderungen
  an Prozess, SAP (z. B. Update, neue Transaktion), Organisation oder Rechtslage
- **0.7 Änderungshistorie des Handbuchs:** Tabelle Datum | Version | Teil/Prozess-ID | Änderung | Freigabe

## Teil 1 · Allgemeine Beschreibung

Einmal schreiben, selten ändern. Ca. 3–5 Seiten.

- **1.1 Unternehmen:** Rechtsform, Gegenstand, Standorte, Konzernzugehörigkeit
- **1.2 Organisation der Buchhaltung:** Organigramm, Stellen, Vertretungsregeln
- **1.3 Rollen:** wer bucht, wer prüft, wer gibt frei, wer zahlt frei (Rollenmatrix im Anhang)
- **1.4 Systemlandschaft auf einen Blick:** SAP und Vorsysteme, Schnittstellen, Archiv
  (Bild/Skizze, Details in Teil 4)
- **1.5 Externe Beteiligte:** Steuerberatung, WP, Lohnbuchhaltung, Dienstleister
- **1.6 Prozesslandkarte:** aus [PROZESSLANDKARTE.md](PROZESSLANDKARTE.md)
- **1.7 Kontenrahmen, Buchungskreise, Geschäftsjahr, Belegarten** (Übersicht, nicht vollständig)

## Teil 2 · Prozesse (Anwenderdokumentation)

Je Prozess eine **Arbeitsanweisung**, gegliedert nach der Prozesslandkarte, nicht nach
Transaktionen. Erzeugt mit dem [Prozess-Interviewer](../interviewer/EINRICHTEN.md).
Aufbau jeder Arbeitsanweisung (entspricht Teil A des Interviewers):

1. Zweck und Ergebnis
2. Auslöser und Häufigkeit
3. Beteiligte und Rollen
4. Voraussetzungen
5. Ablauf (Tabelle mit Bildnummern aus dem Schwärzer)
6. Sonderfälle und Fehler
7. Kontrollen und Nachweis → fließt in Teil 3
8. Belege und Ablage → fließt in Teil 5
9. Begriffe
10. Offene Punkte
11. Änderungshistorie

Dazu je Prozess das **Ablaufdiagramm** aus Teil B des Interviewers (Visio Data Visualizer).

## Teil 3 · Internes Kontrollsystem

Wird aus Abschnitt 7 aller Arbeitsanweisungen zusammengezogen, nicht neu geschrieben.

- **3.1 Kontrollmatrix:** Prozess-ID | Risiko | Kontrolle | Art (manuell/systemseitig) |
  Häufigkeit | Durchführung | Nachweis (wo sieht man, dass kontrolliert wurde)
- **3.2 Funktionstrennung:** wer darf was nicht gleichzeitig (z. B. Kreditor anlegen und Zahlung freigeben)
- **3.3 Berechtigungen:** Rollenkonzept in SAP, Verweis auf Teil 4.3
- **3.4 Systemseitige Kontrollen:** z. B. Periodensperre (OB52), Toleranzgruppen,
  Pflichtfelder, Doppelte-Rechnung-Prüfung [OFFEN: welche sind eingerichtet?]

## Teil 4 · Technische Systemdokumentation

**Zulieferung IT.** Die Buchhaltung beschreibt nicht selbst, sondern verweist auf die
IT-Dokumentation und hält fest, wo sie liegt. Abfrageliste an die IT:

- **4.1** SAP-Release, Mandant(en), Hosting/Betreiber
- **4.2** Vorsysteme und Schnittstellen (Warenwirtschaft, Lohn, Bank, E-Rechnungs-Eingang):
  Richtung, Format, Häufigkeit, Kontrolle auf Vollständigkeit
- **4.3** Berechtigungskonzept und Prozess der Rechtevergabe
- **4.4** Änderungsverfahren (Transporte, Tests, Freigabe von Customizing)
- **4.5** Protokollierung von Änderungen an Stammdaten und Customizing

## Teil 5 · Betriebsdokumentation

Teils IT, teils Buchhaltung.

- **5.1 Datensicherung** (IT): was, wie oft, wo, Wiederherstellung getestet?
- **5.2 Archivierung** (IT + Buchhaltung): Archivsystem, Unveränderbarkeit, Wiederauffinden,
  maschinelle Auswertbarkeit; **E-Rechnungen: XML-Datensatz als Original**
- **5.3 Aufbewahrungsfristen** (Buchhaltung, vom Steuerberater bestätigen lassen):

  | Unterlage | Frist |
  |---|---|
  | Bücher, Jahresabschlüsse, Inventare | 10 Jahre |
  | Arbeitsanweisungen und Organisationsunterlagen (dieses Handbuch) | 10 Jahre |
  | Buchungsbelege (Rechnungen, Kontoauszüge …) | 8 Jahre (seit 01.01.2025) |
  | Handels- und Geschäftsbriefe | 6 Jahre |

- **5.4 Datenzugriff der Finanzverwaltung:** wer stellt Daten bereit, in welchem Format (Z1–Z3)
- **5.5 Notfall:** Ausfall SAP oder Archiv, wer entscheidet, wie wird nachgebucht

## Anhang

- A.1 Begriffe (gesammelt aus allen Arbeitsanweisungen)
- A.2 Rollenmatrix
- A.3 Belegartenliste
- A.4 Verzeichnis aller Arbeitsanweisungen mit Version und Freigabedatum
