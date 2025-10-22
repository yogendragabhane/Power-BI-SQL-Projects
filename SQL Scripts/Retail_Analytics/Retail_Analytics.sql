# Retail Analytics Case Study

-- Q-1 - Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique values and 
        remove the the original table from the databases and replace the name of the new table with the original name.


          Select TransactionID, Count(*) 
          From sales_transaction
          Group By TransactionID
          Having Count(*) > 1;                                 
        
          Create table sales_transaction1 (select Distinct * from sales_transaction);          
          
          Drop table sales_transaction;                        
          
          Alter table sales_transaction1 rename sales_transaction;
          
          Select * from sales_transaction;



-- Q-2 - Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
                Also, update those discrepancies to match the price in both the tables.

        Select s.TransactionId,s.Price As TransactionPrice,p.price as InventoryPrice 
        From sales_transaction s Inner Join product_inventory p On s.productid = p.productid
        Where s.Price <> p.price;
        
        Update sales_transaction S Inner Join product_inventory P
        On S.Productid = P.Productid 
        Set S.price = P.price Where S.price <> P.price;
        
        Select * From sales_transaction;



-- Q-3 - Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.


        Select Count(*) From customer_profiles Where Gender IS NULL OR Location IS NULL OR joinDate IS NULL;
        
        
        Update customer_profiles Set Location = "Unknown" Where Location Is Null;
        
        
        Select * From customer_profiles;
        

-- Q-4 - Write a SQL query to clean the DATE column in the dataset.

        Create Table Sales_transaction_updated As 
        (Select * From Sales_transaction);
        
        Alter Table Sales_transaction_updated Add Column TransactionDate_updated Date; 
        
        Update Sales_transaction_updated 
        Set TransactionDate_updated = transactiondate;
        
        Drop Table Sales_transaction;
        
        Alter Table Sales_transaction_updated
        
        rename TO Sales_transaction;
        
        Select * From Sales_transaction;
        


-- Q-5 - Write a SQL query to summarize the total sales and quantities sold per product by the company.


        Select ProductID, Sum(QuantityPurchased) As TotalUnitsSold, Sum(Price*QuantityPurchased) As TotalSales
        From Sales_transaction
        Group By ProductID
        Order By Sum(Price*QuantityPurchased) Desc;


-- Q-6 - Write a SQL query to count the number of transactions per customer to understand purchase frequency.

        Select CustomerId, Count(Distinct (TransactionID)) As NumberOfTransactions
        From Sales_transaction
        Group By CustomerId
        Order By NumberOfTransactions Desc;

-- Q-7 - Write a SQL query to evaluate the performance of the product categories based on the total sales which help us 
        understand the product categories which needs to be promoted in the marketing campaigns.

        Select P.Category, Sum(S.Quantitypurchased) As TotalUnitsSold, Sum(S.Price*S.Quantitypurchased) As TotalSales 
        From product_inventory P Inner Join Sales_transaction S
        On P.Productid = S.Productid
        Group By P.Category
        Order By TotalSales Desc;

-- Q-8 - Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions.
        This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.
                
        Select ProductID, Sum(Price*QuantityPurchased) as TotalRevenue
        from Sales_transaction
        Group By ProductID
        Order By TotalRevenue  Desc
        Limit 10;

-- Q-9 - Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
        provided that at least one unit was sold for those products.

        Select ProductID,Sum(QuantityPurchased) As TotalUnitsSold
        From Sales_transaction
        Group By ProductID
        Having Sum(QuantityPurchased) >=1
        Order By TotalUnitsSold
        Limit 10;

-- Q-10 - Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

        Select Cast(Transactiondate as Date) as DATETRANS, 
        Count(TransactionID) As Transaction_count,
        Sum(QuantityPurchased) as TotalUnitsSold, 
        Sum(Price*QuantityPurchased) as TotalSales
        From Sales_transaction
        Group By Transactiondate
        Order By Transactiondate Desc;

-- Q-11 - Write a SQL query to understand the month on month growth rate of sales of the company which will help 
        understand the growth trend of the company.

        With CTE_A As
        (
        Select month(TransactionDate) As month, Round(Sum(QuantityPurchased * Price),2) As total_sales,
        Round(Lag(Sum(QuantityPurchased * Price)) Over (Order By Month(TransactionDate)),2) As previous_month_sales
        From Sales_transaction
        Group By month
        Order By month
        )
        Select month,total_sales,previous_month_sales,
        Round((total_sales - previous_month_sales)/previous_month_sales*100,2) As mom_growth_percentage
        from CTE_A
        ;


-- Q-12 - Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
        which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.


        Select CustomerID,Count(TransactionID) As NumberOfTransactions,
        Sum(QuantityPurchased * Price) As TotalSpent
        From Sales_transaction
        Group By CustomerID
        Having Count(TransactionID) > 10 AND Sum(QuantityPurchased * Price) > 1000
        Order By Sum(QuantityPurchased * Price) Desc;
        


-- Q-13 - Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
        which will help us understand the customers who are occasional customers or have low purchase frequency in the company.


        Select CustomerID,Count(TransactionID) As NumberOfTransactions,
        Sum(QuantityPurchased * Price) As TotalSpent
        From Sales_Transaction
        Group By CustomerID
        Having  Count(TransactionID) <= 2
        Order By NumberOfTransactions ASC,TotalSpent DESC;


-- Q-14 - Write a SQL query that describes the total number of purchases made by each customer against each productID to understand 
        the repeat customers in the company.


        Select CustomerID,ProductID,Count(ProductID) As TimesPurchased
        From Sales_transaction
        Group By CustomerID,ProductID
        Having Count(ProductID) > 1
        Order By TimesPurchased Desc;


-- Q-15 - Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular 
        company to understand the loyalty of the customer.


        Select CustomerID,Min(Cast(TransactionDate As Date)) As FirstPurchase,
        Max(Cast(TransactionDate As Date)) As LastPurchase,
        Datediff(Max(Cast(TransactionDate As Date)),Min(Cast(TransactionDate As Date))) As DaysBetweenPurchases
        From Sales_transaction
        Group By CustomerID
        Having Max(Cast(TransactionDate As Date)) - Min(Cast(TransactionDate As Date)) > 0
        Order By DaysBetweenPurchases Desc;


-- Q-16 - Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, 
        count the number of customers in each segment which will help us target a particular segment for marketing.


        Create table customer_segment As 
        Select CP.CustomerID,Sum(QuantityPurchased) total_quantity,
        Case 
            When Sum(QuantityPurchased) Between 1 AND 10 Then "Low"
            When Sum(QuantityPurchased) Between 11 AND 30 Then "Mid"
            Else "High"
            End As CustomerSegment
        From Customer_profiles CP Inner Join Sales_transaction ST
        On CP.CustomerID = ST.CustomerID
        Group By CP.CustomerID;
        
        Select CustomerSegment,Count(*) From customer_segment
        Group By CustomerSegment;
