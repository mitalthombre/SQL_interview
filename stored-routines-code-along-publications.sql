use publications;

/*Create a function that computes the 
 advance that an author gets
*/

drop function advance_per_author;
create function advance_per_author(amount float, percentage int)
returns float(2) deterministic
return round((amount * percentage / 100), 2);

-- test the function
select 
	t.title_id,
    t.title,
    a.au_fname,
    t.advance,
    ta.royaltyper,
    advance_per_author(t.advance, ta.royaltyper) as advance_author
from titles t
left join titleauthor ta on t.title_id = ta.title_id
left join authors a on ta.au_id = a.au_id;


/*Create a function that computes the 
 royalty that an author gets
*/

drop function royalty_per_author;
create function royalty_per_author(price float, qty int, royalty float, royaltyper int)
returns float(2) deterministic
return round((price * qty * royalty / 100 * royaltyper / 100), 2);

-- test the function
SELECT 
    t.title_id,
    ta.au_id,
    a.au_fname,
	royalty_per_author(t.price, s.qty, t.royalty, ta.royaltyper) AS sales_royalty
FROM
    sales s
        LEFT JOIN
    titles t ON s.title_id = t.title_id
        LEFT JOIN
    titleauthor ta ON t.title_id = ta.title_id
		LEFT JOIN
	authors a on ta.au_id = a.au_id;


/* create a stored procedure that takes an author name and last name as input
and outputs their phone
*/

-- No output variable
drop procedure get_phone;
DELIMITER $$
create procedure get_phone (IN first_name varchar(255), IN last_name varchar(255))
BEGIN
SELECT 
phone 
from authors a
where (a.au_fname = first_name) 
	and (a.au_lname = last_name);
END $$

DELIMITER ;

CALL get_phone("Dirk", "Stringer");


-- with output variable
drop procedure get_phone_output;
DELIMITER $$
create procedure get_phone_output (IN first_name varchar(255), IN last_name varchar(255), OUT author_phone varchar(255))
BEGIN
SELECT 
phone 
INTO author_phone
from authors a
where (a.au_fname = first_name) 
	and (a.au_lname = last_name);
END $$

DELIMITER ;

CALL get_phone_output("Dirk", "Stringer", @dirk_phone);

SELECT @dirk_phone;