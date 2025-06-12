USE master
GO;

-- Check if the database exists
IF DB_ID('SportsShop') IS NOT NULL
    DROP DATABASE SportsShop

    CREATE DATABASE SportsShop
GO
IF DB_ID('SportsShop') IS NULL
    CREATE DATABASE SportsShop
GO

USE SportsShop
GO;


CREATE TABLE products (
                product_id INT PRIMARY KEY,
                product_name nvarchar(100) NOT NULL,
                product_type nvarchar(50) NOT NULL,
                quantity INT NOT NULL,
                cost DECIMAL(10,2) NOT NULL,
                manufacturer nvarchar(100) NOT NULL,
                price DECIMAL(10,2) NOT NULL
            );

            CREATE TABLE employees (
                id INT PRIMARY KEY,
                name nvarchar(100) NOT NULL,
                position nvarchar(50) NOT NULL,
                date DATE NOT NULL,
                gender nvarchar(1) NOT NULL,
                salary DECIMAL(10,2) NOT NULL
            );

            CREATE TABLE clients (
                id INT PRIMARY KEY,
                name nvarchar(100) NOT NULL,
                email nvarchar(100),
                phone nvarchar(20),
                gender nvarchar(1),
                discount INT,
                newsletter nvarchar (3)
            );

            CREATE TABLE sales (
                id INT PRIMARY KEY,
                product_id INT NOT NULL,
                employee_id INT NOT NULL,
                client_id INT,
                price DECIMAL(10,2) NOT NULL,
                quantity INT NOT NULL,
                date DATE NOT NULL,

                FOREIGN KEY (product_id) REFERENCES products(product_id),
                FOREIGN KEY (employee_id) REFERENCES employees(id),
                FOREIGN KEY (client_id) REFERENCES clients(id)
            );

            CREATE TABLE history (
                history_id INT PRIMARY KEY,
                product_id INT NOT NULL,
                employee_id INT NOT NULL,
                client_id INT,
                price DECIMAL(10,2) NOT NULL,
                quantity INT NOT NULL,
                date DATE NOT NULL
            );

            CREATE TABLE archive (
                id INT PRIMARY KEY,
                name nvarchar(100) NOT NULL,
                product nvarchar(50) NOT NULL,
                cost DECIMAL(10,2) NOT NULL,
                manufacturer nvarchar(100) NOT NULL,
                sale DECIMAL(10,2) NOT NULL,
                date DATE NOT NULL
            );

            CREATE TABLE last_unit (
                id INT PRIMARY KEY,
                product_id INT NOT NULL,
                name nvarchar(100) NOT NULL,
                date DATE NOT NULL
            );

-- Products
            INSERT INTO products VALUES
            (1, N'Football', N'Sports', 50, 10.00, N'Adidas', 20.00),
            (2, N'Tennis Racket', N'Tennis', 30, 35.00, N'Wilson', 60.00),
            (3, N'Basketball', N'Sports', 40, 12.00, N'Spalding', 25.00),
            (4, N'Running Shoes', N'Footwear', 20, 40.00, N'Nike', 80.00);

            -- Employees
            INSERT INTO employees VALUES
            (1, N'John Doe', N'Salesman', '2020-01-15', N'M', 2500.00),
            (2, N'Anna Ivanova', N'Cashier', '2018-03-10', N'F', 2200.00),
            (3, N'Peter Brown', N'Manager', '2012-07-01', N'M', 4000.00);

            -- Clients
            INSERT INTO clients VALUES
            (1, N'Jane Smith', N'jane.smith@email.com', N'555-1234', N'F', 5, N'yes'),
            (2, N'Mark Lee', N'mark.lee@email.com', N'555-5678', N'M', 10, N'no'),
            (3, N'Olga Petrova', N'olga.p@email.com', N'555-8765', N'F', 0, N'no');

            -- Sales
            INSERT INTO sales VALUES
            (1, 1, 1, 1, 20.00, 2, '2024-06-01'),
            (2, 2, 2, 2, 60.00, 1, '2024-06-02'),
            (3, 3, 1, 3, 25.00, 3, '2024-06-03'),
            (4, 4, 3, 1, 80.00, 1, '2024-06-04');

            -- History (should be filled by trigger, but here are sample rows)
            INSERT INTO history VALUES
            (1, 1, 1, 1, 20.00, 2, '2024-06-01'),
            (2, 2, 2, 2, 60.00, 1, '2024-06-02'),
            (3, 3, 1, 3, 25.00, 3, '2024-06-03'),
            (4, 4, 3, 1, 80.00, 1, '2024-06-04');

            -- Archive (example, normally filled by trigger)
            INSERT INTO archive VALUES
            (1, N'Football', N'Sports', 10.00, N'Adidas', 20.00, '2024-06-05'),
            (2, N'Tennis Racket', N'Tennis', 35.00, N'Wilson', 60.00, '2024-06-06');

            -- Last Unit (example, normally filled by trigger)
            INSERT INTO last_unit VALUES
            (1, 3, N'Basketball', '2024-06-07'),
            (2, 4, N'Running Shoes', '2024-06-08');

-- copy to history
            CREATE TRIGGER afterSale
            ON sales
            AFTER INSERT
            AS
            BEGIN
                INSERT INTO history (history_id, product_id, employee_id, client_id, price, quantity, date)
                SELECT id, product_id, employee_id, client_id, price, quantity, date
                FROM inserted;
            END

-- update product quantity
            CREATE TRIGGER updateQuantity
            ON sales
            AFTER INSERT
            AS
            BEGIN
                UPDATE p
                SET p.quantity = p.quantity - i.quantity
                FROM products p
                INNER JOIN inserted i ON p.product_id = i.product_id;
            END

-- archive if quantity is 0
            CREATE TRIGGER archiveEmpty
            ON products
            AFTER UPDATE
            AS
            BEGIN
                INSERT INTO archive (id, name, product, cost, manufacturer, sale, date)
                SELECT i.product_id, i.product_name, i.product_type, i.cost, i.manufacturer, i.price, GETDATE()
                FROM inserted i
                WHERE i.quantity = 0;
            END

-- notify if quantity is 1
            CREATE TRIGGER checkLast
            ON products
            AFTER UPDATE
            AS
            BEGIN
                INSERT INTO last_unit (id, product_id, name, date)
                SELECT i.product_id, i.product_id, i.product_name, GETDATE()
                FROM inserted i
                WHERE i.quantity = 1;
            END

-- check duplicate
            CREATE TRIGGER checkDuplicate
            ON clients
            INSTEAD OF INSERT
            AS
            BEGIN
                INSERT INTO clients (id, name, email, phone, gender, discount, newsletter)
                SELECT id, name, email, phone, gender, discount, newsletter
                FROM inserted i
                WHERE NOT EXISTS (SELECT 1 FROM clients c WHERE c.name = i.name AND c.email = i.email);
            END

-- prevent deletion
            CREATE TRIGGER clientDelete
            ON clients
            INSTEAD OF DELETE
            AS
            BEGIN
                RETURN;
            END

-- prevent deletion of old employees
            CREATE TRIGGER EmployeeOldDelete
            ON employees
            INSTEAD OF DELETE
            AS
            BEGIN
                DELETE FROM employees
                WHERE id IN (SELECT id FROM deleted WHERE date >= N'2015-01-01');
            END

-- prevent banned manufacturer
            CREATE TRIGGER bannedManufacturer
            ON products
            INSTEAD OF INSERT
            AS
            BEGIN
                INSERT INTO products (product_id, product_name, product_type, quantity, cost, manufacturer, price)
                SELECT product_id, product_name, product_type, quantity, cost, manufacturer, price
                FROM inserted
                WHERE manufacturer <> N'Спорт сонце штанга';
            END