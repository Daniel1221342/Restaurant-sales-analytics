-----------------------------------------------------
-- 1. GENERATE ORDERS (last ~3 years)
-----------------------------------------------------

DECLARE @OrdersCount INT = 10000;
DECLARE @StartDate  date = DATEADD(YEAR, -3, CAST(GETDATE() AS date));
DECLARE @EndDate    date = CAST(GETDATE() AS date);
DECLARE @RangeDays  int  = DATEDIFF(DAY, @StartDate, @EndDate) + 1;

;WITH Numbers AS (
    SELECT TOP (@OrdersCount)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
),
R AS (
    SELECT 
        ID_Restauracji,
        ROW_NUMBER() OVER (ORDER BY ID_Restauracji) AS rn,
        COUNT(*) OVER() AS total
    FROM Restauracje
),
D AS (
    SELECT 
        ID_Dostawcy,
        ROW_NUMBER() OVER (ORDER BY ID_Dostawcy) AS rn,
        COUNT(*) OVER() AS total
    FROM Dostawcy
)
INSERT INTO Zamowienia (ID_Restauracji, ID_Dostawcy, Data_Zamowienia, Status)
SELECT
    r.ID_Restauracji,
    d.ID_Dostawcy,
    x.DataZamowienia,
    CASE 
        WHEN x.DataZamowienia < DATEADD(DAY, -30, @EndDate) THEN 'Zrealizowane'
        WHEN x.DataZamowienia < DATEADD(DAY, -7,  @EndDate) THEN 'W realizacji'
        ELSE 'Nowe'
    END AS Status
FROM Numbers n
CROSS APPLY (
    -- seedy zależne od n.n => per wiersz, nie "raz na cały insert"
    SELECT
        ABS(CHECKSUM(n.n, NEWID()))        AS seed_r,
        ABS(CHECKSUM(n.n, NEWID(), 111))   AS seed_d,
        ABS(CHECKSUM(n.n, NEWID(), 222))   AS seed_date
) s
CROSS APPLY (
    SELECT DATEADD(DAY, (s.seed_date % @RangeDays), @StartDate) AS DataZamowienia
) x
JOIN R r ON r.rn = 1 + (s.seed_r % r.total)
JOIN D d ON d.rn = 1 + (s.seed_d % d.total);
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
