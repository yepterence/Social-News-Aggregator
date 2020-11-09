-- For users table
BEGIN;
-- Populate users table with unique usernames from bad_posts
INSERT INTO users ("username") 
SELECT DISTINCT username 
FROM bad_posts 
UNION 
SELECT DISTINCT username 
FROM bad_comments;

-- Populate topic_name with topics from bad_posts
INSERT INTO topics ("topic_name") 
SELECT DISTINCT LEFT(topic,30) 
FROM bad_posts;


-- Populate topic_id and user_id of posts table after innerjoin with bad_posts
INSERT INTO posts ("topic_id", "user_id","url","content","title") 
SELECT bp_sub.topid, users.id, bp_sub.url, bp_sub.tc, LEFT(bp_sub.title,100)
FROM (
    SELECT topics.id topid, bp.username uname, bp.url, bp.text_content tc, bp.title 
    FROM topics 
    JOIN bad_posts bp
    ON bp.topic = topics.topic_name
) bp_sub 
JOIN users 
ON users.username = bp_sub.uname 
JOIN topics t
ON t.id = bp_sub.topid;

-- Populate post_comments table with comments from bad_comments, be sure to inner join with username and post_id and select for text_content 

INSERT INTO post_comments ("user_id","post_id","comments") 
SELECT usr_sub.id, bc.post_id, bc.text_content  
FROM (
    SELECT id, username
    FROM users 
) usr_sub
JOIN bad_comments bc
ON bc.username = usr_sub.username;