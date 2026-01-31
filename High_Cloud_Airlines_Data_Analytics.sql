create database airlines;
CREATE TABLE `maindata` (
  `Airline ID` varchar(10) DEFAULT NULL,
  `Carrier Group ID` varchar(10) DEFAULT NULL,
  `Unique Carrier Code` VARCHAR(50) default null,
  `Unique Carrier Entity Code` varchar(50) DEFAULT NULL,
  `Region Code` VARCHAR(50),
  `Origin Airport ID` INT DEFAULT NULL,
  `Origin Airport Sequence ID` INT DEFAULT NULL,
  `Origin Airport Market ID` INT DEFAULT NULL,
  `Origin World Area Code` INT DEFAULT NULL,
  `Destination Airport ID` INT DEFAULT NULL,
  `Destination Airport Sequence ID` INT DEFAULT NULL,
  `Destination Airport Market ID` INT DEFAULT NULL,
  `Destination World Area Code` INT DEFAULT NULL,
  `Aircraft Group ID` INT DEFAULT NULL,
  `Aircraft Type ID` INT DEFAULT NULL,
  `Aircraft Configuration ID` INT DEFAULT NULL,
  `Distance Group ID` INT DEFAULT NULL,
  `Service Class ID` VARCHAR(50),
  `Datasource ID` VARCHAR(50),
  `Departures Scheduled` INT DEFAULT NULL,
  `Departures Performed` INT DEFAULT NULL,
  `Payload` INT DEFAULT NULL,
  `Distance` INT DEFAULT NULL,
  `Available Seats` INT DEFAULT NULL,
  `Transported Passengers` INT DEFAULT NULL,
  `Transported Freight` INT DEFAULT NULL,
  `Transported Mail` INT DEFAULT NULL,
  `Ramp-To-Ramp Time` INT DEFAULT NULL,
  `Air Time` INT DEFAULT NULL,
  `Unique Carrier` VARCHAR(100),
  `Carrier Code` VARCHAR(50),
  `Carrier Name` VARCHAR(100),
  `Origin Airport Code` VARCHAR(50),
  `Origin City` VARCHAR(100),
  `Origin State Code` VARCHAR(10),
  `Origin State FIPS` VARCHAR(10) DEFAULT NULL,
  `Origin State` VARCHAR(50),
  `Origin Country Code` VARCHAR(10),
  `Origin Country` VARCHAR(50),
  `Destination Airport Code` VARCHAR(50),
  `Destination City` VARCHAR(100),
  `Destination State Code` VARCHAR(10),
  `Destination State FIPS` VARCHAR(10) DEFAULT NULL,
  `Destination State` VARCHAR(50),
  `Destination Country Code` VARCHAR(10),
  `Destination Country` VARCHAR(50),
  `Year` int DEFAULT NULL,
  `Month (#)` int DEFAULT NULL,
  `Day` INT DEFAULT NULL,
  `From - To Airport Code` VARCHAR(50),
  `From - To Airport ID` VARCHAR(50),
  `From - To City` VARCHAR(100),
  `From - To State Code` VARCHAR(20),
  `From - To State` VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
select * from maindata;
show tables;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maindata.csv'
INTO TABLE maindata
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
alter table maindata add column DayType varchar(20);
update maindata 
set DayType=if(weekday(FullDate) in(0,6),"weekend","weekday");
-- 1 
alter table maindata add column FullDate date;
update maindata
set FullDate=str_to_date(concat(year,'-',`month (#)`,'-',day),'%Y-%m-%d');
-- A TO F
select fulldate from maindata;
select year(Fulldate) as Year from maindata;
select month(Fulldate) as MonthNo from maindata;
select monthname(Fulldate) as MonthName from maindata;
select concat('Q',quarter(Fulldate)) as Quarter from maindata;
select date_format(Fulldate,'%Y-%M') as YearMonth from maindata;
select dayofweek(Fulldate) as WeekdayNo from maindata;
select dayname(Fulldate) as WeekdayName from maindata; 
select 
case 
when month(Fulldate)>=4 then month(Fulldate)-3
else month(Fulldate)+9
end
as FinancialMonth from maindata;
select concat('Qtr',floor(((month(Fulldate)-4+12)%12)/3)+1) as FinancialQuarter from maindata;
-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
select year,round(sum(`transported passengers`)/sum(`available seats`)*100,2) as LoadFactorPercent from maindata
group by year
order by year;
-- Display LoadFactor Percentage on Monthly basis
select year,`month (#)` as MonthNo,round(sum(`transported passengers`)/sum(`available seats`)*100,2) as LoadFactorPercent from maindata
group by year,`month (#)`
order by year asc,`month (#)` asc;
-- Display LoadFactor Percentage on Quarter basis
select Year(fulldate) as Year,concat('Q',Quarter(fulldate)) as Quarter,round(sum(`transported passengers`)/sum(`available seats`)*100,2) as LoadFactorPercent from maindata
group by Year(fulldate),quarter
order by Year asc,Quarter asc;
-- view code
USE `airlines`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `LoadFactor_Quarter` AS
    SELECT 
        YEAR(`maindata`.`FullDate`) AS `Year`,
        CONCAT('Q', QUARTER(`maindata`.`FullDate`)) AS `Quarter`,
        ROUND(((SUM(`maindata`.`Transported Passengers`) / SUM(`maindata`.`Available Seats`)) * 100),
                2) AS `LoadFactorPercent`
    FROM
        `maindata`
    GROUP BY YEAR(`maindata`.`FullDate`) , `Quarter`
    ORDER BY `Year` , `Quarter`;
    
select * from airlines.loadfactor_quarter;
-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
select `carrier name`,coalesce(round(sum(`transported passengers`)/sum(`available seats`)*100,2),0.00) as LoadFactorPercent from maindata
group by `carrier name`
order by LoadFactorPercent desc;
-- 4. Identify Top 10 Carrier Names based passengers preference 
select `carrier name`,sum(`Transported Passengers`) as `Total Passengers` from maindata
group by `carrier name`
order by `Total Passengers` desc
limit 10;
-- Stored Procedure Code
USE `airlines`;
DROP procedure IF EXISTS `airlines`.`Get_Top_Carriers`;
;

DELIMITER $$
USE `airlines`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Top_Carriers`(IN LimitCount Int)
BEGIN
select `carrier name`,coalesce(round(sum(`transported passengers`)/sum(`available seats`)*100,2),0.00) as LoadFactorPercent from maindata
group by `carrier name`
order by LoadFactorPercent desc
limit LimitCount;
END$$

DELIMITER ;
;

call Get_TopCarriers(6);
-- 5. Display top Routes ( from-to City) based on Number of Flights 
select `From - To City`,sum(`Departures Performed`) as `Number of Flights` from maindata
group by `From - To city`
order by `Number of Flights` desc
limit 10;
-- 6. Display LoadFactor % for the DayType
select DayType,round(sum(`transported passengers`)/sum(`available seats`)*100,2) as LoadFactorPercent from maindata
group by daytype;
-- 7. Identify number of flights based on Distance group
select `distance group ID` as `Distance Group`,sum(`Departures Performed`) as `number of Flights` from maindata
group by `Distance Group ID`
order by `Distance Group ID`;















    