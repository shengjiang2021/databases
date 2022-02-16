List all distinct types of titles ordered by type.
SELECT distinct(type) FROM titles ORDER BY type;

List the longest title of each type along with the runtime minutes.
WITH types(type, runtime_minutes) AS ( 
  SELECT type, MAX(runtime_minutes)
    FROM titles
    GROUP BY type
)
SELECT titles.type, titles.primary_title, titles.runtime_minutes
  FROM titles
  JOIN types
  ON titles.runtime_minutes == types.runtime_minutes AND titles.type == types.type
  ORDER BY titles.type, titles.primary_title
  ;

List all types of titles along with the number of associated titles.
SELECT type, count(*) AS title_count FROM titles GROUP BY type ORDER BY title_count ASC;

Which decades saw the most number of titles getting premiered? List the number of titles in every decade. Like 2010s|2789741.
SELECT 
  CAST(premiered/10*10 AS TEXT) || 's' AS decade,
  COUNT(*) AS num_movies
  FROM titles
  WHERE premiered is not null
  GROUP BY decade
  ORDER BY num_movies DESC
  ;

List the decades and the percentage of titles which premiered in the corresponding decade. Display like : 2010s|45.7042
SELECT
  CAST(premiered/10*10 AS TEXT) || 's' AS decade,
  ROUND(CAST(COUNT(*) AS REAL) / (SELECT COUNT(*) FROM titles) * 100.0, 4) as percentage
  FROM titles
  WHERE premiered is not null
  GROUP BY decade
  ORDER BY percentage DESC, decade ASC
  ;

List the top 10 dubbed titles with the number of dubs.
WITH translations AS (
  SELECT title_id, count(*) as num_translations 
    FROM akas 
    GROUP BY title_id 
    ORDER BY num_translations DESC, title_id 
    LIMIT 10
)
SELECT titles.primary_title, translations.num_translations
  FROM translations
  JOIN titles
  ON titles.title_id == translations.title_id
  ORDER BY translations.num_translations DESC
  ;

List the IMDB Top 250 movies along with its weighted rating.
Weighted rating (WR) = (v/(v+m)) * R + (m/(v+m)) * C
- R = average rating for the movie (mean), i.e. ratings.rating
- v = number of votes for the movie, i.e. ratings.votes
- m = minimum votes required to be listed in the Top 250 (current 25000)
- C = weighted average rating of all movies

WITH
  av(average_rating) AS (
    SELECT SUM(rating * votes) / SUM(votes)
      FROM ratings
      JOIN titles
      ON titles.title_id == ratings.title_id AND titles.type == "movie" 
  ),
  mn(min_rating) AS (SELECT 25000.0)
SELECT
  primary_title,
  (votes / (votes + min_rating)) * rating + (min_rating / (votes + min_rating)) * average_rating as weighed_rating
  FROM ratings, av, mn
  JOIN titles
  ON titles.title_id == ratings.title_id and titles.type == "movie"
  ORDER BY weighed_rating DESC
  LIMIT 20
  ;


with
av(c) as (
select sum(votes * rating) / sum(votes) from ratings join titles on ratings.title_id = titles.title_id and titles.type = 'movie'
)

select temp.wr, t.primary_title 
from 
(
  select 
  (
    cast(votes as real) / (votes + 25000) * rating + cast(25000 as real) / (votes +     25000) * c
  ) as wr, title_id from ratings, av
) as temp join titles t on temp.title_id = t.title_id and t.type = 'movie'
order by temp.wr desc limit 20;

List the number of actors / actresses who have appeared in any title with Mark Hamill (born in 1951).
WITH hamill_titles AS (
  SELECT DISTINCT(crew.title_id)
    FROM people
    JOIN crew
    ON crew.person_id == people.person_id AND people.name == "Mark Hamill" AND people.born == 1951
)
SELECT COUNT(DISTINCT(crew.person_id))
  FROM crew
  WHERE (crew.category == "actor" OR crew.category == "actress") AND crew.title_id in hamill_titles
;

List the movies in alphabetical order which cast both Mark Hamill (born in 1951) and George Lucas (born in 1944).
WITH hamill_movies(title_id) AS (
  SELECT crew.title_id
    FROM crew
    JOIN people
    ON crew.person_id == people.person_id AND people.name == "Mark Hamill" AND people.born == 1951
)
SELECT titles.primary_title
  FROM crew
  JOIN people
  ON crew.person_id == people.person_id AND people.name == "George Lucas" AND people.born == 1944 AND crew.title_id IN hamill_movies
  JOIN titles
  ON crew.title_id == titles.title_id AND titles.type == "movie"
  ORDER BY titles.primary_title
;


select primary_title from titles where title_id in (select m.title_id from (select t.title_id from (select title_id from crew where person_id = (select person_id from people where name = 'Mark Hamill' and born = 1951)) temp join titles t on t.title_id = temp.title_id and t.type = 'movie') m    join    (select t.title_id from (select title_id from crew where person_id = (select person_id from people where name = 'George Lucas' and born = 1944)) temp join titles t on t.title_id = temp.title_id and t.type = 'movie') g on m.title_id = g.title_id) order by primary_title;

List all distinct genres and the number of titles associated with them.
Hint: You might find CTEs useful.

WITH RECURSIVE split(genre, rest) AS (
  SELECT '', genres || ',' FROM titles WHERE genres != "\N"
   UNION ALL
  SELECT substr(rest, 0, instr(rest, ',')),
         substr(rest, instr(rest, ',')+1)
    FROM split
   WHERE rest != ''
)
SELECT genre, count(*) as genre_count
  FROM split 
 WHERE genre != ''
 GROUP BY genre
 ORDER BY genre_count DESC;



