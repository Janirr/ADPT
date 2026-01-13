package app.lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;

public class Search {
    private static final String INDEX_DIRECTORY = "index_dir";

    public static void main(String[] args) throws IOException, ParseException {
        // Otwarcie katalogu z indeksem [cite: 130]
        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));

        // Sprawdzenie czy indeks istnieje
        if (!DirectoryReader.indexExists(directory)) {
            System.out.println("Brak indeksu w katalogu '" + INDEX_DIRECTORY + "'. Uruchom najpierw Index.java.");
            return;
        }

        IndexReader reader = DirectoryReader.open(directory);
        IndexSearcher searcher = new IndexSearcher(reader);

        // Musimy użyć tego samego analizatora co przy indeksowaniu [cite: 57]
        PolishAnalyzer analyzer = new PolishAnalyzer();

        // Przykładowe zapytanie: wszystkie dokumenty (*:*)
        String querystr = "*:*";
        Query q = new QueryParser("title", analyzer).parse(querystr);

        System.out.println("Wyszukiwanie dla zapytania: " + querystr);

        int maxHits = 10;
        TopDocs docs = searcher.search(q, maxHits);
        ScoreDoc[] hits = docs.scoreDocs;

        System.out.println("Znaleziono dokumentów: " + hits.length);

        for(int i=0; i<hits.length; ++i) {
            int docId = hits[i].doc;
            Document d = searcher.storedFields().document(docId);
            System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
        }

        reader.close();
        directory.close();
    }
}