-- For users table
BEGIN;
-- Populate users table with unique usernames from bad_posts
INSERT INTO users ("username") SELECT usr_sub.username FROM (SELECT DISTINCT username FROM bad_posts UNION SELECT DISTINCT username FROM bad_comments)usr_sub;

-- Populate topic_name with topics from bad_posts
INSERT INTO topics ("topic_name") SELECT DISTINCT LEFT(topic,30) FROM bad_posts;


-- Populate topic_id and user_id of posts table after innerjoin with bad_posts
INSERT INTO posts (topic_id, user_id) VALUES (
    SELECT topics_posts.id, users.id FROM (SELECT topics.id topid FROM topics JOIN bad_posts ON bad_posts.topic = topics.topic_name;) topics_posts 
    JOIN users 
    ON users.username = topics_posts.uname ;
)

-- Populate post titles (inner join) not to be done until after populating with user id and post id

INSERT INTO posts ("title","post_timestamp") VALUES (
    SELECT title, post_timestamp FROM bad_posts; 
);
