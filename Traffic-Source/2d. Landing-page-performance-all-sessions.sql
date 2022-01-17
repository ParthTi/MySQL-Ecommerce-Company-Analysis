# Analyzing only the home page.
# Landing Page performance. Identifying total sessions, bounced sessions and % of bounced sessions, i.e. Bounce Rate Analysis
USE mavenfuzzyfactory;

-- Step 1: Identify the pageview id for the relevant website sessions

CREATE TEMPORARY TABLE first_pageview_summary
SELECT
	web_pvs.website_session_id,
    MIN(web_pvs.website_pageview_id) AS first_pageview_id
FROM website_pageviews AS web_pvs
	INNER JOIN website_sessions AS web_sess
		ON web_sess.website_session_id = web_pvs.website_session_id
WHERE web_sess.created_at < '2012/06/14'
GROUP BY web_pvs.website_session_id;

-- Step 2: Identify the landing pages for each session:

CREATE TEMPORARY TABLE sessions_home_landing_page
SELECT 
	first_pvs.website_session_id,
    web_pvs.pageview_url AS landing_page
FROM first_pageview_summary AS first_pvs
	LEFT JOIN website_pageviews AS web_pvs
		ON  web_pvs.website_pageview_id = first_pvs.first_pageview_id
WHERE web_pvs.pageview_url = '/home';


SELECT * FROM sessions_home_landing_page; -- Check the temporary table 'sessions_landing_page'

-- Step 3: Identify Bounced Sessions Only:

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	land.website_session_id,
    land.landing_page,
    COUNT(DISTINCT website_pageview_id) AS count_of_pages_viewed
FROM sessions_home_landing_page AS land
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = land.website_session_id
GROUP BY
	land.website_session_id,
    land.landing_page
HAVING count_of_pages_viewed = 1;

-- FINAL STEP: Calculating number of sessions, bounced sessions, and bounce rate:
-- SELECT * FROM bounced_sessions_only;
SELECT 
	
	COUNT(DISTINCT land_sess.website_session_id) AS sessions, -- total sessions
    COUNT(DISTINCT bounced_sess.website_session_id) AS bounced_sessions,
    CONCAT(COUNT(DISTINCT bounced_sess.website_session_id) / COUNT(DISTINCT land_sess.website_session_id)*100,"%") AS bounce_rate
FROM sessions_home_landing_page AS land_sess
	LEFT JOIN bounced_sessions_only AS bounced_sess
		ON bounced_sess.website_session_id = land_sess.website_session_id;
        