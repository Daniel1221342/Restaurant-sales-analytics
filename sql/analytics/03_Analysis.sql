/*
=====================================================
03_analysis.sql
=====================================================
*/

-----------------------------------------------------
-- 1. Monthly orders trend (Year, Month, OrdersCount)
-----------------------------------------------------
SELECT
    YEAR(z.Data_Zamowienia)  AS Year,
    MONTH(z.Data_Zamowienia) AS Month,
    COUNT(*)                AS OrdersCount
FROM Zamowienia AS z
GROUP BY
    YEAR(z.Data_Zamowienia),
    MONTH(z.Data_Zamowienia)
ORDER BY
    Year,
    Month;


-----------------------------------------------------
-- 2. Top 5 restaurants by number of orders
-----------------------------------------------------
SELECT TOP (5)
    r.ID_Restauracji,
    r.Nazwa AS RestaurantName,
    COUNT(*) AS OrdersCount
FROM Zamowienia AS z
JOIN Restauracje AS r
    ON r.ID_Restauracji = z.ID_Restauracji
GROUP BY
    r.ID_Restauracji,
    r.Nazwa
ORDER BY
    OrdersCount DESC,
    r.Nazwa;
-----------------------------------------------------
-- 3. Order status distribution
-----------------------------------------------------
Select z.Status, Count(*) OrdersCount
From Zamowienia AS Z
Group by z.Status
Order by OrdersCount DESC;
-----------------------------------------------------
-- 4. 
-----------------------------------------------------
