USE mavenfuzzyfactory;

-- Conversion funnel analysis is about understanding and optimizing each step of your user's experience on their journey toward purchasing your products

-- Looking at website_pageviews:

-- SELECT * FROM website_pageviews
-- WHERE website_session_id = 1059 -- Looking at a specific customer to check how a customer moves through our website. 
-- ORDER BY created_at

-- Subqueries
-- Syntax SELECT * FROM (subquery) AS "X" # Subquery must always have an Alias

## Building Coversion Funnels
	-- BUSINESS CONTEXT
		-- We want to build a mini conversion funnel, from /lander-2 to /cart
        -- We want to know how many people reach each step and also dropoff rates
        -- For simplicity sake, we are only looking at /lander-2
        -- For simplicity sake, We are only looking at customers who like Mr Fuzzy Only
        
-- Step 1: Select all pageviews for relevant sessions
-- Step 2: Identify each relevant pageview as the specific funnel step
-- Step 3: Create the session-level conversion funnel view
-- Step 4: Aggregate the data to assess funnel performance

SELECT
	web_sess.website_session_id,
	web_pvs.pageview_url,
    web_pvs.created_at AS pageview_created_at,
    -- Following statements flag each sessions at the specific url on created_at time
    CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_pageviews AS web_pvs
	LEFT JOIN website_sessions AS web_sess 
		ON web_sess.website_session_id = web_pvs.website_session_id
WHERE web_sess.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- Random time frame
	AND web_pvs.pageview_url IN('/lander-2','/products','/the-original-mr-fuzzy','/cart') 
ORDER BY web_sess.website_session_id

;
-- Using the previous query as Subquery in the following one:
-- this will produce data for each session_id/customer and which point of shopping they made it to, namely: Productpage, mrfuzzypage or cart_page
-- Then we will convert this into a temp table:

CREATE TEMPORARY TABLE sessions_level_made_it_flags
SELECT 
	website_session_id,
    MAX(product_page) AS product_made_it,
	MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
	( -- Subquery:
		SELECT
	web_sess.website_session_id,
	web_pvs.pageview_url,
    web_pvs.created_at AS pageview_created_at,
    -- Following statements flag each sessions at the specific url on created_at time
    CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_pageviews AS web_pvs
	LEFT JOIN website_sessions AS web_sess 
		ON web_sess.website_session_id = web_pvs.website_session_id
WHERE web_sess.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- Random time frame
	AND web_pvs.pageview_url IN('/lander-2','/products','/the-original-mr-fuzzy','/cart') 
ORDER BY web_sess.website_session_id

) AS pageview_level

GROUP BY website_session_id;

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id  ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id  ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id  ELSE NULL END) AS to_cart
FROM sessions_level_made_it_flags;

-- Calculating rates of above metrics
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id  ELSE NULL END) / COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id  ELSE NULL END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id  ELSE NULL END) AS clicked_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id  ELSE NULL END) /COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id  ELSE NULL END) AS clicked_to_cart
FROM sessions_level_made_it_flags
 -- i.e. 73% of the customers who visited the website reched the product page;
 -- 61% of the customers that made it to the product page visited the mrfuzzy page;
 -- 60.48% of the customers that made it to the mrfuzzy page made it to the cart page


