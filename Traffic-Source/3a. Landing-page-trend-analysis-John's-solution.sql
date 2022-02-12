USE mavenfuzzyfactory;
-- DROP TEMPORARY TABLE sessions_w_min_pvs_id_and_view_count;
CREATE TEMPORARY TABLE sessions_w_min_pvs_id_and_view_count

SELECT
	web_sess.website_session_id,
    MIN(web_pvs.website_pageview_id) AS first_pageview_id,
    COUNT(web_pvs.website_pageview_id) AS count_pageviews
    
FROM website_sessions AS web_sess
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = web_sess.website_session_id
WHERE 
	web_sess.created_at > '2012-06-01'
    AND  web_sess.created_at < '2012-08-31'
	AND web_sess.utm_campaign = 'nonbrand'
    AND web_sess.utm_source = 'gsearch'
GROUP BY
web_sess.website_session_id;

-- SELECT * FROM sessions_w_min_pvs_id_and_view_count

CREATE TEMPORARY TABLE sessions_w_count_lander_and_create_at

SELECT
	temp1.website_session_id,
	temp1.first_pageview_id,
    temp1.count_pageviews,
    web_pvs.pageview_url AS landing_page,
    web_pvs.created_at AS sessions_created_at
FROM sessions_w_min_pvs_id_and_view_count AS temp1 
	LEFT JOIN website_pageviews AS web_pvs
		ON temp1.website_session_id = web_pvs.website_session_id;
        
SELECT
-- 	YEARWEEK(sessions_created_at),
    MIN(DATE(sessions_created_at)) AS week_start_date,
--     COUNT(DISTINCT website_session_id) AS total_sessions,
--     COUNT(DISTINCT CASE
-- 					WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
	COUNT(DISTINCT CASE
					WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate,
	COUNT(DISTINCT CASE
					WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) home_sessions,
	COUNT(DISTINCT CASE
					WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) lander_sessions
FROM 
	sessions_w_count_lander_and_create_at
GROUP BY 
	YEARWEEK(sessions_created_at);