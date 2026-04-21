-----------------------------------------------------
-- 1. GENERATE ORDERS (2023–present)
-----------------------------------------------------

WITH Numbers AS (
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO Zamowienia (ID_Restauracji, ID_Dostawcy, Data_Zamowienia, Status)
SELECT
    r.ID_Restauracji,
    d.ID_Dostawcy,
    x.DataZamowienia,
    CASE 
        WHEN x.DataZamowienia < DATEADD(DAY, -30, GETDATE()) THEN 'Zrealizowane'
        WHEN x.DataZamowienia < DATEADD(DAY, -7, GETDATE()) THEN 'W realizacji'
        ELSE 'Nowe'
    END
FROM Numbers
CROSS APPLY (
    SELECT DATEADD(
               DAY,
               ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, '2023-01-01', GETDATE()),
               '2023-01-01'
           ) AS DataZamowienia
) x
CROSS APPLY (
    SELECT TOP 1 ID_Restauracji FROM Restauracje ORDER BY NEWID()
) r
CROSS APPLY (
    SELECT TOP 1 ID_Dostawcy FROM Dostawcy ORDER BY NEWID()
) d;

-----------------------------------------------------
-- 2. GENERATE ORDER DETAILS (1–5 products per order)
-----------------------------------------------------

WITH OrderProducts AS (
    SELECT 
        z.ID_Zamowienia,
        p.ID_Produktu,
        ROW_NUMBER() OVER (PARTITION BY z.ID_Zamowienia ORDER BY NEWID()) AS rn,
        ABS(CHECKSUM(NEWID())) % 5 + 1 AS LiczbaProduktow
    FROM Zamowienia z
    CROSS JOIN Produkty p
)
INSERT INTO Szczegoly_Zamowienia (ID_Zamowienia, ID_Produktu, Ilosc)
SELECT 
    ID_Zamowienia,
    ID_Produktu,
    ABS(CHECKSUM(NEWID())) % 20 + 1
FROM OrderProducts
WHERE rn <= LiczbaProduktow;

-----------------------------------------------------
-- 3. BASIC VALIDATION
-----------------------------------------------------

SELECT COUNT(*) AS OrdersCount FROM Zamowienia;
SELECT COUNT(*) AS OrderDetailsCount FROM Szczegoly_Zamowienia;
