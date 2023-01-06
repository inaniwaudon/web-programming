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
errors_erb = ERB.new(File.read("template/errors.rhtml"))
user_id = session["id"]

session.close
print cgi.header("text/html; charset=utf-8")

errors = []
if user_id == nil then
  errors.push("サインインが必要な操作です")
elsif !cgi.key?("place") || !cgi.key?("latitude") || !cgi.key?("longitude") then
  errors.push("不正な操作です")
elsif cgi["place"].length == 0 then
  errors.push("場所が指定されていません")
else
  place = cgi["place"]
  id = SecureRandom.uuid
  comment = cgi.key?("comment") && cgi["comment"].length > 0 ? cgi["comment"] : nil
  is_public = cgi.key?("public") && cgi["public"] == "on" ? 1 : 0

  # place
  mapInDetail = cgi.key?("map-in-detail") && cgi["map-in-detail"] == "on"
  latitude = mapInDetail ? cgi["latitude"] : nil
  longitude = mapInDetail ? cgi["longitude"] : nil

  # image
  image = 0
  if cgi.key?("photo") && cgi["photo"].length > 0 then
    begin
      open("img/#{id}.jpg", "w") do |fh|
        fh.binmode
        fh.write cgi['photo'].read
      end
    rescue
      print "ファイル書き込みエラーが発生しました。システムの管理者にお問い合わせください。"
      exit
    end
    image = 1
  end

  # connect database
  begin
    db = SQLite3::Database.new("data.db")
    db.transaction {
      db.execute("REPLACE INTO place VALUES(?, ?, ?)", place, latitude, longitude)
      db.execute("INSERT INTO visit VALUES(?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?);",
        id, place, user_id, comment, is_public, image)
    }
    db.close
  rescue
    print "データベースエラーが発生しました。システムの管理者にお問い合わせください。"
    exit
  end
end

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
        #{errors_erb.result(binding)}
EOF

if errors.length == 0 then
  print "<p>投稿に成功しました</p>"
end

print <<EOF
      </main>
    </div>
  </body>
</html>
EOF
