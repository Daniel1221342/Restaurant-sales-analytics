/* ============================================================
   02_generate_random_data.sql
   Date range: last ~3 years
   ============================================================ */

-----------------------------------------------------
-- 0) OPTIONAL: Disable triggers that block seeding
-----------------------------------------------------
IF OBJECT_ID('trg_BezStarychZam', 'TR') IS NOT NULL
    DISABLE TRIGGER trg_BezStarychZam ON Zamowienia;

IF OBJECT_ID('trg_SprawdzanieDaty', 'TR') IS NOT NULL
    DISABLE TRIGGER trg_SprawdzanieDaty ON Dostawy;

-----------------------------------------------------
-- 1) CLEANUP (delete in FK order)
-----------------------------------------------------
DELETE FROM Dostawy;
DELETE FROM Szczegoly_Zamowienia;
DELETE FROM Zamowienia;

-----------------------------------------------------
-- 2) PARAMETERS
-----------------------------------------------------
DECLARE @OrdersCount INT = 10000;
DECLARE @EndDate    date = CAST(GETDATE() AS date);
DECLARE @StartDate  date = DATEADD(YEAR, -3, @EndDate);
DECLARE @RangeDays  int  = DATEDIFF(DAY, @StartDate, @EndDate) + 1;

-----------------------------------------------------
-- 3) PREP: map Restauracje and Dostawcy to row numbers
-----------------------------------------------------
;WITH R AS (
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
),
Numbers AS (
    SELECT TOP (@OrdersCount)
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
        WHEN x.DataZamowienia < DATEADD(DAY, -30, @EndDate) THEN 'Zrealizowane'
        WHEN x.DataZamowienia < DATEADD(DAY, -7,  @EndDate) THEN 'W realizacji'
        ELSE 'Nowe'
    END AS Status
FROM Numbers n
CROSS APPLY (
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
-- 4) ORDER DETAILS: 1–5 products per order
-----------------------------------------------------
;WITH OrderProducts AS (
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
-- 5) DELIVERIES: only for completed orders (Zrealizowane)
--    Delivery date = order date + 1..7 days
-----------------------------------------------------
INSERT INTO Dostawy (ID_Zamowienia, Data_Dostawy)
SELECT
    z.ID_Zamowienia,
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 7) + 1, z.Data_Zamowienia) AS Data_Dostawy
FROM Zamowienia z
WHERE z.Status = 'Zrealizowane'
  AND NOT EXISTS (
      SELECT 1 FROM Dostawy d WHERE d.ID_Zamowienia = z.ID_Zamowienia
  );

-----------------------------------------------------
-- 6) RE-ENABLE TRIGGERS
-----------------------------------------------------
IF OBJECT_ID('trg_BezStarychZam', 'TR') IS NOT NULL
    ENABLE TRIGGER trg_BezStarychZam ON Zamowienia;

IF OBJECT_ID('trg_SprawdzanieDaty', 'TR') IS NOT NULL
    ENABLE TRIGGER trg_SprawdzanieDaty ON Dostawy;

-----------------------------------------------------
-- 7) QUICK VALIDATION (optional)
-----------------------------------------------------
SELECT COUNT(*) AS OrdersInserted FROM Zamowienia;
SELECT COUNT(*) AS DetailsInserted FROM Szczegoly_Zamowienia;
SELECT COUNT(*) AS DeliveriesInserted FROM Dostawy;

SELECT MIN(Data_Zamowienia) AS MinOrderDate, MAX(Data_Zamowienia) AS MaxOrderDate
FROM Zamowienia;
