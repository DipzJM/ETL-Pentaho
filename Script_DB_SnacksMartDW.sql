/* ============================================================
   DDL Inicial – DataMart SnacksMartDW
   Dim_Customer, Dim_Product, Fact_Sales (grão = OrderDetails)
   DateKey = NUMERIC(8,0) no formato YYYYMMDD
   ============================================================ */

-- 1) Criar BD (se não existir)
IF DB_ID(N'SnacksMartDW') IS NULL
BEGIN
    CREATE DATABASE [SnacksMartDW];
END
GO

USE [SnacksMartDW];
GO

/* (Opcional) Se quiseres recriar do zero (apaga tudo):
-- ALTER DATABASE [SnacksMartDW] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- DROP DATABASE [SnacksMartDW];
-- GO
-- CREATE DATABASE [SnacksMartDW];
-- GO
-- USE [SnacksMartDW];
-- GO
*/

-- 2) Dim_Customer
IF OBJECT_ID(N'dbo.Dim_Customer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Customer
    (
        CustomerKey        INT IDENTITY(1,1) NOT NULL,
        CustomerID         VARCHAR(5)        NOT NULL,   -- NK (OLTP)
        CompanyName        NVARCHAR(80)      NULL,
        ContactName        NVARCHAR(60)      NULL,
        City               NVARCHAR(50)      NULL,
        Region             NVARCHAR(50)      NULL,
        PostalCode         NVARCHAR(20)      NULL,
        Country            NVARCHAR(50)      NULL,
        Version            BIGINT,
        DateFrom           datetime,
        DateTo             datetime,

        CONSTRAINT PK_Dim_Customer PRIMARY KEY (CustomerKey),
        CONSTRAINT UK_Dim_Customer_CustomerID UNIQUE (CustomerID)
    );
END
GO

-- 3) Dim_Product (produto + categoria desnormalizada)
IF OBJECT_ID(N'dbo.Dim_Product', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Product
    (
        ProductKey         INT IDENTITY(1,1) NOT NULL,
        ProductID          INT               NOT NULL,   -- NK (OLTP)
        ProductName        NVARCHAR(80)      NULL,
        CategoryID         INT               NULL,       -- NK (OLTP) opcional
        CategoryName       NVARCHAR(50)      NULL,
        UnitCostPrice      DECIMAL(10,2)     NULL,
        UnitPrice          DECIMAL(10,2)     NULL,
        Version            BIGINT,
        Date_From          datetime,
        Date_To            datetime,

        CONSTRAINT PK_Dim_Product PRIMARY KEY (ProductKey),
        CONSTRAINT UK_Dim_Product_ProductID UNIQUE (ProductID)
    );
END
GO

-- 4) Fact_Sales (grão = OrderDetails: 1 linha por (OrderID, ProductID))
IF OBJECT_ID(N'dbo.Fact_Sales', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Sales
    (
        -- Degenerate dimension (do OLTP)
        OrderID           INT           NOT NULL,

        -- Chaves para dimensões
        DateKey           NUMERIC(8,0)  NOT NULL,
        CustomerKey       INT           NOT NULL,
        ProductKey        INT           NOT NULL,

        -- Medidas base (do OLTP)
        Quantity          SMALLINT      NOT NULL,
        UnitPrice         DECIMAL(10,2) NOT NULL,
        Discount          REAL,

        -- Medidas derivadas (podem ser calculadas no ETL e gravadas)
        SalesAmount       DECIMAL(12,2) NULL,
        NetSalesAmount    DECIMAL(12,2) NULL,
        VatAmount         DECIMAL(12,2) NULL,
        ShipmentDuration  SMALLINT      NULL,
        OnTime            SMALLINT      NULL,

        -- PK do facto (grão)
        CONSTRAINT PK_Fact_Sales PRIMARY KEY (DateKey, CustomerKey, ProductKey),

        CONSTRAINT FK_Fact_Sales_Dim_Customer
            FOREIGN KEY (CustomerKey) REFERENCES dbo.Dim_Customer(CustomerKey),

        CONSTRAINT FK_Fact_Sales_Dim_Product
            FOREIGN KEY (ProductKey) REFERENCES dbo.Dim_Product(ProductKey)
    );
END
GO

-- 6) Índices recomendados (melhoram joins e filtros)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Fact_Sales_DateKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    CREATE INDEX IX_Fact_Sales_DateKey ON dbo.Fact_Sales (DateKey);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Fact_Sales_CustomerKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    CREATE INDEX IX_Fact_Sales_CustomerKey ON dbo.Fact_Sales (CustomerKey);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Fact_Sales_ProductKey' AND object_id = OBJECT_ID('dbo.Fact_Sales'))
    CREATE INDEX IX_Fact_Sales_ProductKey ON dbo.Fact_Sales (ProductKey);
GO