import csv
import re


def sql_text(value):
    return "'" + value.replace("'", "''") + "'"


def make_db_init():
    with open("db_init.sql", "w", encoding="utf-8") as sql:
        sql.write("DROP TABLE IF EXISTS movies;\n")
        sql.write("DROP TABLE IF EXISTS ratings;\n")
        sql.write("DROP TABLE IF EXISTS tags;\n")
        sql.write("DROP TABLE IF EXISTS users;\n\n")

        sql.write("""
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    year INTEGER,
    genres TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);

""")

        with open("movies.csv", "r", encoding="utf-8") as file:
            reader = csv.DictReader(file)

            for row in reader:
                match = re.search(r"\((\d{4})\)$", row["title"])

                if match:
                    year = match.group(1)
                    title = row["title"][:match.start()].strip()
                else:
                    year = "NULL"
                    title = row["title"]

                sql.write(
                    "INSERT INTO movies (id, title, year, genres) VALUES "
                    f"({row['movieId']}, {sql_text(title)}, {year}, "
                    f"{sql_text(row['genres'])});\n"
                )

        with open("ratings.csv", "r", encoding="utf-8") as file:
            reader = csv.DictReader(file)

            for id, row in enumerate(reader, 1):
                sql.write(
                    "INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES "
                    f"({id}, {row['userId']}, {row['movieId']}, "
                    f"{row['rating']}, {row['timestamp']});\n"
                )

        with open("tags.csv", "r", encoding="utf-8") as file:
            reader = csv.DictReader(file)

            for id, row in enumerate(reader, 1):
                sql.write(
                    "INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES "
                    f"({id}, {row['userId']}, {row['movieId']}, "
                    f"{sql_text(row['tag'])}, {row['timestamp']});\n"
                )

        with open("users.txt", "r", encoding="utf-8") as file:
            for id, line in enumerate(file, 1):
                row = line.rstrip("\n").split("|")

                sql.write(
                    "INSERT INTO users "
                    "(id, name, email, gender, register_date, occupation) VALUES "
                    f"({id}, {sql_text(row[1])}, {sql_text(row[2])}, "
                    f"{sql_text(row[3])}, {sql_text(row[4])}, "
                    f"{sql_text(row[5])});\n"
                )


if __name__ == "__main__":
    make_db_init()