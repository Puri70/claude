const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell,
  WidthType, ShadingType, AlignmentType, BorderStyle, Header, Footer, PageNumber,
  TableOfContents, PageBreak, LevelFormat, TabStopType,
} = require('docx');

const OUT = process.argv[2];
const ACCENT = '2F4858';
const LIGHT = 'E8EDF0';
const FONT = 'Calibri';
const W = 9638; // A4 minus 2 cm Rand links/rechts

// Text mit [Platzhaltern]: Platzhalter werden gelb markiert
function runs(text, opts = {}) {
  return text.split(/(\[[^\]]+\])/).filter(Boolean).map(t =>
    t.startsWith('[')
      ? new TextRun({ text: t, highlight: 'yellow', ...opts })
      : new TextRun({ text: t, ...opts }));
}
const p = (text, opts = {}) => new Paragraph({ children: runs(text, opts.run), spacing: { after: 120 }, ...opts.para });
const hint = text => new Paragraph({ children: runs(text, { italics: true, color: '5A6B75' }), spacing: { after: 120 } });
const h1 = text => new Paragraph({ heading: HeadingLevel.HEADING_1, pageBreakBefore: true, children: [new TextRun(text)] });
const h2 = text => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
const h3 = text => new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(text)] });
const bullet = text => new Paragraph({ numbering: { reference: 'bul', level: 0 }, children: runs(text), spacing: { after: 60 } });

const border = { style: BorderStyle.SINGLE, size: 4, color: 'B8C4CB' };
const borders = { top: border, bottom: border, left: border, right: border };

function table(widths, header, rows) {
  const sum = widths.reduce((a, b) => a + b, 0);
  const cell = (text, i, head) => new TableCell({
    width: { size: widths[i], type: WidthType.DXA },
    borders,
    shading: head ? { type: ShadingType.CLEAR, fill: ACCENT, color: 'auto' } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ children: head ? [new TextRun({ text, size: 18, bold: true, color: 'FFFFFF' })] : runs(text, { size: 18 }) })],
  });
  return new Table({
    width: { size: sum, type: WidthType.DXA },
    columnWidths: widths,
    rows: [
      new TableRow({ tableHeader: true, children: header.map((t, i) => cell(t, i, true)) }),
      ...rows.map(r => new TableRow({ children: r.map((t, i) => cell(t, i, false)) })),
    ],
  });
}
const gap = () => new Paragraph({ spacing: { after: 120 }, children: [] });

function callout(title, lines) {
  return new Table({
    width: { size: W, type: WidthType.DXA },
    columnWidths: [W],
    rows: [new TableRow({ cantSplit: true, children: [new TableCell({
      width: { size: W, type: WidthType.DXA },
      shading: { type: ShadingType.CLEAR, fill: LIGHT, color: 'auto' },
      borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
        left: { style: BorderStyle.SINGLE, size: 24, color: ACCENT } },
      margins: { top: 120, bottom: 120, left: 200, right: 200 },
      children: [
        new Paragraph({ children: [new TextRun({ text: title, bold: true, color: ACCENT })], spacing: { after: 80 } }),
        ...lines.map(l => new Paragraph({ children: runs(l, { size: 20 }), spacing: { after: 60 } })),
      ],
    })] })],
  });
}

// ---------- Deckblatt ----------
const cover = [
  new Paragraph({ spacing: { before: 600, after: 1800 }, children: runs('[Firmenlogo]', { size: 22 }) }),
  new Paragraph({ children: [new TextRun({ text: 'Handbuch Buchhaltung', size: 56, bold: true, color: ACCENT })], spacing: { after: 200 } }),
  new Paragraph({ children: [new TextRun({ text: 'Verfahrensdokumentation nach GoBD und Prozesshandbuch', size: 28, color: '5A6B75' })],
    border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: ACCENT, space: 8 } }, spacing: { after: 600 } }),
  table([3000, 6638], ['Angabe', 'Inhalt'], [
    ['Gesellschaft', '[Firmenname, Rechtsform]'],
    ['Geltungsbereich', '[Buchungskreis(e)]'],
    ['Version Handbuch', '[0.1]'],
    ['Gültig ab', '[Datum]'],
    ['Verantwortlich', '[Leitung Buchhaltung]'],
    ['Freigegeben durch', '[Geschäftsführung, Datum]'],
    ['Ablageort gültige Fassung', '[Pfad oder SharePoint-Bibliothek]'],
  ]),
];

// ---------- Hinweise ----------
const usage = [
  new Paragraph({ heading: HeadingLevel.HEADING_1, pageBreakBefore: true, children: [new TextRun('Inhalt')] }),
  new TableOfContents('Inhalt', { hyperlink: true, headingStyleRange: '1-2' }),
  hint('Nach dem Ausfüllen: Rechtsklick ins Inhaltsverzeichnis → „Felder aktualisieren“ → „Gesamtes Verzeichnis aktualisieren“.'),
  gap(),
  callout('So benutzt du diese Vorlage', [
    'Gelb markierte Stellen in [eckigen Klammern] ersetzen und die Markierung entfernen.',
    'Grau-kursive Hinweise sind Ausfüllhilfen. Vor der Freigabe löschen.',
    'Für jeden Prozess das Muster in Kapitel 2.2 kopieren (ab der Überschrift bis vor die nächste Arbeitsanweisung).',
    'Screenshots nur geschwärzt einfügen, Regeln in Kapitel 0.6.',
  ]),
];

// ---------- Teil 0 ----------
const part0 = [
  h1('0 Lenkung des Handbuchs'),
  hint('Dieses Kapitel zeigt Prüfern, dass das Handbuch gelenkt wird: wer ändert, wer freigibt, wo alte Fassungen liegen (GoBD Rz. 154, ISO 9001 Abschnitt 7.5).'),
  h2('0.1 Zweck und Geltungsbereich'),
  p('Dieses Handbuch beschreibt die Verfahren der Buchhaltung der [Firmenname]. Es dient als Verfahrensdokumentation im Sinne der GoBD und als Prozesshandbuch für die Einarbeitung und Vertretung. Es gilt für [Buchungskreise, Standorte] und die Systeme [SAP-System, Vorsysteme].'),
  h2('0.2 Aufbau'),
  table([1600, 4838, 3200], ['Teil', 'Inhalt', 'Liefert'], [
    ['0', 'Lenkung des Handbuchs', 'Leitung Buchhaltung'],
    ['1', 'Allgemeine Beschreibung', 'Leitung Buchhaltung'],
    ['2', 'Prozesse (Arbeitsanweisungen)', 'Kolleginnen und Kollegen der Buchhaltung'],
    ['3', 'Internes Kontrollsystem', 'Leitung Buchhaltung, aus Teil 2'],
    ['4', 'Technische Systemdokumentation', 'IT'],
    ['5', 'Betriebsdokumentation', 'IT und Leitung Buchhaltung'],
    ['A', 'Anhang', 'alle'],
  ]),
  gap(),
  h2('0.3 Versionen'),
  bullet('0.x = Entwurf, nicht verbindlich.'),
  bullet('1.0 = Praxistest bestanden und freigegeben.'),
  bullet('Kleine Korrektur (Tippfehler, Bild ausgetauscht) → nächste Unterversion, z. B. 1.1.'),
  bullet('Geänderter Ablauf → nächste Hauptversion, z. B. 2.0.'),
  h2('0.4 Freigabe'),
  bullet('Arbeitsanweisungen (Teil 2): Leitung Buchhaltung.'),
  bullet('Handbuch gesamt, Teil 1 und Teil 3: Geschäftsführung.'),
  bullet('Vor der ersten Freigabe: Gegenlesen durch [Steuerberatung / Wirtschaftsprüfung].'),
  h2('0.5 Ablage, alte Fassungen, Überprüfung'),
  bullet('Die gültige Fassung liegt nur an einem Ort: [Ablageort].'),
  bullet('Jede freigegebene Fassung wird zusätzlich als PDF unter [Archivordner] abgelegt und mindestens 10 Jahre aufbewahrt. Nicht löschen, nicht überschreiben.'),
  bullet('Überprüfung jährlich im [Monat] und zusätzlich bei Änderungen an Prozess, SAP, Organisation oder Rechtslage.'),
  h2('0.6 Regeln für Screenshots'),
  callout('Kundendaten gehören nicht ins Handbuch', [
    'Wo möglich leere Masken und Selektionsbilder fotografieren.',
    'Schwärzen nur in Paint: schwarzes Rechteck mit Füllung „Einfarbig“, dann als PNG speichern und die PNG-Datei in Word einfügen.',
    'Nie in Word schwärzen, weder mit Formen noch durch Zuschneiden. Das Original bleibt in der Datei erhalten und lässt sich wiederherstellen.',
    'Feste schwarze Balken, kein Weichzeichner.',
    'Sichtbar bleiben dürfen: Feldbezeichnungen, Transaktionscode, Buttons, unkritische Werte wie Buchungskreis, Belegart, Periode.',
  ]),
  h2('0.7 Änderungshistorie des Handbuchs'),
  table([1500, 1100, 1900, 3338, 1800], ['Datum', 'Version', 'Teil / Prozess', 'Änderung', 'Freigabe'], [
    ['[Datum]', '0.1', 'gesamt', 'Ersterstellung', '[offen]'],
    ['', '', '', '', ''],
    ['', '', '', '', ''],
  ]),
];

// ---------- Teil 1 ----------
const part1 = [
  h1('1 Allgemeine Beschreibung'),
  hint('Einmal schreiben, selten ändern. Ziel: Eine fremde Person versteht in 10 Minuten, wie die Buchhaltung organisiert ist.'),
  h2('1.1 Unternehmen'),
  hint('Rechtsform, Gegenstand, Standorte, Konzernzugehörigkeit, Geschäftsjahr.'),
  p('[Text]'),
  h2('1.2 Organisation der Buchhaltung'),
  hint('Organigramm als Bild, Stellen, Vertretungsregeln. Namen nur, wenn nötig, sonst Stellen.'),
  p('[Organigramm einfügen]'),
  h2('1.3 Rollen und Verantwortung'),
  table([2600, 4038, 3000], ['Rolle', 'Aufgaben', 'Vertretung'], [
    ['[Leitung Buchhaltung]', '[Freigaben, Abschluss, …]', '[Stelle]'],
    ['[Kreditorenbuchhaltung]', '[Rechnungseingang, Zahllauf, …]', '[Stelle]'],
    ['[Debitorenbuchhaltung]', '[Zahlungseingang, Mahnwesen, …]', '[Stelle]'],
  ]),
  gap(),
  h2('1.4 Systemlandschaft'),
  hint('Skizze: SAP, Vorsysteme, Schnittstellen, E-Rechnungs-Eingang, Archiv. Details in Teil 4.'),
  p('[Skizze einfügen]'),
  h2('1.5 Externe Beteiligte'),
  table([3200, 6438], ['Wer', 'Wofür'], [
    ['[Steuerberatung]', '[Jahresabschluss, Steuererklärungen]'],
    ['[Lohnbuchhaltung]', '[Lohn- und Gehaltsabrechnung, Übergabe der Buchungen]'],
    ['[Wirtschaftsprüfung]', '[Prüfung Jahresabschluss]'],
  ]),
  gap(),
  h2('1.6 Grundlagen der Buchführung'),
  hint('Kontenrahmen, Buchungskreise, Belegarten (Liste im Anhang A.3), Nummernkreise, Periodensperre.'),
  p('[Text]'),
];

// ---------- Teil 2 ----------
const map = [
  ['KRE-01', 'Rechnungseingang erfassen (Papier, PDF, E-Rechnung)', '', ''],
  ['KRE-02', 'Rechnung prüfen und freigeben', '', ''],
  ['KRE-03', 'Zahllauf', '', ''],
  ['KRE-04', 'Kreditor anlegen oder ändern', '', ''],
  ['DEB-01', 'Zahlungseingang zuordnen und ausgleichen', '', ''],
  ['DEB-02', 'Mahnlauf', '', ''],
  ['BAN-01', 'Kontoauszug einlesen und nachbearbeiten', '', ''],
  ['HB-01', 'Monatsabschluss', 'ja', 'in Arbeit'],
  ['HB-02', 'Sachkonten abstimmen', '', ''],
  ['HB-03', 'Jahresabschluss vorbereiten', '', ''],
  ['ANL-01', 'Anlagenzugang, -abgang, Abschreibung', '', ''],
  ['STE-01', 'Umsatzsteuer-Voranmeldung', '', ''],
  ['QUE-01', 'Belege ablegen und archivieren', '', ''],
];
const part2 = [
  h1('2 Prozesse'),
  hint('Gegliedert nach Aufgaben, nicht nach Transaktionen. Je Prozess eine Arbeitsanweisung nach dem Muster in 2.2. Ein Prozess gilt erst als dokumentiert, wenn eine fremde Person ihn damit ohne Rückfrage durchgeführt hat.'),
  h2('2.1 Prozesslandkarte'),
  hint('Vorschlag mit typischen Prozessen. Anpassen, bis die Liste alle Prozesse der Buchhaltung zeigt. Kernprozesse markieren. Die Prozess-ID bleibt, auch wenn sich der Name ändert.'),
  table([1300, 5338, 1200, 1800], ['ID', 'Prozess', 'Kern', 'Status'], map),
  hint('Status: offen · in Arbeit · Entwurf · Praxistest bestanden · freigegeben'),
  h2('2.2 HB-01 Monatsabschluss'),
  hint('Muster für jede Arbeitsanweisung. Für den nächsten Prozess diesen Abschnitt kopieren und ID und Titel ändern.'),
  table([2400, 7238], ['Angabe', 'Inhalt'], [
    ['Prozess-ID', 'HB-01'],
    ['Version / Stand', '[0.1] / [Datum]'],
    ['Erstellt von', '[Stelle]'],
    ['Geprüft (Praxistest)', '[Stelle, Datum, Anzahl Rückfragen]'],
    ['Freigegeben', '[Leitung Buchhaltung, Datum]'],
  ]),
  gap(),
  h3('1. Zweck und Ergebnis'),
  p('[Was ist am Ende erledigt?]'),
  h3('2. Auslöser und Häufigkeit'),
  p('[z. B. monatlich ab dem 3. Arbeitstag]'),
  h3('3. Beteiligte'),
  p('[Wer führt aus, wer prüft, wer gibt frei]'),
  h3('4. Voraussetzungen'),
  p('[Was muss vorher erledigt sein, welche Berechtigungen braucht man]'),
  h3('5. Ablauf'),
  hint('Tätigkeiten im Infinitiv. Eingaben als Regel, nicht als konkreter Wert: „Periode = abzuschließender Monat“.'),
  table([600, 1300, 2600, 2300, 2038, 800], ['Nr', 'Transaktion', 'Tätigkeit', 'Eingaben (Feld = Regel)', 'Kontrolle / Ergebnis', 'Bild'], [
    ['1', '[OB52]', '[Buchungsperiode öffnen]', '[Periode = abzuschließender Monat]', '[Meldung „Daten gesichert“]', '1'],
    ['2', '', '', '', '', ''],
    ['3', '', '', '', '', ''],
  ]),
  gap(),
  p('[Bild 1 einfügen]'),
  hint('Bild 1: [Bildunterschrift, z. B. Selektionsbild OB52]'),
  h3('6. Sonderfälle und Fehler'),
  table([4000, 5638], ['Wenn …', 'dann …'], [['[Fehlermeldung / Sonderfall]', '[Lösung, wen fragen]']]),
  gap(),
  h3('7. Kontrollen und Nachweis'),
  hint('Fließt in die Kontrollmatrix (Teil 3). Nachweis = woran ein Prüfer später sieht, dass kontrolliert wurde.'),
  table([3000, 1800, 1800, 3038], ['Kontrolle', 'Wer', 'Wann', 'Nachweis'], [['[Abstimmung Saldenliste]', '[Stelle]', '[nach Schritt 5]', '[Ausdruck abgezeichnet, Ablage …]']]),
  gap(),
  h3('8. Belege und Ablage'),
  table([2600, 2200, 2400, 2438], ['Beleg', 'Form', 'Ablageort', 'Bezug zur Buchung'], [['[Eingangsrechnung]', '[E-Rechnung XML / PDF / Papier]', '[Archivsystem]', '[Belegnummer im Archiv verknüpft]']]),
  gap(),
  h3('9. Begriffe'),
  table([2600, 7038], ['Begriff', 'Erklärung'], [['[Abkürzung oder interner Name]', '[Erklärung]']]),
  gap(),
  h3('10. Offene Punkte'),
  bullet('[offen]'),
  h3('11. Änderungshistorie'),
  table([1500, 1100, 5038, 2000], ['Datum', 'Version', 'Änderung', 'Freigabe'], [['[Datum]', '0.1', 'Ersterstellung', '[offen]']]),
];

// ---------- Teil 3 ----------
const part3 = [
  h1('3 Internes Kontrollsystem'),
  hint('Wird aus Abschnitt 7 aller Arbeitsanweisungen zusammengezogen (GoBD Rz. 100 ff.).'),
  h2('3.1 Kontrollmatrix'),
  table([1100, 2000, 2200, 1300, 1300, 1738], ['Prozess', 'Risiko', 'Kontrolle', 'Art', 'Häufigkeit', 'Nachweis'], [
    ['[HB-01]', '[Buchung in falscher Periode]', '[Periodensperre OB52]', '[systemseitig]', '[monatlich]', '[Änderungsprotokoll]'],
    ['', '', '', '', '', ''],
  ]),
  gap(),
  h2('3.2 Funktionstrennung'),
  hint('Was darf eine Person nicht gleichzeitig? Beispiel: Kreditor anlegen und Zahlung freigeben.'),
  table([4819, 4819], ['Tätigkeit A', 'darf nicht zusammen mit Tätigkeit B'], [['[Kreditor anlegen/ändern]', '[Zahllauf freigeben]']]),
  gap(),
  h2('3.3 Systemseitige Kontrollen'),
  hint('Welche sind eingerichtet? Z. B. Periodensperre, Toleranzgruppen, Prüfung auf doppelte Rechnungen, Pflichtfelder, Freigabe-Workflow.'),
  p('[Liste]'),
];

// ---------- Teil 4 ----------
const part4 = [
  h1('4 Technische Systemdokumentation'),
  hint('Liefert die IT. Die Buchhaltung beschreibt nicht selbst, sondern hält fest, wo die IT-Dokumentation liegt.'),
  table([4200, 3438, 2000], ['Frage an die IT', 'Antwort', 'Fundstelle'], [
    ['SAP-Release, Mandanten, Betreiber/Hosting', '', ''],
    ['Vorsysteme und Schnittstellen: Richtung, Format, Häufigkeit, Vollständigkeitskontrolle', '', ''],
    ['Eingang von E-Rechnungen: Kanal, Prüfung, Übergabe an SAP', '', ''],
    ['Berechtigungskonzept und Ablauf der Rechtevergabe', '', ''],
    ['Änderungsverfahren: Transporte, Test, Freigabe von Customizing', '', ''],
    ['Protokollierung von Änderungen an Stammdaten und Customizing', '', ''],
  ]),
];

// ---------- Teil 5 ----------
const part5 = [
  h1('5 Betriebsdokumentation'),
  h2('5.1 Datensicherung'),
  hint('IT: Was wird gesichert, wie oft, wo? Wann wurde die Wiederherstellung zuletzt getestet?'),
  p('[Text oder Verweis]'),
  h2('5.2 Archivierung'),
  hint('Archivsystem, Unveränderbarkeit, Wiederauffinden, maschinelle Auswertbarkeit. Bei E-Rechnungen ist der strukturierte Datensatz (XML) das Original und wird unverändert aufbewahrt.'),
  p('[Text oder Verweis]'),
  h2('5.3 Aufbewahrungsfristen'),
  table([6138, 3500], ['Unterlage', 'Frist'], [
    ['Bücher, Jahresabschlüsse, Inventare', '10 Jahre'],
    ['Arbeitsanweisungen und Organisationsunterlagen, also dieses Handbuch', '10 Jahre'],
    ['Buchungsbelege (Rechnungen, Kontoauszüge, …)', '8 Jahre (seit 01.01.2025)'],
    ['Empfangene und versandte Handels- und Geschäftsbriefe', '6 Jahre'],
  ]),
  hint('Fristen vor der Freigabe von der Steuerberatung bestätigen lassen.'),
  h2('5.4 Datenzugriff bei Betriebsprüfungen'),
  hint('Wer stellt Daten bereit, in welchem Format, wer begleitet den Prüfer?'),
  p('[Text]'),
  h2('5.5 Notfall'),
  hint('Ausfall von SAP oder Archiv: Wer entscheidet, wie wird nacherfasst?'),
  p('[Text]'),
];

// ---------- Anhang ----------
const annex = [
  h1('Anhang'),
  h2('A.1 Begriffe'),
  table([2600, 7038], ['Begriff', 'Erklärung'], [
    ['GoBD', 'Grundsätze zur ordnungsmäßigen Führung und Aufbewahrung von Büchern, Aufzeichnungen und Unterlagen in elektronischer Form sowie zum Datenzugriff (BMF-Schreiben)'],
    ['Verfahrensdokumentation', 'Beschreibung, wie Belege entstehen, verarbeitet, gebucht und aufbewahrt werden. Pflicht nach den GoBD.'],
    ['IKS', 'Internes Kontrollsystem: alle Kontrollen, die Fehler und Missbrauch verhindern oder aufdecken'],
    ['E-Rechnung', 'Rechnung als strukturierter Datensatz (XRechnung, ZUGFeRD), maschinell auswertbar'],
  ]),
  gap(),
  h2('A.2 Rollenmatrix'),
  hint('Zeilen = Prozesse, Spalten = Rollen. A = ausführen, P = prüfen, F = freigeben.'),
  table([1600, 2700, 1780, 1780, 1778], ['ID', 'Prozess', 'Rolle 1', 'Rolle 2', 'Rolle 3'], [['HB-01', 'Monatsabschluss', '', '', '']]),
  gap(),
  h2('A.3 Belegarten'),
  table([1600, 4038, 4000], ['Belegart', 'Bezeichnung', 'Verwendet in'], [['[KR]', '[Kreditorenrechnung]', '[KRE-01]']]),
  gap(),
  h2('A.4 Verzeichnis der Arbeitsanweisungen'),
  table([1300, 4338, 1200, 1400, 1400], ['ID', 'Prozess', 'Version', 'Freigabe am', 'Praxistest'], [['HB-01', 'Monatsabschluss', '0.1', '', '']]),
];

const doc = new Document({
  features: { updateFields: true },
  creator: 'Buchhaltung',
  title: 'Handbuch Buchhaltung',
  styles: {
    default: { document: { run: { font: FONT, size: 21 } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 34, bold: true, color: ACCENT, font: FONT }, paragraph: { spacing: { before: 0, after: 240 }, outlineLevel: 0 } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 26, bold: true, color: ACCENT, font: FONT }, paragraph: { spacing: { before: 300, after: 120 }, outlineLevel: 1 } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 22, bold: true, color: '333333', font: FONT }, paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 2 } },
    ],
  },
  numbering: { config: [{ reference: 'bul', levels: [{ level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT,
    style: { paragraph: { indent: { left: 360, hanging: 260 } } } }] }] },
  sections: [
    {
      properties: { page: { margin: { top: 1418, bottom: 1134, left: 1134, right: 1134 } } },
      children: cover,
    },
    {
      properties: { page: { margin: { top: 1418, bottom: 1134, left: 1134, right: 1134 } } },
      headers: { default: new Header({ children: [new Paragraph({
        children: runs('Handbuch Buchhaltung · [Firmenname]', { size: 16, color: '5A6B75' }),
        border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: 'B8C4CB', space: 4 } } })] }) },
      footers: { default: new Footer({ children: [new Paragraph({
        tabStops: [{ type: TabStopType.RIGHT, position: W }],
        children: [
          ...runs('Version [0.1] · Stand [Datum]', { size: 16, color: '5A6B75' }),
          new TextRun({ text: '\tSeite ', size: 16, color: '5A6B75' }),
          new TextRun({ children: [PageNumber.CURRENT], size: 16, color: '5A6B75' }),
          new TextRun({ text: ' von ', size: 16, color: '5A6B75' }),
          new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 16, color: '5A6B75' }),
        ] })] }) },
      children: [...usage, ...part0, ...part1, ...part2, ...part3, ...part4, ...part5, ...annex],
    },
  ],
});

Packer.toBuffer(doc).then(async b => {
  // docx-js schreibt <w:highlightCs>, das Word nicht im Schema kennt
  const JSZip = require(require.resolve('jszip', { paths: [require.resolve('docx')] }));
  const zip = await JSZip.loadAsync(b);
  for (const name of Object.keys(zip.files).filter(n => n.endsWith('.xml'))) {
    const xml = await zip.file(name).async('string');
    zip.file(name, xml.replace(/<w:highlightCs [^>]*\/>/g, ''));
  }
  fs.writeFileSync(OUT, await zip.generateAsync({ type: 'nodebuffer', compression: 'DEFLATE' }));
});
