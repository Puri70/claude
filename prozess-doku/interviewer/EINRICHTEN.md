# Prozess-Interviewer für Copilot Chat einrichten

Ein Agent in Copilot Chat, der dich **interviewt**, statt dass du eine Anleitung schreibst.
Er fragt nach, bis eine externe Person mit SAP-Zugang den Prozess ohne Rückfrage durchführen kann (INTENT-01),
und gibt am Ende eine fertige Arbeitsanweisung und eine Tabelle für das Ablaufdiagramm aus.

Der Agent arbeitet nur mit seinen Anweisungen und mit dem, was du ihm schreibst. Er hat **keinen Zugriff
auf SharePoint oder andere Firmendaten** und ist damit in Copilot Chat ohne Zusatzlizenz nutzbar.

## Einrichten (einmalig, ca. 5 Minuten)

1. Copilot Chat öffnen (`m365.cloud.microsoft/chat` oder die Microsoft-365-Copilot-App).
2. Links **„Agent erstellen“** bzw. **„Agents“ → „Neuer Agent“** → Reiter **„Konfigurieren“**.
3. Felder ausfüllen:
   - **Name:** `Prozess-Interviewer Buchhaltung`
   - **Beschreibung:** `Interviewt Kolleginnen zu einem SAP-Buchhaltungsprozess und erstellt daraus eine Arbeitsanweisung mit Ablaufdiagramm.`
   - **Anweisungen:** den kompletten Text aus [ANWEISUNGEN.txt](ANWEISUNGEN.txt) hineinkopieren.
   - **Wissen / Funktionen:** nichts hinzufügen.
   - **Startaufforderungen:**
     - `Monatsabschluss dokumentieren`
     - `Neuen Prozess dokumentieren`
     - `Fertige Arbeitsanweisung erstellen`
     - `Anleitung auf Lücken prüfen`
4. **„Erstellen“**. Zunächst nur für dich, nach dem Pilot für die Kolleginnen freigeben.

Fehlt „Agent erstellen“, hat die IT das Erstellen von Agenten für Copilot Chat abgeschaltet. Dann bitte dort nachfragen.

## So läuft eine Sitzung

1. **SAP-Schwärzer starten** (Schild-Symbol unten rechts).
2. Im Agenten **„Monatsabschluss dokumentieren“** anklicken.
3. Erzählen, was du tust, Schritt für Schritt:
   - **Einsprechen:** ins Eingabefeld des Chats klicken, **`Win+H`** drücken und losreden. Nochmal `Win+H` beendet das Diktat.
     **Regel: Den Ablauf einsprechen, keine Kundendaten.** Also „Kreditor laut Rechnung eintragen“, nicht „Kreditor 300417, Firma Müller“.
     Hintergrund: `Win+H` schickt die Sprache an den Spracherkennungsdienst von Windows. Der gehört nicht zu eurem Microsoft-365-Vertrag, und Microsoft darf die Spracheingaben zur Verbesserung des Dienstes nutzen.
   - **Screenshots:** `Win+Shift+S` → im Vorschaufenster prüfen, Werte zum Eingeben per Klick freigeben → „Übernehmen“ → `Strg+V` in den Chat.
     Der Schwärzer meldet „Gespeichert als Bild-03“. Schreib die Nummer dazu, z. B. „Bild-03: so sieht die Selektion aus“.
4. Der Agent fragt nach, was fehlt. Antworte einfach, auch stichpunktartig.
5. Am Ende **„fertig“** schreiben. Er gibt aus:
   - die **Arbeitsanweisung**: in die Word-Vorlage kopieren, Bilder aus `Dokumente\SAP-Schwaerzer\<Datum>` an den markierten Stellen einfügen
   - die **Diagramm-Tabelle**: in Excel einfügen → *Einfügen → Visio Data Visualizer* → „Funktionsübergreifendes Flussdiagramm“, Spalten der Vorlage zuordnen
   - **offene Punkte** und die **drei schwächsten Stellen** für den Praxistest

## Nach dem Pilot (Monatsabschluss)

Notiere kurz, bevor du es an Kolleginnen gibst:
- Wie lange hat die Sitzung gedauert, und wie lange das Fertigstellen in Word?
- Welche Fragen des Agenten waren hilfreich, welche überflüssig?
- Welche Feldnamen musstest du in `Feldnamen.txt` ergänzen?
- Was hat der Agent falsch verstanden?

Das ist die Grundlage, um die Anweisungen nachzuschärfen.
