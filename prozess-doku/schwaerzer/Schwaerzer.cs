// SAP-Schwaerzer: Kernlogik.
// Bewusst ohne System.Drawing und ohne LINQ, damit der Code in Windows PowerShell 5.1
// (C#-5-Compiler, nur mscorlib) laeuft und sich ausserhalb von Windows testen laesst.
// Umlaute nur als \u-Escapes, damit die Datei unabhaengig von der Kodierung gleich gelesen wird.

using System;
using System.Collections.Generic;
using System.Text;

namespace SapSchwaerzer
{
    // Ein von der Texterkennung gefundenes Wort, Koordinaten in Pixeln des Originalbilds.
    public sealed class Wort
    {
        public string Text;
        public int Zeile;
        public int X;
        public int Y;
        public int Breite;
        public int Hoehe;

        public Wort() { }

        public Wort(string text, int zeile, int x, int y, int breite, int hoehe)
        {
            Text = text;
            Zeile = zeile;
            X = x;
            Y = y;
            Breite = breite;
            Hoehe = hoehe;
        }
    }

    public sealed class Einstellungen
    {
        // Helligkeit 0..255: dunkler gilt ein Pixel als Schrift.
        public int DunkelSchwelle = 128;
        // Farbige Pixel (Symbole, Links) zaehlen nicht als Schrift.
        public int MaxSaettigung = 80;
        // Kantenlaenge der Rasterzellen fuer Schrift ohne Texterkennung.
        public int Zelle = 4;
        // So viele Zellen Abstand werden noch zu einem Block verbunden.
        public int Luecke = 3;
        // Zusaetzlicher Rand um jeden schwarzen Bereich.
        public int Rand = 2;
    }

    // Ein schwaerzbarer Bereich: ein nicht gelistetes Wort oder ein Block Schrift ohne Texterkennung.
    // Aussen = mit Rand; Kern = der eigentliche Wortkasten (bei Bloecken gleich Aussen).
    public sealed class Bereich
    {
        public bool IstWort;
        public bool Geschwaerzt = true;
        public int X;
        public int Y;
        public int Breite;
        public int Hoehe;
        public int KernX;
        public int KernY;
        public int KernBreite;
        public int KernHoehe;
    }

    public sealed class Analyse
    {
        public int Breite;
        public int Hoehe;
        public List<Bereich> Bereiche = new List<Bereich>();
        // Pixel lesbarer Feldnamen: der Rand eines Nachbarbereichs darf sie nicht ueberdecken.
        public bool[] Frei;
        public int LesbareWoerter;
    }

    public sealed class Ergebnis
    {
        public int[] Pixel;
        public int LesbareWoerter;
        public int GeschwaerzteWoerter;
        public int BloeckeOhneTexterkennung;
    }

    public sealed class Feldliste
    {
        private readonly Dictionary<string, bool> phrasen = new Dictionary<string, bool>();
        private int maxLaenge;

        public int Anzahl { get { return phrasen.Count; } }

        // Jede Zeile ist ein Feldname oder eine Wortfolge; # leitet einen Kommentar ein.
        // Gespeichert wird die normalisierte Zeichenfolge ohne Leerzeichen. So passt ein Eintrag
        // auch dann, wenn die Texterkennung Woerter anders trennt ("Kredit-Nr" / "Kredit Nr").
        public static Feldliste AusZeilen(IEnumerable<string> zeilen)
        {
            Feldliste liste = new Feldliste();
            foreach (string roh in zeilen)
            {
                if (roh == null) continue;
                string zeile = roh.Trim();
                if (zeile.Length == 0 || zeile.StartsWith("#")) continue;
                string schluessel = Normalisiere(zeile);
                if (schluessel.Length == 0) continue;
                liste.phrasen[schluessel] = true;
                if (schluessel.Length > liste.maxLaenge) liste.maxLaenge = schluessel.Length;
            }
            return liste;
        }

        // Kleinbuchstaben, Umlaute ohne Punkte, nur a-z und 0-9.
        // Umlaute werden zu a/o/u, weil die Texterkennung die Punkte oft verliert.
        public static string Normalisiere(string text)
        {
            if (text == null) return "";
            string klein = text.ToLowerInvariant();
            StringBuilder sb = new StringBuilder(klein.Length);
            foreach (char c in klein)
            {
                if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) sb.Append(c);
                else if (c == 'ä') sb.Append('a');
                else if (c == 'ö') sb.Append('o');
                else if (c == 'ü') sb.Append('u');
                else if (c == 'ß') sb.Append("ss");
            }
            return sb.ToString();
        }

        // Nur Satzzeichen und Symbole, keine Buchstaben oder Ziffern: kann keine Kundendaten tragen.
        public static bool IstNeutral(string text)
        {
            if (text == null) return true;
            foreach (char c in text)
            {
                if (char.IsLetterOrDigit(c)) return false;
            }
            return true;
        }

        // Liefert pro Wort, ob es lesbar bleiben darf. Gesucht wird zeilenweise die laengste
        // Folge benachbarter Woerter, deren zusammengesetzter Text in der Liste steht.
        public bool[] Markiere(IList<Wort> woerter)
        {
            bool[] lesbar = new bool[woerter.Count];
            Dictionary<int, List<int>> zeilen = new Dictionary<int, List<int>>();
            List<int> reihenfolge = new List<int>();
            for (int i = 0; i < woerter.Count; i++)
            {
                List<int> indizes;
                if (!zeilen.TryGetValue(woerter[i].Zeile, out indizes))
                {
                    indizes = new List<int>();
                    zeilen[woerter[i].Zeile] = indizes;
                    reihenfolge.Add(woerter[i].Zeile);
                }
                indizes.Add(i);
                if (IstNeutral(woerter[i].Text)) lesbar[i] = true;
            }

            foreach (int zeilenNr in reihenfolge)
            {
                List<int> indizes = zeilen[zeilenNr];
                int start = 0;
                while (start < indizes.Count)
                {
                    int treffer = -1;
                    StringBuilder zusammen = new StringBuilder();
                    for (int ende = start; ende < indizes.Count; ende++)
                    {
                        zusammen.Append(Normalisiere(woerter[indizes[ende]].Text));
                        if (zusammen.Length > maxLaenge) break;
                        if (zusammen.Length > 0 && phrasen.ContainsKey(zusammen.ToString())) treffer = ende;
                    }
                    if (treffer >= 0)
                    {
                        for (int k = start; k <= treffer; k++) lesbar[indizes[k]] = true;
                        start = treffer + 1;
                    }
                    else
                    {
                        start++;
                    }
                }
            }
            return lesbar;
        }
    }

    public static class Kern
    {
        private const int Schwarz = unchecked((int)0xFF000000);

        // Findet alles, was nicht ausdruecklich lesbar sein darf:
        //  1. erkannte Woerter, die nicht in der Feldliste stehen,
        //  2. dunkle Schrift, die die Texterkennung gar nicht gefunden hat.
        // Alle Bereiche sind zunaechst geschwaerzt und koennen einzeln freigegeben werden.
        public static Analyse Analysiere(int[] argb, int breite, int hoehe, IList<Wort> woerter,
                                         Feldliste liste, Einstellungen e)
        {
            if (argb == null || argb.Length != breite * hoehe)
                throw new ArgumentException("Pixelanzahl passt nicht zu Breite x Hoehe.");
            if (e == null) e = new Einstellungen();

            bool[] lesbar = liste.Markiere(woerter);
            int n = breite * hoehe;
            Analyse analyse = new Analyse();
            analyse.Breite = breite;
            analyse.Hoehe = hoehe;
            analyse.Frei = new bool[n];
            bool[] erkannt = new bool[n];     // irgendein erkanntes Wort, inklusive Rand

            for (int i = 0; i < woerter.Count; i++)
            {
                Wort w = woerter[i];
                Fuelle(erkannt, breite, hoehe, w.X - e.Rand, w.Y - e.Rand, w.Breite + 2 * e.Rand, w.Hoehe + 2 * e.Rand);
                if (lesbar[i])
                {
                    Fuelle(analyse.Frei, breite, hoehe, w.X, w.Y, w.Breite, w.Hoehe);
                    analyse.LesbareWoerter++;
                }
                else
                {
                    Bereich b = NeuerBereich(w.X - e.Rand, w.Y - e.Rand, w.Breite + 2 * e.Rand, w.Hoehe + 2 * e.Rand);
                    b.IstWort = true;
                    b.KernX = w.X;
                    b.KernY = w.Y;
                    b.KernBreite = w.Breite;
                    b.KernHoehe = w.Hoehe;
                    analyse.Bereiche.Add(b);
                }
            }

            SucheUnerkannteSchrift(argb, breite, hoehe, erkannt, analyse.Bereiche, e);
            return analyse;
        }

        // Zeichnet das Bild mit allen Bereichen, die gerade auf Geschwaerzt stehen.
        public static int[] Zeichne(int[] argb, Analyse analyse)
        {
            int breite = analyse.Breite;
            int hoehe = analyse.Hoehe;
            byte[] maske = new byte[breite * hoehe];   // 1 = Rand oder Block, 2 = Wortkern
            foreach (Bereich b in analyse.Bereiche)
            {
                if (!b.Geschwaerzt) continue;
                Markiere(maske, breite, hoehe, b.X, b.Y, b.Breite, b.Hoehe, 1);
                if (b.IstWort) Markiere(maske, breite, hoehe, b.KernX, b.KernY, b.KernBreite, b.KernHoehe, 2);
            }

            int[] aus = new int[maske.Length];
            for (int i = 0; i < aus.Length; i++)
            {
                bool dunkel = maske[i] == 2 || (maske[i] == 1 && !analyse.Frei[i]);
                aus[i] = dunkel ? Schwarz : (argb[i] | Schwarz);
            }
            return aus;
        }

        // Index des kleinsten Bereichs an dieser Stelle, sonst -1. Fuer das Ein- und Ausblenden per Klick.
        public static int FindeBereich(Analyse analyse, int x, int y)
        {
            int treffer = -1;
            long kleinste = long.MaxValue;
            for (int i = 0; i < analyse.Bereiche.Count; i++)
            {
                Bereich b = analyse.Bereiche[i];
                if (x < b.X || y < b.Y || x >= b.X + b.Breite || y >= b.Y + b.Hoehe) continue;
                long flaeche = (long)b.Breite * b.Hoehe;
                if (flaeche < kleinste)
                {
                    kleinste = flaeche;
                    treffer = i;
                }
            }
            return treffer;
        }

        public static Ergebnis Berechne(int[] argb, int breite, int hoehe, IList<Wort> woerter,
                                        Feldliste liste, Einstellungen e)
        {
            Analyse analyse = Analysiere(argb, breite, hoehe, woerter, liste, e);
            Ergebnis ergebnis = Zaehle(analyse);
            ergebnis.Pixel = Zeichne(argb, analyse);
            return ergebnis;
        }

        // Zaehlt nur Bereiche, die gerade geschwaerzt sind.
        public static Ergebnis Zaehle(Analyse analyse)
        {
            Ergebnis ergebnis = new Ergebnis();
            ergebnis.LesbareWoerter = analyse.LesbareWoerter;
            foreach (Bereich b in analyse.Bereiche)
            {
                if (!b.Geschwaerzt) continue;
                if (b.IstWort) ergebnis.GeschwaerzteWoerter++;
                else ergebnis.BloeckeOhneTexterkennung++;
            }
            return ergebnis;
        }

        private static Bereich NeuerBereich(int x, int y, int breite, int hoehe)
        {
            Bereich b = new Bereich();
            b.X = x;
            b.Y = y;
            b.Breite = breite;
            b.Hoehe = hoehe;
            b.KernX = x;
            b.KernY = y;
            b.KernBreite = breite;
            b.KernHoehe = hoehe;
            return b;
        }

        public static bool IstSchrift(int pixel, Einstellungen e)
        {
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            int helligkeit = (r * 299 + g * 587 + b * 114) / 1000;
            int max = Math.Max(r, Math.Max(g, b));
            int min = Math.Min(r, Math.Min(g, b));
            return helligkeit < e.DunkelSchwelle && (max - min) <= e.MaxSaettigung;
        }

        private static void SucheUnerkannteSchrift(int[] argb, int breite, int hoehe, bool[] erkannt,
                                                   List<Bereich> bereiche, Einstellungen e)
        {
            int z = Math.Max(1, e.Zelle);
            int zx = (breite + z - 1) / z;
            int zy = (hoehe + z - 1) / z;
            bool[] zelle = new bool[zx * zy];
            for (int y = 0; y < hoehe; y++)
            {
                int zeile = y * breite;
                for (int x = 0; x < breite; x++)
                {
                    int i = zeile + x;
                    if (!erkannt[i] && IstSchrift(argb[i], e)) zelle[(y / z) * zx + (x / z)] = true;
                }
            }

            bool[] besucht = new bool[zelle.Length];
            Queue<int> offen = new Queue<int>();
            for (int start = 0; start < zelle.Length; start++)
            {
                if (!zelle[start] || besucht[start]) continue;
                int minX = int.MaxValue, minY = int.MaxValue, maxX = -1, maxY = -1;
                besucht[start] = true;
                offen.Enqueue(start);
                while (offen.Count > 0)
                {
                    int c = offen.Dequeue();
                    int cx = c % zx;
                    int cy = c / zx;
                    if (cx < minX) minX = cx;
                    if (cy < minY) minY = cy;
                    if (cx > maxX) maxX = cx;
                    if (cy > maxY) maxY = cy;
                    for (int dy = -1; dy <= 1; dy++)
                    {
                        int ny = cy + dy;
                        if (ny < 0 || ny >= zy) continue;
                        for (int dx = -e.Luecke; dx <= e.Luecke; dx++)
                        {
                            int nx = cx + dx;
                            if (nx < 0 || nx >= zx) continue;
                            int nc = ny * zx + nx;
                            if (zelle[nc] && !besucht[nc])
                            {
                                besucht[nc] = true;
                                offen.Enqueue(nc);
                            }
                        }
                    }
                }
                bereiche.Add(NeuerBereich(minX * z - e.Rand, minY * z - e.Rand,
                                          (maxX - minX + 1) * z + 2 * e.Rand, (maxY - minY + 1) * z + 2 * e.Rand));
            }
        }

        private static void Fuelle(bool[] maske, int breite, int hoehe, int x, int y, int b, int h)
        {
            int x0 = Math.Max(0, x);
            int y0 = Math.Max(0, y);
            int x1 = Math.Min(breite, x + b);
            int y1 = Math.Min(hoehe, y + h);
            for (int yy = y0; yy < y1; yy++)
            {
                int zeile = yy * breite;
                for (int xx = x0; xx < x1; xx++) maske[zeile + xx] = true;
            }
        }

        // Hoeherer Wert gewinnt: ein Wortkern bleibt Kern, auch wenn ein Rand darueber liegt.
        private static void Markiere(byte[] maske, int breite, int hoehe, int x, int y, int b, int h, byte wert)
        {
            int x0 = Math.Max(0, x);
            int y0 = Math.Max(0, y);
            int x1 = Math.Min(breite, x + b);
            int y1 = Math.Min(hoehe, y + h);
            for (int yy = y0; yy < y1; yy++)
            {
                int zeile = yy * breite;
                for (int xx = x0; xx < x1; xx++)
                {
                    if (maske[zeile + xx] < wert) maske[zeile + xx] = wert;
                }
            }
        }
    }
}
