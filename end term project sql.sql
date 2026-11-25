StreamSphere OTT Platform Content & User Engagement Analysis

CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    age INT CHECK (age BETWEEN 13 AND 100),
    city VARCHAR(50),
    signup_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS content (
    content_id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    content_type VARCHAR(30) NOT NULL,
    genre VARCHAR(40),
    release_year INT,
    duration INT CHECK (duration > 0)
);

CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    plan_name VARCHAR(30) NOT NULL,
    monthly_price NUMERIC(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS viewing_history (
    view_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    content_id INT NOT NULL REFERENCES content(content_id),
    watch_date DATE NOT NULL,
    watch_minutes INT NOT NULL CHECK (watch_minutes >= 0),
    completion_percentage NUMERIC(5,1) CHECK (completion_percentage BETWEEN 0 AND 100)
);

CREATE TABLE IF NOT EXISTS ratings (
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    content_id INT NOT NULL REFERENCES content(content_id),
    rating NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    rating_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY,
    subscription_id INT NOT NULL REFERENCES subscriptions(subscription_id),
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL
);

-- 2. VERIFY TABLES
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND table_name IN ('users', 'content', 'subscriptions', 'viewing_history', 'ratings', 'payments')
ORDER BY table_name;

-- 3. DATA CLEANING (safe to rerun)
UPDATE users
SET city = 'Unknown'
WHERE city IS NULL OR TRIM(city) = '';

UPDATE content
SET genre = INITCAP(TRIM(genre))
WHERE genre IS NOT NULL
  AND genre <> INITCAP(TRIM(genre));

SELECT * FROM users WHERE city IS NULL OR TRIM(city) = '';

-- 4. ANALYSIS QUERIES

-- QUERY 1: Top 10 most-watched content
SELECT c.content_id, c.title, c.content_type, c.genre,
       SUM(v.watch_minutes) AS total_watch_minutes
FROM content AS c
INNER JOIN viewing_history AS v ON c.content_id = v.content_id
GROUP BY c.content_id, c.title, c.content_type, c.genre
ORDER BY total_watch_minutes DESC
LIMIT 10;

-- QUERY 2: Genre-wise viewing analysis
SELECT c.genre,
       COUNT(v.view_id) AS total_views,
       SUM(v.watch_minutes) AS total_watch_minutes,
       ROUND(AVG(v.watch_minutes), 2) AS avg_watch_minutes
FROM content AS c
INNER JOIN viewing_history AS v ON c.content_id = v.content_id
GROUP BY c.genre
ORDER BY total_views DESC;

-- QUERY 3: Average ratings by genre
SELECT c.genre,
       ROUND(AVG(r.rating), 2) AS average_rating,
       COUNT(r.rating_id) AS total_ratings
FROM content AS c
INNER JOIN ratings AS r ON c.content_id = r.content_id
GROUP BY c.genre
ORDER BY average_rating DESC;

-- QUERY 4: Subscription plan popularity (all statuses included)
SELECT plan_name,
       COUNT(subscription_id) AS total_subscriptions,
       ROUND(AVG(monthly_price), 2) AS average_monthly_price
FROM subscriptions
GROUP BY plan_name
ORDER BY total_subscriptions DESC;

-- QUERY 5: Revenue from successful payments only
SELECT s.plan_name,
       COUNT(p.payment_id) AS successful_transactions,
       SUM(p.amount) AS total_revenue
FROM subscriptions AS s
INNER JOIN payments AS p ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Successful'
GROUP BY s.plan_name
ORDER BY total_revenue DESC;

-- QUERY 6: Top 10 users by watch time
SELECT u.user_id, u.user_name,
       COUNT(v.view_id) AS total_sessions,
       SUM(v.watch_minutes) AS total_watch_minutes
FROM users AS u
INNER JOIN viewing_history AS v ON u.user_id = v.user_id
GROUP BY u.user_id, u.user_name
ORDER BY total_watch_minutes DESC
LIMIT 10;

-- QUERY 7: User engagement classification (duplicate copy removed)
SELECT user_id, total_watch_minutes,
       CASE
           WHEN total_watch_minutes >= 500 THEN 'High'
           WHEN total_watch_minutes >= 200 THEN 'Medium'
           ELSE 'Low'
       END AS engagement_level
FROM (
    SELECT user_id, SUM(watch_minutes) AS total_watch_minutes
    FROM viewing_history
    GROUP BY user_id
) AS user_activity
ORDER BY total_watch_minutes DESC;

-- QUERY 8: Rank content within each genre
SELECT genre, title, total_watch_minutes,
       RANK() OVER (PARTITION BY genre ORDER BY total_watch_minutes DESC) AS genre_rank
FROM (
    SELECT c.genre, c.title, SUM(v.watch_minutes) AS total_watch_minutes
    FROM content AS c
    INNER JOIN viewing_history AS v ON c.content_id = v.content_id
    GROUP BY c.content_id, c.genre, c.title
) AS content_activity
ORDER BY genre, genre_rank;

-- QUERY 9: Users with above-average watch time
-- Average is calculated among users with at least one viewing record.
WITH user_watch AS (
    SELECT user_id, SUM(watch_minutes) AS total_watch_minutes
    FROM viewing_history
    GROUP BY user_id
)
SELECT user_id, total_watch_minutes
FROM user_watch
WHERE total_watch_minutes > (SELECT AVG(total_watch_minutes) FROM user_watch)
ORDER BY total_watch_minutes DESC;

-- QUERY 10: Monthly viewing activity
SELECT DATE_TRUNC('month', watch_date)::date AS viewing_month,
       COUNT(*) AS total_viewing_sessions,
       SUM(watch_minutes) AS total_watch_minutes,
       ROUND(AVG(watch_minutes), 2) AS average_watch_minutes
FROM viewing_history
GROUP BY DATE_TRUNC('month', watch_date)
ORDER BY viewing_month;
