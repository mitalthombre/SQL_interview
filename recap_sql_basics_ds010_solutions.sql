USE imdb_ijs;

/******
The Big Picture
******/

-- How many actors are there in the actors table?
SELECT count(id) as number_of_actors FROM actors;

-- How many directors are there in the directors table?
SELECT COUNT(id) FROM directors;

-- How many movies are there in the movies table?
SELECT COUNT(id) FROM movies;

/******
Exploring the Movies
******/

-- From what year are the oldest and the newest movies? What are the names of those movies?
SELECT name, year FROM Movies
ORDER BY year ASC
LIMIT 1;
SELECT name, year FROM Movies
ORDER BY year DESC
LIMIT 1;

SELECT  min(year), max(year) FROM movies;
select name from movies where year = "1888";
select name from movies where year = "2008";

SELECT name, year
FROM movies
WHERE year = (SELECT MAX(year) FROM movies)
OR year = (SELECT MIN(year) FROM movies);

-- What movies have the highest and the lowest ranks?
SELECT name, `rank`
FROM movies
WHERE `rank` IS NOT NULL AND `rank` = 9.9
ORDER BY name ASC;

SELECT name, `rank`
FROM movies
WHERE `rank` IS NOT NULL AND `rank` = 1
ORDER BY name ASC;


SELECT name, movies.rank 
FROM movies 
WHERE movies.rank = (
	SELECT MAX(movies.rank) 
    FROM movies)
;

-- What is the most common movie title?
SELECT 
    name, COUNT(name)
FROM
    movies
GROUP BY name
HAVING COUNT(name) > 1
ORDER BY COUNT(`name`) DESC;

/******
Understanding the Database
******/

-- Are there movies with multiple directors?
-- What is the movie with the most directors? Why do you think it has so many?
SELECT movie_id, COUNT(director_id) FROM movies_directors
GROUP BY movie_id
ORDER BY COUNT(director_id) DESC;
-- Long running tv series

-- On average, how many actors are listed per movie?
SELECT AVG(CA.Count_Actors) FROM (
SELECT COUNT(actor_id) AS Count_Actors FROM roles
GROUP BY movie_id) AS CA;

WITH actors_per_movie AS (
	SELECT movie_id, COUNT(actor_id) AS no_actors
	FROM roles
	GROUP BY movie_id)
SELECT AVG(no_actors)
FROM actors_per_movie;

-- Are there movies with more than one "genre"?
SELECT movie_id, COUNT(genre) FROM movies_genres
GROUP BY movie_id
ORDER BY COUNT(genre) DESC;

/******
Looking for specific movies
******/

-- Can you find the movie called “Pulp Fiction”?
select * from movies
where name like "Pulp Fiction";
	-- Who directed it?
SELECT directors.first_name, directors.last_name, movies.name FROM movies
JOIN movies_directors ON movies.id = movies_directors.movie_id
JOIN directors ON movies_directors.director_id = directors.id
WHERE movies.name = "Pulp Fiction";

	-- Which actors where casted on it?
SELECT * FROM movies
JOIN roles ON movies.id = roles.movie_id
JOIN actors ON roles.actor_id = actors.id
WHERE movies.name = "Pulp Fiction";

-- Can you find the movie called “La Dolce Vita”?
	-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";

	-- Which actors where casted on it?
SELECT * FROM movies
JOIN roles ON movies.id = roles.movie_id
JOIN actors ON roles.actor_id = actors.id
WHERE movies.name LIKE "Dolce Vita, La";

-- When was the movie “Titanic” by James Cameron released?
SELECT *
FROM movies
JOIN movies_directors ON movies.Id = movies_directors.movie_id
JOIN directors ON movies_directors.director_id = directors.Id
WHERE directors.first_name LIKE "%James%" 
	AND directors.last_name LIKE "%Cameron%"
    AND movies.name LIKE "%Titanic%";   -- 1997


/******
Actors and directors
******/

-- Who is the actor that acted more times as “Himself”?
SELECT `role`, actor_id, COUNT(actor_id) FROM roles
WHERE `role` LIKE "%Himself%"
GROUP BY actor_id
ORDER BY COUNT(actor_id) DESC;

-- What is the most common name for actors? 
SELECT first_name, COUNT(first_name) FROM actors
GROUP BY first_name
ORDER BY COUNT(first_name) DESC;

SELECT last_name, COUNT(last_name) FROM actors
GROUP BY last_name
ORDER BY COUNT(last_name) DESC;

SELECT *, COUNT(id) FROM actors
GROUP BY first_name, last_name
ORDER BY COUNT(id) DESC;


-- And for directors?


/******
Analysing genders
******/

-- How many actors are male and how many are female?
SELECT gender, count(id) FROM actors
GROUP BY gender;

select count(gender) from actors as sum_gender
where gender like "M"
group by gender;


-- What percentage of actors are female, and what percentage are male?
SELECT 
	CASE
		WHEN gender = "M" THEN "male"
        WHEN gender = "F" THEN "female"
        ELSE "divers"
    END AS male_and_female,
    Count(*), 
    (Count(*)/817718*100) As Percentage
    FROM actors
    GROUP BY male_and_female;
    
SELECT 10 * 5;

SELECT
(SELECT COUNT(id)
FROM actors
WHERE gender LIKE "f")
/
(SELECT COUNT(id)
FROM actors);

/******
Movies across time
******/

-- How many of the movies were released after the year 2000?
SELECT COUNT(*) FROM movies
WHERE year > 2000;

-- How many of the movies where released between the years 1990 and 2000?
SELECT COUNT(DISTINCT(id)) FROM movies
WHERE `year` BETWEEN 1990 AND 2000;

-- Which are the 3 years with the most movies? How many movies were produced on those years?
SELECT year, COUNT(name) FROM movies
GROUP BY year 
ORDER BY COUNT(name) DESC
LIMIT 3;

-- What are the top 5 movie genres?
SELECT genre, COUNT(movie_id) FROM movies_genres
GROUP BY genre
ORDER BY COUNT(movie_id) DESC
LIMIT 5;

-- What are the top 5 movie genres before 1920?
SELECT *, COUNT(DISTINCT(movie_id)) FROM movies
JOIN movies_genres ON movies_genres.movie_id = movies.id
WHERE movies.year < 1920
GROUP BY movies_genres.genre
ORDER BY COUNT(DISTINCT(movie_id)) DESC
LIMIT 5;

-- What is the evolution of the top movie genres across all the decades of the 20th century?
 SELECT 
    md.genre, 
    CASE 
        WHEN movies.year BETWEEN 1900 AND 1909 THEN "1900-1909"
        WHEN movies.year BETWEEN 1910 AND 1919 THEN "1910-1919"
        WHEN movies.year BETWEEN 1920 AND 1929 THEN "1920-1929"
        WHEN movies.year BETWEEN 1930 AND 1939 THEN "1930-1939"
        WHEN movies.year BETWEEN 1940 AND 1949 THEN "1940-1949"
        WHEN movies.year BETWEEN 1950 AND 1959 THEN "1950-1959"
        WHEN movies.year BETWEEN 1960 AND 1969 THEN "1960-1969"
        WHEN movies.year BETWEEN 1970 AND 1979 THEN "1970-1979"
        WHEN movies.year BETWEEN 1980 AND 1989 THEN "1980-1989"
        WHEN movies.year BETWEEN 1990 AND 1999 THEN "1990-1999"
        ELSE "other"
    END AS decades, 
    COUNT(movie_id) 
FROM movies_genres md
JOIN movies ON md.movie_id = movies.id
WHERE md.genre IN ('Short', 'Drama', 'Documentary', 'Comedy', 'Animation')
GROUP BY md.genre, decades
ORDER BY md.genre, decades;

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

/******
Putting it all together: names, genders, and time
******/

-- Has the most common name for actors changed over time?
-- Get the most common actor name for each decade in the XX century.


-- Re-do the analysis on most common names, splitted for males and females


-- How many movies had a majority of females among their cast? 


-- What percentage of the total movies had a majority female cast?
