-- Author: Terence Yep

-- Goal is to create a new schema that has significant improvements compared to bad-db.sql with given business requirements
SET AUTOCOMMIT OFF
BEGIN;
-- 1. Users table
CREATE TABLE users (
    "id" BIGSERIAL PRIMARY KEY, 
    "username" VARCHAR(25) UNIQUE CHECK(LENGTH(TRIM("username"))>0), 
    "last_login" TIMESTAMP 
);

COMMENT ON COLUMN users.id IS 'large no of users expected';
COMMENT ON COLUMN users.username IS ' username must be unique, max 25 char, not empty';
CREATE INDEX "search_by_usrname" ON users (username VARCHAR_PATTERN_OPS);

-- 2. Topics table
CREATE TABLE topics (
    "id" SERIAL PRIMARY KEY,
    "topic_name" VARCHAR(30) UNIQUE,
    "description" VARCHAR(500),
    CONSTRAINT "non_empty_topic" CHECK(LENGTH(TRIM("topic_name"))>0)  
);

COMMENT ON COLUMN topics.topic_name IS 'topic must be unique, max 30 char, not empty';
COMMENT ON COLUMN topics.description IS 'description max 500 char, optional';

-- CREATE INDEX "search_by_topic_name" ON topics ("topic_name")

-- 3. Posts table
CREATE TABLE posts (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(100) ,
    "content" TEXT,
    "url" VARCHAR,
    "post_timestamp" TIMESTAMP WITHOUT TIME ZONE,
    "topic_id" INTEGER CONSTRAINT "posts_topic_fk" REFERENCES topics("id") ON DELETE CASCADE,
    "user_id" BIGINT CONSTRAINT "posts_usr_fk" REFERENCES users("id") ON DELETE SET NULL,
    CONSTRAINT "nospaces_non_empty_title" CHECK (LENGTH(TRIM(title))>0),
    CONSTRAINT "url_content_null_check" CHECK ("url" IS NOT NULL OR "content" IS NOT NULL)
);

COMMENT ON COLUMN posts.topic_id IS 'If a topic gets deleted, all the posts associated with it should be automatically deleted too';
COMMENT ON COLUMN posts.user_id IS 'If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.';

CREATE INDEX "users_no_post_idx" ON posts (user_id,title);
-- CREATE INDEX "posts_url_idx" ON posts (url,)

-- 4. Comments table
CREATE TABLE post_comments (
    "id" SERIAL PRIMARY KEY,
    "parent_comment_id" INTEGER,
    "comments" TEXT NOT NULL,
    "user_id" BIGINT CONSTRAINT "user_id_fk" REFERENCES users("id") ON DELETE SET NULL,
    "post_id" INTEGER CONSTRAINT "post_id_fk" REFERENCES posts("id"),
    CONSTRAINT "initial_comment" FOREIGN KEY (parent_comment_id) REFERENCES post_comments("id") ON DELETE CASCADE 
);

COMMENT ON CONSTRAINT "initial_comment" ON post_comments IS 'references post_comments id column with the intent of creating threaded comment structure';

COMMENT ON COLUMN post_comments.user_id IS 'if user deleted, comment dissociated from user';

-- CREATE INDEX "all_posts_given_user" ON post_comments (post_id,user_id);

-- 5. Post Up/Downvotes table
CREATE TABLE post_votes (
    "post_id" BIGINT CONSTRAINT "post_id_delete_votes_idx" REFERENCES posts("id") ON DELETE CASCADE,
    "user_id" BIGINT CONSTRAINT "user_id_idx" REFERENCES users("id") ON DELETE SET NULL,
    CONSTRAINT "post_user_composite_pk" PRIMARY KEY ("post_id", "user_id"),
    "vote" SMALLINT DEFAULT 0,
    CONSTRAINT "up_down_vote_chk" CHECK ("vote" = 1 OR "vote" = -1)
);

END;
