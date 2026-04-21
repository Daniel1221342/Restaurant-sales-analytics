/*
=====================================================
03_analysis.sql
=====================================================
*/

-----------------------------------------------------
-- 1. Monthly orders trend (Year, Month, OrdersCount)
-----------------------------------------------------
SELECT YEAR(z.Data_Zamowienia)  AS Year, MONTH(z.Data_Zamowienia) AS Month, COUNT(*) AS OrdersCount
FROM Zamowienia AS z
GROUP BY YEAR(z.Data_Zamowienia), MONTH(z.Data_Zamowienia)
ORDER BY Year, Month;


-----------------------------------------------------
-- 2. Top 5 restaurants by number of orders
-----------------------------------------------------
SELECT TOP (5) r.ID_Restauracji, r.Nazwa AS RestaurantName,
    COUNT(*) AS OrdersCount
FROM Zamowienia AS z
JOIN Restauracje AS r ON r.ID_Restauracji = z.ID_Restauracji
GROUP BY r.ID_Restauracji, r.Nazwa
ORDER BY OrdersCount DESC, r.Nazwa;

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
Select TOP (10) p.ID_Produktu, p.Nazwa AS ProductName, SUM(sz.Ilosc) AS TotalQuantity
From Szczegoly_Zamowienia sz
JOIN Produkty p ON p.ID_Produktu = sz.ID_Produktu
Group by p.ID_Produktu, p.Nazwa
Order by TotalQuantity DESC, p.Nazwa;

-----------------------------------------------------
-- 5. Top 10 suppliers by number of orders
-----------------------------------------------------
Select TOP(10) d.Nazwa,d.ID_Dostawcy, count(*) as OrdersCount
From Zamowienia as z Join Dostawcy as d ON z.ID_Dostawcy=d.ID_Dostawcy
Group by d.Nazwa, d.ID_Dostawcy
Order by OrdersCount DESC,d.Nazwa
    
-----------------------------------------------------
-- 6. Monthly orders trend by status
-----------------------------------------------------
Select Year(Data_Zamowienia) AS Year_, MONTH(Data_Zamowienia) AS Month_,Z.Status,COUNT(*) AS OrdersCount
From Zamowienia as Z 
Group by Year(Data_Zamowienia),MONTH(Data_Zamowienia),Z.Status
Order by Year_,Month_,Status
    
-----------------------------------------------------
-- 7. Top 10 products: total quantity + orders with product
-----------------------------------------------------
Select TOP (10) P.ID_Produktu,P.Nazwa, SUM(SZ.Ilosc) AS TotalQuantity,COUNT(DISTINCT SZ.ID_Zamowienia) AS OrdersWithProduct
From Szczegoly_Zamowienia as SZ Join Produkty as P On SZ.ID_Produktu=P.ID_Produktu
Group by P.ID_Produktu,P.Nazwa
Order by TotalQuantity DESC, OrdersWithProduct DESC, P.Nazwa
