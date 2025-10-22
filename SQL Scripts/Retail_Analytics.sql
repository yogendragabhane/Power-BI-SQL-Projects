# Retail Analytics Case Study

-- Q-1 - Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique values and 
        remove the the original table from the databases and replace the name of the new table with the original name.


  Select TransactionID, Count(*) 
  From sales_transaction
  group by TransactionID
  having count(*) > 1;
  Create table sales_transaction1 
  (select Distinct * from sales_transaction
  );
  
  Drop table sales_transaction;
  
  Alter table sales_transaction1
  
  rename sales_transaction;
  
  Select * from sales_transaction;
