USE mavenfuzzyfactory;

SELECT * 
FROM website_sessions
WHERE website_session_id = 1059;

SELECT * 
FROM website_pageviews
WHERE website_session_id = 1059;

SELECT * 
FROM orders
WHERE website_session_id = 1059;

/*1) Getting the session to order conversions rate*/
SELECT
	sessions.utm_content,
	COUNT(DISTINCT sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    CONCAT(COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT sessions.website_session_id)*100,"%") AS session_to_order_conv_rt
FROM website_sessions AS sessions
	LEFT JOIN orders 
		ON orders.website_session_id = sessions.website_session_id
        
WHERE sessions.website_session_id
GROUP BY
	1
ORDER BY session_to_order_conv_rt DESC;

/*2) Task 1) Analyzing bulk of the website sessions source before the '04/12/2012'
				i.e. Top Traffic Sources*/
SELECT
	sessions.utm_source,
    sessions.utm_campaign,
    sessions.http_referer,
    COUNT(DISTINCT sessions.website_session_id) AS sessions
FROM
	website_sessions AS sessions
WHERE
	created_at < '2012-04-12'
    
GROUP BY
	sessions.utm_source,
    sessions.utm_campaign,
    sessions.http_referer
ORDER BY 
	4 DESC;
    
/*3) Task 2) Analyzing the Conversion rate from sessions to orders of the Top Traffic Sources*/
SELECT
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT ord.order_id) AS orders,
    CONCAT(COUNT(DISTINCT ord.order_id)/COUNT(DISTINCT ws.website_session_id)*100,"%") AS CVR -- Sessions to Order conversion rate
    
FROM website_sessions AS ws
	LEFT JOIN orders AS ord
		ON ord.website_session_id = ws.website_session_id

WHERE ws.created_at < '2012-04-14'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
