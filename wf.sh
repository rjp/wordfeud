#! /bin/bash

### dumps finished Wordfeud games into an SQLite database
### requires: ruby (Digest::SHA1, JSON), sqlite3, curl

### THESE MUST BE SET

EMAIL=
PASSWORD=

### NO USER SERVICEABLE PARTS BELOW

if [ -z "$EMAIL" -o -z "$PASSWORD" ]; then
    echo "Email or Password is empty."
    exit
fi

SHASALT="JarJarBinks9"
SHAPASS=$(echo -n "${PASSWORD}${SHASALT}" | ruby -rDigest -e 'print Digest::SHA1.hexdigest($stdin.read)')
JSON='{"email":"'$EMAIL'","password":"'$SHAPASS'"}'

USERAGENT="frottage.org Wordfeud API 0.1"
ASJ="application/json"

BD=~/.wf
mkdir -p $BD

# first we need to get our login cookie
curl -b $BD/cookies -c $BD/cookies -d $JSON -H "User-Agent: $USERAGENT" -H "Accept: $ASJ" -H "Content-Type: $ASJ" -s 'http://game06.wordfeud.com/wf/user/login/email/' > /dev/null

if [ $? -gt 0 ]; then
    echo "Error logging in. Check username/password."
    exit
fi

# now we fetch our current game list
curl -b $BD/cookies -H "User-Agent: $USERAGENT" -H "Accept: $ASJ" -H "Content-Type: $ASJ"  -s 'http://game06.wordfeud.com/wf/user/games/' > $BD/games.json

if [ $? -gt 0 ]; then
    echo "Error fetching games."
    cat $BD/games.json
    exit
fi

# create our JSON => SQL parsing script if we don't have one
if [ ! -e $BD/parser.rb ]; then
    cat > $BD/parser.rb <<RUBYCODE
require 'json'
g=JSON.load(File.open(ARGV.shift))
g['content']['games'].reject{|i|i['is_running']}.each do |gm|
p0=gm['players'][0]; p1=gm['players'][1]
puts [gm['id'],p0['username'],p0['score'],p1['username'],p1['score'],gm['move_count'],gm['ruleset'],gm['updated'].to_i].map{|i|"'#{i}'"}.join(',')
end
RUBYCODE
    chmod +x $BD/parser.rb
fi

# if we don't have an sqlite to use, create one
if [ ! -e $BD/games.sqlite ]; then
    echo "CREATE TABLE games (id int primary key, p0name varchar(128), p0score int, p1name varchar(128), p1score int, moves int, rules int, epoch int);" | sqlite3 $BD/games.sqlite
fi

ruby $BD/parser.rb $BD/games.json | while read i; do
    echo "INSERT OR IGNORE INTO games VALUES ($i);" 
done | sqlite3 $BD/games.sqlite
