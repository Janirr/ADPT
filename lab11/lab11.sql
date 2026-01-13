// 1.
CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;

// 2.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE LOWER(TEKST) LIKE '%optymista%'
AND LOWER(TEKST) LIKE '%pesymista%';

// 3.
CREATE INDEX cytaty_idx ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

// 4.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'optymista AND pesymista') > 0;

// 5.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista NOT optymista') > 0;

// 6.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((optymista, pesymista), 3)') > 0;

// 7.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((optymista, pesymista), 10)') > 0;

// 8.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0;

// 9.
SELECT AUTOR, TEKST, SCORE(1) as DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

// 10.
SELECT AUTOR, TEKST, SCORE(1) as DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0
ORDER BY SCORE(1) DESC
FETCH FIRST 1 ROWS ONLY;

// 11.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, '?probelm') > 0;

// 12.
INSERT INTO CYTATY VALUES (
    (SELECT MAX(ID)+1 FROM CYTATY),
    'Bertrand Russell', 
    'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);
COMMIT;

// 13.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy') > 0;
// Zapytanie nie zwróci nowego wiersza. Wyjaśnienie: Indeksy Oracle Text domyślnie nie są aktualizowane automatycznie po operacjach DML (INSERT/UPDATE). Nowe dane nie są widoczne w indeksie do momentu synchronizacji.

// 14.
--SELECT token_text, token_count 
--FROM DR$CYTATY_IDX$I 
--WHERE token_text = 'GŁUPCY';
--SELECT * FROM DR$CYTATY_IDX$I WHERE ROWNUM <= 10;
SELECT TOKEN_TEXT FROM DR$CYTATY_IDX$I WHERE TOKEN_TEXT = 'GŁUPCY';

// 15.
BEGIN
  CTX_DDL.SYNC_INDEX('cytaty_idx');
END;
/

// 16.
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy') > 0;

// 17.
DROP INDEX cytaty_idx;
DROP TABLE CYTATY;

// Zaawansowane indeksowanie i wyszukiwanie
// 1.
CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

// 2.
CREATE INDEX quotes_idx ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT;

// 3.
-- a) szukanie dokładne 'work'
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'work', 1) > 0;

-- b) szukanie rdzenia $work (znajdzie work, working, works itp.)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$work', 2) > 0;

-- c) szukanie dokładne 'working'
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working', 3) > 0;

-- d) szukanie rdzenia $working (sprowadzi do 'work' i znajdzie jego odmiany)
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working', 4) > 0;

// 4.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it', 1) > 0;
// Słowo 'it' znajduje się na domyślnej liście słów wyłączonych (Stop List) dla języka angielskiego, więc nie zostało zaindeksowane.

// 5.
SELECT * FROM CTX_STOPLISTS;

// 6.
SELECT * FROM CTX_STOPWORDS 
WHERE SPW_STOPLIST = 'DEFAULT_STOPLIST';

// 7.
DROP INDEX quotes_idx;

CREATE INDEX quotes_idx ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('STOPLIST CTXSYS.EMPTY_STOPLIST');

// 8.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it', 1) > 0;
// Tak

// 9.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND humans', 1) > 0;

// 10.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

// 11.
SELECT * FROM QUOTES 
WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE', 1) > 0;
// Błąd (ORA-20000: Oracle Text error: DRG-10837: sekcja SENTENCE nie istnieje). Interpretacja: Domyślny indeks (NULL_SECTION_GROUP bez dodatkowych ustawień) nie posiada zdefiniowanych granic zdań ani akapitów. Należy je dodać ręcznie do grupy sekcji.

// 12.
DROP INDEX quotes_idx;

// 13.
BEGIN
    CTX_DDL.CREATE_SECTION_GROUP('nowa_grupa', 'NULL_SECTION_GROUP');
    CTX_DDL.ADD_SPECIAL_SECTION('nowa_grupa', 'SENTENCE');
    CTX_DDL.ADD_SPECIAL_SECTION('nowa_grupa', 'PARAGRAPH');
END;
/

// 14.
CREATE INDEX quotes_idx ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('STOPLIST CTXSYS.EMPTY_STOPLIST SECTION GROUP nowa_grupa');

// 15.
-- Szukanie 'fool' i 'humans' w jednym zdaniu
SELECT * FROM QUOTES 
WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE', 1) > 0;

-- Szukanie 'fool' i 'computer' w jednym zdaniu
SELECT * FROM QUOTES 
WHERE CONTAINS(TEXT, '(fool AND computer) WITHIN SENTENCE', 1) > 0;

// 16.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans', 1) > 0;
// Tak. Domyślny lekser traktuje myślnik (-) jako separator (break character), a nie część słowa. Dlatego 'non-humans' jest widoczne dla indeksu jako dwa osobne tokeny: 'non' oraz 'humans'.

// 17.
DROP INDEX quotes_idx;

BEGIN
    CTX_DDL.CREATE_PREFERENCE('moj_lexer', 'BASIC_LEXER');
    CTX_DDL.SET_ATTRIBUTE('moj_lexer', 'printjoins', '-');
END;
/

CREATE INDEX quotes_idx ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('STOPLIST CTXSYS.EMPTY_STOPLIST SECTION GROUP nowa_grupa LEXER moj_lexer');

// 18.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans', 1) > 0;

// 19.
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'non\-humans', 1) > 0;

// 20.
DROP TABLE QUOTES;
BEGIN
    CTX_DDL.DROP_PREFERENCE('moj_lexer');
    CTX_DDL.DROP_SECTION_GROUP('nowa_grupa');
END;
/