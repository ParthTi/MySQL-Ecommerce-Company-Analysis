# Analyzing Bounce Rates and Landing Page Tests

# BUSINESS CONTEXT: We want to see the landing page performance for a certain time period
	-- STEP 1: Find the first website_pageview_id for relevant sessions
    -- STEP 2: Identify the landing page of each session
    -- STEP 3: Counting page views for each sessions to identify "BOUNCES"
    -- STEp 4: Summarizing total sessions and bounced sessions, by LP (landing page)
    
SELECT
	web_pvs.website_session_id,
    MIN(web_pvs.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS web_pvs
	INNER JOIN website_sessions AS web_sess
		ON web_sess.website_session_id = web_pvs.website_session_id
        AND web_sess.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
	web_pvs.website_session_id;

-- SAME QUERY as above, just stored in a temporary table for future use
CREATE TEMPORARY TABLE first_pageview_demo
SELECT
	web_pvs.website_session_id,
    MIN(web_pvs.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS web_pvs
	INNER JOIN website_sessions AS web_sess
		ON web_sess.website_session_id = web_pvs.website_session_id
        AND web_sess.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
	web_pvs.website_session_id;
    
-- Bringing in the landing page to Each sessions

CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT
	first_pageview_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview_demo 
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview_demo.min_pageview_id; -- Website pageview is the landing page view
	
SELECT * FROM sessions_w_landing_page_demo; -- QA Only

-- Next we make a table to include a count of pageviews per session.
-- First, Print all of the sessions. Then limit to bounced sessions and create a temp table.


CREATE TEMPORARY TABLE bounced_sessions_only

SELECT
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM
	sessions_w_landing_page_demo
	LEFT JOIN website_pageviews
		ON	website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
        
GROUP BY
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page
HAVING
	count_of_pages_viewed = 1;

# Will output No of sessions and Bounced Sessions and Rate of bounced sessions
SELECT
	sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
	COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id)/ COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS bounced_rates
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON bounced_sessions_only.website_session_id = sessions_w_landing_page_demo.website_session_id
GROUP BY
	sessions_w_landing_page_demo.landing_page
ORDER BY 
	bounced_sessions
    ;


