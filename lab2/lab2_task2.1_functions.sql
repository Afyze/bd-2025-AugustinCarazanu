---------------------------------------------------------
-- Task #1  
-- Pull OrderDate from SalesOrderHeader and apply DATEPART  
-- to extract every available time fragment (year, month,
-- day, quarter, week, weekday, etc.)
---------------------------------------------------------
SELECT 
    OrderDate,
    DATEPART(YEAR, OrderDate)      AS YearPart,
    DATEPART(MONTH, OrderDate)     AS MonthPart,
    DATEPART(DAY, OrderDate)       AS DayPart,
    DATEPART(QUARTER, OrderDate)   AS QuarterPart,
    DATEPART(WEEK, OrderDate)      AS WeekPart,
    DATEPART(WEEKDAY, OrderDate)   AS WeekdayPart
FROM SalesLT.SalesOrderHeader;


---------------------------------------------------------
-- Task #2  
-- Use DATENAME to pull the textual form of each time 
-- component (month name, weekday name, quarter name, etc.)
---------------------------------------------------------
SELECT 
    OrderDate,
    DATENAME(YEAR, OrderDate)      AS YearName,
    DATENAME(MONTH, OrderDate)     AS MonthName,
    DATENAME(DAY, OrderDate)       AS DayName,
    DATENAME(QUARTER, OrderDate)   AS QuarterName,
    DATENAME(WEEKDAY, OrderDate)   AS WeekdayName
FROM SalesLT.SalesOrderHeader;


---------------------------------------------------------
-- Task #2.1  
-- Experiment with built‑in date helpers YEAR(), MONTH(), DAY()  
-- using the OrderDate column
---------------------------------------------------------
SELECT
    OrderDate,
    YEAR(OrderDate)  AS OnlyYear,
    MONTH(OrderDate) AS OnlyMonth,
    DAY(OrderDate)   AS OnlyDay
FROM SalesLT.SalesOrderHeader;


---------------------------------------------------------
-- Task #3  
-- Compute how many days passed between today and each OrderDate.  
-- GETDATE() returns the current system timestamp.
---------------------------------------------------------
SELECT
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysAgo
FROM SalesLT.SalesOrderHeader;


---------------------------------------------------------
-- Task #4  
-- Merge Title, FirstName and LastName into a single value  
-- using CONCAT to form a full customer name.
---------------------------------------------------------
SELECT 
    CustomerID,
    CONCAT(Title, ' ', FirstName, ' ', LastName) AS FullName
FROM SalesLT.Customer;


---------------------------------------------------------
-- Task #5  
-- Determine where '@' appears inside EmailAddress  
-- using CHARINDEX to get its position.
---------------------------------------------------------
SELECT 
    CustomerID,
    EmailAddress,
    CHARINDEX('@', EmailAddress) AS AtSignPosition
FROM SalesLT.Customer;


---------------------------------------------------------
-- Task #6  
-- Reverse the characters of CompanyName using REVERSE  
-- to return it flipped backwards.
---------------------------------------------------------
SELECT 
    CustomerID,
    CompanyName,
    REVERSE(CompanyName) AS CompanyNameReversed
FROM SalesLT.Customer;


---------------------------------------------------------
-- Task #7  
-- Combine all CompanyName values into a single aggregated  
-- string using STRING_AGG.
---------------------------------------------------------
SELECT STRING_AGG(CompanyName, ', ') AS AllCompanies
FROM SalesLT.Customer;


---------------------------------------------------------
-- Task #8  
-- Add a row counter per OrderID using ROW_NUMBER  
-- to identify how many entries each order has inside  
-- the SalesOrderDetail table.
---------------------------------------------------------
SELECT 
    SalesOrderID,
    ProductID,
    ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY ProductID) AS RowNum
FROM SalesLT.SalesOrderDetail;
