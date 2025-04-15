USE classicmodels;

create table metrics (
With emp_off as (
Select
e.employeeNumber,
concat(e.firstName, " ", e.lastName) as employeeName,
o.officeCode,
o.territory
From employees e
Left Join offices o 
on e.officeCode = o.officeCode
),

shipped_orders as (
Select
*
FROM
orders
where lower(status) = "shipped"
),


customers_emp as (
Select 
c.customerNumber,
e.employeeNumber,
e.employeeName,
e.officeCode
From 
customers c
Left Join emp_off e 
On
c.salesRepEmployeeNumber = e.employeeNumber
),


cust_orders as (
Select
orderDate,
orderNumber,
c.customerNumber,
c.employeeNumber,
c.employeeName,
c.officeCode
From shipped_orders s
left join customers_emp c
on s.customerNumber = c.customerNumber
),
order_rev as (
Select
orderNumber as revOrderNumber,
sum(quantityOrdered*priceEach) order_rev,
sum(quantityOrdered) as order_items,
(sum(quantityOrdered*priceEach) / sum(quantityOrdered)) as avg_item_price
From orderdetails
group by 1
),


combined as (
Select * 
From cust_orders c
Left join order_rev r
on c.orderNumber = r.revOrderNumber
),

metrics as (
Select 
orderDate,
officeCode,
employeeNumber,
employeeName,
count(distinct orderNumber) totalOrders,
sum(order_rev) totalRevenue,
count(distinct customerNumber) totalCustomers,
avg(order_rev) avgOrderRev,
avg(order_items) avgItems,
avg(avg_item_price) avgItemRev
from combined 
group by 1,2,3,4
order by 1,2,3
)
Select * from metrics
); 

