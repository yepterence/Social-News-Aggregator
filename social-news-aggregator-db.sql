-- Author: Terence Yep

-- Goal is to create a new schema with given business requirements

CREATE TABLE users (
    "id" SERIAL PRIMARY KEY,
    "username" VARCHAR(25) NOT NULL CHECK (LENGTH(username)<=25)
);

CREATE TABLE topics (
    "id" SERIAL,
    "name" VARCHAR(30) NOT NULL CHECK (LENGTH("name")<=30),
    "description" VARCHAR(500)   
);

CREATE TABLE posts (
    "id" SERIAL,
    "title" VARCHAR(100) NOT NULL CHECK (LENGTH("title")<=100) ON DELETE CASCADE,
    "user_id" INTEGER ON DELETE SET NULL
);

CREATE TABLE post_comments (
    "post_id" INTEGER,
    "user_id" INTEGER,
    "comments" TEXT NOT NULL
);

