1.

Select YEAR(Z.Data_Zamowienia) AS Year, MONTH(z.Data_Zamowienia) AS Month, COUNT(*) AS Quantity_Of_Orders
From Zamowienia AS Z 
Group by YEAR(Z.Data_Zamowienia), MONTH(z.Data_zamowienia)
Order by Month, Year
