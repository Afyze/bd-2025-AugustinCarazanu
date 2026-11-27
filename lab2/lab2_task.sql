------------------------------------------------------------
-- Lab 2
------------------------------------------------------------

-- #1 Count how many entries exist in the Product table
SELECT COUNT(*) AS TotalProducts
FROM SalesLT.Product;


-- #2 Count total customers stored in the Customer table
SELECT COUNT(*) AS TotalCustomers
FROM SalesLT.Customer;


-- #3 Determine how many customers are Male vs Female
-- (Assuming the 'Gender' column exists in your version)
SELECT Gender, COUNT(*) AS TotalByGender
FROM SalesLT.Customer
GROUP BY Gender;


-- #4 Find how often each product appears in sales orders
SELECT
    p.ProductID,
    p.Name,
    COUNT(sod.ProductID) AS TimesOrdered
FROM SalesLT.Product AS p
LEFT JOIN SalesLT.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TimesOrdered DESC;


-- #5 Show how many orders belong to each customer
SELECT
    soh.CustomerID,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM SalesLT.SalesOrderHeader AS soh
GROUP BY soh.CustomerID
ORDER BY NumberOfOrders DESC;


-- #6 Compute total product cost per order
SELECT
    sod.SalesOrderID,
    SUM(sod.LineTotal) AS OrderTotal
FROM SalesLT.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY OrderTotal DESC;


-- #7 Display orders containing more than one type of product
SELECT
    sod.SalesOrderID,
    COUNT(DISTINCT sod.ProductID) AS ProductCount
FROM SalesLT.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
HAVING COUNT(DISTINCT sod.ProductID) > 1;


-- #8 Display orders that include only a single product
SELECT
    sod.SalesOrderID,
    COUNT(DISTINCT sod.ProductID) AS ProductCount
FROM SalesLT.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
HAVING COUNT(DISTINCT sod.ProductID) = 1;


-- #9 Calculate the total number of units purchased per order
SELECT
    sod.SalesOrderID,
    SUM(sod.OrderQty) AS TotalUnits
FROM SalesLT.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
ORDER BY TotalUnits DESC;
