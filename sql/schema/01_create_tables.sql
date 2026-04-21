-- Tworzenie bazy danych oraz tabel:
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = N'Zaopatrzenie'
)
BEGIN
    EXEC('CREATE DATABASE Zaopatrzenie');
END;
GO

USE Zaopatrzenie;
GO

IF OBJECT_ID('Stany_Magazynowe', 'U') IS NOT NULL DROP TABLE Stany_Magazynowe;
IF OBJECT_ID('Dostawy', 'U') IS NOT NULL DROP TABLE Dostawy;
IF OBJECT_ID('Szczegoly_Zamowienia', 'U') IS NOT NULL DROP TABLE Szczegoly_Zamowienia;
IF OBJECT_ID('Zamowienia', 'U') IS NOT NULL DROP TABLE Zamowienia;
IF OBJECT_ID('Produkty', 'U') IS NOT NULL DROP TABLE Produkty;
IF OBJECT_ID('Dostawcy', 'U') IS NOT NULL DROP TABLE Dostawcy;
IF OBJECT_ID('Restauracje', 'U') IS NOT NULL DROP TABLE Restauracje;
GO

-- Tabela Restauracje
CREATE TABLE Restauracje (
    ID_Restauracji INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(100) NOT NULL CHECK (Nazwa NOT LIKE '%[0-9!@#$%^&*()]%'),
    Miasto NVARCHAR(100) NOT NULL CHECK (Miasto NOT LIKE '%[0-9!@#$%^&*()]%'),
    Adres NVARCHAR(255) NOT NULL
);
GO

-- Tabela Dostawcy
CREATE TABLE Dostawcy (
    ID_Dostawcy INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(100) NOT NULL CHECK (Nazwa NOT LIKE '%[0-9]%' AND Nazwa NOT LIKE '%[^a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ ]%'),
    Telefon NVARCHAR(20) NOT NULL CHECK (Telefon LIKE '+%' OR Telefon LIKE '%[0-9-]%'),
    Email NVARCHAR(100) NOT NULL UNIQUE CHECK (Email LIKE '%@%.%')
);
GO

-- Tabela Produkty
CREATE TABLE Produkty (
    ID_Produktu INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(100) NOT NULL,
    Jednostka_Miary NVARCHAR(20) NOT NULL CHECK (Jednostka_Miary IN ('kg', 'szt.', 'l')),
    Min_Poziom_Zapasow INT NOT NULL CHECK (Min_Poziom_Zapasow >= 0)
);
GO

-- Tabela Zamowienia
CREATE TABLE Zamowienia (
    ID_Zamowienia INT IDENTITY(1,1) PRIMARY KEY,
    ID_Restauracji INT NOT NULL,
    ID_Dostawcy INT NOT NULL,
    Data_Zamowienia DATE NOT NULL CHECK (Data_Zamowienia <= GETDATE()),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Nowe'
        CHECK (Status IN ('Nowe', 'W realizacji', 'Zrealizowane')),
    FOREIGN KEY (ID_Restauracji) REFERENCES Restauracje(ID_Restauracji),
    FOREIGN KEY (ID_Dostawcy) REFERENCES Dostawcy(ID_Dostawcy)
);
GO

-- Tabela Szczegoly_Zamowienia
CREATE TABLE Szczegoly_Zamowienia (
    ID_Szczegolu INT IDENTITY(1,1) PRIMARY KEY,
    ID_Zamowienia INT NOT NULL,
    ID_Produktu INT NOT NULL,
    Ilosc INT NOT NULL CHECK (Ilosc > 0),
    FOREIGN KEY (ID_Zamowienia) REFERENCES Zamowienia(ID_Zamowienia),
    FOREIGN KEY (ID_Produktu) REFERENCES Produkty(ID_Produktu)
);
GO

-- Tabela Dostawy
CREATE TABLE Dostawy (
    ID_Dostawy INT IDENTITY(1,1) PRIMARY KEY,
    ID_Zamowienia INT NOT NULL,
    Data_Dostawy DATE NOT NULL,
    FOREIGN KEY (ID_Zamowienia) REFERENCES Zamowienia(ID_Zamowienia)
);
GO

-- Tabela Stany_Magazynowe
CREATE TABLE Stany_Magazynowe (
    ID_Stanu INT IDENTITY(1,1) PRIMARY KEY,
    ID_Produktu INT NOT NULL,
    ID_Restauracji INT NOT NULL,
    Ilosc INT NOT NULL CHECK (Ilosc >= 0),
    FOREIGN KEY (ID_Produktu) REFERENCES Produkty(ID_Produktu),
    FOREIGN KEY (ID_Restauracji) REFERENCES Restauracje(ID_Restauracji),
    CONSTRAINT UQ_Stan UNIQUE (ID_Produktu, ID_Restauracji)
);
GO
