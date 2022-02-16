Download the database dump file:

$ wget https://15445.courses.cs.cmu.edu/fall2019/files/imdb-cmudb2019.db.gz
Check its MD5 checksum to ensure that you have correctly downloaded the file:

$ md5 imdb-cmudb2019.db.gz 
MD5 (imdb-cmudb2019.db.gz) = 6443351d4b55eb3c881622bd60a8dc5b
Unzip the database from the provided database dump by running the following commands on your shell. Note that the database file be 900MB after you decompress it.
$ gunzip imdb-cmudb2019.db.gz
$ sqlite3 imdb-cmudb2019.db
We have prepared a random sample of the original dataset for this assignment. Although this is not required to complete the assignment, the complete dataset is available by following the steps here.

Check the contents of the database by running the .tables command on the sqlite3 terminal. You should see 6 tables, and the output should look like this:
$ sqlite3 imdb-cmudb2019.db
SQLite version 3.11.0
Enter ".help" for usage hints.
sqlite> .tables
akas      crew      episodes  people    ratings   titles
Create indices using the following commands in SQLite:
CREATE INDEX ix_people_name ON people (name);
CREATE INDEX ix_titles_type ON titles (type);
CREATE INDEX ix_titles_primary_title ON titles (primary_title);
CREATE INDEX ix_titles_original_title ON titles (original_title);
CREATE INDEX ix_akas_title_id ON akas (title_id);
CREATE INDEX ix_akas_title ON akas (title);
CREATE INDEX ix_crew_title_id ON crew (title_id);
CREATE INDEX ix_crew_person_id ON crew (person_id);

CHECK THE SCHEMA
Get familiar with the schema (structure) of the tables (what attributes do they contain, what are the primary and foreign keys). Run the .schema $TABLE_NAME command on the sqlite3 terminal for each table. The output should look like the example below for each table.
