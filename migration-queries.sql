BEGIN;
-- For users table
-- Populate users table with unique usernames from bad_posts
INSERT INTO users ("username") 
SELECT DISTINCT username 
FROM bad_posts 
UNION 
SELECT DISTINCT username 
FROM bad_comments
UNION
SELECT REGEXP_SPLIT_TO_TABLE(upvotes,',') username
FROM bad_posts
UNION
SELECT REGEXP_SPLIT_TO_TABLE(downvotes,',') username
FROM bad_posts;

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

-- Populate votes for all posts by a user by other users
-- inner join based on the username and then assign a value +1/-1 based on whether its taken from upvotes or downvotes column

-- For all upvotes,select ids that match and assign 1 to upvote column
INSERT INTO post_votes ("post_id","user_id","vote")
SELECT bp_u.id, u.id, 1 upvote
FROM (
    SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes,',') usernames
    FROM bad_posts
)bp_u
JOIN users u 
ON u.username=bp_u.usernames;

-- For all downvotes, select ids that match and assign -1 to downvote column

INSERT INTO post_votes ("post_id","user_id","vote")
SELECT bp_d.id, u.id, -1 AS downvote
FROM (
    SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes,',') usernames
    FROM bad_posts
)bp_d
JOIN users u 
ON u.username=bp_d.usernames;

END;