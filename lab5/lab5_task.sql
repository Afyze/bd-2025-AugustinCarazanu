-- Function that receives a CustomerID and combines first and last name into one string
CREATE FUNCTION dbo.GetCustomerFullName (@CustomerID INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @FullName NVARCHAR(200);

    SELECT @FullName = FirstName + ' ' + LastName
    FROM SalesLT.Customer
    WHERE CustomerID = @CustomerID;

    RETURN @FullName;
END;

-- Function that applies a percentage discount and outputs the final price value
CREATE FUNCTION dbo.GetDiscountedPrice
(
    @ListPrice MONEY,
    @DiscountPercent FLOAT
)
RETURNS MONEY
AS
BEGIN
    RETURN @ListPrice - (@ListPrice * @DiscountPercent / 100.0);
END;

-- Small function that counts how many orders a particular customer has placed
CREATE FUNCTION dbo.GetCustomerOrderCount (@CustomerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @OrderCount INT;

    SELECT @OrderCount = COUNT(*)
    FROM SalesLT.SalesOrderHeader
    WHERE CustomerID = @CustomerID;

    RETURN @OrderCount;
END;

-- Table‑valued function that lists product IDs and names for a specific category ID
CREATE FUNCTION dbo.GetProductsByCategory (@CategoryID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ProductID, Name AS ProductName
    FROM SalesLT.Product
    WHERE ProductCategoryID = @CategoryID
);

-- Produces a list of order IDs where TotalDue surpasses a given amount
CREATE FUNCTION dbo.GetOrdersAboveAmount (@MinAmount MONEY)
RETURNS TABLE
AS
RETURN
(
    SELECT SalesOrderID AS OrderID, TotalDue
    FROM SalesLT.SalesOrderHeader
    WHERE TotalDue > @MinAmount
);

-- Returns a summary for customers whose name matches a given pattern
CREATE FUNCTION dbo.GetCustomerPurchaseSummary (@SearchPattern NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS FullName,
        COUNT(soh.SalesOrderID) AS TotalOrders,
        SUM(soh.TotalDue) AS TotalSpent
    FROM SalesLT.Customer c
    LEFT JOIN SalesLT.SalesOrderHeader soh
        ON c.CustomerID = soh.CustomerID
    WHERE c.FirstName LIKE '%' + @SearchPattern + '%'
       OR c.LastName  LIKE '%' + @SearchPattern + '%'
    GROUP BY c.CustomerID, c.FirstName, c.LastName
);

