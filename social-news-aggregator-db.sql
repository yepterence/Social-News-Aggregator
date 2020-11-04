-- Author: Terence Yep

-- Goal is to create a new schema with given business requirements

CREATE TABLE users (
    "id" BIGSERIAL PRIMARY KEY COMMENT 'large no of users, quick search on id, reqd for FK ref',
    "username" VARCHAR(25) NOT NULL CHECK (LENGTH(username)<=25) COMMENT 'username must be unique, max 25 char, not empty'
);

CREATE TABLE topics (
    "id" SERIAL,
    "name" VARCHAR(30) NOT NULL COMMENT 'topic must be unique, max 30 char, not empty' ON DELETE CASCADE,
    CHECK (LENGTH(name)<=30),
    "description" VARCHAR(500) COMMENT 'optional desc, max 500 char'  
);

CREATE TABLE posts (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(100) NOT NULL CHECK (LENGTH("title")<=100) ON DELETE CASCADE COMMENT 'max char 100, not empty, unique',
    "content" TEXT,
    "url" VARCHAR,
    "user_id" INTEGER ON DELETE SET NULL
    CONSTRAINT "url_content_null_check" CHECK (url IS NOT NULL OR content IS NOT NULL)

);

CREATE TABLE post_comments (
    "id" SERIAL PRIMARY KEY,
    "parent_comment_id" INTEGER DEFAULT NULL,
    "comments" TEXT NOT NULL,
    "user_id" INTEGER REFERENCES users("id"),
    "post_id" INTEGER REFERENCES posts("id"),
    CONSTRAINT "initial_comment" FOREIGN KEY (parent_comment_id) REFERENCES post_comments("id") ON DELETE CASCADE 
);

