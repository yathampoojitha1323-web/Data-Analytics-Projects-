create database stockmarket;
use stockmarket;
alter table fact_daily_prices add column daily_return decimal(20,12);
update fact_daily_prices fdp 
join (
select company_id,calendar_id,
case 
when lag(calendar_id) over(partition by company_id order by calendar_id)=calendar_id-1
then
(adjusted_close/lag(adjusted_close) over(partition by company_id order by calendar_id))-1
else null
end as daily_return from fact_daily_prices) dr
on fdp.company_id=dr.company_id 
and fdp.calendar_id=dr.calendar_id
set fdp.daily_return=dr.daily_return;
--
-- 1
select sum(share_price*outstanding_shares) as `Total Market Capitalization`from stocks;
-- 2
select avg(volume) as `Average Daily Trading Volume` from fact_daily_prices;
-- 3
select stddev_samp(daily_return)*100 as Volatility from fact_daily_prices where daily_return is not null;
-- 4
select sector,avg(return_pct) as average_return from stocks
group by sector
order by avg(return_pct) desc;
-- create stored procedure 
USE `stockmarket`;
DROP procedure IF EXISTS `GetTopSectors`;

DELIMITER $$
USE `stockmarket`$$
CREATE PROCEDURE `GetTopSectors` (in TopN int)
BEGIN
select sector,avg(return_pct) as average_return from stocks
group by sector
order by avg(return_pct) desc
limit TopN;
END$$

DELIMITER ;
-- 5
select sum(quantity*share_price) as Portfolio_Value from stocks;
-- 6
select concat(round((sum(current_value) -sum( initial_value))/sum(initial_value)*100,2),"%") as portfolioReturnPerc from stocks;
-- 7
Select
    Round(sum(d.dividend_per_share)/MAX(s.share_price)*100,2) as dividend_yield_pct
from fact_dividends d
cross join (
    select max(share_price) as share_price
    from stocks
) s;
-- 8
Select round((count(distinct case when status="filled" then order_id end)*100.0)/count(distinct order_id),2) as Execution_Rate from fact_orders;
-- create view 
USE `stockmarket`;
CREATE  OR REPLACE VIEW `Order Execution Rate` AS
Select 
round((count(distinct case when status="filled" then order_id end)*100.0)/count(distinct order_id),2) 
as Execution_Rate from fact_orders;

select * from `order execution rate`;
-- 9
select round(sum(win_flag)/count(*)*100,2) as Trade_Win_Rate from fact_trades_pnl_kpi;
-- 10
select sum(gross_sell_amount-gross_buy_amount) as Trader_Performance from fact_trades_pnl_kpi;

    