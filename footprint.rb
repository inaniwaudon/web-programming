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
    <title>これまでのあしあと - 位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <link href="common.css" rel="stylesheet" type="text/css" />
    <link href="index.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
EOF
print erb.result(binding)
print <<EOF
      <main>
        <h2>これまでのあしあと</h2>
        <ul>
        </ul>
      </main>
    </div>
  </body>
</html>
EOF
