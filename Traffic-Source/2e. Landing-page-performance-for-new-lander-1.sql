USE mavenfuzzyfactory;
# Analyzing Landing page tests:
# Based on the high bounce rate we previously analyzed in 2d. There was new lander page introduced '/lander-1'.
# Now we need to test the performance of the '/lander-1' page against the homepage(/home) for our gsearch nonbrand traffic.
-- Date when the /Lander-1 page was created. We will use this date to test the performance of the new lander page as compared to previous lander page. i.e. '/home';
SELECT
-- 	web_pvs.pageview_url AS url,
	MIN(created_at) AS fist_created_at,
    MIN(web_pvs.website_pageview_id) AS first_pageview_id
FROM website_pageviews AS web_pvs
-- GROUP BY url
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;

# -- Step 1: Identify the pageview id for the relevant website sessions: Creating first page view summary

CREATE TEMPORARY TABLE first_pageview

SELECT
	web_pvs.website_session_id,
    MIN(web_pvs.website_pageview_id) AS first_pageview
FROM website_pageviews AS web_pvs
		INNER JOIN website_sessions AS web_sess
			ON web_sess.website_session_id = web_pvs.website_session_id
            AND web_sess.created_at < '2012-07-28'
            AND web_pvs.website_pageview_id > 23504
            AND web_sess.utm_source = 'gsearch'
            AND web_sess.utm_campaign = 'nonbrand'
GROUP BY
	web_pvs.website_session_id
;


# Step 2: Identifying Landing pages for each sessions, limiting landing pages to /home and /lander-1
CREATE TEMPORARY TABLE landing_page
SELECT
	first_pvs.website_session_id,
    web_pvs.pageview_url AS landing_page_url
FROM first_pageview AS first_pvs
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = first_pvs.website_session_id
		AND web_pvs.pageview_url  IN('/home', '/lander-1');
        


# Step 3: Identifying bounced sessions only
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	land.website_session_id,
    land.landing_page_url,
    COUNT(DISTINCT web_pvs.website_pageview_id) AS count_of_pageview_id
FROM landing_page AS land
	LEFT JOIN website_pageviews AS web_pvs
		ON web_pvs.website_session_id = land.website_session_id
GROUP BY 
	land.website_session_id,
	land.landing_page_url
HAVING
	count_of_pageview_id = 1;
    

# Final Step: Calulating and comparing the bounced_sessions, total_sessions and for custom landing page(/lander-1) and homepage(/home) to determine whether or not the new landing page performs better:

SELECT
	landing_page.landing_page_url,
	COUNT(DISTINCT landing_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT landing_page.website_session_id) AS bounce_rate
FROM 
	landing_page 
		LEFT JOIN bounced_sessions
			ON bounced_sessions.website_session_id = landing_page.website_session_id
GROUP BY 
	landing_page_url;
    
  # Final Conclusion:   Based on the better perfomance of the new page: Lander-1,  we should route all the traffic from /Home to /Lander-1 landing page to gain more customer attention.



