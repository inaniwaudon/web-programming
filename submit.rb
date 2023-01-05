#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"
require "erb"
require 'securerandom'
require "sqlite3"

cgi = CGI.new
session = CGI::Session.new(cgi)
header_erb = ERB.new(File.read("template/header.rhtml"))
user_id = session["id"]

errors = []
if user_id == nil then
  errors.push("サインインが必要な操作です")
elsif !cgi.key?("place") then
  errors.push("不正な操作です")
elsif cgi["place"].length == 0 then
  errors.push("場所が指定されていません")
else
  # connect database
  db = SQLite3::Database.new("data.db")
  id = SecureRandom.uuid
  place = cgi["place"]
  comment = cgi.key?("comment") && cgi["comment"].length > 0 ? cgi["comment"] : nil
  is_public = cgi.key?("public") && cgi["public"] == "on" ? 1 : 0
  image = 0

  # image
  if cgi.key?("photo") && cgi["photo"].length > 0 then
    open("img/#{id}.jpg", "w") do |fh|
      fh.binmode
      fh.write cgi['photo'].read
    end
    image = 1
  end

  db.transaction {
    db.execute("REPLACE INTO place VALUES(?, NULL, NULL)", place)
    db.execute("INSERT INTO visit VALUES(?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?);",
      id, place, user_id, comment, is_public, image)
  }
  db.close
end

session.close
print cgi.header("text/html; charset=utf-8")

print <<EOF
<!doctype html>
<html>
  <head>
    <title>投稿 - 位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <link href="style/common.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
      #{header_erb.result(binding)}
      <main>
EOF

if errors.length == 0 then
  print "<p>投稿に成功しました</p>"
else
  print "<div class=\"errors\">"
  errors.each do |e|
    print "<p>#{e}</p>"
  end
  print "</div>"
end

print <<EOF
      </main>
    </div>
  </body>
</html>
EOF
