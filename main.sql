USE master
GO;


IF DB_ID('Sales') IS NOT NULL
    DROP DATABASE Sales
    CREATE DATABASE Sales
GO;
IF DB_ID('Sales') IS NULL
    CREATE DATABASE Sales
GO;

USE Sales
GO;

-- Create a table with sellers
CREATE TABLE Sellers (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    Phone NVARCHAR(10) NOT NULL UNIQUE,

    CONSTRAINT CHK_Sellers_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Sellers_Email CHECK (Email <> ''),
    CONSTRAINT CHK_Sellers_Phone CHECK (LEN(Phone) = 10)
);

-- Create a table with buyers
CREATE TABLE Buyers (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    Phone NVARCHAR(10) NOT NULL UNIQUE,

    CONSTRAINT CHK_Buyers_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Buyers_Email CHECK (Email <> ''),
    CONSTRAINT CHK_Buyers_Phone CHECK (LEN(Phone) = 10)
);

-- Create a table with sales
CREATE TABLE Sales (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(256) NOT NULL,
    Price INT NOT NULL,
    Date DATE NOT NULL DEFAULT (GETDATE()),
    SellerId INT NOT NULL,
    BuyerId INT NOT NULL,

    CONSTRAINT CHK_Sales_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Sales_Price CHECK (Price >= 0),

    CONSTRAINT FK_Sales_Sellers FOREIGN KEY (SellerId) REFERENCES Sellers(Id),
    CONSTRAINT FK_Sales_Buyers FOREIGN KEY (BuyerId) REFERENCES Buyers(Id)
);


CREATE TABLE BuyerLastNameMatches (
    Id INT PRIMARY KEY IDENTITY(1,1),
    BuyerId INT NOT NULL,
    ExistingBuyerId INT NOT NULL,
    MatchDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_BuyerLastNameMatches_Buyer FOREIGN KEY (BuyerId) REFERENCES Buyers(Id),
    CONSTRAINT FK_BuyerLastNameMatches_ExistingBuyer FOREIGN KEY (ExistingBuyerId) REFERENCES Buyers(Id)
);


CREATE TABLE PurchaseHistory (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OriginalSaleId INT NOT NULL,
    ProductName NVARCHAR(256) NOT NULL,
    Price INT NOT NULL,
    SaleDate DATE NOT NULL,
    OriginalBuyerId INT NOT NULL,
    OriginalBuyerName NVARCHAR(100) NOT NULL,
    SellerId INT NOT NULL,
    ArchiveDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_PurchaseHistory_Seller FOREIGN KEY (SellerId) REFERENCES Sellers(Id)
);
GO;


-- Insert data into sellers table
INSERT INTO Sellers (Name, Email, Phone) VALUES
(N'John Smith', N'john.smith@email.com', N'1234567890'),
(N'Emma Johnson', N'emma.johnson@email.com', N'2345678901'),
(N'Michael Brown', N'michael.brown@email.com', N'3456789012'),
(N'Sarah Davis', N'sarah.davis@email.com', N'4567890123'),
(N'David Wilson', N'david.wilson@email.com', N'5678901234'),
(N'Jennifer Taylor', N'jennifer.taylor@email.com', N'6789012345'),
(N'Robert Miller', N'robert.miller@email.com', N'7890123456'),
(N'Jessica Anderson', N'jessica.anderson@email.com', N'8901234567'),
(N'William Thomas', N'william.thomas@email.com', N'9012345678'),
(N'Elizabeth Martin', N'elizabeth.martin@email.com', N'0123456789');

-- Insert data into buyers table
INSERT INTO Buyers (Name, Email, Phone) VALUES
(N'James Williams', N'james.williams@email.com', N'9876543210'),
(N'Patricia Jones', N'patricia.jones@email.com', N'8765432109'),
(N'Richard Garcia', N'richard.garcia@email.com', N'7654321098'),
(N'Linda Martinez', N'linda.martinez@email.com', N'6543210987'),
(N'Charles Robinson', N'charles.robinson@email.com', N'5432109876'),
(N'Barbara Clark', N'barbara.clark@email.com', N'4321098765'),
(N'Joseph Rodriguez', N'joseph.rodriguez@email.com', N'3210987654'),
(N'Susan Lewis', N'susan.lewis@email.com', N'2109876543'),
(N'Thomas Walker', N'thomas.walker@email.com', N'1098765432'),
(N'Margaret Hall', N'margaret.hall@email.com', N'0987654321');

-- Insert data into sales table
INSERT INTO Sales (Name, Price, Date, SellerId, BuyerId) VALUES
(N'Laptop Computer', 1200, '2023-01-15', 1, 3),
(N'Smartphone', 800, '2023-02-20', 2, 1),
(N'Office Furniture', 3500, '2023-03-10', 3, 2),
(N'Software License', 500, '2023-04-05', 4, 5),
(N'Network Equipment', 2000, '2023-05-12', 5, 4),
(N'Consulting Services', 1500, '2023-06-18', 6, 7),
(N'Training Package', 750, '2023-07-22', 7, 6),
(N'Server Hardware', 4000, '2023-08-30', 8, 9),
(N'Cloud Subscription', 300, '2023-09-14', 9, 8),
(N'Maintenance Contract', 1800, '2023-10-25', 10, 10);


CREATE TRIGGER CheckBuyerLastName
ON Buyers
AFTER INSERT
AS
BEGIN
INSERT INTO BuyerLastNameMatches (BuyerId, ExistingBuyerId)
SELECT I.Id, B.Id FROM inserted I
JOIN Buyers B ON B.Id <> I.Id
WHERE RIGHT(I.Name, CHARINDEX(' ', REVERSE(i.Name + ' ')) - 1) =
RIGHT(B.Name, CHARINDEX(' ', REVERSE(b.Name + ' ')) - 1);
END;
GO;

CREATE TRIGGER ArchivePurchaseHistory
ON Buyers
AFTER DELETE
AS
BEGIN
INSERT INTO PurchaseHistory (OriginalSaleId, ProductName, Price, SaleDate, OriginalBuyerId, OriginalBuyerName, SellerId)
SELECT S.Id, S.Name, S.Price, S.Date, D.Id, D.Name, S.SellerIdFROM deleted D
JOIN Sales S ON S.BuyerId = D.Id;
END;
GO;

CREATE TRIGGER PreventSellerAsBuyer
ON Sellers
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO Sellers (Name, Email, Phone)
SELECT I.Name, I.Email, I.Phone FROM inserted I
WHERE NOT EXISTS ( SELECT 1 FROM Buyers B WHERE B.Name = I.Name OR B.Email = I.Email OR B.Phone = I.Phone);
END;
GO;

CREATE TRIGGER PreventSellerAsBuyer
ON Sellers
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO Sellers (Name, Email, Phone)
SELECT I.Name, I.Email, I.Phone FROM inserted I
WHERE NOT EXISTS ( SELECT 1 FROM Buyers B  WHERE B.Name = I.Name OR B.Email = I.Email OR B.Phone = I.Phone);
END;
GO;

CREATE TRIGGER PreventBuyerAsSeller
ON Buyers
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO Buyers (Name, Email, Phone)
SELECT I.Name, I.Email, I.Phone FROM inserted I
WHERE NOT EXISTS ( SELECT 1 FROM Sellers S WHERE S.Name = I.Name OR S.Email = I.Email OR S.Phone = I.Phone);
END;
GO;

CREATE TRIGGER PreventCertainProducts
ON Sales
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO Sales (Name, Price, Date, SellerId, BuyerId)
SELECT I.Name, I.Price, I.Date, I.SellerId, I.BuyerId FROM inserted I
WHERE LOWER(I.Name) NOT IN ('яблука', 'груші', 'сливи', 'кінза');
END;
GO;