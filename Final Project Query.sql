-- Data Exploration
Use FinalProjectNTI

-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

-- Production Schema 

Select * from production.brands

select * from production.categories

select * from production.products

select * from production.stocks

-- sales Schema

Select * from sales.customers

-- This in normal to have missing values in the phone column, because not everybody will give you their phone #
Select 
	* 
from sales.customers s
Where s.phone Is NULL OR s.city Is NULL OR s.customer_id Is NULL OR s.email Is NULL OR s.state Is NULL OR s.zip_code Is NULL 

Select * from sales.order_items

-- there are some nulls in the ShippedDate Column, Let's see what are the reasons for that ???
Select * from sales.orders


/*
 after we checked we saw Some Reasons why there is Missing Values in the ShippedDate Column, Here are some scenarios:

	1- The Order Date is the Same as the Required date that's why there is no shipping Date.

	2- The Customer Could have bought the bike and took it himself from the store and didn't need shipping 
		Because All those orders with null shippingDate Values have the Store and the Customre in the Same State.

	Note:
		1- We Could Just ask the Data Provider For the reason for that.
*/
----------------------------------------------------------------------------------
-- First Way
Select
	Count(sales.orders.order_id)
from sales.orders
Where
	order_date = required_date AND 
	shipped_date IS NULL

Select 
	Count(order_id)
from sales.orders
where shipped_date IS NULL

-- Second Way
Select 
	so.shipped_date,
	sc.state CustomerState,
	sc.city CustomerCity,
	ss.state StoreState,
	ss.city StoreCity
from sales.orders so JOIN sales.customers sc
					ON so.customer_id = sc.customer_id
						Join sales.stores ss 
							ON	ss.store_id = so.store_id 
Where
		shipped_date IS NULL
-------------------------------------------------------------------------------------

Select * from sales.staffs

Select * from sales.stores
------------------------------------------------
--    1- Most Expensive bike and Why?
------------------------------------------------

-- Most Expensive bike is from TREK company in the Road bike
-- Category, now let's see why Trek bike is the most expensive
Select
		TOP 1 pp.product_name,
		pc.category_name,
		Max(pp.list_price) MaxPrice
From production.products pp JOIN production.categories pc
							ON pp.category_id = pc.category_id
Group By pp.product_name,pc.category_name
ORDER BY Max(pp.list_price) Desc

-- TREK is considered a fancy company for making bikes,
-- we see here that thier average price for a bike is relativly higher than the other companies
-- Trek bikes are considered Pricey beacause of the quality, innovation, and reliability of thier bikes and most people that priortize those things
-- Buy trek bikes, so Trek Bikes are considered a good long term investement

-- 1) Brands price comparison 
Select
		pb.brand_name,
		AVG(pp.list_price) AVGPrice
From production.products pp Join production.brands pb
								On pp.brand_id = pb.brand_id 
Group By pb.brand_name
ORDER BY
		AVGPrice DESC

-------------------------------------------------------
--    2- How many total customers does BikeStore have?
-------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
----------------------------------------------------------
--------------------------------------------------------------
----------------------------------------------------------------
------------------------------------------------------------------
/* Order status:
			1 = Pending;
			2 = Processing;
			3 = Rejected;
			4 = Completed
*/
Select
		so.order_status,
		Count(distinct so.customer_id) #OfCustomers
From sales.orders so
Group By 
	so.order_status
	
select * from sales.orders

------------------------------------------------
--  3) How many stores does BikeStore have?
------------------------------------------------

Select
	Count(Distinct ss.store_name) AS #OfStores
from
	sales.stores ss 


------------------------------------------------
--  4) What is the total price spent per order?
------------------------------------------------
select
	so.order_id,
	(so.list_price*so.quantity*(1-so.discount)) OrderPrice
from sales.order_items so 
Order BY OrderPrice DESC


------------------------------------------------
--  5) What’s the sales/revenue per store?
------------------------------------------------

select
	FORMAT(sum(si.list_price*si.quantity*(1-si.discount)), 'N0') Revenue
from 
	sales.order_items si  JOIN sales.orders so
						  ON si.order_id = so.order_id
						  JOIN sales.stores ss
								ON so.store_id = ss.store_id 

-- Group BY ss.store_name
-- ORDER BY sum(si.list_price*si.quantity*(1-si.discount)) DESC





select
	-- ss.store_name,
	FORMAT(sum(si.list_price*si.quantity*(1-si.discount)), 'N0') Revenue
from 
	sales.order_items si  JOIN sales.orders so
						  ON si.order_id = so.order_id
						  JOIN sales.stores ss
								ON so.store_id = ss.store_id 
-- Group BY ss.store_name
-- ORDER BY sum(si.list_price*si.quantity*(1-si.discount)) DESC

------------------------------------------------
--  6) Which category is most sold?
------------------------------------------------

SELECT TOP 1
    c.category_name,
    SUM(oi.quantity) AS TotalSoldQuantity
FROM 
    production.categories c
JOIN 
    production.products p ON c.category_id = p.category_id
JOIN 
    sales.order_items oi ON p.product_id = oi.product_id
GROUP BY 
    c.category_name
ORDER BY 
    TotalSoldQuantity DESC;


------------------------------------------------
--  7) Which category rejected more orders?
------------------------------------------------

SELECT TOP 1
    c.category_name,
    COUNT(DISTINCT o.order_id) AS RejectedOrdersCount
FROM 
    production.categories c
JOIN 
    production.products p ON c.category_id = p.category_id
JOIN 
    sales.order_items oi ON p.product_id = oi.product_id
JOIN 
    sales.orders o ON oi.order_id = o.order_id
WHERE 
    o.order_status = 3 -- Rejected orders
GROUP BY 
    c.category_name
ORDER BY 
    RejectedOrdersCount DESC;


------------------------------------------------
--  8) Which bike is the least sold?
------------------------------------------------
Select 
	pp.product_name,
    Count(pp.product_name) #OfBikesSold
From 
	production.products pp Join sales.order_items si
							ON pp.product_id = si.product_id
Group BY
	PP.product_name
HAVING
	        Count(pp.product_name) = 1


------------------------------------------------
--  9) What’s the full name of a customer with ID 259?
------------------------------------------------

select
	sc.customer_id,
	CONCAT(sc.first_name,' ',sc.last_name) FullName
from 
	sales.customers sc
Where
	sc.customer_id = 259

-------------------------------------------------------------------------------
--  10)  What did the customer on question 9 buy and when? What’s the status of
--this order?
--------------------------------------------------------------------------------
select
	sc.customer_id,
	CONCAT(sc.first_name,' ',sc.last_name) FullName,
	pp.product_name,
	so.order_date,
	so.required_date,
	so.order_status
from 
	sales.customers sc JOIN sales.orders so
							ON  sc.customer_id = so.customer_id
					   JOIN sales.order_items si
							ON so.order_id = si.order_id
						JOIN production.products pp
							ON si.product_id = pp.product_id
Where
	sc.customer_id = 259

-------------------------------------------------------------------------------
--  11) Which staff processed the order of customer 259? And from which store?
--------------------------------------------------------------------------------
Select
		CONCAT(ssta.first_name,' ',ssta.last_name) FullStaffName,
		ssto.store_name
from 
	sales.orders so JOIN sales.staffs ssta
						ON so.staff_id = ssta.staff_id
					JOIN sales.stores ssto
						ON ssto.store_id = so.store_id
Where
	so.customer_id = 259

-------------------------------------------------------------------------------
--  12) How many staff does BikeStore have? Who seems to be the lead Staff at
--      BikeStore?
--------------------------------------------------------------------------------
select * from sales.staffs

Select 
	COUNt(staff_id) #OfStaff
from 
	sales.staffs

-- LEAD STAFF
Select
	* 
From 
	sales.staffs
Where 
	manager_id IS NULL

----------------------------------------
--  13) Which brand is the most liked?
----------------------------------------
SELECT 
    TOP 1 b.brand_name,
    SUM(oi.quantity) AS TotalQuantitySold
FROM 
    sales.order_items oi
JOIN 
    production.products p ON oi.product_id = p.product_id
JOIN 
    production.brands b ON p.brand_id = b.brand_id
GROUP BY 
    b.brand_name
ORDER BY 
    TotalQuantitySold DESC

--------------------------------------------------------------------------
-- 14) How many categories does BikeStore have, and which one is the least
--     liked?
--------------------------------------------------------------------------
Select Count(Distinct category_name) #OfCategories from production.categories

SELECT 
    TOP 1 pc.category_name,
    SUM(oi.quantity) AS TotalQuantitySold
FROM 
    sales.order_items oi JOIN production.products p
							ON oi.product_id = p.product_id
						 JOIN   production.categories pc
							ON p.category_id = pc.category_id
GROUP BY 
    pc.category_name
ORDER BY 
    TotalQuantitySold ASC

--------------------------------------------------------------------------
-- 15) Which store still have more products of the most liked brand?
--------------------------------------------------------------------------

SELECT TOP 1 
    s.store_name,
    SUM(st.quantity) AS TotalStockQuantity
FROM 
    production.stocks st
JOIN 
    production.products p ON st.product_id = p.product_id
JOIN 
    production.brands b ON p.brand_id = b.brand_id
JOIN 
    sales.stores s ON st.store_id = s.store_id
WHERE 
    b.brand_id = (
        SELECT TOP 1 
            b1.brand_id
        FROM 
            production.brands b1
        JOIN 
            production.products p1 ON b1.brand_id = p1.brand_id
        JOIN 
            sales.order_items oi1 ON p1.product_id = oi1.product_id
        GROUP BY 
            b1.brand_id
        ORDER BY 
            SUM(oi1.quantity) DESC
    )
GROUP BY 
    s.store_name
ORDER BY 
    TotalStockQuantity DESC;


	-- another way to answer this question

SELECT TOP 1 
    s.store_name,
    SUM(st.quantity) AS TotalStockQuantity
FROM 
    production.stocks st
JOIN 
    production.products p ON st.product_id = p.product_id
JOIN 
    production.brands b ON p.brand_id = b.brand_id
JOIN 
    sales.stores s ON st.store_id = s.store_id
WHERE 
    b.brand_name = 'Electra' 
GROUP BY 
    s.store_name
ORDER BY 
    TotalStockQuantity DESC;





















-----------------------------------------------------
-- 16) Which state is doing better in terms of sales?
-----------------------------------------------------

select
	ss.state,
	FORMAT(sum(si.list_price*si.quantity*(1-si.discount)), 'N0') TotalSales
from 
	sales.order_items si  JOIN sales.orders so
						  ON si.order_id = so.order_id
						  JOIN sales.stores ss
								ON so.store_id = ss.store_id 
Group BY ss.state
ORDER BY sum(si.list_price*si.quantity*(1-si.discount)) DESC


-----------------------------------------------------
-- 17) What’s the discounted price of product id 259?
-----------------------------------------------------

select
	product_id,
	discount
from 
	sales.order_items
where product_id = 259

---------------------------------------------------------------------------------
-- 18) What’s the product name, quantity, price, category, model year and brand
--     name of product number 44?
---------------------------------------------------------------------------------

select
	pp.*,
	pc.category_name
from 
	production.products pp JOIN production.categories pc
								ON pp.category_id = pc.category_id 
Where
	pp.product_id = 44

--------------------------------
--19) What’s the zip code of CA?
--------------------------------

select
	state,
	zip_code
from 
	sales.stores
where 
	State = 'CA'

-------------------------------------------------
-- 20) How many states does BikeStore operate in?
-------------------------------------------------

select
	COUNT(state) #ofStates
from 
	sales.stores

-------------------------------------------------
-- 21) How many bikes under the children category were sold in the last 8
--     months?
-------------------------------------------------

SELECT 
    SUM(oi.quantity) AS TotalChildrenBikesSold
FROM 
    production.categories c
JOIN 
    production.products p ON c.category_id = p.category_id
JOIN 
    sales.order_items oi ON p.product_id = oi.product_id
JOIN 
    sales.orders o ON oi.order_id = o.order_id
WHERE 
    c.category_name = 'Children Bicycles'
    AND DATEDiff(MONTH, o.order_date, GETDATE()) <= 8 -- Last 8 months
    AND o.order_status = 4; -- Completed orders


--------------------------------------------------------------
-- 22) What’s the shipped date for the order from customer 523
--------------------------------------------------------------

SELECT order_id, shipped_date
FROM sales.orders
WHERE customer_id = 523;

------------------------------------------
-- 23) How many orders are still pending?
------------------------------------------

SELECT COUNT(*) AS PendingOrders
FROM sales.orders
WHERE order_status = 1;

------------------------------------------
-- 24) What’s the names of category and brand does "Electra white water 3i -
--      2018" fall under?
------------------------------------------

SELECT 
    c.category_name,
    b.brand_name
FROM 
    production.products p
JOIN 
    production.categories c ON p.category_id = c.category_id
JOIN 
    production.brands b ON p.brand_id = b.brand_id
WHERE 
    p.product_name = 'Electra white water 3i - 2018';
