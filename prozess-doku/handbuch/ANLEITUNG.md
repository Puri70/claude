# So dokumentierst du einen Prozess

Stand: 2026-10-17 · Version: 0.1

Ohne eigene Werkzeuge, nur mit Teams, Copilot Chat, Paint und Word.
Du **machst den Prozess einmal und erzählst dabei** (Weg B). Die Screenshots holst du
danach aus der Aufnahme oder aus leeren SAP-Masken (Weg A).
Ziel ist eine Arbeitsanweisung in [Handbuch-Buchhaltung-Vorlage.docx](Handbuch-Buchhaltung-Vorlage.docx), Kapitel 2.

```
Teams: Prozess durchführen und erzählen ──▶ Transkript ──▶ Copilot Chat: Arbeitsanweisung + Bildliste + Rückfragen
                 │                                                           │
                 ▼                                                           ▼
     Video: an die Bild-Stellen springen ──▶ Paint: schwärzen, PNG ──▶ Word: Kapitel 2 ──▶ Praxistest ──▶ Freigabe
```

Zeitbedarf beim ersten Mal: etwa doppelt so lange wie der Prozess selbst, plus 1–2 Stunden in Word.

## 1. Aufnehmen

1. In Teams **Kalender → „Jetzt besprechen“ → „Besprechung starten“**. Du bist allein in der Besprechung.
2. **„…“ (Mehr) → „Aufzeichnen und transkribieren“ → „Aufzeichnung starten“**. Die Transkription läuft mit.
3. **„Teilen“** → das SAP-Fenster wählen.
4. Den Prozess ganz normal durchführen und dabei laut erzählen:
   - **was** du tust und **warum**
   - **woher** ein Wert kommt („Periode ist immer der Monat, den ich abschließe“)
   - **woran** du siehst, dass es geklappt hat
   - was du tust, **wenn es nicht klappt**, und wen du dann fragst
   - wer etwas **prüft oder freigibt**, und wo das festgehalten wird
   - welche **Belege** dazugehören und wo sie abgelegt sind
5. Bei jedem neuen Bildschirm laut **„Bild“** sagen. Das steht dann mit Uhrzeit im Transkript.
6. Aufnahme beenden, Besprechung verlassen.

> **Regel: Den Ablauf erzählen, keine Kundendaten vorlesen.**
> Also „Kreditor laut Rechnung eintragen“, nicht „Kreditor 300417, Firma Müller“.
> Das Transkript geht später in Copilot Chat.

Fehlt „Aufzeichnen und transkribieren“, hat die IT es abgeschaltet. Dann dort nachfragen.

## 2. Transkript holen

Im **Chat der Besprechung** → **„Zusammenfassung“** (bzw. „Recap“) → **„Transkript“** → **„Herunterladen“** als `.docx`.
Die Aufnahme selbst liegt im selben Chat und in deinem OneDrive unter „Aufzeichnungen“.

## 3. Arbeitsanweisung erzeugen

1. **Copilot Chat** öffnen (`m365.cloud.microsoft/chat`). Prüfen, dass das Schild-Symbol für den Unternehmensdatenschutz angezeigt wird.
2. Transkript über die **Büroklammer** hochladen.
3. Den Text aus [PROMPT-TRANSKRIPT.txt](PROMPT-TRANSKRIPT.txt) einfügen, Prozess-ID und Name eintragen, absenden.
4. Copilot gibt dir:
   - die **Arbeitsanweisung** im Aufbau des Handbuchs (Abschnitte 1–11)
   - eine **Bildliste** mit Uhrzeit aus dem Transkript
   - **Rückfragen** zu Lücken. Beantworte sie im Chat, dann „Bitte Arbeitsanweisung aktualisieren“.

**Keine Screenshots in Copilot hochladen.** Die zeigen Kundendaten.

## 4. Screenshots

Für jede Zeile der Bildliste:

1. **Besser:** In SAP die **leere Maske** oder das Selektionsbild aufrufen und fotografieren. Dann gibt es nichts zu schwärzen.
2. **Sonst:** Aufnahme öffnen, zur Uhrzeit springen, **pausieren**.
3. **`Win+Shift+S`** → Bereich wählen.
4. **Paint** öffnen → `Strg+V`.
5. Alles schwärzen, was Kundendaten zeigt: **Formen → Rechteck**, **Füllung „Einfarbig“**, Farbe **Schwarz**.
   Lesbar bleiben dürfen Feldbezeichnungen, T-Code, Buttons und unkritische Werte (Buchungskreis, Belegart, Periode).
6. **Speichern als PNG**, z. B. `HB-01_Bild-01.png`, in einen Ordner pro Prozess.
7. In Word: **Einfügen → Bilder → Dieses Gerät** → die PNG-Datei.

> **Nie in Word schwärzen**, weder mit schwarzen Formen noch durch Zuschneiden.
> Das Originalbild bleibt in der Datei und lässt sich mit zwei Klicks wiederherstellen.

## 5. In die Vorlage übertragen

1. In der Handbuch-Vorlage den Abschnitt **2.2** kopieren und für den Prozess anpassen (ID, Titel).
2. Text und Tabellen aus Copilot einfügen (`Strg+Umschalt+V` = nur Text, falls die Formatierung stört).
3. Bilder an den markierten Stellen einfügen, Bildunterschrift dazu.
4. Offene Punkte stehen lassen, nicht raten.
5. Prozess in die **Prozesslandkarte (2.1)** und ins **Verzeichnis (A.4)** eintragen. Kontrollen aus Abschnitt 7 in die **Kontrollmatrix (3.1)** übernehmen.

## 6. Praxistest

1. Eine Kollegin, die den Prozess **nicht** kennt, führt ihn nur mit der Arbeitsanweisung durch.
2. Du sitzt daneben und sagst nichts. **Jede Rückfrage = ein Strich.**
3. Danach prüfst du, ob das Ergebnis stimmt.
4. **Bestanden = 0 Rückfragen und Ergebnis korrekt.** Sonst nachbessern und erneut testen.
5. Bestanden → Version **1.0**, Freigabe eintragen, Fassung als PDF ins Archiv.

## 7. Aufräumen

Wenn die Arbeitsanweisung freigegeben ist: **Aufnahme und Transkript löschen.** Die Aufnahme zeigt
Kundendaten aus SAP. Aufbewahrt wird die freigegebene Arbeitsanweisung, nicht das Video.

## Datenweg

| Schritt | Wo liegen die Daten | Einstufung | Regel |
|---|---|---|---|
| Teams-Aufnahme | OneDrive im Firmen-Tenant | Gelb | Zeigt Kundendaten auf dem Bildschirm. Nicht teilen, nach Freigabe löschen. |
| Transkript → Copilot Chat | Microsoft 365 mit Unternehmensdatenschutz | Gelb | Nur, wenn keine Kundendaten gesprochen wurden |
| Paint, Word | lokal bzw. Ablage der Abteilung | Grün | Nur geschwärzte PNGs ins Handbuch |
