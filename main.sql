USE master
GO;

-- Check if the database exists
IF DB_ID('Academy') IS NOT NULL
    DROP DATABASE Academy
IF DB_ID('Academy') IS NULL
    CREATE DATABASE Academy

USE Academy
GO

