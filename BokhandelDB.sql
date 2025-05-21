---------------------------------------------
-- Skapa tabeller
---------------------------------------------

-- Tabell: Författare
CREATE TABLE Författare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Födelsedatum DATE NOT NULL
);
GO

-- Tabell: Förlag
CREATE TABLE Förlag (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(100) NOT NULL,
    Adress NVARCHAR(200) NULL,
    Stad NVARCHAR(50) NULL,
    Postnummer NVARCHAR(20) NULL
);
GO

-- Tabell: Böcker
CREATE TABLE Böcker (
    ISBN13 CHAR(13) PRIMARY KEY CHECK (LEN(ISBN13) = 13),
    Titel NVARCHAR(200) NOT NULL,
    Språk NVARCHAR(50) NOT NULL,
    Pris DECIMAL(10,2) NOT NULL,
    Utgivningsdatum DATE NOT NULL,
    Sidor INT NULL,
    FörlagID INT NULL,
    CONSTRAINT FK_Böcker_Förlag FOREIGN KEY (FörlagID) REFERENCES Förlag(ID)
);
GO

-- Junction-tabell: BokFörfattare (för many-to-many relation mellan Böcker & Författare)
CREATE TABLE BokFörfattare (
    BokISBN13 CHAR(13) NOT NULL,
    FörfattareID INT NOT NULL,
    PRIMARY KEY (BokISBN13, FörfattareID),
    CONSTRAINT FK_BokFörfattare_Böcker FOREIGN KEY (BokISBN13) REFERENCES Böcker(ISBN13),
    CONSTRAINT FK_BokFörfattare_Författare FOREIGN KEY (FörfattareID) REFERENCES Författare(ID)
);
GO

-- Tabell: Butiker
CREATE TABLE Butiker (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Butiksnamn NVARCHAR(100) NOT NULL,
    Adress NVARCHAR(200) NOT NULL,
    Stad NVARCHAR(50) NOT NULL,
    Postnummer NVARCHAR(20) NOT NULL
);
GO

-- Tabell: LagerSaldo (lagersaldo per bok per butik)
CREATE TABLE LagerSaldo (
    ButikID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL CHECK (Antal >= 0),
    PRIMARY KEY (ButikID, ISBN13),
    CONSTRAINT FK_LagerSaldo_Butiker FOREIGN KEY (ButikID) REFERENCES Butiker(ID),
    CONSTRAINT FK_LagerSaldo_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13)
);
GO

-- Tabell: Kunder
CREATE TABLE Kunder (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Telefonnummer NVARCHAR(20),
    Adress NVARCHAR(200)
);
GO

-- Tabell: Ordrar
CREATE TABLE Ordrar (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    KundID INT NOT NULL,
    OrderDatum DATETIME NOT NULL DEFAULT GETDATE(),
    TotalBelopp DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Ordrar_Kunder FOREIGN KEY (KundID) REFERENCES Kunder(ID)
);
GO

-- Tabell: Orderrader 
CREATE TABLE Orderrader (
    OrderID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Antal INT NOT NULL CHECK (Antal > 0),
    PrisAtSale DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ISBN13),
    CONSTRAINT FK_Orderrader_Ordrar FOREIGN KEY (OrderID) REFERENCES Ordrar(OrderID),
    CONSTRAINT FK_Orderrader_Böcker FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13)
);
GO

---------------------------------------------
-- Populera databasen med testdata
---------------------------------------------

-- Författare
INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum) VALUES
('Emma', 'Askling', '1982-05-12'),
('Oskar', 'Lundberg', '1975-08-23'),
('Sara', 'Nilsson', '1990-10-05'),
('Lars', 'Berg', '1965-03-18');
GO

-- Förlag
INSERT INTO Förlag (Namn, Adress, Stad, Postnummer) VALUES
('Bokförlaget AB', 'Storgatan 1', 'Stockholm', '11122'),
('Lärande Förlag', 'Kyrkogatan 10', 'Göteborg', '40012');
GO

-- Böcker
INSERT INTO Böcker (ISBN13, Titel, Språk, Pris, Utgivningsdatum, Sidor, FörlagID) VALUES
('9781234567890', 'SQL för nybörjare', 'Svenska', 299.00, '2018-01-15', 320, 1),
('9781234567891', 'Avancerad SQL', 'Svenska', 399.00, '2019-06-20', 450, 1),
('9781234567892', 'Python Programmering', 'Svenska', 349.00, '2020-09-10', 380, 2),
('9781234567893', 'Databaser i praktiken', 'Svenska', 319.00, '2017-03-05', 290, 1),
('9781234567894', 'Webbutveckling 101', 'Svenska', 259.00, '2018-11-11', 300, 2),
('9781234567895', 'Agil utveckling', 'Svenska', 289.00, '2021-02-18', 210, 2),
('9781234567896', 'Designmönster i mjukvara', 'Svenska', 399.00, '2016-07-07', 500, 1),
('9781234567897', 'Systemarkitektur', 'Svenska', 459.00, '2020-12-01', 420, 1),
('9781234567898', 'AI och Maskininlärning', 'Svenska', 499.00, '2021-08-20', 380, 2),
('9781234567899', 'Molnteknologier', 'Svenska', 379.00, '2019-04-25', 340, 1);
GO

-- BokFörfattare (koppling mellan böcker och författare)
INSERT INTO BokFörfattare (BokISBN13, FörfattareID) VALUES
('9781234567890', 1),
('9781234567891', 2),
('9781234567892', 3),
('9781234567893', 1),
('9781234567893', 2),
('9781234567894', 3),
('9781234567895', 4),
('9781234567896', 4),
('9781234567897', 2),
('9781234567897', 3),
('9781234567898', 1),
('9781234567899', 2),
('9781234567899', 4);
GO

-- Butiker
INSERT INTO Butiker (Butiksnamn, Adress, Stad, Postnummer) VALUES
('Bokhandeln Centrum', 'Kungsportsavenyen 1', 'Göteborg', '41105'),
('Bokbutiken i Centrum', 'Storgatan 5', 'Stockholm', '11122'),
('Lokal Bokhandel', 'Västra Hamngatan 10', 'Malmö', '21120');
GO

-- LagerSaldo för Butik 1
INSERT INTO LagerSaldo (ButikID, ISBN13, Antal) VALUES
(1, '9781234567890', 5),
(1, '9781234567891', 3),
(1, '9781234567892', 7),
(1, '9781234567893', 4),
(1, '9781234567894', 2),
(1, '9781234567895', 6),
(1, '9781234567896', 3),
(1, '9781234567897', 5),
(1, '9781234567898', 4),
(1, '9781234567899', 2);
GO

-- LagerSaldo för Butik 2
INSERT INTO LagerSaldo (ButikID, ISBN13, Antal) VALUES
(2, '9781234567890', 2),
(2, '9781234567891', 4),
(2, '9781234567892', 1),
(2, '9781234567893', 6),
(2, '9781234567894', 3),
(2, '9781234567895', 5),
(2, '9781234567896', 2),
(2, '9781234567897', 3),
(2, '9781234567898', 7),
(2, '9781234567899', 4);
GO

-- LagerSaldo för Butik 3
INSERT INTO LagerSaldo (ButikID, ISBN13, Antal) VALUES
(3, '9781234567890', 4),
(3, '9781234567891', 1),
(3, '9781234567892', 3),
(3, '9781234567893', 2),
(3, '9781234567894', 5),
(3, '9781234567895', 4),
(3, '9781234567896', 1),
(3, '9781234567897', 2),
(3, '9781234567898', 3),
(3, '9781234567899', 5);
GO

-- Kunder
INSERT INTO Kunder (Förnamn, Efternamn, Email, Telefonnummer, Adress) VALUES
('Anna', 'Svensson', 'anna.svensson@example.com', '0701234567', 'Lilla gatan 1, Göteborg'),
('Bertil', 'Karlsson', 'bertil.karlsson@example.com', '0702345678', 'Storgatan 2, Stockholm'),
('Cecilia', 'Andersson', 'cecilia.andersson@example.com', '0703456789', 'Västra gatan 3, Malmö');
GO

-- Ordrar
INSERT INTO Ordrar (KundID, OrderDatum, TotalBelopp) VALUES
(1, '2025-05-10', 0),
(2, '2025-05-11', 0),
(3, '2025-05-12', 0);
GO

-- Orderrader
INSERT INTO Orderrader (OrderID, ISBN13, Antal, PrisAtSale) VALUES
(1, '9781234567890', 1, 299.00),
(1, '9781234567893', 1, 319.00),
(2, '9781234567897', 1, 459.00),
(3, '9781234567892', 1, 349.00),
(3, '9781234567898', 1, 499.00);
GO

-- Uppdatera totalbelopp i Ordrar baserat på Orderrader
UPDATE Ordrar
SET TotalBelopp = (
    SELECT SUM(Antal * PrisAtSale)
    FROM Orderrader
    WHERE Orderrader.OrderID = Ordrar.OrderID
)
WHERE OrderID IN (1,2,3);
GO

---------------------------------------------
-- Skapa vyer och stored procedure
---------------------------------------------

-- Vy: TitlarPerFörfattare
CREATE VIEW TitlarPerFörfattare AS
SELECT
    f.Förnamn + ' ' + f.Efternamn AS Namn,
    DATEDIFF(YEAR, f.Födelsedatum, GETDATE()) AS Ålder,
    COUNT(DISTINCT b.ISBN13) AS Titlar,
    SUM(b.Pris * ls.Antal) AS Lagervärde
FROM Författare f
JOIN BokFörfattare bf ON f.ID = bf.FörfattareID
JOIN Böcker b ON bf.BokISBN13 = b.ISBN13
JOIN LagerSaldo ls ON b.ISBN13 = ls.ISBN13
GROUP BY f.Förnamn, f.Efternamn, f.Födelsedatum;
GO

-- Stored Procedure: FlyttaBok
CREATE PROCEDURE FlyttaBok
    @SourceButikID INT,
    @TargetButikID INT,
    @ISBN13 CHAR(13),
    @Antal INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- Kontrollera att källbutiken har tillräckligt med exemplar
    IF NOT EXISTS (
        SELECT 1 FROM LagerSaldo
        WHERE ButikID = @SourceButikID AND ISBN13 = @ISBN13 AND Antal >= @Antal
    )
    BEGIN
        RAISERROR('Insufficient stock in source butik.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    -- Subtrahera antalet från källbutiken
    UPDATE LagerSaldo
    SET Antal = Antal - @Antal
    WHERE ButikID = @SourceButikID AND ISBN13 = @ISBN13;

    -- Om målposten redan finns, uppdatera antalet. Annars, skapa en ny post.
    IF EXISTS (
        SELECT 1 FROM LagerSaldo
        WHERE ButikID = @TargetButikID AND ISBN13 = @ISBN13
    )
    BEGIN
        UPDATE LagerSaldo
        SET Antal = Antal + @Antal
        WHERE ButikID = @TargetButikID AND ISBN13 = @ISBN13;
    END
    ELSE
    BEGIN
        INSERT INTO LagerSaldo (ButikID, ISBN13, Antal)
        VALUES (@TargetButikID, @ISBN13, @Antal);
    END

    COMMIT TRANSACTION;
END;
GO

-- Vy: KundOrderÖversikt
-- Denna vy sammanställer data från tabellerna Kunder och Ordrar för att ge en överblick
-- av kundernas orderaktivitet. Syftet är att hjälpa bokhandeln att identifiera högvärdiga kunder,
-- planera riktade kampanjer och stödja affärsbeslut genom att visa trender i försäljningsdata.
CREATE VIEW KundOrderÖversikt AS
SELECT 
    k.Förnamn + ' ' + k.Efternamn AS KundNamn,
    COUNT(o.OrderID) AS AntalOrdrar,
    SUM(o.TotalBelopp) AS TotalOrderVärde,
    AVG(o.TotalBelopp) AS GenomsnittligtOrderVärde
FROM Kunder k
LEFT JOIN Ordrar o ON k.ID = o.KundID
GROUP BY k.Förnamn, k.Efternamn;
GO
