#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"
require "sqlite3"

cgi = CGI.new
session = CGI::Session.new(cgi)

# redirect if the user is already signed in
if session["id"] != nil then
  print cgi.header({ "status" => "REDIRECT", "Location" => "index.rb" })
  exit
end

# connect database
db = SQLite3::Database.new("data.db")
errors = []

catch(:break) do
  if cgi.key?("method") && cgi.key?("id") && cgi.key?("password") then
    id = cgi["id"]
    password = cgi["password"]
    method = cgi["method"]
    
    if id.length < 8 then
      errors.push("ID は 8 文字以上で指定してください")
      throw :break
    end
    if password.length < 8 then
      errors.push("パスワードは 8 文字以上で指定してください")
      throw :break
    end

    # signin
    if method == "signin" then
      password_lines = []
      db.transaction {
        password_lines = db.execute("SELECT password FROM user WHERE id = '#{id}';")
      }
      if password_lines.length == 0 then
        errors.push("指定されたアカウント（#{id}）は存在しません")
        throw :break
      end
      
      if password_lines.map{ |line| line[0] }.include?(password) then
        # redirect
        session["id"] = id
        print cgi.header({ "status" => "REDIRECT", "Location" => "index.rb" })
        exit
      else
        errors.push("指定された ID かパスワードに誤りがあります")
        throw :break
      end
    end

    # signup
    if method == "signup" then
      user_count = []
      db.transaction {
        user_count = db.execute("SELECT count(*) FROM user WHERE id = '#{id}';")[0][0]
      }
      if user_count > 0 then
        errors.push("指定された ID は既に登録されています")
        throw :break
      end
      db.transaction {
        db.execute("INSERT INTO user VALUES('#{id}', '#{password}');")
      }
    end
  end
end

db.close
session.close
print cgi.header("text/html; charset=utf-8")

print <<EOF
<!doctype html>
<html>
  <head>
    <title>サインイン・サインアップ - 位置情報共有アプリケーション</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, minimum-scale=1.0">
    <link href="common.css" rel="stylesheet" type="text/css" />
    <link href="login.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="page">
      <header id="top-header">
        <a href="index.rb"><h1>位置情報共有アプリケーション</h1></a>
      </header>
      <main>
EOF

if errors.length > 0 then
  print "<div class=\"errors\">"
  errors.each do |e|
    print "<p>#{e}</p>"
  end
  print "</div>"
end

print <<EOF
        <div class="contents">
          <div class="signin-signup">
            <h2>サインイン</h2>
            <form action="login.rb" method="get" class="form">
              <div>
                <label>
                  <div class="form-header">ID <span class="type-label required-label">必須</span></div>
                  <input type="text" name="id" />
                </label>
              </div>
              <div>
                <label>
                  <div class="form-header">パスワード <span class="type-label required-label">必須</span></div>
                  <input type="password" name="password" />
                </label>
              </div>
              <input type="hidden" name="method" value="signin" />
              <div><input type="submit" value="ログインする" class="submit-input" /></div>
            </form>
          </div>
          <div class="signin-signup">
            <h2>サインアップ</h2>
            <form action="login.rb" method="get" class="form">
              <div>
                <label>
                  <div class="form-header">ID <span class="type-label required-label">必須</span></div>
                  <input type="text" name="id" />
                  <div class="form-description">8文字以上で指定してください</div>
                </label>
              </div>
              <div>
                <label>
                  <div class="form-header">パスワード <span class="type-label required-label">必須</span></div>
                  <input type="text" name="password" />
                  <div class="form-description">8文字以上で指定してください</div>
                </label>
              </div>
              <input type="hidden" name="method" value="signup" />
              <div><input type="submit" value="登録する" class="submit-input" /></div>
            </form>
          </div>
        </div>
      </main>
    </div>
  </body>
</html>
EOF
