#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'

cgi = CGI.new
print cgi.header("type" => "text/html", "charset" => "utf-8")

print <<EOS
<!doctype html>
<html>
  <head>
    <title>位置情報共有アプリケーション</title>
  </head>
  <body>
    <header>
      <h1>位置情報共有アプリケーション</h1>
      <nav>
        <ul>
          <li>友人のを見る</li>
        </ul>
      </nav>
    </header>
    <div>
      あなたは <strong>gjrieghjriaemi</strong> でログイン中です。
    </div>
    <form>
      あなたの位置は 〜〜〜
      <input type="submit" value="共有する！">
    </form>
  </body>
</html>
EOS
