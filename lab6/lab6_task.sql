/*---------------------------------------------------------------
    Task 1 — Procedure to Show All Orders of a Given Customer

    - This procedure receives a CustomerID.
    - It returns all orders tied to that customer together with:
        • SalesOrderID
        • Order date
        • Total amount
        • Total quantity of items in that order
    - Uses SalesOrderHeader + SalesOrderDetail.
    - Orders the output from newest to oldest.
    - If no orders exist, the result is simply empty.
----------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        h.SalesOrderID,
        h.OrderDate,
        h.TotalDue,
        SUM(d.OrderQty) AS TotalItems
    FROM SalesLT.SalesOrderHeader h
    JOIN SalesLT.SalesOrderDetail d 
        ON h.SalesOrderID = d.SalesOrderID
    WHERE h.CustomerID = @CustomerID
    GROUP BY h.SalesOrderID, h.OrderDate, h.TotalDue
    ORDER BY h.OrderDate DESC;
END;
GO

/*---------------------------------------------------------------
    Task 2 — Procedure to Modify a Product's List Price

    - Accepts ProductID and a new price value.
    - First verifies:
        • The product exists
        • The new price is positive
    - Updates ListPrice if validation passes.
    - Returns a clear success message.
    - Raises an error if the product is not found.
----------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.UpdateProductPrice
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    IF (@NewPrice <= 0)
    BEGIN
        RAISERROR('Price must be greater than zero.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM SalesLT.Product WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('This product does not exist.', 16, 1);
        RETURN;
    END;

    UPDATE SalesLT.Product
    SET ListPrice = @NewPrice
    WHERE ProductID = @ProductID;

    PRINT 'Price updated successfully.';
END;
GO

/*---------------------------------------------------------------
    Task 3 — Procedure for Adding, Editing, or Removing Customers

    - Requires CustomerID at minimum.
    - Receives an @Action parameter (INSERT / UPDATE / DELETE).
    - Remaining customer data is sent as a CSV-style string.
    - Depending on @Action:
        • INSERT → adds new customer
        • UPDATE → updates existing record
        • DELETE → removes customer
    - At the end, prints confirmation containing the CustomerID.
----------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.ManageCustomer
    @CustomerID INT,
    @Action NVARCHAR(10),
    @Data NVARCHAR(MAX) = NULL  -- format: 'Title,FirstName,LastName,Email'
AS
BEGIN
    IF @CustomerID IS NULL
    BEGIN
        RAISERROR('CustomerID is required.', 16, 1);
        RETURN;
    END;

    DECLARE 
        @Title NVARCHAR(20),
        @First NVARCHAR(50),
        @Last NVARCHAR(50),
        @Email NVARCHAR(100);

    -- Break input string into fields if provided
    IF @Data IS NOT NULL
    BEGIN
        SELECT 
            @Title = PARSENAME(REPLACE(@Data, ',', '.'), 4),
            @First = PARSENAME(REPLACE(@Data, ',', '.'), 3),
            @Last  = PARSENAME(REPLACE(@Data, ',', '.'), 2),
            @Email = PARSENAME(REPLACE(@Data, ',', '.'), 1);
    END;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO SalesLT.Customer (CustomerID, Title, FirstName, LastName, EmailAddress)
        VALUES (@CustomerID, @Title, @First, @Last, @Email);

        PRINT 'Customer ' + CAST(@CustomerID AS NVARCHAR) + ' was successfully inserted.';
        RETURN;
    END;

    IF @Action = 'UPDATE'
    BEGIN
        UPDATE SalesLT.Customer
        SET 
            Title = @Title,
            FirstName = @First,
            LastName = @Last,
            EmailAddress = @Email
        WHERE CustomerID = @CustomerID;

        PRINT 'Customer ' + CAST(@CustomerID AS NVARCHAR) + ' was successfully updated.';
        RETURN;
    END;

    IF @Action = 'DELETE'
    BEGIN
        DELETE FROM SalesLT.Customer
        WHERE CustomerID = @CustomerID;

        PRINT 'Customer ' + CAST(@CustomerID AS NVARCHAR) + ' was successfully deleted.';
        RETURN;
    END;

    RAISERROR('Invalid action type. Use INSERT/UPDATE/DELETE.', 16, 1);
END;
GO
