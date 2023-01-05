#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"
require "erb"
require "sqlite3"

cgi = CGI.new
session = CGI::Session.new(cgi)
header_erb = ERB.new(File.read("template/header.rhtml"))
user_id = session["id"]

# connect database
db = SQLite3::Database.new("data.db")
places = []
db.transaction {
  places = db.execute("SELECT name FROM place;")
}
db.close
places = places.map { |place| "\"#{CGI.escapeHTML(place[0])}\"" }.join(", ")

session.close
print cgi.header("text/html; charset=utf-8")

print <<EOF
<!doctype html>
<html>
  <head>
    <title>位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <script>var places = [#{places}];</script>
    <script src="script/index.js" type="text/javascript"></script>
    <link href="style/common.css" rel="stylesheet" type="text/css" />
    <link href="style/form.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
      #{header_erb.result(binding)}
      <main>
        <h2 class="title">位置情報を投稿する</h2>
        <div class="form-card card">
          <form action="submit.rb" method="post" enctype="multipart/form-data" class="form">
            <div>
              <div class="form-header">
                <strong>現在位置</strong>
                <span class="type-label required-label">必須</span>
              </div>
              <input name="place" placeholder="いまどこにいますか？" list="place-candidate" autocomplete="off" id="input-place" class="form-input" />
              <datalist id="place-candidate">
              </datalist>
            </div>
            <div>
              <div class="form-header">
                <strong>詳細位置</strong>
              </div>
              <div id="your-place"></div>
              <label><input type="checkbox" />正確な位置を含める</label>
            </div>
            <div>
              <div class="form-header">
                <strong>写真</strong>
                <span class="type-label optional-label">任意</span>
              </div>
              <input type="file" name="photo" />
            </div>
            <div>
              <div class="form-header">
                <strong>ひとこと</strong>
                <span class="type-label optional-label">任意</span>
              </div>
              <input name="comment" placeholder="思いの丈をどうぞ" class="form-input" />
            </div>
            <div>
              <label><input type="checkbox" name="public" checked />パブリックに公開する</label>
            </div>
            <div><input type="submit" value="共有する！" class="submit-input" /></div>
          </form>
        </div>
      </main>
    </div>
  </body>
</html>
EOF
