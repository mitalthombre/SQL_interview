USE publications; 

-- Basic subqueries
-- Most of the time, used inside a WHERE, as an alternative to JOINS

/******
If we want to find all of the titles, published by publishers in the USA
******/

-- titles are in the titles table
SELECT 
    *
FROM
    titles;

-- publishers are in the publishers table
SELECT 
    *
FROM
    publishers;


-- how to find the titles published by a publisher in the USA


-- using a join:
SELECT 
    t.title
FROM
    titles t
        LEFT JOIN
    publishers p ON t.pub_id = p.pub_id
WHERE
    p.country = 'USA';


-- using a subquery
SELECT 
    title
FROM
    titles
WHERE
    pub_id IN (SELECT 
            pub_id
        FROM
            publishers
        WHERE
            country = 'USA');
    
-- using a temporary table
-- this is a little silly with such little data, but an example of how they work
create temporary table titles_publishers
select 
    t.*, 
    p.pub_name, 
    p.city, 
    p.state, 
    p.country 
from 
    titles t 
        left join 
    publishers p
        on t.pub_id = p.pub_id;

SELECT 
    *
FROM
    titles_publishers
WHERE
    country = 'USA';

drop temporary table titles_publishers;

/******
WE WILL FIND OUT THE TOP 3 MOST PROFITABLE AUTHORS
    - 1: Step by step exploration of how we calculate profit per author (advance + royalties)
    - 2: How to find the top 3 with temporary table
    - 3: How to find the top 3 with subqueries
******/

-- how are "profits" defined in the database?

-- authors get a fixed amount called "advance" for each title they publish
SELECT 
    title, 
    advance
FROM
    titles;



-- to get the advance per author, we join titles with authors:
SELECT 
    t.title_id, 
    t.title, 
    a.au_fname, 
    a.au_lname, 
    t.advance
FROM
    titles t
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
        LEFT JOIN
    authors a ON ta.au_id = a.au_id;

-- as you see with 'Cooking with Computers...", a title can be published by several authors. 
-- how do Michael and Steearns split the 5000 dollars advance?



-- the answer is in the column "royaltyper" fromo the titleauthor table
SELECT 
    t.title_id, t.title, a.au_fname, t.advance, ta.royaltyper
FROM
    titles t
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
        LEFT JOIN
    authors a ON ta.au_id = a.au_id;

-- it looks like Michael gets 40% of that money and Stearns 60%



-- let's make column, advance_au, with the amount of the advance each author receives
SELECT 
    t.title_id,
    t.title,
    a.au_fname,
    t.advance,
    ta.royaltyper,
    ROUND((t.advance * ta.royaltyper / 100), 2) AS advance_au
FROM
    titles t
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
        LEFT JOIN
    authors a ON ta.au_id = a.au_id;



-- the authors also make profits through royalties
-- a percentage of the price from each sale that goes to the authors
-- the percentage can vary from title to title. It's stored in titles.royalty
-- the sales are in the sales table as "qty"
-- for titles with multiple authors, they split the money following "royaltyper"
SELECT 
    t.title_id,
    ta.au_id,
    a.au_fname,
    ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),
            2) AS sales_royalty
FROM
    sales s
        LEFT JOIN
    titles t ON s.title_id = t.title_id
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
        LEFT JOIN
    authors a ON ta.au_id = a.au_id;
    
-- As you can see, some authors like Anne have published several books.
-- the profit for each author will be calculated as the sum of
-- advance + royalty
-- grouped by author

-- When queries are that long and complex, we use subqueries & temporary tables.
-- Sometimes subqueries are a must
-- Other times they just allow us to break a huge query into simpler steps

-- Temporary tables

-- Step 1: 
-- Create a table for:
--      - the advance for each author and publication (as seen above)
--      &
--      - the royalty of each sale for each author (as seen above)
-- 
DROP TABLE IF EXISTS royalties_per_sale;
CREATE TEMPORARY TABLE royalties_per_sale
SELECT 
    t.title_id,
    ta.au_id,
    a.au_fname,
    a.au_lname,
    ROUND((t.advance * ta.royaltyper / 100), 2) AS advance,
    ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),
            2) AS sales_royalty
FROM
    sales s
        LEFT JOIN
    titles t ON s.title_id = t.title_id
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
		LEFT JOIN
    authors a ON ta.au_id = a.au_id;

-- view the created temporary table
SELECT * FROM royalties_per_sale;



-- Step 2: 
--      Aggregate the total royalties for each title and author
DROP TABLE IF EXISTS roy_adv_per_title_author;
CREATE TEMPORARY TABLE roy_adv_per_title_author
SELECT 
    title_id,
    au_id,
    au_fname,
    au_lname,
    SUM(sales_royalty) AS total_roy,
    ROUND(AVG(advance)) AS advance -- mysql allows non-aggregated, non-grouped fields, but other sql dbms don't!
FROM
	royalties_per_sale
GROUP BY 
	title_id , au_id, au_fname, au_lname;

-- view the created temporary table
SELECT * from roy_adv_per_title_author;



-- Step 3: 
--      Calculate the total profits of each author and order by profit
SELECT 
    au_id,
    au_fname,
    au_lname,
    SUM(total_roy + advance) AS total_profit_author
FROM
    roy_adv_per_title_author
GROUP BY au_id , au_fname , au_lname
ORDER BY total_profit_author DESC
LIMIT 3;



-- the same result using subquries instead of temporary tables
SELECT 
    s2.au_id,
    s2.au_fname,
    s2.au_lname,
    SUM(s2.total_roy + s2.advance) AS total_profit_author
FROM
    (SELECT 
        s1.title_id,
            s1.au_id,
            s1.au_fname,
            s1.au_lname,
            SUM(s1.sales_royalty) AS total_roy,
            ROUND(AVG(s1.advance)) AS advance
    FROM
        (SELECT 
        t.title_id,
            ta.au_id,
            a.au_fname,
            a.au_lname,
            ROUND((t.advance * ta.royaltyper / 100), 2) AS advance,
            ROUND((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100), 2) AS sales_royalty
    FROM
        sales s
    LEFT JOIN titles t ON s.title_id = t.title_id
    LEFT JOIN titleauthor ta ON t.title_id = ta.title_id
    LEFT JOIN authors a ON ta.au_id = a.au_id) s1
    GROUP BY title_id , au_id , au_fname , au_lname) s2
GROUP BY au_id , au_fname , au_lname
ORDER BY total_profit_author DESC
LIMIT 3;
    


