-- Retrieve each order together with its date, amount due,
-- and the complete customer name who placed it
SELECT 
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOH.TotalDue,
    CONCAT(C.Title, ' ', C.FirstName, ' ', C.LastName) AS FullName
FROM SalesLT.SalesOrderHeader AS SOH
JOIN SalesLT.Customer AS C 
    ON SOH.CustomerID = C.CustomerID;

-- List all products that appear in any order, showing name and price
SELECT DISTINCT 
    P.Name,
    P.ListPrice
FROM SalesLT.Product AS P
JOIN SalesLT.SalesOrderDetail AS SOD
    ON P.ProductID = SOD.ProductID;

-- Display each product along with the number of times it was ordered;
-- include items that never appeared in any order
SELECT 
    P.ProductID,
    P.Name,
    COUNT(SOD.ProductID) AS TimesOrdered
FROM SalesLT.Product AS P
LEFT JOIN SalesLT.SalesOrderDetail AS SOD
    ON P.ProductID = SOD.ProductID
GROUP BY 
    P.ProductID, 
    P.Name;

-- For each customer, show their latest order date using a subquery
SELECT 
    C.CustomerID,
    C.FirstName,
    C.LastName,
    (SELECT MAX(SOH.OrderDate)
     FROM SalesLT.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = C.CustomerID) AS LatestOrder
FROM SalesLT.Customer AS C;

-- CTE used to total sales per customer;
-- later select the customers with the highest amounts spent
WITH TotalSales AS (
    SELECT 
        C.CustomerID,
        C.FirstName,
        C.LastName,
        SUM(SOD.LineTotal) AS TotalSpent
    FROM SalesLT.Customer AS C
    JOIN SalesLT.SalesOrderHeader AS SOH 
        ON C.CustomerID = SOH.CustomerID
    JOIN SalesLT.SalesOrderDetail AS SOD 
        ON SOH.SalesOrderID = SOD.SalesOrderID
    GROUP BY 
        C.CustomerID, C.FirstName, C.LastName
)
SELECT *
FROM TotalSales
ORDER BY TotalSpent DESC;

-- Select products that exceed the average ListPrice within
-- their category by comparing each to a subquery
SELECT 
    P.ProductID,
    P.Name,
    P.ListPrice,
    P.ProductCategoryID
FROM SalesLT.Product AS P
WHERE P.ListPrice >
      (SELECT AVG(P2.ListPrice)
       FROM SalesLT.Product AS P2
       WHERE P2.ProductCategoryID = P.ProductCategoryID);

-- Use a CTE to calculate average spending per customer, 
-- then join back to the Customer table to show their names
WITH AvgOrder AS (
    SELECT 
        SOH.CustomerID,
        AVG(SOH.TotalDue) AS AvgTotal
    FROM SalesLT.SalesOrderHeader AS SOH
    GROUP BY SOH.CustomerID
)
SELECT 
    C.CustomerID,
    C.FirstName,
    C.LastName,
    A.AvgTotal
FROM AvgOrder AS A
JOIN SalesLT.Customer AS C
    ON A.CustomerID = C.CustomerID;

-- Provide a detailed view of orders: customer name, product name,
-- quantity, line total, and when the order was placed
SELECT 
    SOH.SalesOrderID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    P.Name AS ProductName,
    SOD.OrderQty,
    SOD.LineTotal,
    SOH.OrderDate
FROM SalesLT.SalesOrderHeader AS SOH
JOIN SalesLT.Customer AS C
    ON SOH.CustomerID = C.CustomerID
JOIN SalesLT.SalesOrderDetail AS SOD
    ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN SalesLT.Product AS P
    ON SOD.ProductID = P.ProductID;

-- Rank each customer's orders by TotalDue, then pick only their top 3
WITH OrderRank AS (
    SELECT 
        SOH.CustomerID,
        SOH.SalesOrderID,
        SOH.TotalDue,
        ROW_NUMBER() OVER (
            PARTITION BY SOH.CustomerID
            ORDER BY SOH.TotalDue DESC
        ) AS Ranking
    FROM SalesLT.SalesOrderHeader AS SOH
)
SELECT *
FROM OrderRank
WHERE Ranking <= 3
ORDER BY CustomerID, Ranking;
