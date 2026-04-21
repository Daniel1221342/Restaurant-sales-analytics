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
    SELECT DATEADD(DAY,
                   ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, '2023-01-01', GETDATE()),
                   '2023-01-01') AS DataZamowienia
) x
CROSS APPLY (
    SELECT TOP 1 ID_Restauracji FROM Restauracje ORDER BY NEWID()
) r
CROSS APPLY (
    SELECT TOP 1 ID_Dostawcy FROM Dostawcy ORDER BY NEWID()
) d;
