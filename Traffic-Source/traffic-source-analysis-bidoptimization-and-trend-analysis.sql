/* Continuation from "traffic-source-analysis" query file*/

USE mavenfuzzyfactory;

/* Pivoting the Data using COUNT and CASE functions*/
SELECT 
	primary_product_id,
	COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
	
	COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item,
	
	COUNT(DISTINCT order_id) AS Total_orders
	
FROM orders

WHERE order_id
GROUP BY 1
;

/* TREND ANALYSIS*/

/*5 Task 3) TRAFFIC SOURCE TRENDING (Trend Analysis)
	Based on the CVR, i.e. Conversion Rate Analysis of the Traffic source we BID down the gsearch nonbrand (on 2012-04-15).
			Analyzing the gsearch nonbrand trended session volume by week, to find out whether or not bid changes casued the volume to drop.*/
                    
SELECT 
	-- YEAR(created_at) AS Yr,
	-- WEEK(created_at) AS wk,
    DATE(MIN(created_at)) AS week_start_date,
    COUNT(DISTINCT ws.website_session_id) AS sessions
    
FROM website_sessions AS ws

WHERE 
	created_at < '2012-05-10'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
    
GROUP BY 
	YEAR(created_at),
	WEEK(created_at);
		/* Analysis: gsearch nonbrand is sensitive to the BID Changes, after 2012-04-15 you can see a clear down trend for the remainder of the weeks in YTD*/
        
/*BID OPTIMIZATION*/

-- /*6 Task 3b) Although our gsearch nonbrand is trending down by volume, to get a clearer picture, we need to analyze which device types are performing (or bringing more volumes to the websties), 
-- 				depending on which device Type is performing better, we can optimize their BID to get more volume.*/
 
 SELECT
	ws.device_type AS 'Device Type',
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT ord.order_id) AS orders,
	CONCAT(COUNT(DISTINCT ord.order_id)/COUNT(DISTINCT ws.website_session_id)*100,"%") AS CVR
        
FROM
	website_sessions AS ws
		LEFT JOIN orders AS ord
			ON ord.website_session_id = ws.website_session_id
WHERE
	ws.created_at < '2012-05-11'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
GROUP BY 
	ws.device_type
		/* Analysis: Mobile devices have a conversion rate of .97% as compared to the desktop's CVR of 3.73% therefore it is will beneficial to increase the bid on the Desktop */
;

/* TRAFFIC SOURCE SEGMENT TRENDING ANALYSIS*/
/* 7 Task 4) Checking whether or not the bid changes impacted our volumes after April 15, 2012. */

SELECT 
-- 	YEAR(ws.created_at) AS yr,
-- 	WEEK(ws.created_at) AS wk,
    MIN(DATE(ws.created_at)) AS week_start_date,
	COUNT(DISTINCT
		CASE WHEN ws.device_type = 'desktop' THEN  ws.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT
		CASE WHEN ws.device_type = 'mobile' THEN  ws.website_session_id ELSE NULL END) AS mobile_sessions
FROM
	website_sessions AS ws
WHERE
	ws.created_at > '2012-04-15'
    AND ws.created_at < '2012-06-09'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
	YEAR(ws.created_at),
	WEEK(ws.created_at)
ORDER BY week_start_date;
    
