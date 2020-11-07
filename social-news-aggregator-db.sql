-- Author: Terence Yep

-- Goal is to create a new schema that has significant improvements compared to bad-db.sql with given business requirements

CREATE TABLE users (
    "id" BIGSERIAL PRIMARY KEY, 
    "username" VARCHAR(25) UNIQUE CHECK(LENGTH(TRIM("username"))>0), 
    "last_login" TIMESTAMP 
);
COMMENT ON COLUMN users.id IS 'large no of users expected';
COMMENT ON COLUMN users.username IS ' username must be unique, max 25 char, not empty';

CREATE TABLE topics (
    "id" SERIAL PRIMARY KEY,
    "topic_name" VARCHAR(30) UNIQUE,
    "description" VARCHAR(500),
    CONSTRAINT "non_empty_topic" CHECK(LENGTH(TRIM("topic_name"))>0)  
);

COMMENT ON COLUMN topics.topic_name IS 'topic must be unique, max 30 char, not empty';
COMMENT ON COLUMN topics.description IS 'description max 500 char, optional';

CREATE TABLE posts (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(100) ,
    "content" TEXT,
    "url" VARCHAR,
    "topic_id" INTEGER REFERENCES topics("id") ON DELETE CASCADE,
    "user_id" BIGINT REFERENCES users("id") ON DELETE SET NULL,
    CHECK (LENGTH(TRIM(title))>0),
    CONSTRAINT "url_content_null_check" CHECK ("url" IS NOT NULL OR "content" IS NOT NULL)
);

COMMENT ON COLUMN posts.topic_id IS 'If a topic gets deleted, all the posts associated with it should be automatically deleted too';
COMMENT ON COLUMN posts.user_id IS 'If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.';

CREATE TABLE post_comments (
    "id" SERIAL PRIMARY KEY,
    "parent_comment_id" INTEGER,
    "comments" TEXT NOT NULL,
    "user_id" BIGINT REFERENCES users("id") ON DELETE SET NULL,
    "post_id" INTEGER REFERENCES posts("id"),
    CONSTRAINT "initial_comment" FOREIGN KEY (parent_comment_id) REFERENCES post_comments("id") ON DELETE CASCADE 
);

COMMENT ON CONSTRAINT "initial_comment" ON post_comments IS 'references post_comments id column with the intent of creating threaded comment structure';

COMMENT ON COLUMN post_comments.user_id IS 'if user deleted, comment dissociated from user';

CREATE TABLE post_votes (
    "post_id" BIGINT REFERENCES posts("id"),
    "user_id" BIGINT REFERENCES users("id") ON DELETE SET NULL,
    UNIQUE ("post_id", "user_id"),
    "vote" SMALLINT DEFAULT 0,
    CHECK ("vote" = 1 OR "vote" = -1)
);

