# Testsatz SAP-Schwärzer

Der Schwärzer rechnet nicht, aber er ist die Schutzschranke, bevor Bilder in Copilot landen.
Deshalb wird er **vor der Weitergabe an Kolleginnen** mit echten Masken geprüft.

**Ziel:** 0 lesbare Kundendaten bei angekreuztem „Kundendaten schwärzen“, ohne einen einzigen Klick.
Feldnamen sollen lesbar sein. Das ist aber nur Komfort, keine Sicherheitsfrage.

## So geht's

1. Je Fall einen Screenshot mit `Win+Shift+S` machen, im Vorschaufenster **nichts anklicken**, „Übernehmen“.
   Die Bilder liegen dann unter `Dokumente\SAP-Schwaerzer\<Datum>`.
2. Jedes Bild ansehen und die Tabelle ausfüllen.
3. Jeder lesbare Kundendatenrest ist ein **Fehler** → in `WARUM.md` unter „Aufgetretene Fehler“ eintragen und mir melden.
   Nicht lesbare Feldnamen → in `Feldnamen.txt` ergänzen.

Bitte die Bilder selbst **nicht weitergeben**. Für die Auswertung reicht die ausgefüllte Tabelle.

## Fälle

| # | Maske | Soll | Kundendaten lesbar? | Feldnamen lesbar? | Status |
|---|---|---|---|---|---|
| 1 | FB60 leer | keine Werte vorhanden, Feldnamen lesbar | | | offen |
| 2 | FB60 befüllt, mit Kreditoren-Infoblock rechts | Kreditor, Name, Adresse, Betrag schwarz | | | offen |
| 3 | MIRO mit Bestellbezug | Bestellnummer, Lieferant, Beträge schwarz | | | offen |
| 4 | FBL1N Ergebnisliste (mind. 10 Zeilen) | alle Zellen schwarz, Spaltenköpfe lesbar | | | offen |
| 5 | FBL1N mit markierter (farbiger) Zeile | auch die markierte Zeile schwarz | | | offen |
| 6 | BP / XK03 Adresse | Name, Straße, Ort, Telefon, E-Mail schwarz | | | offen |
| 7 | BP / XK03 Bankverbindung | IBAN, BIC, Kontoinhaber schwarz | | | offen |
| 8 | F110 Zahlungsvorschlag / Protokoll | Kreditoren, Beträge, Bankdaten schwarz | | | offen |
| 9 | Statusleiste nach dem Buchen | Belegnummer schwarz, Text lesbar | | | offen |
| 10 | Fehlermeldung (rot) mit Kreditorennummer | Nummer schwarz | | | offen |
| 11 | OB52 Buchungsperioden | Perioden-Werte schwarz (per Klick freigebbar) | | | offen |
| 12 | FAGL_FCV Selektionsbild | Feldnamen lesbar, Werte schwarz | | | offen |
| 13 | Bildausschnitt mit sehr kleiner Schrift (SAP-Zoom 80 %) | nichts lesbar | | | offen |
| 14 | Bildausschnitt stark vergrößert (SAP-Zoom 150 %) | nichts lesbar | | | offen |
| 15 | Ganzer Bildschirm mit zwei Fenstern (SAP + Outlook) | Mailinhalte schwarz | | | offen |
| 16 | Klick-Freigabe: in FB60 nur das Buchungsdatum freigeben | nur dieser Wert sichtbar | | | offen |

**Freigabe für Kolleginnen**, wenn die Fälle 1–15 bei „Kundendaten lesbar?“ alle **nein** haben.
