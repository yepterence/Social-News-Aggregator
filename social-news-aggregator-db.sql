-- INSERTING DATA into a table
-- migrate the list of people without their emails into the normalized people table, which contains an id SERIAL column in addition to first_name and last_name.
INSERT INTO people (first_name, last_name) SELECT first_name, last_name FROM denormalized_people;


-- How to insert data from one table to another table 

-- migrate the email addresses of each person to the normalized people_emails table
INSERT INTO people_emails 
SELECT sub.id, regexp_split_to_table(emails,',')
FROM (SELECT id,last_name FROM people p) sub
JOIN denormalized_people dn 
ON dn.last_name = sub.last_name;

-- inserting multiple values at the same time into table
INSERT INTO "table_name" ("column1", "column2", "column3") VALUES 
  ('value1','value2','value3'),
  ('value4','value5','value6');

-- performing this join on denormalized people will ensure the emails are mapped to the specific individual's unique ID 

-- UPDATING DATA in a table

-- All values of the last_name column are currently in upper-case. We'd like to change them from e.g. "SMITH" to "Smith"
UPDATE people SET last_name = LEFT(last_name,1)||LOWER(RIGHT(last_name,length(last_name)-1));

-- the table has a column born_ago, a TEXT field of the form e.g. '34 years 5 months 3 days'. We'd like to convert this to an actual date of birth.
-- Create new column date_of_birth with dtype DATE
ALTER TABLE people ADD COLUMN date_of_birth DATE;
-- Coercing string into interval and then subtracting from current date to receive date of birth
UPDATE people SET date_of_birth = CURRENT_TIMESTAMP - born_ago::INTERVAL::DATE; 
-- Drop column redundant born_ago 
ALTER TABLE people DROP COLUMN born_ago;

-- Checking datatype of column using func pg_typeof 
SELECT pg_typeof(CURRENT_TIMSTAMP - date_of_birth) FROM people;

-- turning off autocommit
\set AUTOCOMMIT off

BEGIN;

-- Deleting all users in states CA and NY from table
DELETE FROM user_data WHERE state IN ('CA','NY');

-- split up the name column into two new columns: first_name and last_name.
-- create new columns named first_name and last_name
ALTER TABLE user_data ADD COLUMN first_name VARCHAR, ADD COLUMN last_name VARCHAR;
-- add data into table from name column into the new columns
UPDATE user_data SET first_name = SPLIT_PART(name,' ',1), last_name = SPLIT_PART(name,' ',2);
-- INSERT statement is used, when you want to dump/insert some new set of values in to target table. In this case you have to use the update operator, update statement is used when you want to update the given row (based on criteria) (or) update the entire table (with out any criteria). 

-- simplify the data by changing the state column to a state_id column.
--  create a states table with an automatically generated id and state abbreviation
CREATE TABLE states (
  "state_id" SERIAL, 
  "state" VARCHAR(2)
);
-- migrate all the states from the dataset to that table, taking care to not have duplicates
INSERT INTO states ("state")
SELECT DISTINCT state
FROM user_data;
--  add a state_id column to the user_data table.
ALTER TABLE user_data ADD COLUMN state_id INTEGER;
-- make the state_id of the user_data column match the appropriate ID from the new states table. 
UPDATE user_data SET state_id = (SELECT state_id FROM states WHERE user_data.state = states.state);
-- Remove the now redundant state column from the user_data table.
ALTER TABLE user_data DROP COLUMN state;

-- TO-DO revise how to insert data into new columns (INSERT INTO and UPDATE)


-- FOREGIN KEYS, MODIFIERS AND CONSTRAINTS
-- A when manager gets deleted from system keep employees, set null
-- self reference employees table to remove manager employee id but keep others intact
ALTER TABLE employees ADD CONSTRAINT "valid_manager" FOREIGN KEY (manager_id) REFERENCES employees ON DELETE SET NULL;
-- B constraint, can't delete employee if project_id is related to them
-- restricts deletion of employee if project still exists   
ALTER TABLE employee_projects ADD CONSTRAINT "valid_employee" FOREIGN KEY (employee_id) REFERENCES employees;
-- C when projects get deleted, delete everything related to projects
-- Any deletion from the projects table will "cascade" over to employee projects table
ALTER TABLE employee_projects ADD CONSTRAINT "valid_project" FOREIGN KEY (project_id) REFERENCES projects ON DELETE CASCADE;


-- 1. Primary keys
-- Books
-- Primary key should be isbn and id since both need to be unique 

-- ALTER TABLE books ADD PRIMARY KEY (id), ADD UNIQUE (isbn); 
ALTER TABLE books ADD PRIMARY KEY (id);
-- User_book_preferences 
-- Primary key for user_id and book_id as this is used to reference a user_id to a book
ALTER TABLE user_book_preferences ADD PRIMARY KEY (user_id,book_id) ;

-- Exercise 14: Final review 
-- Given all the tables, explore the database and 
    -- Identify the primary key for each table
    -- Identify the unique constraints necessary for each table
    -- Identify the foreign key constraints necessary for each table
    -- In addition to the three types of constraints above, you'll have to implement some custom business rules:
    --     Usernames need to have a minimum of 5 characters
    --     A book's name cannot be empty
    --     A book's name must start with a capital letter
    --     A user's book preferences have to be distinct

-- Users
-- Best to have id and email as primary keys as we'd like unique emails and respective id's for each account
ALTER TABLE users ADD PRIMARY KEY (id);

-- 2. Add constraints
-- ISBN should always be unique 
ALTER TABLE books ADD UNIQUE (isbn);

-- Emails need to be unique to users
ALTER TABLE users ADD UNIQUE (email), ADD UNIQUE(username);
-- user_book_preferences needs to be unique
ALTER TABLE user_book_preferences ADD UNIQUE (preference,user_id);
-- referencing foreign key to books 
ALTER TABLE user_book_preferences ADD CONSTRAINT "fkey_book_id" FOREIGN KEY (book_id) REFERENCES books;
ALTER TABLE user_book_preferences ADD CONSTRAINT "fkey_user_id" FOREIGN KEY (user_id) REFERENCES users;

-- books names can't be empty and must have first letter capitalized
ALTER TABLE books ADD CONSTRAINT "bookname_first_name_capitalized" CHECK (LEFT(username,1) = UPPER(LEFT(username,1)));
ALTER TABLE books ADD CONSTRAINT "bookname_greater_than_5" CHECK (LENGTH(TRIM(name))>= 5);

-- INDEXING EXERCISES

-- Creating primary keys
ALTER TABLE authors ADD PRIMARY KEY (id), ADD UNIQUE (name);
ALTER TABLE books ADD PRIMARY KEY (id), ADD UNIQUE (isbn), ADD FOREIGN KEY (author_id) REFERENCES (authors);
-- Note the foreign key referencing table authors. It is necessary to have an index on the column (id) so that postgres can quickly verify entries based on conditions.
ALTER TABLE topics ADD PRIMARY KEY (id);
ALTER TABLE book_topics ADD PRIMARY KEY (book_id, topic_id);

-- Creating foreign keys
ALTER TABLE books ADD FOREIGN KEY (author_id) REFERENCES authors;
--     We need to be able to quickly find books and authors by their IDs.
-- No need for extra indices as primary key acts as an index that will allow for this behavior.
--     We need to be able to quickly tell which books an author has written.
CREATE INDEX "search_by_author_id" ON books (author_id);


--     We need to be able to quickly find a book by its ISBN #.
CREATE INDEX "isbn_search" ON books (isbn); -- No need for this as unique constraint makes it efficient as is.
--     We need to be able to quickly search for books by their titles in a case-insensitive way, even if the title is partial. For example, searching for "the" should return "The Lord of the Rings".
CREATE INDEX "case_insensitive_title_search" ON books (LOWER(title) VARCHAR_PATTERN_OPS);
--     For a given book, we need to be able to quickly find all the topics associated to it.
-- Primary key in book_topics will allow for quick searches on book_id, book_id and topic_id
--     For a given topic, we need to be able to quickly find all the books tagged with it.
CREATE INDEX "search_by_topic_id" ON book_topics (topic_id);