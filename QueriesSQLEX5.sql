--EX 5.1
SELECT TOP 1 
    dbo.Dim_Product.ProductName, 
    SUM(dbo.Fact_Sales.SalesAmount) AS TotalVendas
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Product ON dbo.Fact_Sales.ProductKey = dbo.Dim_Product.ProductKey
GROUP BY dbo.Dim_Product.ProductName
ORDER BY TotalVendas DESC;
--EX 5.2
SELECT TOP 5 
    dbo.Dim_Product.ProductName, 
    SUM(dbo.Fact_Sales.SalesAmount) AS TotalVendas
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Product ON dbo.Fact_Sales.ProductKey = dbo.Dim_Product.ProductKey
INNER JOIN dbo.Dim_Time ON dbo.Fact_Sales.DateKey = dbo.Dim_Time.DateKey
WHERE dbo.Dim_Time.EnglishWeekDayName = 'Saturday'
GROUP BY dbo.Dim_Product.ProductName
ORDER BY TotalVendas DESC;


--EX 5.3
SELECT TOP 5 
    dbo.Dim_Product.ProductName, 
    SUM(dbo.Fact_Sales.SalesAmount) AS TotalVendas
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Product ON dbo.Fact_Sales.ProductKey = dbo.Dim_Product.ProductKey
INNER JOIN dbo.Dim_Time ON dbo.Fact_Sales.DateKey = dbo.Dim_Time.DateKey
WHERE dbo.Dim_Time.EnglishWeekDayName = 'Sunday'
GROUP BY dbo.Dim_Product.ProductName
ORDER BY TotalVendas ASC;

--EX5.4(Maior)
SELECT TOP 3 
    dbo.Dim_Customer.Country, 
    SUM(dbo.Fact_Sales.SalesAmount) AS TotalVendas
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Customer ON dbo.Fact_Sales.CustomerKey = dbo.Dim_Customer.CustomerKey
GROUP BY dbo.Dim_Customer.Country
ORDER BY TotalVendas DESC;
--MENOR
SELECT TOP 3 
    dbo.Dim_Customer.Country, 
    SUM(dbo.Fact_Sales.SalesAmount) AS TotalVendas
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Customer ON dbo.Fact_Sales.CustomerKey = dbo.Dim_Customer.CustomerKey
GROUP BY dbo.Dim_Customer.Country
ORDER BY TotalVendas ASC;

--EX5.5
SELECT 
    dbo.Dim_Product.CategoryName,
    SUM(dbo.Fact_Sales.NetSalesAmount) AS ReceitaLiquida,
    (SUM(dbo.Fact_Sales.NetSalesAmount) / (SELECT SUM(NetSalesAmount) FROM dbo.Fact_Sales) * 100) AS PercentagemTotal
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Product ON dbo.Fact_Sales.ProductKey = dbo.Dim_Product.ProductKey
GROUP BY dbo.Dim_Product.CategoryName;

--EX5.6
SELECT 
    dbo.Dim_Customer.Country,
    MIN(dbo.Fact_Sales.ShipmentDuration) AS PrazoMin,
    AVG(dbo.Fact_Sales.ShipmentDuration) AS PrazoMedio,
    MAX(dbo.Fact_Sales.ShipmentDuration) AS PrazoMax
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Customer ON dbo.Fact_Sales.CustomerKey = dbo.Dim_Customer.CustomerKey
GROUP BY dbo.Dim_Customer.Country;

--EX5.7
SELECT 
    dbo.Dim_Time.CalendarYear,
    dbo.Dim_Time.CalendarQuarter,
    SUM(dbo.Fact_Sales.SalesAmount) AS VolumeVendas,
    SUM(dbo.Fact_Sales.Quantity) AS QuantidadeVendida
FROM dbo.Fact_Sales
INNER JOIN dbo.Dim_Time ON dbo.Fact_Sales.DateKey = dbo.Dim_Time.DateKey
WHERE dbo.Dim_Time.CalendarYear IN (2024, 2025) 
  AND dbo.Dim_Time.CalendarQuarter IN (2, 3)
GROUP BY dbo.Dim_Time.CalendarYear, dbo.Dim_Time.CalendarQuarter
ORDER BY dbo.Dim_Time.CalendarYear, dbo.Dim_Time.CalendarQuarter;