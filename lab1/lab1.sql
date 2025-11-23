-- Zad 1
CREATE OR REPLACE TYPE Samochod AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);


CREATE TABLE samochody OF Samochod;

INSERT INTO samochody VALUES (Samochod('fiat','brava',60000,DATE '1999-11-30',25000));
INSERT INTO samochody VALUES (Samochod('ford','mondeo',80000,DATE '1997-05-10',45000));
INSERT INTO samochody VALUES (Samochod('mazda','323',12000,DATE '2000-09-22',52000));

-- Zad 2
CREATE OR REPLACE TYPE Wlasciciel AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto Samochod
);
/

CREATE TABLE wlasciciele OF Wlasciciel;

INSERT INTO wlasciciele VALUES (Wlasciciel('Jan','Kowalski',Samochod('fiat','seicento',30000,DATE '2010-12-02',19500)));
INSERT INTO wlasciciele VALUES (Wlasciciel('Adam','Nowak',Samochod('opel','astra',34000,DATE '2009-06-01',33700)));

-- Zad 3
ALTER TYPE Samochod ADD MEMBER FUNCTION wartosc RETURN NUMBER;

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN ROUND(cena * POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produ)),2);
    END wartosc;
END;
/

-- Zad 4
ALTER TYPE Samochod ADD MAP MEMBER FUNCTION odwzoruj RETURN NUMBER CASCADE INCLUDING TABLE DATA;
/

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN ROUND(cena * POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produ)),2);
    END wartosc;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN ROUND(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produ) + (kilometry/10000),2);
    END odwzoruj;
END;
/

-- Zad 5
CREATE OR REPLACE TYPE Wlasciciel2 AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);
/

CREATE TABLE wlasciciele2 OF Wlasciciel2;

INSERT INTO wlasciciele2 VALUES (Wlasciciel2('Jan','Kowalski'));

CREATE OR REPLACE TYPE Samochod2 AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produ DATE,
    cena NUMBER(10,2),
    wlasciciel REF Wlasciciel2
);
/

CREATE TABLE samochody2 OF Samochod2;

INSERT INTO samochody2 VALUES (Samochod2('ford','mondeo',80000,DATE '1997-05-10',45000,NULL));
INSERT INTO samochody2 VALUES (Samochod2('mazda','323',12000,DATE '2000-09-22',52000,NULL));
INSERT INTO samochody2 VALUES (Samochod2('fiat','brava',60000,DATE '1999-11-30',25000,NULL));

UPDATE samochody2 s
SET s.wlasciciel = (SELECT REF(w) FROM wlasciciele2 w WHERE w.imie='Jan');
-- Zad 6
SET SERVEROUTPUT ON SIZE 30000;

DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;
/

-- Zad 7
DECLARE
    TYPE t_ksiazki IS VARRAY(5) OF VARCHAR2(50);
    moje_ksiazki t_ksiazki := t_ksiazki('title');
BEGIN
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Count: ' || moje_ksiazki.COUNT());

    moje_ksiazki.EXTEND(4);
    moje_ksiazki(2) := 'Podstawy Techniki Cyfrowej';
    FOR i IN 3..5 LOOP
        moje_ksiazki(i) := 'Book_' || i;
    END LOOP;

    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Count: ' || moje_ksiazki.COUNT());

    moje_ksiazki.TRIM(1);
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Count: ' || moje_ksiazki.COUNT());
END;
/

-- Zad 8
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);

    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;

    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.TRIM(2);

    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;

    moi_wykladowcy.DELETE(5,7);

    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;

    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';

    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Count: ' || moi_wykladowcy.COUNT());
END;
/

-- Zad 9
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.EXTEND(12);
    moje_miesiace(1) := 'styczen';
    moje_miesiace(2) := 'luty';
    moje_miesiace(3) := 'marzec';
    moje_miesiace(4) := 'kwiecien';
    moje_miesiace(5) := 'maj';
    moje_miesiace(6) := 'czerwiec';
    
    FOR i IN 7..12 LOOP
        moje_miesiace(i) := 'Miesiac_' || i;
    END LOOP;

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END IF;
    END LOOP;

    moje_miesiace.DELETE(7,12);
    moje_miesiace(7) := 'lipiec';

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
        IF moje_miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END IF;
    END LOOP;
END;
/
-- Zad 10
CREATE OR REPLACE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/

CREATE OR REPLACE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj VARCHAR2(30),
    jezyki jezyki_obce
);
/

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES ('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES ('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
COMMIT;

UPDATE stypendia
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
COMMIT;

CREATE OR REPLACE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/

CREATE OR REPLACE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
/

CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES (semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES (semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
COMMIT;


INSERT INTO TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) VALUES('METODY NUMERYCZNE');

UPDATE TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) e
SET e.COLUMN_VALUE = 'SYSTEMY ROZPROSZONE'
WHERE e.COLUMN_VALUE = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE numer=2) e
WHERE e.COLUMN_VALUE = 'BAZY DANYCH';
COMMIT;

-- Zad 11
CREATE OR REPLACE TYPE koszyk_produktow AS TABLE OF VARCHAR2(20);
/

CREATE OR REPLACE TYPE zakup AS OBJECT (
    osoba VARCHAR2(50),
    produkty koszyk_produktow
);
/

CREATE TABLE zakupy OF zakup
NESTED TABLE produkty STORE AS tab_produkty;

INSERT INTO zakupy VALUES (zakup('Afimico Pululu', koszyk_produktow('pilka','celownik','buty')));
INSERT INTO zakupy VALUES (zakup('Jesus Imaz', koszyk_produktow('pilka','buty')));
INSERT INTO zakupy VALUES (zakup('Sergio Lozano', koszyk_produktow('pilka')));
COMMIT;

DELETE FROM zakupy 
WHERE osoba IN (
    SELECT osoba
    FROM zakupy z, TABLE(z.produkty) p
    WHERE p.COLUMN_VALUE='buty'
);
COMMIT;

-- Zad 12
CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/
DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;

-- Zad 13
CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;
DECLARE
 KrolLew lew := lew('LEW',4);
 InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
-- Zad 14
DECLARE
 tamburyn instrument;
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
 -- saksofon := instrument('saksofon','tra-taaaa');
 -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- Zad 15
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;