package app.lucene;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.*;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.*;
import org.apache.lucene.store.ByteBuffersDirectory;
import org.apache.lucene.store.Directory;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException, ParseException {
        // 10. & 11. Użycie PolishAnalyzer [cite: 103]
        Analyzer analyzer = new PolishAnalyzer();

        // Indeks w pamięci RAM [cite: 31]
        Directory directory = new ByteBuffersDirectory();
        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        IndexWriter w = new IndexWriter(directory, config);

        // 11. Dodanie polskich dokumentów [cite: 103-110]
        w.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
        w.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
        w.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
        w.addDocument(buildDoc("Naturalnie urodzeni mordercy", "9780316485616"));
        w.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
        w.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));

        w.close(); // [cite: 46]

        // Przygotowanie do wyszukiwania
        IndexReader reader = DirectoryReader.open(directory); // [cite: 66]
        IndexSearcher searcher = new IndexSearcher(reader);

        // 12. Wykonanie zapytań a-l [cite: 111-124]
        System.out.println("--- WYNIKI ZAPYTAŃ ---");

        // a) isbn "9780062316097" - szukamy w polu isbn
        runQuery("isbn:9780062316097", searcher, analyzer, "a) ISBN exact");

        // b) tytuł "urodzić" (stemming zadziała na "Urodzić")
        runQuery("title:urodzić", searcher, analyzer, "b) title:urodzić");

        // c) tytuł "rodzić" (stemming zadziała na "rodzi")
        runQuery("title:rodzić", searcher, analyzer, "c) title:rodzić");

        // d) słowo rozpoczynające się od "ro" (wildcard)
        runQuery("title:ro*", searcher, analyzer, "d) title:ro*");

        // e) tytuł "ponieważ" (stop word - brak wyników)
        runQuery("title:ponieważ", searcher, analyzer, "e) title:ponieważ");

        // f) "Lucyna" AND "akcja"
        runQuery("title:Lucyna AND title:akcja", searcher, analyzer, "f) Lucyna AND akcja");

        // g) "akcja" NOT "Lucyna"
        runQuery("title:akcja NOT title:Lucyna", searcher, analyzer, "g) akcja NOT Lucyna");

        // h) "naturalnie" i "morderca" odległość max 2 (phrase slop)
        runQuery("title:\"naturalnie morderca\"~2", searcher, analyzer, "h) \"naturalnie morderca\"~2");

        // i) "naturalnie" i "morderca" odległość max 1
        runQuery("title:\"naturalnie morderca\"~1", searcher, analyzer, "i) \"naturalnie morderca\"~1");

        // j) "naturalnie" i "morderca" odległość max 0 (obok siebie)
        runQuery("title:\"naturalnie morderca\"~0", searcher, analyzer, "j) \"naturalnie morderca\"~0");

        // k) słowo "naturalne" (stemmer sprowadzi do rdzenia pasującego do "Naturalnie")
        runQuery("title:naturalne", searcher, analyzer, "k) title:naturalne");

        // l) słowo "naturalne" z tolerancją na literówki (fuzzy)
        runQuery("title:naturalne~", searcher, analyzer, "l) title:naturalne~");

        reader.close();
    }

    // Metoda pomocnicza do tworzenia dokumentów [cite: 19-21]
    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }

    // Metoda pomocnicza do wykonywania i wypisywania zapytań
    private static void runQuery(String querystr, IndexSearcher searcher, Analyzer analyzer, String label) throws ParseException, IOException {
        System.out.println("\nZapytanie: " + label + " [" + querystr + "]");
        Query q = new QueryParser("title", analyzer).parse(querystr);

        int maxHits = 10;
        TopDocs docs = searcher.search(q, maxHits);
        ScoreDoc[] hits = docs.scoreDocs;

        System.out.println("Znaleziono: " + hits.length);
        for (int i = 0; i < hits.length; ++i) {
            int docId = hits[i].doc;
            Document d = searcher.storedFields().document(docId); // [cite: 76]
            System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
        }
    }
}