#!/bin/bash

chcp 65001 > /dev/null 2>&1 || true

sqlite3 movies_rating.db < db_init.sql

echo "1. Средний рейтинг фильмов и их ранг"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH movie_averages AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m LEFT JOIN ratings r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year), ranked_movies AS (SELECT title, year, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg_rating FROM movie_averages) SELECT title, year, ROUND(avg_rating, 3) AS avg_rating, rank_by_avg_rating FROM ranked_movies WHERE rank_by_avg_rating <= 10 ORDER BY rank_by_avg_rating, title;"
echo " "

echo "2. Средний рейтинг фильмов по жанрам и ранг жанра"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, remaining) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL UNION ALL SELECT movie_id, substr(remaining, 1, instr(remaining, '|') - 1), substr(remaining, instr(remaining, '|') + 1) FROM genre_split WHERE remaining <> ''), genre_ratings AS (SELECT gs.genre, AVG(r.rating) AS avg_rating FROM genre_split gs JOIN ratings r ON r.movie_id = gs.movie_id WHERE gs.genre <> '' GROUP BY gs.genre) SELECT genre, ROUND(avg_rating, 3) AS avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS genre_rank FROM genre_ratings ORDER BY genre_rank, genre;"
echo " "

echo "3. Количество фильмов в каждом жанре"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, remaining) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL UNION ALL SELECT movie_id, substr(remaining, 1, instr(remaining, '|') - 1), substr(remaining, instr(remaining, '|') + 1) FROM genre_split WHERE remaining <> '' ) SELECT genre, COUNT(DISTINCT movie_id) AS movie_count FROM genre_split WHERE genre <> '' GROUP BY genre ORDER BY movie_count DESC, genre;"
echo " "

echo "4. Количество тегов и их доля по жанрам"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, remaining) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL UNION ALL SELECT movie_id, substr(remaining, 1, instr(remaining, '|') - 1), substr(remaining, instr(remaining, '|') + 1) FROM genre_split WHERE remaining <> ''), genre_tags AS (SELECT gs.genre, COUNT(t.id) AS tag_count FROM genre_split gs LEFT JOIN tags t ON t.movie_id = gs.movie_id WHERE gs.genre <> '' GROUP BY gs.genre) SELECT genre, tag_count, ROUND(100.0 * tag_count / (SELECT COUNT(*) FROM tags), 2) AS tag_share FROM genre_tags ORDER BY tag_count DESC, genre;"
echo " "

echo "5. Статистика оценок пользователей"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT user_id, COUNT(*) AS rating_count, ROUND(AVG(rating), 3) AS avg_rating, DATE(MIN(timestamp), 'unixepoch') AS first_rating_date, DATE(MAX(timestamp), 'unixepoch') AS last_rating_date FROM ratings GROUP BY user_id ORDER BY rating_count DESC, user_id LIMIT 10;"
echo " "

echo "6. Сегментация пользователей по активности"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH user_activity AS (SELECT u.id AS user_id, COUNT(DISTINCT r.id) AS rating_count, COUNT(DISTINCT t.id) AS tag_count FROM users u LEFT JOIN ratings r ON r.user_id = u.id LEFT JOIN tags t ON t.user_id = u.id GROUP BY u.id) SELECT user_id, rating_count, tag_count, CASE WHEN rating_count >= 10 AND tag_count >= 10 THEN 'Активные' WHEN rating_count < 5 AND tag_count < 5 THEN 'Пассивные' WHEN tag_count > rating_count THEN 'Комментаторы' WHEN rating_count > tag_count THEN 'Оценщики' ELSE 'Сбалансированные' END AS user_segment FROM user_activity ORDER BY user_segment, user_id;"
echo " "

echo "7. Последний оценённый фильм каждого пользователя"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH ranked_ratings AS (SELECT user_id, movie_id, timestamp, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC, id DESC) AS rating_number FROM ratings) SELECT u.id AS user_id, u.name, m.title AS last_rated_movie_title, rr.timestamp AS last_rating_timestamp FROM users u LEFT JOIN ranked_ratings rr ON rr.user_id = u.id AND rr.rating_number = 1 LEFT JOIN movies m ON m.id = rr.movie_id ORDER BY u.id;"