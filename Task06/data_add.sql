PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- Добавление пяти пользователей

INSERT INTO users (first_name, surname, email, gender, occupation_id)
SELECT 'Дмитрий', 'Яськин Евгеньевич', 'dmitriyyaskin520@mail.ru', 'male', id
FROM occupations
WHERE name = 'student';

INSERT INTO users (first_name, surname, email, gender, occupation_id)
SELECT 'Максим', 'Шапошников Витальевич', 'maxim.shaposhnikov201@gmail.com', 'male', id
FROM occupations
WHERE name = 'student';

INSERT INTO users (first_name, surname, email, gender, occupation_id)
SELECT 'Максим', 'Цветков Сергеевич', 'maxim.tsvetkov201@gmail.com', 'male', id
FROM occupations
WHERE name = 'student';

INSERT INTO users (first_name, surname, email, gender, occupation_id)
SELECT 'Арслан', 'Умяров Риянович', 'arslan.umyarov201@yandex.ru', 'male', id
FROM occupations
WHERE name = 'student';

INSERT INTO users (first_name, surname, email, gender, occupation_id)
SELECT 'Александр', 'Смирнов Сергеевич', 'alex.smirnov201@yandex.ru', 'male', id
FROM occupations
WHERE name = 'student';

-- Добавление фильмов трёх разных жанров

INSERT INTO genres (name)
SELECT 'Comedy'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Comedy');

INSERT INTO genres (name)
SELECT 'Animation'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Animation');

INSERT INTO genres (name)
SELECT 'Drama'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Drama');

INSERT INTO movies (title, year)
SELECT 'Palm Springs', 2020
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'Palm Springs' AND year = 2020
);

INSERT INTO movies (title, year)
SELECT 'Soul', 2020
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'Soul' AND year = 2020
);

INSERT INTO movies (title, year)
SELECT 'The Father', 2020
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'The Father' AND year = 2020
);

-- Связи фильмов с жанрами

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'Palm Springs' AND m.year = 2020
  AND g.name = 'Comedy'
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id AND mg.genre_id = g.id
  );

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'Soul' AND m.year = 2020
  AND g.name = 'Animation'
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id AND mg.genre_id = g.id
  );

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'The Father' AND m.year = 2020
  AND g.name = 'Drama'
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id AND mg.genre_id = g.id
  );

-- Три оценки от Дмитрия

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, unixepoch()
FROM users u, movies m
WHERE u.email = 'dmitriyyaskin520@mail.ru'
  AND m.title = 'Palm Springs' AND m.year = 2020;

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, unixepoch()
FROM users u, movies m
WHERE u.email = 'dmitriyyaskin520@mail.ru'
  AND m.title = 'Soul' AND m.year = 2020;

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.5, unixepoch()
FROM users u, movies m
WHERE u.email = 'dmitriyyaskin520@mail.ru'
  AND m.title = 'The Father' AND m.year = 2020;

COMMIT;
