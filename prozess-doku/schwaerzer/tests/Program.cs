// Tests der Kernlogik mit kuenstlichen Bildern im SAP-Stil (keine echten Daten).
// Aufruf: dotnet run --project tests

using System;
using System.Collections.Generic;
using SapSchwaerzer;

internal static class Program
{
    private const int Hintergrund = unchecked((int)0xFFF2F2F2);
    private const int Feld = unchecked((int)0xFFFFFFFF);
    private const int Feldrand = unchecked((int)0xFFBFBFBF);
    private const int Beschriftung = unchecked((int)0xFF32363A);
    private const int Wert = unchecked((int)0xFF000000);
    private const int SymbolBlau = unchecked((int)0xFF0A6ED1);
    private const int Schwarz = unchecked((int)0xFF000000);

    private static int fehler;
    private static int geprueft;

    private static int Main()
    {
        TesteNormalisierung();
        TesteMarkierung();
        TesteSchwaerzung();
        TesteFehlerfaelle();
        Console.WriteLine(geprueft + " Pruefungen, " + fehler + " Fehler");
        return fehler == 0 ? 0 : 1;
    }

    private static void Pruefe(bool bedingung, string beschreibung)
    {
        geprueft++;
        if (!bedingung)
        {
            fehler++;
            Console.WriteLine("FEHLER: " + beschreibung);
        }
    }

    private static void TesteNormalisierung()
    {
        Pruefe(Feldliste.Normalisiere("Rechnungsdatum:") == "rechnungsdatum", "Doppelpunkt entfernt");
        Pruefe(Feldliste.Normalisiere("Zurück") == "zuruck", "Umlaut ohne Punkte");
        Pruefe(Feldliste.Normalisiere("Straße") == "strasse", "scharfes s");
        Pruefe(Feldliste.Normalisiere("Kredit-Nr.") == "kreditnr", "Bindestrich und Punkt");
        Pruefe(Feldliste.IstNeutral(":"), "Doppelpunkt ist neutral");
        Pruefe(!Feldliste.IstNeutral("Иван"), "kyrillischer Name ist nicht neutral");
        Pruefe(!Feldliste.IstNeutral("4711"), "Ziffern sind nicht neutral");
    }

    private static Feldliste Liste(params string[] zeilen)
    {
        return Feldliste.AusZeilen(zeilen);
    }

    private static List<Wort> Zeile(int zeile, params string[] texte)
    {
        List<Wort> woerter = new List<Wort>();
        for (int i = 0; i < texte.Length; i++) woerter.Add(new Wort(texte[i], zeile, i * 50, zeile * 20, 40, 12));
        return woerter;
    }

    private static void TesteMarkierung()
    {
        Feldliste liste = Liste("# Kommentar", "Kreditor", "Steuer rechnen", "Kredit-Nr",
                                "Betrag", "Betrag in Hauswährung", "   ", "FB60");

        Pruefe(liste.Anzahl == 6, "Kommentar und Leerzeile werden ignoriert");

        bool[] m = liste.Markiere(Zeile(0, "Kreditor", "4711"));
        Pruefe(m[0] && !m[1], "Feldname lesbar, Wert nicht");

        m = liste.Markiere(Zeile(0, "Steuer", "rechnen"));
        Pruefe(m[0] && m[1], "Mehrwort-Feldname");

        m = liste.Markiere(Zeile(0, "Kredit", "Nr"));
        Pruefe(m[0] && m[1], "Texterkennung trennt anders als die Liste");

        m = liste.Markiere(Zeile(0, "KreditNr."));
        Pruefe(m[0], "Texterkennung verbindet anders als die Liste");

        m = liste.Markiere(Zeile(0, "Betrag", "in", "Hauswährung", "1.190,00"));
        Pruefe(m[0] && m[1] && m[2] && !m[3], "laengster Treffer, Betrag bleibt schwarz");

        m = liste.Markiere(Zeile(0, "Muster", "GmbH", ":"));
        Pruefe(!m[0] && !m[1] && m[2], "Name schwarz, Satzzeichen neutral");

        List<Wort> zweiZeilen = Zeile(0, "Steuer");
        zweiZeilen.AddRange(Zeile(1, "rechnen"));
        m = liste.Markiere(zweiZeilen);
        Pruefe(!m[0] && !m[1], "Treffer reicht nicht ueber Zeilen hinweg");

        m = liste.Markiere(Zeile(0, "FB60"));
        Pruefe(m[0], "Transaktionscode aus der Liste");

        m = liste.Markiere(Zeile(0, "FB61"));
        Pruefe(!m[0], "aehnlicher, nicht gelisteter Code bleibt schwarz");
    }

    // Maske: Beschriftung "Kreditor" links, weisses Eingabefeld mit Wert rechts,
    // darunter ein Wert, den die Texterkennung uebersehen hat, und ein blaues Symbol.
    private static void TesteSchwaerzung()
    {
        int b = 200, h = 80;
        int[] bild = new int[b * h];
        for (int i = 0; i < bild.Length; i++) bild[i] = Hintergrund;

        Rechteck(bild, b, 10, 10, 50, 10, Beschriftung);        // "Kreditor"
        Rechteck(bild, b, 80, 6, 100, 18, Feldrand);             // Feldrand
        Rechteck(bild, b, 81, 7, 98, 16, Feld);                  // Feldinneres
        Rechteck(bild, b, 85, 10, 40, 10, Wert);                 // "4711", erkannt
        Rechteck(bild, b, 85, 50, 60, 10, Wert);                 // Wert ohne Texterkennung
        Rechteck(bild, b, 10, 50, 12, 12, SymbolBlau);           // farbiges Symbol

        List<Wort> woerter = new List<Wort>();
        woerter.Add(new Wort("Kreditor", 0, 10, 10, 50, 10));
        woerter.Add(new Wort("4711", 0, 85, 10, 40, 10));

        Ergebnis e = Kern.Berechne(bild, b, h, woerter, Liste("Kreditor"), new Einstellungen());

        Pruefe(e.LesbareWoerter == 1 && e.GeschwaerzteWoerter == 1, "Zaehler fuer Woerter");
        Pruefe(e.BloeckeOhneTexterkennung == 1, "genau ein unerkannter Block");
        Pruefe(Gleich(e.Pixel, bild, b, 10, 10, 50, 10), "Feldname bleibt unveraendert");
        Pruefe(Ueberall(e.Pixel, b, 83, 8, 44, 14, Schwarz), "erkannter Wert samt Rand schwarz");
        Pruefe(Ueberall(e.Pixel, b, 85, 50, 60, 10, Schwarz), "unerkannter Wert schwarz");
        Pruefe(e.Pixel[6 * b + 150] == Feldrand, "heller Feldrand bleibt");
        Pruefe(e.Pixel[55 * b + 15] == SymbolBlau, "farbiges Symbol bleibt");
        Pruefe(e.Pixel[40 * b + 5] == Hintergrund, "Hintergrund bleibt");

        // Einzelnen Wert per Klick wieder einblenden, z. B. die Periode im Monatsabschluss.
        Analyse a = Kern.Analysiere(bild, b, h, woerter, Liste("Kreditor"), null);
        Pruefe(a.Bereiche.Count == 2, "zwei schwaerzbare Bereiche");
        int wertBereich = Kern.FindeBereich(a, 90, 15);
        Pruefe(wertBereich >= 0 && a.Bereiche[wertBereich].IstWort, "Klick trifft den erkannten Wert");
        Pruefe(Kern.FindeBereich(a, 5, 40) == -1, "Klick auf Hintergrund trifft nichts");
        a.Bereiche[wertBereich].Geschwaerzt = false;
        int[] teilweise = Kern.Zeichne(bild, a);
        Pruefe(Gleich(teilweise, bild, b, 83, 8, 44, 14), "freigegebener Wert ist wieder sichtbar");
        Pruefe(Ueberall(teilweise, b, 85, 50, 60, 10, Schwarz), "anderer Wert bleibt schwarz");
        Ergebnis z = Kern.Zaehle(a);
        Pruefe(z.GeschwaerzteWoerter == 0 && z.BloeckeOhneTexterkennung == 1, "Zaehler beruecksichtigen Freigabe");
        foreach (Bereich bereich in a.Bereiche) bereich.Geschwaerzt = false;
        int[] alles = Kern.Zeichne(bild, a);
        Pruefe(Gleich(alles, bild, b, 0, 0, b, h), "ohne Schwaerzung ist das Bild unveraendert");

        // Rand eines geschwaerzten Nachbarworts darf einen lesbaren Feldnamen nicht anknabbern.
        int[] eng = new int[b * h];
        for (int i = 0; i < eng.Length; i++) eng[i] = Hintergrund;
        Rechteck(eng, b, 10, 10, 50, 10, Beschriftung);
        Rechteck(eng, b, 61, 10, 30, 10, Wert);
        List<Wort> nah = new List<Wort>();
        nah.Add(new Wort("Kreditor", 0, 10, 10, 50, 10));
        nah.Add(new Wort("4711", 0, 61, 10, 30, 10));
        Ergebnis e2 = Kern.Berechne(eng, b, h, nah, Liste("Kreditor"), new Einstellungen());
        Pruefe(Gleich(e2.Pixel, eng, b, 10, 10, 50, 10), "Feldname neben Wert bleibt vollstaendig");
        Pruefe(Ueberall(e2.Pixel, b, 61, 10, 30, 10, Schwarz), "Wert neben Feldname schwarz");

        // Transparente Pixel aus der Zwischenablage werden deckend ausgegeben.
        int[] transparent = new int[4];
        for (int i = 0; i < 4; i++) transparent[i] = 0x00F2F2F2;
        Ergebnis e3 = Kern.Berechne(transparent, 2, 2, new List<Wort>(), Liste(), new Einstellungen());
        Pruefe(e3.Pixel[0] == Hintergrund, "Ausgabe ist deckend");
    }

    private static void TesteFehlerfaelle()
    {
        bool geworfen = false;
        try { Kern.Berechne(new int[3], 2, 2, new List<Wort>(), Liste(), null); }
        catch (ArgumentException) { geworfen = true; }
        Pruefe(geworfen, "falsche Pixelanzahl wird abgelehnt");

        // Wort teilweise ausserhalb des Bilds: kein Absturz.
        int[] bild = new int[100];
        List<Wort> woerter = new List<Wort>();
        woerter.Add(new Wort("4711", 0, 8, 8, 10, 10));
        Ergebnis e = Kern.Berechne(bild, 10, 10, woerter, Liste(), null);
        Pruefe(e.Pixel[99] == Schwarz, "Wort am Bildrand geschwaerzt");
    }

    private static void Rechteck(int[] bild, int breite, int x, int y, int b, int h, int farbe)
    {
        for (int yy = y; yy < y + h; yy++)
            for (int xx = x; xx < x + b; xx++)
                bild[yy * breite + xx] = farbe;
    }

    private static bool Ueberall(int[] bild, int breite, int x, int y, int b, int h, int farbe)
    {
        for (int yy = y; yy < y + h; yy++)
            for (int xx = x; xx < x + b; xx++)
                if (bild[yy * breite + xx] != farbe) return false;
        return true;
    }

    private static bool Gleich(int[] a, int[] original, int breite, int x, int y, int b, int h)
    {
        for (int yy = y; yy < y + h; yy++)
            for (int xx = x; xx < x + b; xx++)
            {
                int i = yy * breite + xx;
                if (a[i] != (original[i] | Schwarz)) return false;
            }
        return true;
    }
}
