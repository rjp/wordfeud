Wordfeud logger
===============
wf.sh captures finished games from Wordfeud and logs the results into an SQLite database.

Usage
-----
First set the `EMAIL` and `PASSWORD` variables at the top of the script. Then run the script.

Requirements
------------
A recent Ruby with Digest::SHA1 and JSON
SQLite (with the sqlite3 command line)
Curl

Useful queries
--------------
    -- find my winning games if I'm called zimpenfish
    select * from (select *, p0score>p1score as p0win, p0name='zimpenfish' as p0me from games) as q where p0win=p0me;