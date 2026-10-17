# Prozesslandkarte Buchhaltung · Vorschlag

Stand: 2026-10-17 · Version: 0.1 · Status: **Vorschlag zum Anpassen**

Typische Prozesse einer SAP-Buchhaltung, gruppiert nach Bereichen. Nicht aus unseren
Abläufen abgeleitet: streichen, umbenennen, ergänzen, bis die Liste unsere ca. 40 Prozesse zeigt.
Danach die **Kernprozesse** (5–10, ca. 80 % der täglichen Arbeit) markieren.
Das ist der Nenner für [INTENT-01](../intents/INTENT-01.md). ST03N (Transaktionsprofil) hilft
bei der Auswahl.

Prozess-ID = Bereichskürzel + Nummer. Die ID bleibt, auch wenn sich der Name ändert.

| ID | Prozess | Typische Transaktionen | Kern? | Status |
|---|---|---|---|---|
| **KRE** | **Kreditoren** | | | |
| KRE-01 | Rechnungseingang erfassen (Papier, PDF, E-Rechnung) | FB60, MIRO | | |
| KRE-02 | Rechnung prüfen und freigeben | | | |
| KRE-03 | Gutschrift und Storno | FB65, FB08 | | |
| KRE-04 | Zahllauf vorbereiten und ausführen | F110 | | |
| KRE-05 | Kreditor anlegen oder ändern | XK01/XK02 bzw. BP | | |
| **DEB** | **Debitoren** | | | |
| DEB-01 | Zahlungseingang zuordnen und ausgleichen | F-28, FEBAN | | |
| DEB-02 | Mahnlauf | F150 | | |
| DEB-03 | Debitor anlegen oder ändern | XD01/XD02 bzw. BP | | |
| DEB-04 | Offene Posten klären | FBL5N | | |
| **BAN** | **Bank und Kasse** | | | |
| BAN-01 | Elektronischen Kontoauszug einlesen und nachbearbeiten | FF_5, FEBAN | | |
| BAN-02 | Kasse führen | FBCJ | | |
| **HB** | **Hauptbuch und Abschluss** | | | |
| HB-01 | Monatsabschluss | OB52, FAGL_FCV … | ja (Pilot) | in Arbeit |
| HB-02 | Sachkonten abstimmen | FAGLL03 | | |
| HB-03 | Abgrenzungen und Rückstellungen buchen | FB50 | | |
| HB-04 | Jahresabschluss vorbereiten | | | |
| HB-05 | Sachkonto anlegen oder ändern | FS00 | | |
| **ANL** | **Anlagen** | | | |
| ANL-01 | Anlagenzugang | AS01, F-90 | | |
| ANL-02 | Abschreibungslauf | AFAB | | |
| ANL-03 | Anlagenabgang | ABAVN | | |
| **STE** | **Steuern** | | | |
| STE-01 | Umsatzsteuer-Voranmeldung | | | |
| STE-02 | Zusammenfassende Meldung | | | |
| **QUE** | **Querschnitt** | | | |
| QUE-01 | Belege ablegen und archivieren | | | |
| QUE-02 | Datenträgerüberlassung an Prüfer | | | |
| QUE-03 | Berechtigung beantragen | | | |
| QUE-04 | Korrektur- und Umbuchungen | FB50, FB08 | | |

**Status:** leer = offen · in Arbeit · Entwurf (0.x) · Praxistest bestanden · freigegeben (1.0)
