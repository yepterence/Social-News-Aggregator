-- From guideline 2 of business req.
BEGIN;
-- All users who haven't logged in since last year
SELECT username FROM users WHERE (NOW() - last_login) >= 1 year;

-- List all users who haven’t created any post
SELECT user_id FROM posts WHERE title IS NULL;

--  Find a user by their username.
SELECT username FROM users WHERE username = 'Bob';

-- List all topics that don’t have any posts
SELECT topic_id FROM posts WHERE title IS NULL;

-- Find a topic by its name.
SELECT title FROM posts WHERE title = 'Placeholder';

-- List the latest 20 posts for a given topic
SELECT title, sub.username 
FROM (SELECT id, topic_name, username FROM topics JOIN users ON users.id = topics.user_id ) sub
JOIN posts 
ON sub.id = posts.post_id
WHERE sub.username = 'Joe'
LIMIT 20; 

-- List all the top-level comments (those that don’t have a parent comment) for a given post. For eg. title = Science
SELECT comments 
FROM post_comments 
JOIN posts 
ON post_comments.post_id = posts.id
WHERE parent_comment_id = id AND posts.title = 'Science';


-- List all the direct children of a parent comment. 


-- Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes

SELECT SUM(votes) FROM post_votes WHERE post_id = NULL;

END;