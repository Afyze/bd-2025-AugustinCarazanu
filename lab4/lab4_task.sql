/* ------------------------------------------------------------
   TASK 1 — Split products into 3 pricing groups
   ------------------------------------------------------------
   Goal:
   Loop through all products and place them into 3 temp tables
   based on their ListPrice value.
-------------------------------------------------------------*/

-- Temporary tables for each pricing tier
CREATE TABLE #BudgetProducts (
    ProductID INT,
    ProductName NVARCHAR(255),
    ProductPrice MONEY
);

CREATE TABLE #MediumProducts (
    ProductID INT,
    ProductName NVARCHAR(255),
    ProductPrice MONEY
);

CREATE TABLE #PremiumProducts (
    ProductID INT,
    ProductName NVARCHAR(255),
    ProductPrice MONEY
);

-- Helper table to iterate through
SELECT 
    ProductID,
    Name AS ProductName,
    ListPrice
INTO #TempProd
FROM SalesLT.Product;

-- Variables for looping
DECLARE @ID INT, @Name NVARCHAR(255), @Price MONEY;

-- Continue looping while there are still rows
WHILE EXISTS (SELECT 1 FROM #TempProd)
BEGIN
    -- Fetch one product
    SELECT TOP 1 
        @ID = ProductID,
        @Name = ProductName,
        @Price = ListPrice
    FROM #TempProd;

    -- Decide where this product belongs
    IF @Price BETWEEN 9 AND 1600
        INSERT INTO #BudgetProducts VALUES (@ID, @Name, @Price);
    ELSE IF @Price BETWEEN 1601 AND 2500
        INSERT INTO #MediumProducts VALUES (@ID, @Name, @Price);
    ELSE IF @Price >= 2501
        INSERT INTO #PremiumProducts VALUES (@ID, @Name, @Price);

    -- Remove processed record
    DELETE FROM #TempProd WHERE ProductID = @ID;
END;

-- Displaying the categorized results
SELECT * FROM #BudgetProducts;
SELECT * FROM #MediumProducts;
SELECT * FROM #PremiumProducts;

/* ------------------------------------------------------------
   TASK 2 — Compute total sales value for each parent category
   ------------------------------------------------------------
   Goal:
   Use a WHILE loop to add up all order costs per parent 
   category, and load results into a temp table.
-------------------------------------------------------------*/

-- Temp table for final aggregated result
CREATE TABLE #ParentProductCategories (
    ProductCategoryID INT,
    ProductCategoryName NVARCHAR(255),
    TotalPrice MONEY
);

-- Create list of parent categories to iterate through
SELECT 
    ProductCategoryID,
    Name AS CategoryName
INTO #TempParent
FROM SalesLT.ProductCategory
WHERE ParentProductCategoryID IS NULL;

-- Variables for looping
DECLARE @CatID INT, @CatName NVARCHAR(255), @Total MONEY;

-- Loop until no categories left
WHILE EXISTS (SELECT 1 FROM #TempParent)
BEGIN
    -- Get next category
    SELECT TOP 1 
        @CatID = ProductCategoryID,
        @CatName = CategoryName
    FROM #TempParent;

    -- Compute total line price for this category
    SELECT @Total = SUM(SOD.LineTotal)
    FROM SalesLT.SalesOrderDetail SOD
    JOIN SalesLT.Product P ON SOD.ProductID = P.ProductID
    JOIN SalesLT.ProductCategory C ON P.ProductCategoryID = C.ProductCategoryID
    WHERE C.ParentProductCategoryID = @CatID;

    -- Store the results
    INSERT INTO #ParentProductCategories
    VALUES (@CatID, @CatName, @Total);

    -- Remove processed category
    DELETE FROM #TempParent WHERE ProductCategoryID = @CatID;
END;

-- Final output
SELECT * FROM #ParentProductCategories;
