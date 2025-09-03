DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select * from netflix

select count(*) from netflix

select * from netflix limit 5


-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems


-- 1. Count the number of Movies vs TV Shows

select distinct type from netflix

select type, count(type) from netflix
group by type



-- 2. Find the most common rating for movies and TV shows

select * from netflix limit 5

select distinct rating from netflix


with my_cte as (
select type, rating, count(rating) as total
from netflix
group by type, rating
order by total desc

),
 ranked as (
select type,rating, row_number() over(partition by type order by total desc ) as rn
from my_cte
) 
select * from ranked where rn<=1


-- 3. List all movies released in a specific year (e.g., 2020)

select * from netflix

select title from netflix where release_year = 2020 and type = 'Movie'
select count(title) from netflix where release_year = 2020 and type = 'Movie'


-- 4. Find the top 5 countries with the most content on Netflix


/* select country,count(country) from netflix 
group by country
order by count(country)desc
limit 5 */


select trim(unnest(string_to_array(country, ','))) as new_country,count(show_id)
from netflix
group by 1
order by 2 desc


-- 5. Identify the longest movie

select * from netflix



SELECT
type,
title,
SPLIT_PART (duration, ' ', 1) :: INT 
FROM
netflix
WHERE type IN ('Movie') AND duration IS NOT NULL
ORDER BY 3 DESC
LIMIT 5




-- 6. Find content added in the last 5 years

select current_date
select * from netflix


select now()

select * 
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select trim(unnest(string_to_array(director, ','))), title, type
from netflix 
where director = 'Rajiv Chilaka'


-- 8. List all TV shows with more than 5 seasons

select title, split_part(duration,' ',1 )::int as total_season from netflix
where type = 'TV Show' and  split_part(duration,' ',1 )::int >=5



-- 9. Count the number of content items in each genre

select trim(unnest(string_to_array(listed_in, ','))) as genre, count(show_id)
from netflix 
group by genre
order by 2 desc










-- 11. List all movies that are documentaries

with my_cte as (
select trim(unnest(string_to_array(listed_in, ','))) as genre, title,type 
from netflix  
)
select * from my_cte where genre = 'Documentaries' and type = 'Movie'


-- 12. Find all content without a director

select * from netflix where director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


with my_cte as(
select trim(unnest(string_to_array(casts, ','))) as actor, title,release_year 
from netflix
)
select * from my_cte 
where actor = 'Salman Khan' and release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



WITH my_cte AS (
    SELECT 
        trim(unnest(string_to_array(casts, ','))) AS actor,
        title,
        release_year, 
        trim(unnest(string_to_array(country, ','))) AS new_country
    FROM netflix
),
actor_count AS (
    SELECT 
        actor, 
        COUNT(*) AS movie_count
    FROM my_cte 
    WHERE new_country = 'India' AND actor IS NOT NULL
    GROUP BY actor
),
ranked AS (
    SELECT 
        actor,
        movie_count,
        ROW_NUMBER() OVER (ORDER BY movie_count DESC) AS rnk
    FROM actor_count
)
SELECT * 
FROM ranked
WHERE rnk <= 10;

-------- another way -------- 

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


select current_date



SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) 
GROUP BY 1,2
ORDER BY 2
