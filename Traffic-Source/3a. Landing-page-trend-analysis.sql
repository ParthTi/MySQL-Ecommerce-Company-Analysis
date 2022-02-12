USE mavenfuzzyfactory;

# Analyzing trend of the new landing page by week to make sure that the traffic is routed correctly from /home to /lander-1:

-- Step 1: Identifying first page_view Id for each website_sessions
CREATE TEMPORARY TABLE first_pageview
SELECT
	DATE(MIN(web_pvs.created_at)) AS week_start_date,
	web_pvs.website_session_id,
	MIN(web_pvs.website_pageview_id) AS first_pageview
FROM website_pageviews AS web_pvs
	INNER JOIN website_sessions AS web_sess
		ON web_sess.website_session_id = web_pvs.website_session_id
        AND web_sess.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND web_sess.utm_campaign = 'nonbrand'
GROUP BY 
	web_pvs.website_session_id,
    WEEK(web_pvs.created_at),
    YEAR(web_pvs.created_at);

-- Step 2: Identifying Landing pages for each sessions, i.e. the first page the customer landed on. Limiting landing pages to /lander-1 and /home for the analysis and comparison
-- DROP TEMPORARY TABLE landing_page;
CREATE TEMPORARY TABLE landing_page
SELECT
	first_pvs.website_session_id,
    web_pvs.pageview_url AS landing_page_url
FROM first_pageview AS first_pvs
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = first_pvs.website_session_id
        AND web_pvs.pageview_url IN('/home', '/lander-1');
        
-- Step 3: Identifying bounced sessions 
SELECT 
	land.website_session_id,
    land.landing_page_url,
    COUNT(DISTINCT web_pvs.website_pageview_id) AS count_of_pageviews
FROM landing_page AS land
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = land.website_session_id
GROUP BY
	land.website_session_id,
    land.landing_page_url;
