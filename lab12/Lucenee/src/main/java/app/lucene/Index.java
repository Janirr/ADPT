package app.lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;


/**
 * 1. Po poprawnym wykonaniu operacji indeksowania, w katalogu index_dir powstały pliki binarne stanowiące strukturę indeksu Lucene.
 * Zaobserwowano pliki takie jak _0.cfe, _0.cfs oraz _0.si, które reprezentują tzw. segmenty indeksu.
 * Dodatkowo widoczny jest plik segments_N, który przechowuje metadane dotyczące aktualnego stanu i wersji indeksu.
 * 2. Ponowne uruchomienie programu Index.java (bez wcześniejszego usunięcia zawartości katalogu) spowodowało, że
 * program Search.java dodał nowe wyniki oraz segments_1 zostało podmienione na segments_2.
 * Każdy z dokumentów .cfe, .cfs, .si pojawił się w wynikach wyszukiwania dwukrotnie.
 * _0.cfe
 * _0.cfs
 * _0.si
 * _1.cfe
 * _1.cfs
 * _1.si
 * segments_2
 * write.lock
 */
public class Index {
    // Ścieżka, gdzie zostanie utworzony folder z indeksem
    private static final String INDEX_DIRECTORY = "index_dir";

    public static void main(String[] args) throws IOException {
        // Używamy analizatora polskiego
        PolishAnalyzer analyzer = new PolishAnalyzer();

        // Konfiguracja zapisu na dysku
        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));
        IndexWriterConfig config = new IndexWriterConfig(analyzer);

        // Utworzenie writera
        IndexWriter w = new IndexWriter(directory, config);

        // Dodawanie dokumentów (te same co w kroku 11)
        System.out.println("Rozpoczynam indeksowanie...");

        w.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
        w.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
        w.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
        w.addDocument(buildDoc("Naturalnie urodzeni mordercy", "9780316485616"));
        w.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
        w.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));

        // Zamknięcie writera zapisuje zmiany na dysku
        w.close();
        directory.close();

        System.out.println("Indeksowanie zakończone. Pliki zapisano w folderze: " + INDEX_DIRECTORY);
    }

    // Metoda pomocnicza
    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }
}