USE master
GO;

-- Перевіряємо чи існує база даних
IF DB_ID('MusicColection') IS NOT NULL
    DROP DATABASE MusicColection

    CREATE DATABASE MusicColection
GO
IF DB_ID('MusicColection') IS NULL
    CREATE DATABASE MusicColection
GO

USE MusicColection
GO;

--table styles
CREATE TABLE styles (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50) NOT NULL UNIQUE
);

-- table performers
CREATE TABLE performers (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL UNIQUE
);

-- table publishers
CREATE TABLE publishers (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    country NVARCHAR(100) NOT NULL
);

--table albums
CREATE TABLE albums (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    performer INT NOT NULL,
    releaseDate DATE NOT NULL,
    style INT NOT NULL,
    publisher INT NOT NULL,

    FOREIGN KEY (performer) REFERENCES performers(id),
    FOREIGN KEY (style) REFERENCES styles(id),
    FOREIGN KEY (publisher) REFERENCES publishers(id)
);

--table songs
CREATE TABLE songs (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    album INT NOT NULL,
    duration INT NOT NULL,
    style INT NOT NULL,
    performer INT NOT NULL,

    FOREIGN KEY (album) REFERENCES albums(id),
    FOREIGN KEY (style) REFERENCES styles(id),
    FOREIGN KEY (performer) REFERENCES performers(id)
);

--styles
INSERT INTO styles (name) VALUES
(N'Рок'),
(N'Поп'),
(N'Джаз'),
(N'Класична музика'),
(N'Електронна музика'),
(N'Хіп-хоп'),
(N'Блюз');

-- performers
INSERT INTO performers (name) VALUES
(N'The Beatles'),
(N'Queen'),
(N'Michael Jackson'),
(N'Elvis Presley'),
(N'Pink Floyd'),
(N'Led Zeppelin'),
(N'Bob Dylan');

--publishers
INSERT INTO publishers (name, country) VALUES
(N'Capitol Records', N'США'),
(N'Columbia Records', N'США'),
(N'EMI Records', N'Великобританія'),
(N'Warner Music Group', N'США'),
(N'Universal Music Group', N'США'),
(N'Sony Music Entertainment', N'Японія');

--albums
INSERT INTO albums (name, performer, releaseDate, style, publisher) VALUES
(N'Abbey Road', 1, '1969-09-26', 1, 1),
(N'A Night at the Opera', 2, '1975-11-21', 1, 3),
(N'Thriller', 3, '1982-11-30', 2, 6),
(N'The Dark Side of the Moon', 5, '1973-03-01', 1, 3),
(N'Led Zeppelin IV', 6, '1971-11-08', 1, 4);

--songs
INSERT INTO songs (name, album, duration, style, performer) VALUES
(N'Come Together', 1, 259, 1, 1),
(N'Something', 1, 183, 1, 1),
(N'Oh! Darling', 1, 206, 1, 1),
(N'Bohemian Rhapsody', 2, 355, 1, 2),
(N'Love of My Life', 2, 218, 1, 2),
(N'Billie Jean', 3, 294, 2, 3),
(N'Beat It', 3, 258, 2, 3),
(N'Time', 4, 413, 1, 5),
(N'Money', 4, 382, 1, 5),
(N'Stairway to Heaven', 5, 482, 1, 6),
(N'Black Dog', 5, 295, 1, 6);

