/*-----------------------------------------------------------
    TASK 1 — Transaction + Error Logging
    This block creates an error log table and demonstrates 
    how to use a TRY/CATCH structure to handle failures.
-----------------------------------------------------------*/

-- 1. Create logging table for storing caught errors
CREATE TABLE dbo.ErrorLog_Transactions (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(4000),
    ErrorTime DATETIME,
    ActionDescription NVARCHAR(500)
);

------------------------------------------------------------
-- 2. Transaction using TRY/CATCH
------------------------------------------------------------

DECLARE @CustomerID INT;
DECLARE @NewEmail NVARCHAR(200) = 'this_email_is_way_too_long_to_fit_in_the_column_and_will_definitely_break_the_update_operation@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com';

BEGIN TRY
    BEGIN TRAN;

    -- Pick any customer from the table
    SELECT TOP 1 @CustomerID = CustomerID FROM SalesLT.Customer;

    -- Apply 10% discount to all order subtotals of that customer
    UPDATE SalesLT.SalesOrderHeader
    SET SubTotal = SubTotal * 0.9
    WHERE CustomerID = @CustomerID;

    -- Force an error by updating the email with an oversized value
    UPDATE SalesLT.Customer
    SET EmailAddress = @NewEmail
    WHERE CustomerID = @CustomerID;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;

    INSERT INTO dbo.ErrorLog_Transactions (ErrorMessage, ErrorTime, ActionDescription)
    VALUES (
        ERROR_MESSAGE(),
        GETDATE(),
        'Attempted to apply discount and update email for a customer'
    );
END CATCH;

/*-----------------------------------------------------------
    TASK 2 — Trigger to keep track of email edits
    This will create a log table and a trigger that records
    every time a customer's email is modified.
-----------------------------------------------------------*/

-- Table for storing email update history
CREATE TABLE dbo.CustomerEmailAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OldEmail NVARCHAR(255),
    NewEmail NVARCHAR(255),
    ChangeTimestamp DATETIME
);

------------------------------------------------------------
-- Trigger that runs after every UPDATE
------------------------------------------------------------

CREATE TRIGGER trg_LogEmailChange
ON SalesLT.Customer
AFTER UPDATE
AS
BEGIN
    -- Only log if the email value is actually modified
    IF UPDATE(EmailAddress)
    BEGIN
        INSERT INTO dbo.CustomerEmailAudit (CustomerID, OldEmail, NewEmail, ChangeTimestamp)
        SELECT
            d.CustomerID,
            d.EmailAddress,
            i.EmailAddress,
            GETDATE()
        FROM deleted d
        INNER JOIN inserted i ON d.CustomerID = i.CustomerID
        WHERE d.EmailAddress <> i.EmailAddress;
    END
END;
GO

-- To test:
-- UPDATE SalesLT.Customer SET EmailAddress = 'new@mail.com' WHERE CustomerID = 1;

/*-----------------------------------------------------------
    TASK 3 — Cursor Example
    This section creates a table to store original and recalculated 
    prices, then iterates through all products using a cursor.
-----------------------------------------------------------*/

-- Table to store original & recalculated prices
CREATE TABLE dbo.ProductAdjustedPrices (
    ProductID INT,
    OriginalPrice MONEY,
    AdjustedPrice MONEY
);

DECLARE @ProdID INT;
DECLARE @Price MONEY;

-- Cursor selecting all products
DECLARE price_cursor CURSOR FOR
SELECT ProductID, ListPrice
FROM SalesLT.Product;

OPEN price_cursor;
FETCH NEXT FROM price_cursor INTO @ProdID, @Price;

-- Loop through each product row
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.ProductAdjustedPrices (ProductID, OriginalPrice, AdjustedPrice)
    VALUES (@ProdID, @Price, @Price * 1.05);

    FETCH NEXT FROM price_cursor INTO @ProdID, @Price;
END

CLOSE price_cursor;
DEALLOCATE price_cursor;
