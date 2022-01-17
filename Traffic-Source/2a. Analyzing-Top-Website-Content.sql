# ANALYZING TOP WEBSITE CONTENT 

use mavenfuzzyfactory;

-- SELECT
-- 	pageview_url,
--     COUNT(DISTINCT website_pageview_id) AS PVS
-- FROM website_pageviews
-- WHERE website_pageview_id < 1000
-- GROUP BY pageview_url
-- ORDER BY pvs DESC;

# For Later: Number of people that visited the website and made a purchase. Also find the %age of those people.

# INTRO TO TEMP TABLE
CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
	MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

SELECT 
-- 	first_pageview.website_session_id,
--     website_pageviews.created_at,
    website_pageviews.pageview_url AS landing_page, -- aka "entry page"
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pageview_id = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url