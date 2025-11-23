-- Zadanie A
CREATE TABLE FIGURY (
  ID NUMBER(1) PRIMARY KEY,
  KSZTALT MDSYS.SDO_GEOMETRY
);

-- Zadanie B
-- Kształt 1: Okrąg (Circle)
INSERT INTO FIGURY VALUES (
  1,
  MDSYS.SDO_GEOMETRY(
    2003, -- Typ 2D Polygon
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 4), -- Okrąg zdefiniowany przez 3 punkty
    MDSYS.SDO_ORDINATE_ARRAY(5,7, 7,5, 5,3) -- Punkty: Góra, Prawo, Dół
  )
);

-- Kształt 2: Kwadrat (Square)
INSERT INTO FIGURY VALUES (
  2,
  MDSYS.SDO_GEOMETRY(
    2003, -- Typ 2D Polygon
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 3), -- Prostokąt
    MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5) -- Lewy-dolny, Prawy-górny
  )
);

-- Kształt 3: Linia złożona (Compound Line String)
INSERT INTO FIGURY VALUES (
  3,
  MDSYS.SDO_GEOMETRY(
    2002, -- Typ 2D Line String
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 4, 2, 1, 2, 1, 3, 2, 2), -- Złożona: Linia prosta + Łuk
    MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,1, 6,0) -- Współrzędne: Prosta (3,2->6,2), Łuk (6,2->7,1->6,0)
  )
);

-- Zadanie C
-- Wstawienie kształtu o nieprawidłowej definicji (np. otwarty wielokąt)
INSERT INTO FIGURY VALUES (
  4,
  MDSYS.SDO_GEOMETRY(
    2003, -- Definiujemy jako wielokąt
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1),
    MDSYS.SDO_ORDINATE_ARRAY(10,10, 14,10, 14,14, 10,14) -- Brak domknięcia (brak punktu 10,10 na końcu)
  )
);

-- Zadanie D
SELECT ID, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) AS VALIDATION_RESULT
FROM FIGURY;

-- Zadanie E
DELETE FROM FIGURY
WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) <> 'TRUE';

-- Zadanie F
COMMIT;