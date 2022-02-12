# Analyzing conversion funnel for the gesearch visitors (utm_source) between the following pageview_url: /lander-1 to /cart
# Analyze the data between 2012-08-05 to 2012-09-05
USE mavenfuzzyfactory;

-- SELECT * FROM website_pageviews
-- WHERE created_at BETWEEN '2012-08-05' AND '2012-09-05'
-- and website_session_id = 4493;

# Step 1: Create a query for all the relevant sessions with specific pageviews and flag the pageview urls for gsearch.

SELECT 
	web_sess.website_session_id,
    web_pvs.pageview_url,
    web_pvs.created_at AS pageview_created_at,
    -- Flagging each session to track session id through the order cycle
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS order_page

FROM website_pageviews AS web_pvs
	LEFT JOIN website_sessions AS web_sess
		ON web_sess.website_session_id = web_pvs.website_session_id
WHERE web_pvs.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND web_sess.utm_source = 'gsearch'
    AND web_pvs.pageview_url IN('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')

ORDER BY web_sess.website_session_id;

#Step 2: Using the previous query as Subquery
CREATE TEMPORARY TABLE sessions_level_made_it_flags
SELECT 
	website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(order_page) AS order_made_it
FROM
-- Subquery:
(
	SELECT 
		web_sess.website_session_id,
		web_pvs.pageview_url,
		web_pvs.created_at AS pageview_created_at,
		-- Flagging each session to track session id through the order cycle
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS order_page

	FROM website_pageviews AS web_pvs
		LEFT JOIN website_sessions AS web_sess
			ON web_sess.website_session_id = web_pvs.website_session_id
	WHERE web_pvs.created_at BETWEEN '2012-08-05' AND '2012-09-05'
		AND web_sess.utm_source = 'gsearch'
		AND web_pvs.pageview_url IN('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
	ORDER BY web_sess.website_session_id
) AS pageview_level

GROUP BY website_session_id;

# STEP 3: 

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN order_made_it = 1 THEN website_session_id ELSE NULL END) AS to_order
FROM sessions_level_made_it_flags
;

# Step 4: Calculating Click Through Rates for Each pages:
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /  COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN order_made_it = 1 THEN website_session_id ELSE NULL END) /  COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM sessions_level_made_it_flags

