--1. Cate comenzi a plasat farmacia Dona in August - suma totala, valoarea medie per comanda.

--am creat un view unde am pus toate comenzile facute de farmacia dona in luna august
CREATE VIEW COMENZI_DONA AS SELECT * FROM
(SELECT  comenzi.id_comanda, depozit.nume_produs, farmacii.nume_farmacie , depozit.pret, comenzi.cantitate, EXTRACT(MONTH FROM comenzi.data_comenzii) luna 
 FROM comenzi, farmacii, depozit 
 WHERE farmacii.nume_farmacie = 'Dona' AND farmacii.id_farmacie = comenzi.id_farmacie AND comenzi.id_produs = depozit.id_produs 
 AND comenzi.data_comenzii>='01-AUG-21' AND comenzi.data_comenzii<='31-AUG-21');

--apoi am creat un alt view pentru a calcula si retina atata numarul de comenzi din view-ul comenzi_dona, cat si suma totala a acestora, pentru a putea apoi afisa valoarea medie per comanda
CREATE VIEW NUMAR_COMENZI AS SELECT * FROM
(SELECT  COUNT(id_comanda) AS nr_comenzi, SUM(pret * cantitate) AS suma_totala FROM comenzi_dona);

SELECT nume_farmacie, luna, nr_comenzi, suma_totala, suma_totala/nr_comenzi AS valoare_medie FROM comenzi_dona, numar_comenzi GROUP BY nume_farmacie, luna, nr_comenzi, suma_totala ;




--2. Cate comenzi de antibiotice a plasat farmacia Vlad in 2021.

--am creat un view unde am pus toate comenzile de antibiotice facute de catre farmacie vlad in anul 2021
CREATE VIEW COMENZI_VLAD AS SELECT * FROM
(SELECT  comenzi.id_comanda, depozit.nume_produs, farmacii.nume_farmacie , categorii.denumire_categorie, EXTRACT(YEAR FROM comenzi.data_comenzii) an 
 FROM comenzi, farmacii, depozit, categorii
 WHERE farmacii.nume_farmacie = 'Vlad' AND categorii.denumire_categorie = 'antibiotice' AND comenzi.id_produs=depozit.id_produs 
 AND depozit.id_categorie=categorii.id_categorie AND comenzi.id_farmacie = farmacii.id_farmacie); 

SELECT nume_farmacie, denumire_categorie, an, COUNT(id_comanda) as nr_comenzi FROM comenzi_vlad WHERE an = 2021 GROUP BY nume_farmacie, denumire_categorie, an;




--3. Care e farmacia care a comandat cel mai mult in 2021 , ca valoare absoluta .

--am creat un view unde am pus toate comenzile din anul 2021
CREATE VIEW COMENZI_2021 AS SELECT * FROM
(SELECT  comenzi.id_comanda, farmacii.nume_farmacie , depozit.pret, comenzi.cantitate, EXTRACT(YEAR FROM comenzi.data_comenzii) AN 
 FROM comenzi, farmacii, depozit WHERE farmacii.id_farmacie = comenzi.id_farmacie AND  comenzi.id_produs = depozit.id_produs);

--apoi am creat un alt view unde am stocat numarul de comenzi din view-ul comenzi_2021 si suma toatala pentru fiecare dintre cele 3 farmacii
CREATE VIEW TOTAL_COMENZI AS SELECT * FROM
(SELECT nume_farmacie, an, COUNT(id_comanda) AS nr_comenzi, SUM(pret * cantitate) AS suma_totala FROM comenzi_2021 WHERE an=2021 GROUP BY nume_farmacie, an);

--apoi, in ultimul view, am calculat care dintre sumele stocate in view-ul total_comenzi este cea maxima, pentru a putea ca mai apoi sa o afisez
CREATE VIEW COMANDA_MAXIMA AS SELECT * FROM
(SELECT MAX(suma_totala) AS total_maxim FROM total_comenzi);

SELECT total_comenzi.nume_farmacie, an, comanda_maxima.total_maxim FROM total_comenzi, comanda_maxima WHERE total_comenzi.suma_totala = comanda_maxima.total_maxim;




--4. Pentru fiecare produs cat s-a comandat de catre fiecare client.

--implementare MySQL
SELECT depozit.id_produs, depozit.nume_produs, COUNT(comenzi.id_comanda) AS nr_comenzi, SUM(comenzi.cantitate) AS CANTITATE, farmacii.id_farmacie, farmacii.nume_farmacie  FROM comenzi, depozit, farmacii 
WHERE comenzi.id_produs(+)=depozit.id_produs AND comenzi.id_farmacie(+)=farmacii.id_farmacie GROUP BY  depozit.id_produs, depozit.nume_produs, farmacii.id_farmacie, farmacii.nume_farmacie ORDER BY depozit.id_produs;

--implementare PL/SQL
CREATE OR REPLACE PROCEDURE NR_COMENZI IS
BEGIN

DECLARE
    ID_PRODUS1  NUMBER;
    ID_FARMACIE1 NUMBER;
    ID_COMANDA1 NUMBER;
    CANTITATE1 NUMBER;
    COUNT1 NUMBER;   --va retine numarul de comenzi pentru un produs de la o anumita farmacie
    COUNT2 NUMBER;   --va retine numarul total de comenzi pentru un produs

--pentru fiecare produs am verificat de cate ori a fost comandat de catre fiecare farmacie si in ce cantitate
BEGIN
    FOR i IN (SELECT DISTINCT id_produs INTO id_produs1 FROM comenzi ORDER BY id_produs) LOOP            
        count2 := 0;
        FOR j IN (SELECT DISTINCT id_farmacie INTO id_farmacie1 FROM comenzi ) LOOP
            count1 := 0;
            FOR k IN (SELECT id_comanda, sum(cantitate) as cant INTO id_comanda1, cantitate1 FROM comenzi 
            WHERE id_produs=i.id_produs AND id_farmacie=j.id_farmacie GROUP BY id_comanda, id_produs, id_farmacie) LOOP
                count1 := count1+1;     
                count2 := count2+1;
                DBMS_OUTPUT.PUT_LINE('Cantitatea produsului ' || i.id_produs || ' comandata de farmacia ' || j.id_farmacie || ' este '  || k.cant);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Numarul de comenzi ale produsului ' || i.id_produs || ' de la farmacia ' || j.id_farmacie || ' este '  || count1);
            
         END LOOP;
         DBMS_OUTPUT.PUT_LINE('Numarul total de comenzi ale produsului ' || i.id_produs ||  ' este '  || count2);
    END LOOP;   
END; 

END NR_COMENZI;
/
    
BEGIN
    NR_COMENZI(); 
END;


