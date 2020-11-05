-- Author: Terence Yep

-- Goal is to create a new schema that has significant improvements compared to bad-db.sql with given business requirements

CREATE TABLE users (
    "id" BIGSERIAL PRIMARY KEY COMMENT 'large no of users expected',
    "username" VARCHAR(25) UNIQUE CHECK (LENGTH(TRIM("username")>0)) COMMENT 'username must be unique, max 25 char, not empty',
    "last_login" TIMESTAMP
);

CREATE TABLE topics (
    "id" SERIAL PRIMARY KEY,
    "topic_name" VARCHAR(30) UNIQUE COMMENT 'topic must be unique, max 30 char, not empty' ON DELETE CASCADE,
    "description" VARCHAR(500) COMMENT 'optional desc, max 500 char',  
    CHECK (LENGTH(TRIM("topic_name"))>0)
);

CREATE TABLE posts (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(100) COMMENT 'max char 100, not empty, unique',
    CHECK (LENGTH(TRIM(title))>0),
    "content" TEXT,
    "url" VARCHAR,
    "topic_id" INTEGER REFERENCES topics("id") ON DELETE CASCADE,
    "user_id" INTEGER ON DELETE SET NULL,
    CONSTRAINT "url_content_null_check" CHECK ("url" IS NOT NULL OR "content" IS NOT NULL),
    FOREIGN KEY user_id REFERENCES users("id") 
);

CREATE TABLE post_comments (
    "id" SERIAL PRIMARY KEY,
    "parent_comment_id" INTEGER DEFAULT NULL,
    "comments" TEXT NOT NULL,
    "user_id" INTEGER REFERENCES users("id"),
    "post_id" INTEGER REFERENCES posts("id"),
    CONSTRAINT "initial_comment" FOREIGN KEY (parent_comment_id) REFERENCES post_comments("id") ON DELETE CASCADE 
);

CREATE TABLE post_votes (
    "post_id" BIGINT REFERENCES posts(id),
    "user_id" BIGINT REFERENCES users(id),
    UNIQUE (post_id, user_id)
    "upvote" INTEGER,
    "downvote" INTEGER 
);

