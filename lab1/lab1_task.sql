-- Task 1
-- Fetch customers whose address type is either Mail Office or Main Office.
-- Only key personal and address details are shown, sorted alphabetically by first name.
SELECT
    c.Title        AS CustomerTitle,
    c.FirstName,
    c.LastName,
    c.CompanyName,
    a.AddressLine1
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
    ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a
    ON ca.AddressID = a.AddressID
WHERE ca.AddressType IN ('Mail Office', 'Main Office')
ORDER BY c.FirstName;

-- Task 2
-- List products that have no defined color.
-- Displays basic item information, arranged by product name.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.Product AS p
WHERE p.Color IS NULL
ORDER BY p.Name;

-- Task 3
-- Shows all products weighing more than 900.
-- Results are sorted so the heaviest items appear first.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size,
    p.Weight
FROM SalesLT.Product AS p
WHERE p.Weight > 900
ORDER BY p.Weight DESC;

-- Task 4
-- Displays all low‑cost products (under $40).
-- Sorted alphabetically by item name.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.Product AS p
WHERE p.ListPrice < 40
ORDER BY p.Name;

-- Task 5
-- Shows items priced above $50 that are Red or Silver.
-- Basic product properties included.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.Product AS p
WHERE p.ListPrice > 50
  AND p.Color IN ('Red', 'Silver')
ORDER BY p.Name;

-- Task 6
-- Products belonging to Brakes or Mountain Bikes categories.
-- Join with category table to filter items properly.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc
    ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name IN ('Brakes', 'Mountain Bikes')
ORDER BY p.Name;

-- Task 7
-- Retrieves products in Clothing, Mountain Bikes, or Road Bikes.
-- Again filtered by category name.
SELECT
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc
    ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name IN ('Clothing', 'Mountain Bikes', 'Road Bikes')
ORDER BY p.Name;

-- Task 8
-- Products from specific categories that were actually ordered.
-- Includes order details along with product info.
SELECT
    sod.SalesOrderID AS OrderID,
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p
    ON sod.ProductID = p.ProductID
JOIN SalesLT.ProductCategory AS pc
    ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name IN ('Touring Bikes', 'Handlebars', 'Bottom Brackets')
ORDER BY p.Name;

-- Task 9
-- Same as Task 8 but only for Forks category.
SELECT
    sod.SalesOrderID AS OrderID,
    p.ProductNumber,
    p.Name,
    p.Color,
    p.StandardCost,
    p.ListPrice AS LastPrice,
    p.Size
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p
    ON sod.ProductID = p.ProductID
JOIN SalesLT.ProductCategory AS pc
    ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Forks'
ORDER BY p.Name;

-- Task 10
-- Orders where the product unit price exceeds $100.
-- Includes order info plus the customer’s name.
SELECT
    soh.OrderDate,
    p.Name        AS ProductName,
    sod.UnitPrice AS ProductPrice,
    sod.OrderQty  AS Quantity,
    soh.CustomerID,
    c.FirstName,
    c.LastName
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
JOIN SalesLT.Customer AS c
    ON soh.CustomerID = c.CustomerID
JOIN SalesLT.Product AS p
    ON sod.ProductID = p.ProductID
WHERE sod.UnitPrice > 100
ORDER BY soh.OrderDate, p.Name;

-- Task 11
-- Lists orders that include more than one distinct product.
-- Uses GROUP BY to count items per order.
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    COUNT(DISTINCT sod.ProductID) AS NumberOfProducts,
    SUM(sod.OrderQty)             AS TotalQuantity
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID
HAVING COUNT(DISTINCT sod.ProductID) > 1
ORDER BY soh.SalesOrderID;

-- Task 12
-- Anonymize customers from Sports Store.
-- First anonymize their orders, then mask their personal fields.
UPDATE soh
SET soh.CustomerID = -1
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Customer AS c
    ON soh.CustomerID = c.CustomerID
WHERE c.CompanyName = 'Sports Store';

UPDATE SalesLT.Customer
SET Title        = '****',
    FirstName    = '****',
    MiddleName   = '****',
    LastName     = '****',
    SalesPerson  = '****',
    EmailAddress = '****',
    Phone        = '****'
WHERE CompanyName = 'Sports Store';

-- Task 13
-- For customers 29638 and 30025: anonymize their orders and remove them entirely.
UPDATE SalesLT.SalesOrderHeader
SET CustomerID = -1
WHERE CustomerID IN (29638, 30025);

DELETE FROM SalesLT.Customer
WHERE CustomerID IN (29638, 30025);
