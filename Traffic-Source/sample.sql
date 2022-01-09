 SELECT
	DISTINCT ws.device_type AS 'Device Type',
    ws.utm_source,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT ord.order_id) AS orders,
    CONCAT(COUNT(DISTINCT ord.order_id)/COUNT(DISTINCT ws.website_session_id)*100,"%") AS CVR
        
FROM
	website_sessions AS ws
		LEFT JOIN orders AS ord
			ON ord.website_session_id = ws.website_session_id
WHERE
	ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'