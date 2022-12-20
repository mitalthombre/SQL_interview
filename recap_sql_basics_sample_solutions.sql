USE imdb_ijs;

/******
The Big Picture
******/

-- How many actors are there in the actors table?
SELECT COUNT(id)
FROM actors;
-- '817718'

-- How many directors are there in the directors table?
SELECT COUNT(id)
FROM directors;
-- '86880'

-- How many movies are there in the movies table?
SELECT COUNT(id)
FROM movies;
-- '388269'

/******
Exploring the Movies
******/

-- From what year are the oldest and the newest movies? What are the names of those movies?
SELECT name, year
FROM movies
WHERE year = (SELECT MAX(year) FROM movies)
OR year = (SELECT MIN(year) FROM movies);
/* # name, year
'Harry Potter and the Half-Blood Prince', '2008'
'Roundhay Garden Scene', '1888'
'Traffic Crossing Leeds Bridge', '1888'
*/

-- What movies have the highest and the lowest ranks?
SELECT name, `rank` 
FROM movies
WHERE `rank` = (SELECT MAX(`rank`) FROM movies)
OR `rank` = (SELECT MIN(`rank`) FROM movies);
/*
A lot of movies with either 1 or 9.9 as rank
*/

-- What is the most common movie title?
SELECT name, COUNT(name)
FROM movies
GROUP BY name
ORDER BY 2 DESC;
/* # name, COUNT(name)
'Eurovision Song Contest, The', '49' */

/******
Understanding the Database
******/

-- Are there movies with multiple directors?
SELECT movie_id, COUNT(director_id)
FROM movies_directors
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;
/*
List of movies with multiple directors
*/

-- What is the movie with the most directors? Why do you think it has so many?
SELECT m.name, COUNT(md.director_id)
FROM movies_directors md
JOIN movies m
	ON md.movie_id = m.id
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;
/* # name, COUNT(md.director_id)
"Bill, The", 87 */


-- On average, how many actors are listed by movie?
WITH actors_per_movie AS (
	SELECT movie_id, COUNT(actor_id) AS no_actors
	FROM roles
	GROUP BY movie_id)
SELECT AVG(no_actors)
FROM actors_per_movie;
-- 11.4303

-- Are there movies with more than one "genre"?
SELECT movie_id, COUNT(genre)
FROM movies_genres
GROUP BY movie_id
HAVING COUNT(genre) > 1
ORDER BY COUNT(genre) DESC;
-- Yes

/******
Looking for specific movies
******/

-- Can you find the movie called “Pulp Fiction”?
	-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "pulp fiction";
/* # first_name, last_name
Quentin, Tarantino */

	-- Which actors where casted on it?
SELECT a.first_name, a.last_name
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE m.name LIKE "pulp fiction";
/*
Long list of actors
*/

-- Can you find the movie called “La Dolce Vita”?
	-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";
/* # first_name, last_name
Federico, Fellini */

	-- Which actors where casted on it?
SELECT a.first_name, a.last_name
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";
/*
Long list of actors
*/

-- When was the movie “Titanic” by James Cameron released?
SELECT m.year
FROM movies m
JOIN movies_directors md
	ON m.id = md.movie_id
JOIN directors d
	ON md.director_id = d.id
WHERE m.name LIKE "titanic"
AND d.last_name LIKE "Cameron";
-- 1997

/******
Actors and directors
******/

-- Who is the actor that acted more times as “Himself”?
SELECT a.first_name, a.last_name, COUNT(a.id)
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
WHERE `role` LIKE "%himself%"
GROUP BY a.id, a.first_name, a.last_name
ORDER BY COUNT(a.id) DESC;
/* # first_name, last_name, COUNT(a.id)
Adolf, Hitler, 206 */

-- What is the most common name for actors? 
SELECT first_name, COUNT(first_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
John, 4371 */

SELECT last_name, COUNT(last_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 2425 */

WITH concat_names as (SELECT 
    concat(first_name,' ',last_name) fullname
FROM
	actors)
SELECT fullname, COUNT(fullname)
FROM concat_names
GROUP BY 1
ORDER BY 2 DESC;
/* # fullname, COUNT(fullname)
Shauna MacDonald, 7 */

	-- And for directors?
SELECT first_name, COUNT(first_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
Michael, 670 */

SELECT last_name, COUNT(last_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 243 */

WITH concat_names as (SELECT 
    concat(first_name,' ',last_name) fullname
FROM
	directors)
SELECT fullname, COUNT(fullname)
FROM concat_names
GROUP BY 1
ORDER BY 2 DESC;
/* # fullname, COUNT(fullname)
Kaoru UmeZawa, 10 */

/******
Analysing genders
******/

-- How many actors are male and how many are female?
SELECT gender, COUNT(gender)
FROM actors
GROUP BY gender;
/* # gender, COUNT(gender)
F, 304412
M, 513306 */
	
-- What percentage of actors are female, and what percentage are male?
SELECT
(SELECT COUNT(id)
FROM actors
WHERE gender LIKE "f")
/
(SELECT COUNT(id)
FROM actors);
-- '0.3723' 37% female, therefore 63% male

/******
Movies across time
******/

-- How many of the movies were released after the year 2000?
SELECT COUNT(id)
FROM movies
WHERE year > 2000;
-- '46006'

-- How many of the movies where released between the years 1990 and 2000?
SELECT COUNT(id)
FROM movies
WHERE year BETWEEN 1990 AND 2000;
-- '91138'
-- BETWEEN 1990 AND 2000 is the same as >= 1990 AND <= 2000, be wary of this!!!

-- Which are the 3 years with the most movies? How many movies were produced on those years?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(id) DESC) ranking,
    year,
    count(id) total
FROM movies
GROUP BY year
ORDER BY 1)
SELECT ranking, year, total
FROM cte
WHERE ranking <= 3;
/* # ranking, year, total
1, 2002, 12056
2, 2003, 11890
3, 2001, 11690 */

-- What are the top 5 movie genres?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 81013
2, Drama, 72877
3, Comedy, 56425
4, Documentary, 41356
5, Animation, 17652 */

-- What are the top 5 movie genres before 1920?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
WHERE movie_id IN (SELECT id FROM movies WHERE year < 1920)
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 18559
2, Comedy, 8676
3, Drama, 7692
4, Documentary, 3780
5, Western, 1704 */

-- What is the evolution of the top movie genres across all the decades of the 20th century?
with genre_count_per_decade as (
select rank() over (partition by decade order by movies_per_genre desc) ranking, genre, decade
from (SELECT 
    genre,
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(genre) AS movies_per_genre
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
GROUP BY decade , genre) as a
)
select genre, decade
FROM genre_count_per_decade
WHERE ranking = 1;
/*
# genre, decade
Short, 1880
Documentary, 1890
Short, 1900
Short, 1910
Short, 1920
Short, 1930
Short, 1940
Drama, 1950
Drama, 1960
Drama, 1970
Drama, 1980
Drama, 1990
Short, 2000
*/

/******
Putting it all together: names, genders, and time
******/

-- Has the most common name for actors changed over time?
-- Get the most common actor name for each decade in the XX century.
with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, 
	fname, 
	totals, 
	decade
from (SELECT a.first_name as fname, 
	COUNT(a.first_name) as totals, 
	FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY decade, fname) sub)
SELECT decade, 
	fname, 
	totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* # decade, name, totals
1890, Petr, 26
1900, Florence, 180
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5929
2000, Michael, 3914 */

with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fullname, totals, decade
from (SELECT concat(a.first_name,' ',a.last_name) as fullname, COUNT(concat(a.first_name,' ',a.last_name)) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY decade, concat(a.first_name,' ',a.last_name)) sub)
SELECT decade, fullname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/*
# decade, fullname, totals
1890, Petr Lenícek, 26
1900, Mack Sennett, 168
1910, Lee (I) Moran, 315
1910, Gilbert M. 'Broncho Billy' Anderson, 315
1920, Oliver Hardy, 130
1930, Lee Phelps, 284
1940, Mel Blanc, 300
1950, Mel Blanc, 258
1960, Sung-il Shin, 225
1970, Adoor Bhasi, 306
1980, Robert Mammone, 212
1990, Frank Welker, 180
2000, Kevin Michael Richardson, 90
*/

-- Re-do the analysis on most common names, splitted for males and females
with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fname, totals, decade
from (SELECT a.first_name as fname, COUNT(a.first_name) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE a.gender LIKE 'f'
-- WHERE a.gender LIKE 'm'
GROUP BY decade, fname) sub)
SELECT decade, fname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* FEMALE
# decade, name, totals
1890, Rosemarie, 16
1900, Florence, 180
1910, Florence, 782
1920, Mary, 649
1930, Dorothy, 830
1940, Maria, 739
1950, María, 1005
1960, Maria, 1059
1970, María, 1191
1980, Maria, 1228
1990, Maria, 1728
2000, María, 1148 */

/* MALE
# decade, fname, totals
1890, Petr, 26
1900, Mack, 168
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5907
2000, Michael, 3899
*/

with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fullname, totals, decade
from (SELECT concat(a.first_name,' ',a.last_name) as fullname, COUNT(concat(a.first_name,' ',a.last_name)) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE a.gender LIKE 'f'
-- WHERE a.gender LIKE 'm'
GROUP BY decade, concat(a.first_name,' ',a.last_name)) sub)
SELECT decade, fullname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/*
# decade, fullname, totals
1890, Rosemarie Quednau, 16
1900, Florence Lawrence, 135
1910, Mabel Normand, 211
1920, Gertrude Astor, 83
1920, Dot Farley, 83
1930, Bess Flowers, 203
1940, Bess Flowers, 232
1950, Bess Flowers, 177
1960, Ji-mi Kim, 164
1970, Carla Mancini, 145
1980, Bunsri Sribunruttanachai, 158
1990, Lisa (I) Comshaw, 128
2000, Grey DeLisle, 77
*/

/*
# decade, fullname, totals
1890, Petr Lenícek, 26
1900, Mack Sennett, 168
1910, Lee (I) Moran, 315
1910, Gilbert M. 'Broncho Billy' Anderson, 315
1920, Oliver Hardy, 130
1930, Lee Phelps, 284
1940, Mel Blanc, 300
1950, Mel Blanc, 258
1960, Sung-il Shin, 225
1970, Adoor Bhasi, 306
1980, Robert Mammone, 212
1990, Frank Welker, 180
2000, Kevin Michael Richardson, 90
*/

-- How many movies had a majority of females among their cast? 
SELECT COUNT(movie_title)
FROM (select
  r.movie_id as movie_title,
  count(case when a.gender='M' then 1 end) as male_count,
  count(case when a.gender='F' then 1 end) as female_count
from roles r
JOIN actors a
    ON r.actor_id = a.id
GROUP BY r.movie_id) sub
WHERE female_count > male_count;
-- 50666 movies with more female actors than male (absolute)

-- What percentage of the total movies had a majority female cast?
SELECT
(SELECT COUNT(movie_title)
FROM (select
  r.movie_id as movie_title,
  count(case when a.gender='M' then 1 end) as male_count,
  count(case when a.gender='F' then 1 end) as female_count
from roles r
JOIN actors a
    ON r.actor_id = a.id
GROUP BY r.movie_id) sub
WHERE female_count > male_count)
/
(SELECT COUNT(DISTINCT(movie_id))
FROM roles)
-- 0.1687 17% of movies have more female actors than males (relative)