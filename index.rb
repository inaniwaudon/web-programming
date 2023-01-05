#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"
require "erb"

cgi = CGI.new
session = CGI::Session.new(cgi)

id = session["id"]
erb = ERB.new(File.read("header.rhtml"))

session.close
print cgi.header("text/html; charset=utf-8")

print <<EOF
<!doctype html>
<html>
  <head>
    <title>位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <script src="index.js" type="text/javascript"></script>
    <link href="common.css" rel="stylesheet" type="text/css" />
    <link href="index.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
EOF
print erb.result(binding)
print <<EOF
      <main>
        <form action="submit.rb" class="form">
          <div>
            <div class="form-header">
              現在位置 <span class="type-label required-label">必須</span>
            </div>
            <input placeholder="いまどこにいますか？" id="input-place" />
          </div>
          <div>
            <div class="form-header">
              写真 <span class="type-label optional-label">任意</span>
            </div>
            <input type="file" />
          </div>
          <div>
            <div class="form-header">詳細位置</div>
            <div id="your-place"></div>
            <label><input type="checkbox" />正確な位置を含める</label>
          </div>
          <div><input type="submit" value="共有する！" class="submit-input" /></div>
        </form>
      </main>
    </div>
  </body>
</html>
EOF
