USE master
GO;


IF DB_ID('Sales') IS NOT NULL
    DROP DATABASE Sales

    CREATE DATABASE Sales
GO
IF DB_ID('Sales') IS NULL
    CREATE DATABASE Sales
GO

USE Sales
GO;

CREATE TABLE sellers (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone NVARCHAR(20) NOT NULL
);

CREATE TABLE buyers (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20) NOT NULL
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY IDENTITY(1,1),
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    product_name NVARCHAR(200) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,

    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

INSERT INTO sellers (name, email, phone) VALUES
(N'Іванов Іван Іванович', N'ivanov@sales.com', N'+380501234567'),
(N'Петренко Марія Олександрівна', N'petrenko@sales.com', N'+380672345678'),
(N'Сидоров Олег Михайлович', N'sidorov@sales.com', N'+380633456789');

INSERT INTO buyers (name, email, phone) VALUES
(N'Коваленко Анна Сергіївна', N'kovalenko@gmail.com', N'+380501111111'),
(N'Мельник Петро Васильович', N'melnyk@ukr.net', N'+380672222222'),
(N'Шевченко Олена Іванівна', N'shevchenko@i.ua', N'+380633333333'),
(N'Бондаренко Михайло Петрович', N'bondarenko@gmail.com', N'+380674444444');

INSERT INTO sales (buyer_id, seller_id, product_name, price, date) VALUES
(1, 1, N'Ноутбук ASUS', 25000.00, '2024-06-01'),
(2, 2, N'Смартфон Samsung', 15000.00, '2024-06-02'),
(3, 1, N'Планшет iPad', 18000.00, '2024-06-03'),
(4, 3, N'Навушники Sony', 3500.00, '2024-06-04'),
(1, 2, N'Клавіатура Logitech', 1200.00, '2024-06-05'),
(2, 3, N'Миша Apple', 2800.00, '2024-06-06');