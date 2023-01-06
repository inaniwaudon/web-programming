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
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
      integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
      crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.6.0/dist/leaflet.js"
      integrity="sha512-gZwIG9x3wUXg2hdXF6+rVkLF/0Vi9U8D2Ntg4Ga5I5BZpVkVxlJWbSQtXPSiUTtC0TjtGOmxa1AJPuV0CPthew=="
      crossorigin=""></script>
    <style>
      #map {
        width: 100%;
        height: 200px;
        margin: 10px 0 10px 0;
      }
      #map.disabled {
        opacity: 0.2;
        pointer-events: none;
      }
      #map-description {
        font-size: 14px;
      }
    </style>
  </head>
  <body>
    <div id="page">
      #{header_erb.result(binding)}
      <main>
EOF

if user_id != nil then
  print <<EOF
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
                <span class="type-label optional-label">任意</span>
              </div>
              <label><input name="map-in-detail" type="checkbox" id="map-in-detail"  />詳細位置を含める</label>
              <div id="map" class="disabled"></div>
              <div id="map-description">
                <div>中央の緯度経度を詳細位置に設定します。</div>
                <div id="your-place"></div>
              </div>
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
            <input type="hidden" name="latitude" id="latitude-input" />
            <input type="hidden" name="longitude" id="longitude-input" />
          </form>
        </div>
EOF
else
  print <<EOF
        <div>
          <h2 class="title">ようこそ</h2>
          <p>本アプリケーションは、訪れた場所を気軽に共有するためのサービスです。</p>
          <p>
            投稿を行うにはがアカウントを作成する必要があります。<br />
            <a href="login.rb">サインイン・サインアップしてはじめましょう。</a>
          </p>
        </div>
EOF
end

print <<EOF
      </main>
    </div>
  </body>
</html>
EOF