Wordfeud logger
===============
wf.sh captures finished games from Wordfeud and logs the results into an SQLite database.

Usage
-----
First set the `EMAIL` and `PASSWORD` variables at the top of the script. Then run the script.

Requirements
------------
* A recent Ruby with Digest::SHA1 and JSON
* SQLite (with the sqlite3 command line)
* Curl

Useful queries
--------------
Assuming your username is _zimpenfish_

    -- find my won games
    select * from (select *, p0score>p1score as p0win, p0name='zimpenfish' as p0me from games) as q where p0win=p0me;

    -- find my lost games
    select * from (select *, p0score>p1score as p0win, p0name='zimpenfish' as p0me from games) as q where p0win<>p0me;

    -- how many times and by how many (total, average) points have I beaten X?
    select count(1), sum(score), avg(score), opponent from (select coalesce(nullif(p0name,'zimpenfish'), p1name, p0name) as opponent, abs(p0score - p1score) as score from (select *, p0score>p1score as p0win, p0name='zimpenfish' as p0me from games) as q where p0win=p0me) as r group by opponent;

    -- how many times and by how many (total, average) points has X beaten me?
    select count(1), sum(score), avg(score), opponent from (select coalesce(nullif(p0name,'zimpenfish'), p1name, p0name) as opponent, abs(p0score - p1score) as score from (select *, p0score>p1score as p0win, p0name='zimpenfish' as p0me from games) as q where p0win<>p0me) as r group by opponent;
