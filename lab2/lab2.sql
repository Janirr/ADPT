-- zad 1
CREATE TABLE MOVIES AS
SELECT * FROM ztpd.movies;
/
-- zad 2
DESC movies;
/
-- Name      Null?    Type           
--------- -------- -------------- 
--ID        NOT NULL NUMBER(12)     
--TITLE     NOT NULL VARCHAR2(400)  
--CATEGORY           VARCHAR2(50)   
--YEAR               CHAR(4)        
--CAST               VARCHAR2(4000) 
--DIRECTOR           VARCHAR2(4000) 
--STORY              VARCHAR2(4000) 
--PRICE              NUMBER(5,2)    
--COVER              BLOB           
--MIME_TYPE          VARCHAR2(50)
-- zad 3
SELECT ID, TITLE FROM movies WHERE Cover IS NULL;
/
-- zad 4
SELECT 
    ID, 
    TITLE, 
    DBMS_LOB.GETLENGTH(cover) AS FILESIZE
FROM movies 
WHERE Cover IS NOT NULL;
/
-- zad 5
SELECT 
    ID, 
    TITLE, 
    DBMS_LOB.GETLENGTH(cover) AS FILESIZE
FROM movies 
WHERE Cover IS NULL;
/
-- zad 6
SELECT directory_name, directory_path
FROM all_directories
WHERE directory_name = 'TPD_DIR';
/
-- zad 7
UPDATE movies
SET cover = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
WHERE id = 66;
commit;
/
-- zad 8
SELECT 
    ID, 
    TITLE, 
    DBMS_LOB.GETLENGTH(cover) AS FILESIZE
FROM movies 
WHERE ID IN (65,66);
/
-- zad 9
DECLARE
    -- 1) Zmienne dla pliku i obiektu BLOB
    v_bfile  BFILE;  
    v_blob   BLOB;
BEGIN
    -- Powiązanie zmiennej BFILE z plikiem 'escape.jpg' w katalogu TPD_DIR
    v_bfile := BFILENAME('TPD_DIR', 'escape.jpg');

    -- 2) Odczyt pustego obiektu BLOB z tabeli MOVIES z blokadą do modyfikacji
    SELECT cover
    INTO v_blob
    FROM movies
    WHERE id = 66
    FOR UPDATE;  -- konieczne, by móc zapisać do LOB-a

    -- 3) Skopiowanie danych binarnych z pliku (BFILE → BLOB)
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);  -- otwarcie pliku
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));  -- kopiowanie
    DBMS_LOB.FILECLOSE(v_bfile);  -- zamknięcie pliku

    -- 4) Zatwierdzenie zmian
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/
-- zad 10
CREATE TABLE temp_covers (
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);
/
-- zad 11
INSERT INTO temp_covers (movie_id, image, mime_type)
VALUES (
    65, 
    BFILENAME('TPD_DIR', 'eagles.jpg'),  -- powiązanie z plikiem w katalogu serwera
    'image/jpeg'
);

COMMIT;
-- zad 12
SELECT movie_id,
       DBMS_LOB.GETLENGTH(image) AS filesize
FROM temp_covers;
/
-- zad 13
DECLARE
    BL BLOB;
    IMG_FILE BFILE;
    MIME VARCHAR2(100);
BEGIN
    SELECT IMAGE INTO IMG_FILE
    FROM TEMP_COVERS
    WHERE MOVIE_ID = 65;
    
    SELECT MIME_TYPE INTO MIME
    FROM TEMP_COVERS
    WHERE MOVIE_ID = 65;
    
    DBMS_LOB.CREATETEMPORARY(BL, TRUE);
    
    DBMS_LOB.FILEOPEN(IMG_FILE, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(BL, IMG_FILE, DBMS_LOB.GETLENGTH(IMG_FILE));
    DBMS_LOB.FILECLOSE(IMG_FILE);
    
    UPDATE MOVIES
    SET COVER = BL, MIME_TYPE = MIME
    WHERE ID = 65;
    
    DBMS_LOB.FREETEMPORARY(BL);
    
    COMMIT;
END;
/
-- zad 14
SELECT id AS movie_id,
       DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id IN (65, 66);
/
-- zad 15
DROP TABLE movies;
