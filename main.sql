USE master
GO;

IF DB_ID('SportsShop') IS NOT NULL
    DROP DATABASE SportsShop

    CREATE DATABASE SportsShop
GO
IF DB_ID('SportsShop') IS NULL
    CREATE DATABASE SportsShop
GO

USE SportsShop
GO;

-- Create a table with employees
CREATE TABLE Employees (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    FullName NVARCHAR(256) NOT NULL UNIQUE,
    DateOfHire DATE NOT NULL,
    Sex BINARY NOT NULL,
    Salary INT NOT NULL DEFAULT (0),

    CONSTRAINT CHK_Employees_FullName CHECK (FullName <> ''),
    CONSTRAINT CHK_Employees_Salary CHECK (Salary >= 0)
);

-- Create a table with customers
CREATE TABLE Customers (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    FullName NVARCHAR(256) NOT NULL UNIQUE,
    Phone NVARCHAR(10) NOT NULL UNIQUE,
    Email NVARCHAR(512) NOT NULL UNIQUE,
    Sex BINARY NOT NULL,
    OrderHistory NVARCHAR(MAX),
    DiscountPercentage INT NOT NULL DEFAULT (0),
    isSubscribed BINARY NOT NULL,

    CONSTRAINT CHK_Customers_FullName CHECK (FullName <> ''),
    CONSTRAINT CHK_Customers_Phone CHECK (LEN(Phone) = 10),
    CONSTRAINT CHK_Customers_DiscountPercentage CHECK (DiscountPercentage >= 0 AND DiscountPercentage <= 100)
);

-- Create a table with goods
CREATE TABLE Goods (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(256) NOT NULL,
    Type NVARCHAR(100) NOT NULL,
    Amount INT NOT NULL,
    CostPrice INT NOT NULL,
    Manufacturer NVARCHAR(MAX) NOT NULL,
    SellingPrice INT NOT NULL,

    CONSTRAINT CHK_Goods_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Goods_Type CHECK (Type <> ''),
    CONSTRAINT CHK_Goods_Manufacturer CHECK (Manufacturer <> '')
);

-- Create a table with sales
CREATE TABLE Sales (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(MAX) NOT NULL,
    Price INT NOT NULL,
    EmployeeId INT NOT NULL,
    CustomerId INT NOT NULL,

    CONSTRAINT CHK_Sales_Name CHECK (Name <> ''),

    CONSTRAINT FK_Sales_Employees FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
    CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
);



INSERT INTO Employees (FullName, DateOfHire, Sex, Salary) VALUES
(N'John Smith', '2020-01-15', 1, 4000),
(N'Emily Davis', '2019-03-22', 0, 4200),
(N'Michael Brown', '2021-07-10', 1, 3900),
(N'Sarah Wilson', '2018-11-05', 0, 4500),
(N'David Lee', '2022-02-28', 1, 4100),
(N'Jessica Miller', '2020-09-17', 0, 4300),
(N'Chris Johnson', '2017-06-30', 1, 4700),
(N'Laura Clark', '2019-12-12', 0, 4000),
(N'James Lewis', '2021-04-03', 1, 3800),
(N'Olivia Walker', '2022-08-19', 0, 4400);


INSERT INTO Customers (FullName, Phone, Email, Sex, OrderHistory, DiscountPercentage, isSubscribed) VALUES
(N'Alice Green', N'1234567890', N'alice.green@email.com', 0, N'Football, Shoes', 10, 1),
(N'Brian White', N'2345678901', N'brian.white@email.com', 1, N'Basketball', 5, 0),
(N'Chloe Harris', N'3456789012', N'chloe.harris@email.com', 0, N'Yoga Mat, Gloves', 15, 1),
(N'Daniel Young', N'4567890123', N'daniel.young@email.com', 1, N'Helmet', 0, 0),
(N'Ella King', N'5678901234', N'ella.king@email.com', 0, N'Golf Clubs', 20, 1),
(N'Frank Scott', N'6789012345', N'frank.scott@email.com', 1, N'Racket, Shoes', 8, 1),
(N'Grace Adams', N'7890123456', N'grace.adams@email.com', 0, N'Goggles', 12, 0),
(N'Henry Baker', N'8901234567', N'henry.baker@email.com', 1, N'Football', 0, 1),
(N'Ivy Carter', N'9012345678', N'ivy.carter@email.com', 0, N'Basketball, Mat', 18, 1),
(N'Jack Evans', N'0123456789', N'jack.evans@email.com', 1, N'Gloves', 7, 0);


INSERT INTO Goods (Name, Type, Amount, CostPrice, Manufacturer, SellingPrice) VALUES
(N'Football', N'Sports Equipment', 50, 20, N'Adidas', 35),
(N'Tennis Racket', N'Sports Equipment', 30, 40, N'Wilson', 65),
(N'Running Shoes', N'Footwear', 100, 60, N'Nike', 90),
(N'Basketball', N'Sports Equipment', 40, 25, N'Spalding', 45),
(N'Yoga Mat', N'Fitness', 70, 10, N'Reebok', 20),
(N'Cycling Helmet', N'Accessories', 25, 30, N'Giro', 55),
(N'Baseball Glove', N'Sports Equipment', 15, 35, N'Rawlings', 60),
(N'Swimming Goggles', N'Accessories', 80, 8, N'Speedo', 18),
(N'Golf Clubs', N'Sports Equipment', 10, 200, N'Callaway', 350),
(N'Boxing Gloves', N'Fitness', 35, 22, N'Everlast', 40);


INSERT INTO Sales (Name, Price, EmployeeId, CustomerId) VALUES
(N'Football', 35, 1, 1),
(N'Tennis Racket', 65, 2, 2),
(N'Running Shoes', 90, 3, 3),
(N'Basketball', 45, 4, 4),
(N'Yoga Mat', 20, 5, 5),
(N'Cycling Helmet', 55, 6, 6),
(N'Baseball Glove', 60, 7, 7),
(N'Swimming Goggles', 18, 8, 8),
(N'Golf Clubs', 350, 9, 9),
(N'Boxing Gloves', 40, 10, 10);


GO;

-- Check product existence and update quantity instead of adding duplicate
CREATE TRIGGER Checkgoodsexists
ON Goods
INSTEAD OF INSERT
AS
BEGIN
    UPDATE G
    SET G.Amount = G.Amount + I.Amount FROM Goods G
    INNER JOIN inserted I ON G.Name = I.Name
        AND G.Type = I.Type
        AND G.Costprice = I.Costprice
        AND G.Manufacturer = I.Manufacturer
        AND G.Sellingprice = I.Sellingprice;

    INSERT INTO Goods (Name, Type, Amount, Costprice, Manufacturer, Sellingprice)
    SELECT Name, Type, Amount, Costprice, Manufacturer, Sellingprice FROM inserted I
    WHERE NOT EXISTS ( SELECT 1 FROM Goods G  WHERE G.Name = I.Name
        AND G.Type = I.Type
        AND G.Costprice = I.Costprice
        AND G.Manufacturer = I.Manufacturer
        AND G.Sellingprice = I.Sellingprice);
END



-- Move dismissed employee to archive
CREATE TRIGGER Movetoarchive
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO Employeesarchive (Id, Fullname, Dateofhire, Sex, Salary, Dismissaldate)
    SELECT Id, Fullname, Dateofhire, Sex, Salary, GETDATE() FROM deleted;

    DELETE FROM Employees WHERE Id IN (SELECT Id FROM deleted);
END



--  Prevent adding salesman if count exceeds 6
CREATE TRIGGER Checksalesmanlimit
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM Employees) + (SELECT COUNT(*) FROM inserted) <= 6
    BEGIN
    INSERT INTO Employees (Fullname, Dateofhire, Sex, Salary)
    SELECT Fullname, Dateofhire, Sex, Salary FROM inserted;
END
END