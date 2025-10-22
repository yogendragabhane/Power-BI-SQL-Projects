
                                            -- E-Commerce_Sales_Analysis.sql scripts 


-- Q1 - Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

    Select location,Count(customer_id) as number_of_customers
    From customers
    Group By location
    Order By Count(customer_id) Desc
    Limit 3;


-- Q2 - Determine the distribution of customers by the number of orders placed.This insight will help in segmenting customers into one-time buyers, 
    occasional shoppers, and regular customers for tailored marketing strategies.

    With CTE_A As (
    Select customer_id, count(order_id) as NumberOfOrders,
    Case
    When Count(order_id) = 1 Then "One_time buyer"
    When Count(order_id) Between 2 AND 4 Then "Occasional Shoppers"
    Else "Regular customers"
    End As Terms
    From Orders
    Group By customer_id
    Order By NumberOfOrders
    )
    Select NumberOfOrders,Count(customer_id) as CustomerCount
    from CTE_A
    Group By NumberOfOrders;
    

-- Q3 - Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.


    Select Product_Id,Avg(quantity) As AvgQuantity,Sum(quantity * price_per_unit) as TotalRevenue
    From OrderDetails
    Group By Product_Id
    Having AvgQuantity = 2
    Order By TotalRevenue Desc;

-- Q4 - For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories 
        have wider appeal across the customer base.

    Select p.category, Count(Distinct o.customer_id) As unique_customers
    From products p Inner Join orderdetails od On p.product_id = od.product_id
    Inner Join orders o On od.order_id = o.order_id
    Group By p.category
    Order By unique_customers Desc;

-- Q5 - Analyze the month-on-month percentage change in total sales to identify growth trends.

    With CTE_A As (
    Select date_format(order_date,"%Y-%m") As Month, Sum(total_amount) As TotalSales,
    Lag(sum(total_amount)) Over (Order By date_format(order_date,"%Y-%m")) As previous_month_sale
    From Orders
    Group By date_format(order_date,"%Y-%m")
    )
    Select 
    Month,TotalSales,
    Round(((TotalSales - previous_month_sale)/
    previous_month_sale*100),2) as PercentChange
    From CTE_A
    ;


-- Q6 - Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

    With CTE_A As (
    Select date_format(order_date,"%Y-%m") As Month,
    Round(Avg(total_amount),2) As AvgOrderValue
    From Orders
    Group By date_format(order_date,"%Y-%m")
    )
        Select Month,AvgOrderValue,
        AvgOrderValue - Round(Lag(AvgOrderValue) Over (Order By Month),2)
        As ChangeInValue
        From CTE_A
        Order By ChangeInValue Desc;


-- Q7 - Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

    Select product_id,
    Count(order_id) As SalesFrequency
    From OrderDetails
    Group By product_id
    Order By SalesFrequency Desc
    Limit 5;

-- Q8 - List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

    Select P.Product_id,P.Name, Count(Distinct o.customer_id) As UniqueCustomerCount
    From products p Inner Join orderdetails od on p.product_id = od.product_id
    Inner Join orders o On od.order_id = o.order_id 
    Group By P.Product_id,P.Name
    Having Count(Distinct o.customer_id) < (Select Count(Distinct customer_id) * 0.40 As Total_Customers From customers); 


-- Q9 - Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.


With CTE_A As 
    (
    Select customer_id,Min(Order_date) As Min_order_date From orders 
    Group By customer_id
    )
        Select Date_format(Min_order_date,"%Y-%m") As FirstPurchaseMonth,
        Count(Distinct customer_id) As TotalNewCustomers
        From CTE_A
        Group By Date_format(Min_order_date,"%Y-%m")
        Order By Date_format(Min_order_date,"%Y-%m");

-- Q10 - Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

    
    Select Date_format(Order_date,"%Y-%m") As Month,
    Sum(total_amount) As TotalSales
    From Orders
    Group By Date_format(Order_date,"%Y-%m")
    Order By Sum(total_amount) Desc
    Limit 3;
