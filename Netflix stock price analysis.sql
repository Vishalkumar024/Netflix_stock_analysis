/*
Q1. Price Performance: What are the highest and lowest closing 
prices for Netflix stock in 2023-24, and on which dates did these occur?
*/

SELECT "Highest" AS Price_type, Date, Close 
FROM netflix.netflix_stock
WHERE Close = (SELECT MAX(Close) FROM netflix.netflix_stock)
UNION ALL
SELECT  "Lowest" AS Price_type, Date, Close 
FROM netflix.netflix_stock
WHERE Close = (SELECT MIN(Close) FROM netflix.netflix_stock);


/*
Q2. Volatility Analysis: Which days showed the highest volatility in Netflix 
stock prices, measured by the difference between daily high and low prices?
*/

SELECT Date, (High - Low) AS Volatility
FROM netflix.netflix_stock
ORDER BY Volatility DESC
LIMIT 5;


/*
Q3. Volume Trends: How does the average monthly trading volume change over time?
*/

SELECT 
    DATE_FORMAT(Date, '%m') AS Month,
    AVG(Volume) AS Avg_Monthly_Volume
FROM 
    netflix.netflix_stock
GROUP BY 
    DATE_FORMAT(Date, '%m')
ORDER BY Month;


/*
Q4. Consistent Price Movements: On how many days did Netflix’s stock close higher than it opened, 
and are there patterns in days or weeks where the price consistently increased or decreased?
*/

# Part 1: Count of Days with Closing Price Higher Than Opening Price. 
SELECT 
    COUNT(*) AS Higher_then_opening
FROM
    netflix.netflix_stock
WHERE
    Close > Open;

# Part 2: Identify Weekly Consistent Patterns. 
SELECT 
    WEEK(Date, 1) AS Week,
    SUM(CASE WHEN Close > Open THEN 1 ELSE 0 END) AS Increase,
    SUM(CASE WHEN Close < Open THEN 1 ELSE 0 END) AS Decrease,
    COUNT(*) AS Total_Days
FROM netflix.netflix_stock
GROUP BY WEEK(Date, 1)
HAVING Increase = Total_Days OR Decrease = Total_Days;


/*
Q5. Monthly and Weekly Trends: What are the average opening and closing 
prices per week and per month ?
*/

-- Weekly Average Opening and Closing Prices
SELECT 
    WEEK(Date, 1) AS Week,
    AVG(Open) AS Avg_Open_Weekly,
    AVG(Close) AS Avg_Close_Weekly
FROM 
    netflix.netflix_stock
GROUP BY 
    WEEK(Date, 1)
ORDER BY 
    Week;

-- Monthly Average Opening and Closing Prices
SELECT 
    MONTH(Date) AS Month,
    AVG(Open) AS Avg_Open_Monthly,
    AVG(Close) AS Avg_Close_Monthly
FROM 
    netflix.netflix_stock
GROUP BY 
    MONTH(Date)
ORDER BY 
	Month;


/*
Q6. Return on Investment: What are the daily, weekly, and monthly
return percentages based on adjusted closing prices ?
*/

# Daily Return Percentage
SELECT 
    date,
    `adj close`,
    (`adj close` - LAG(`adj close`, 1) OVER (ORDER BY date)) / LAG(`adj close`, 1) OVER (ORDER BY date) * 100 AS daily_return
FROM netflix.netflix_stock
ORDER BY date;

# Weekly Return Percentage
SELECT 
    date,
    `adj close`,
    (`adj close` - LAG(`adj close`, 7) OVER (ORDER BY date)) / LAG(`adj close`, 7) OVER (ORDER BY date) * 100 AS weekly_return
FROM netflix.netflix_stock
ORDER BY date;

# Monthly Return Percentage
SELECT 
    date,
    `adj close`,
    (`adj close` - LAG(`adj close`, 30) OVER (ORDER BY date)) / LAG(`adj close`, 30) OVER (ORDER BY date) * 100 AS monthly_return
FROM netflix.netflix_stock
ORDER BY date;


/*
Q7. Trading Activity Correlation : Is there a correlation
between daily trading volume and daily price changes? 
For example, do larger volumes coincide with larger price changes?
*/

WITH Daily_Price_Change AS (
    SELECT 
        Date,
        `Adj close`,
        Volume,
        LAG(`Adj close`) OVER (ORDER BY Date) AS Prev_Adjusted_Close,
        CASE 
            WHEN LAG(`Adj close`) OVER (ORDER BY Date) IS NULL THEN NULL
            ELSE ABS((`Adj close` - LAG(`Adj close`) OVER (ORDER BY Date)) / LAG(`Adj close`) OVER (ORDER BY Date) * 100)
        END AS Daily_Price_Change_Percentage
    FROM 
        netflix.netflix_stock
)

SELECT 
    Date,
    Volume,
    Daily_Price_Change_Percentage
FROM 
    Daily_Price_Change
WHERE 
    Daily_Price_Change_Percentage IS NOT NULL
ORDER BY 
    Date; 


/*
Q8. find out how many days had a positive price change, how many 
had a negative price change, and how many had no change at all.
*/

SELECT 
    SUM(CASE WHEN PriceChange > 0 THEN 1 ELSE 0 END) AS PositiveDays,
    SUM(CASE WHEN PriceChange < 0 THEN 1 ELSE 0 END) AS NegativeDays,
    SUM(CASE WHEN PriceChange = 0 THEN 1 ELSE 0 END) AS NoChangeDays
FROM (
    SELECT 
        Date,
        (Close - Open) AS PriceChange
    FROM 
        netflix_stock
) AS DailyChanges;


