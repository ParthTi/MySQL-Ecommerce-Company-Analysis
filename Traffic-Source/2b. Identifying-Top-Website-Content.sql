USE mavenfuzzyfactory;

-- CREATE TEMPORARY TABLE most_pageviews

# Top Website sessions by Website page URL
SELECT
	pageview_url,
    COUNT(DISTINCT website_session_id) AS num_of_website_session    
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 
	pageview_url
ORDER BY 
	num_of_website_session DESC;


# Top Entry/Landing Pages, i.e. which website url the customer landed at first:
	# STEP 1: Find the first page view for each session
	# STEP 2: Find the url the customer saw on that first pageview

CREATE TEMPORARY TABLE first_pv_per_session
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM 
	website_pageviews
WHERE 
	created_at < '2012-06-12'
GROUP BY 
	website_session_id;

# Top Entry Code 
SELECT
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions_hitting_page
FROM first_pv_per_session
	LEFT JOIN website_pageviews
		ON first_pv_per_session.first_pv = website_pageviews.website_pageview_id
GROUP BY landing_page_url
ORDER BY sessions_hitting_page DESC;

