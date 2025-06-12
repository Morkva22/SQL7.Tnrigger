USE master
GO;

IF DB_ID('MusicCollection') IS NOT NULL
    DROP DATABASE MusicCollection
    CREATE DATABASE MusicCollection
GO;
IF DB_ID('MusicCollection') IS NULL
    CREATE DATABASE MusicCollection
GO;

USE MusicCollection
GO;

-- Create a table with styles
CREATE TABLE Styles (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(64) NOT NULL UNIQUE,

    CONSTRAINT CHK_Styles_Name CHECK (Name <> '')
);

-- Create a table with artists
CREATE TABLE Artists (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(64) NOT NULL UNIQUE,

    CONSTRAINT CHK_Artists_Name CHECK (Name <> '')
);

-- Create a table with publishers
CREATE TABLE Publishers (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(64) NOT NULL UNIQUE,
    Country NVARCHAR(64) NOT NULL,

    CONSTRAINT CHK_Publishers_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Publishers_Country CHECK (Country <> '')
);

-- Create a table with music cds
CREATE TABLE MusicCds (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Title NVARCHAR(256) NOT NULL,
    ReleaseDate DATE NOT NULL DEFAULT (GETDATE()),
    PublisherId INT NOT NULL,
    StyleId INT NOT NULL,
    ArtistId INT NOT NULL,

    CONSTRAINT CHK_MusicCd_Title CHECK (Title <> ''),

    CONSTRAINT FK_MusicCd_Styles FOREIGN KEY (StyleId) REFERENCES Styles(Id),
    CONSTRAINT FK_MusicCd_Artists FOREIGN KEY (ArtistId) REFERENCES Artists(Id),
    CONSTRAINT FK_MusicCd_Publishers FOREIGN KEY (PublisherId) REFERENCES Publishers(Id)
);

-- Create a table with songs
CREATE TABLE Songs (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Title NVARCHAR(256) NOT NULL,
    SongDuration INT NOT NULL,
    StyleId INT NOT NULL,
    ArtistId INT NOT NULL,
    MusicCdId INT NOT NULL,

    CONSTRAINT CHK_Songs_Title CHECK (Title <> ''),
    CONSTRAINT CHK_Songs_SongDuration CHECK (SongDuration > 0),

    CONSTRAINT FK_Songs_Styles FOREIGN KEY (StyleId) REFERENCES Styles(Id),
    CONSTRAINT FK_Songs_Artists FOREIGN KEY (ArtistId) REFERENCES Artists(Id),
    CONSTRAINT FK_Songs_MusicCds FOREIGN KEY (MusicCdId) REFERENCES MusicCds(Id)
);




INSERT INTO Styles (Name) VALUES
('Rock'),
('Pop');


INSERT INTO Artists (Name) VALUES
('The Rolling Stones'),
('Madonna'),
('Queen'),
('Michael Jackson');


INSERT INTO Publishers (Name, Country) VALUES
('Universal Music Group', 'United States'),
('Sony Music', 'Japan'),
('EMI Records', 'United Kingdom'),
('Warner Music', 'United States');


INSERT INTO MusicCds (Title, ReleaseDate, PublisherId, StyleId, ArtistId) VALUES
('Rock Classics', '2020-01-15', 1, 1, 1),
('Pop Essentials', '2021-05-20', 3, 2, 2);


INSERT INTO Songs (Title, SongDuration, StyleId, ArtistId, MusicCdId) VALUES
('Paint It Black', 180, 1, 1, 1),
('Bohemian Rhapsody', 355, 1, 3, 1),
('Start Me Up', 195, 1, 1, 1),
('Beat It (Rock Cover)', 225, 1, 4, 1),
('Radio Ga Ga', 240, 1, 3, 1);


INSERT INTO Songs (Title, SongDuration, StyleId, ArtistId, MusicCdId) VALUES
('Vogue', 200, 2, 2, 2),
('Thriller', 358, 2, 4, 2),
('Like A Virgin', 220, 2, 2, 2),
('I Want To Break Free', 215, 2, 3, 2),
('Billie Jean', 230, 2, 4, 2);



CREATE TRIGGER PreventDuplicateAlbums
ON MusicCds
INSTEAD OF INSERT
AS
BEGIN

INSERT INTO MusicCds (Title, ReleaseDate, PublisherId, StyleId, ArtistId)
SELECT i.Title, i.ReleaseDate, i.PublisherId, i.StyleId, i.ArtistId FROM inserted i
LEFT JOIN MusicCds mc ON mc.Title = i.Title  AND mc.ArtistId = i.ArtistId AND mc.ReleaseDate = i.ReleaseDate WHERE mc.Id IS NULL;
END;
GO;

CREATE TRIGGER PreventBeatlesDeletion
ON MusicCds
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Songs  WHERE MusicCdId IN ( SELECT d.Id FROM deleted d
JOIN Artists a ON d.ArtistId = a.Id WHERE a.Name <> 'The Beatles');
DELETE FROM MusicCds
WHERE Id IN ( SELECT d.Id FROM deleted d
JOIN Artists a ON d.ArtistId = a.Id WHERE a.Name <> 'The Beatles');
END;
GO;

CREATE TRIGGER ArchiveDeletedCds
ON MusicCds
AFTER DELETE
AS
BEGIN
    INSERT INTO ArchivedCds (Id, Title, ReleaseDate, PublisherId, StyleId, ArtistId)
    SELECT Id, Title, ReleaseDate, PublisherId, StyleId, ArtistId FROM deleted;
END;
GO;


CREATE TRIGGER PreventDarkPowerPop
ON MusicCds
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO MusicCds (Title, ReleaseDate, PublisherId, StyleId, ArtistId)
SELECT i.Title, i.ReleaseDate, i.PublisherId, i.StyleId, i.ArtistId FROM inserted i
JOIN Styles s ON i.StyleId = s.Id WHERE s.Name <> 'Dark Power Pop';
END;
GO;



