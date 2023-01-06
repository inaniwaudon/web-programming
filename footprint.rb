#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"
require "erb"
require "sqlite3"

cgi = CGI.new
session = CGI::Session.new(cgi)
header_erb = ERB.new(File.read("template/header.rhtml"))
errors_erb = ERB.new(File.read("template/errors.rhtml"))
user_id = session["id"]

# connect database
if user_id != nil then
  db = SQLite3::Database.new("data.db")
  visits = []
  db.results_as_hash = true
  db.transaction {
    visits = db.execute(
      "SELECT visit.id, place, user_id, datetime(date, 'localtime') as date, comment, image, public, latitude, longitude
      FROM visit, place
      WHERE user_id = ? and visit.place = place.name;",
      user_id
    )
  }
  db.close

  # filter
  keyword = ""
  if cgi.key?("search") && cgi["search"].length > 0 then
    keyword = cgi["search"]
    visits = visits.filter { |visit|
      Regexp.new(cgi["search"], Regexp::IGNORECASE).match(visit["place"])
    }
  end
end

session.close
print cgi.header("text/html; charset=utf-8")

print <<EOF
<!doctype html>
<html>
  <head>
    <title>これまでのあしあと - 位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <link href="style/common.css" rel="stylesheet" type="text/css" />
    <link href="style/visit.css" rel="stylesheet" type="text/css" />
    <link href="style/form.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
      #{header_erb.result(binding)}
      <main>
        <h2 class="title">これまでのあしあと</h2>        
EOF


if user_id != nil then
  print <<EOF
        <div class="search-box">
          <form action="all-visit.rb" method="get">
            <input type="text" name="search" placeholder="正規表現を使用できます" value="#{keyword}" class="form-input" />
            <input type="submit" value="検索" class="submit-input" />
          </form>
        </div>
        <div class="visit-list">
EOF

  visits.each do |visit|
    place_erb = ERB.new(File.read("template/visit.rhtml"))
    print place_erb.result_with_hash(
      id: visit["id"],
      user_id: visit["user_id"],
      place_name: visit["place"],
      latitude: visit["latitude"],
      longitude: visit["longitude"],
      date: visit["date"],
      comment: visit["comment"],
      is_public: visit["public"] == 1,
      image: visit["image"] == 1,
    )
  end
else
  print errors_erb.result_with_hash(errors: ["ログインが必要なページです"])
end

print <<EOF
      </main>
    </div>
  </body>
</html>
EOF
