SET NOCOUNT ON;
USE [Moskatel];
GO

/* ============================================================
   Script de "actualização" (incremental) – BD Moskatel
   Objectivos:
   1) Alterar alguns registos em Customers e Products, actualizando ChangeDateTime
      (para simular SCD no carregamento do Data Warehouse).
   2) Inserir novas encomendas (Orders) e linhas (OrderDetails)
      com datas entre 2026-01-01 e 2026-03-31.

   NOTAS:
   - Assume que a carga inicial criou Orders 1..1000 e OrderDetails 3000.
   - As alterações de ChangeDateTime em Customers/Products devem ser detectadas
     pelo ETL do DW (SCD Tipo 1 ou Tipo 2, conforme as tuas regras).
   ============================================================ */

BEGIN TRY
    BEGIN TRAN;

    /* ------------------------------------------------------------
       1) Alterações em Customers (exemplos: contacto, morada, telefone)
          e actualização do ChangeDateTime (SCD trigger no DW)
       ------------------------------------------------------------ */
    DECLARE @dtCust datetime = '2026-02-15T10:30:00';

    UPDATE dbo.Customers
    SET ContactTitle   = N'Gestor(a) de Compras',
        Phone          = N'+351 211234567',
        Address        = N'Av. da Liberdade, 125',
        City           = N'Lisboa',
        Region         = N'Lisboa',
        PostalCode     = N'1250-140',
        ChangeDateTime = @dtCust
    WHERE CustomerID = 'C0007';

    UPDATE dbo.Customers
    SET ContactTitle   = N'Director(a) Comercial',
        Phone          = N'+351 229876543',
        Address        = N'Rua do Comércio, 44',
        City           = N'Porto',
        Region         = N'Porto',
        PostalCode     = N'4050-253',
        ChangeDateTime = DATEADD(MINUTE, 5, @dtCust)
    WHERE CustomerID = 'C0042';

    UPDATE dbo.Customers
    SET ContactTitle   = N'Responsável de Logística',
        Phone          = N'+351 234111222',
        Address        = N'Av. República, 9',
        City           = N'Aveiro',
        Region         = N'Aveiro',
        PostalCode     = N'3810-123',
        ChangeDateTime = DATEADD(MINUTE, 10, @dtCust)
    WHERE CustomerID = 'C0101';

    UPDATE dbo.Customers
    SET ContactTitle   = N'Administrador(a)',
        Phone          = N'+351 253555444',
        Address        = N'Rua Nova, 18',
        City           = N'Braga',
        Region         = N'Braga',
        PostalCode     = N'4710-001',
        ChangeDateTime = DATEADD(MINUTE, 15, @dtCust)
    WHERE CustomerID = 'C0120';

    UPDATE dbo.Customers
    SET ContactTitle   = N'Gestor(a) de Produto',
        Phone          = N'+351 239333222',
        Address        = N'Rua do Mercado, 77',
        City           = N'Coimbra',
        Region         = N'Coimbra',
        PostalCode     = N'3000-210',
        ChangeDateTime = DATEADD(MINUTE, 20, @dtCust)
    WHERE CustomerID = 'C0188';

    /* ------------------------------------------------------------
       2) Alterações em Products (exemplos: preço, stock, discontinued)
          e actualização do ChangeDateTime
       ------------------------------------------------------------ */
    DECLARE @dtProd datetime = '2026-02-20T09:00:00';

    UPDATE dbo.Products
    SET UnitPrice      = ROUND(UnitPrice * 1.06, 2),
        UnitsInStock   = UnitsInStock + 25,
        UnitsOnOrder   = CASE WHEN UnitsOnOrder > 0 THEN UnitsOnOrder - 2 ELSE 0 END,
        ChangeDateTime = @dtProd
    WHERE ProductID IN (3, 7, 12, 18, 25);

    UPDATE dbo.Products
    SET UnitPrice      = ROUND(UnitPrice * 0.95, 2),
        UnitsInStock   = CASE WHEN UnitsInStock >= 10 THEN UnitsInStock - 10 ELSE UnitsInStock END,
        Discontinued   = 1,
        ChangeDateTime = DATEADD(DAY, 1, @dtProd)
    WHERE ProductID IN (41, 58);

    UPDATE dbo.Products
    SET UnitPrice      = ROUND(UnitPrice * 1.12, 2),
        UnitsInStock   = UnitsInStock + 10,
        Discontinued   = 0,
        ChangeDateTime = DATEADD(DAY, 2, @dtProd)
    WHERE ProductID IN (79, 96, 105);

    /* ------------------------------------------------------------
       3) Inserir novas Orders (ex.: +200) entre 2026-01-01 e 2026-03-31
          e respectivas OrderDetails (3 por encomenda => +600 linhas)
       ------------------------------------------------------------ */
    DECLARE @DataInicio date = '2026-01-01';
    DECLARE @DataFim    date = '2026-03-31';
    DECLARE @NOrders    int  = 200;

    -- Guardar OrderIDs gerados (IDENTITY) para inserir OrderDetails
    DECLARE @NewOrders TABLE
    (
        OrderID int NOT NULL PRIMARY KEY
    );

    ;WITH N AS
    (
        SELECT TOP (@NOrders) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ),
    O AS
    (
        SELECT
            -- escolher um cliente "aleatório"
            (SELECT TOP 1 CustomerID FROM dbo.Customers ORDER BY NEWID()) AS CustomerID,

            -- OrderDate entre @DataInicio e @DataFim, com hora 08:00..19:59
            DATEADD(MINUTE,
                (ABS(CHECKSUM(NEWID())) % (12*60)),  -- 0..719 minutos
                DATEADD(HOUR, 8,
                    CAST(DATEADD(DAY,
                        (ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, @DataInicio, @DataFim) + 1)),
                        @DataInicio
                    ) AS datetime)
                )
            ) AS OrderDate
        FROM N
    )
    INSERT INTO dbo.Orders
    (
        CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
        ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
    )
    OUTPUT INSERTED.OrderID INTO @NewOrders(OrderID)
    SELECT
        o.CustomerID,
        CONCAT('E', RIGHT(CONCAT('00', CAST(1 + (ABS(CHECKSUM(NEWID())) % 25) AS varchar(2))), 3)) AS EmployeeID,
        o.OrderDate,
        DATEADD(DAY, 3 + (ABS(CHECKSUM(NEWID())) % 12), o.OrderDate) AS RequiredDate,
        CASE WHEN (ABS(CHECKSUM(NEWID())) % 100) < 92
             THEN DATEADD(DAY, 1 + (ABS(CHECKSUM(NEWID())) % 10), o.OrderDate)
             ELSE NULL
        END AS ShippedDate,
        1 + (ABS(CHECKSUM(NEWID())) % 3) AS ShipVia,
        CAST(5 + (ABS(CHECKSUM(NEWID())) % 196) + (ABS(CHECKSUM(NEWID())) % 100) / 100.0 AS decimal(10,2)) AS Freight,
        c.CompanyName AS ShipName,
        c.Address     AS ShipAddress,
        c.City        AS ShipCity,
        c.Region      AS ShipRegion,
        c.PostalCode  AS ShipPostalCode,
        c.Country     AS ShipCountry
    FROM O o
    JOIN dbo.Customers c ON c.CustomerID = o.CustomerID;

    -- Inserir 3 linhas de detalhe por encomenda recém-criada (total = @NOrders * 3)
    ;WITH OD AS
    (
        SELECT n.OrderID
        FROM @NewOrders n
    ),
    L AS
    (
        SELECT
            od.OrderID,
            p.ProductID,
            CAST(ROUND(p.UnitPrice + ((ABS(CHECKSUM(NEWID())) % 101) - 50) / 100.0, 2) AS decimal(10,2)) AS UnitPrice,
            CAST(1 + (ABS(CHECKSUM(NEWID())) % 10) AS smallint) AS Quantity,
            CAST(
                CASE (ABS(CHECKSUM(NEWID())) % 7)
                    WHEN 0 THEN 0.00
                    WHEN 1 THEN 0.00
                    WHEN 2 THEN 0.00
                    WHEN 3 THEN 0.05
                    WHEN 4 THEN 0.10
                    WHEN 5 THEN 0.15
                    ELSE 0.20
                END
            AS real) AS Discount
        FROM OD od
        CROSS APPLY
        (
            SELECT TOP 3 ProductID, UnitPrice
            FROM dbo.Products
            ORDER BY NEWID()
        ) p
    )
    INSERT INTO dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
    FROM L;

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
END CATCH;
GO
