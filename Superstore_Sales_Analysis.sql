-- Datadase Craetion and Usage
create database `Project 3`;
use `Project 3`;
-- Updating and formatting
update `project 3`.`superstore`
set `ship date`=str_to_date(`ship date`,'%m/%d/%Y');
alter table superstore modify `order date` date;
alter table superstore modify `ship date` date;
-- Adding Profit margin
alter table superstore add column `Profit Margin` decimal(10,2);
update superstore set`profit margin`=
case when sales=0 then null else profit/sales end;
select `profit margin` from superstore;
-- Basic Data Exploration
select count(*) from superstore;
select distinct category from superstore;
select distinct region from superstore;
select country,state,city,sales from superstore
order by sales desc;
select region,profit from superstore
order by profit desc;
select year(`order date`) as Year,profit margin from superstore
order by Year asc;
-- Profit with high sales and profit
select `product name`,sum(Sales) as Sales,sum(profit) as Profit from superstore 
group by `product name`
having Sales>10000 and Profit>1000;
-- Top 10 Products by Sales
USE `project 3`;
CREATE  OR REPLACE VIEW `Top_10_Products` AS
select `product name`,sum(Sales) as Sales from superstore 
group by `product name`
order by Sales desc
limit 10;
select * from top_10_products;
-- Bottom 10 Products by profit
select `product name`,sum(Profit) as Profit from superstore 
group by `product name`
having sum(profit)<0
order by Profit asc
limit 10;
select category,`Sub-category`,region,quantity from superstore;
USE `project 3`;
DROP procedure IF EXISTS `project 3`.`TopQuantities`;
;

DELIMITER $$
USE `project 3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TopQuantities`(in N int)
BEGIN
select `customer id`,`customer name`,`product name`,quantity from superstore
order by quantity desc
limit N;
END$$

DELIMITER ;
;
call `project 3`.TopQuantities(6);
-- monthly and yearly aggregates
select month(`order date`) as Month,sum(profit) from superstore
group by Month
order by Month asc;
select year(`order date`) as Year,sum(sales) as Sales,sum(profit) as Profit from superstore
group by Year
order by Year asc;
-- Top customers by sales
SELECT `customer name`, SUM(sales) AS Total_Sales
FROM superstore
GROUP BY `customer name`
ORDER BY Total_Sales DESC
LIMIT 10;
SELECT AVG(DATEDIFF(`ship date`, `order date`)) AS Avg_Shipping_Days
FROM superstore;
SELECT `order id`, DATEDIFF(`ship date`, `order date`) AS Shipping_Days
FROM superstore
ORDER BY Shipping_Days DESC;





