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
    new_id = cgi["id"]
    password = cgi["password"]
    method = cgi["method"]
    
    if new_id.length < 8 then
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
        password_lines = db.execute("SELECT password FROM user WHERE id = ?;", new_id)
      }
      if password_lines.length == 0 then
        errors.push("指定されたアカウントは存在しません")
        throw :break
      end
      
      if password_lines.map{ |line| line[0] }.include?(password) then
        # redirect
        session["id"] = new_id
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
        user_count = db.execute("SELECT count(*) FROM user WHERE id = ?;", new_id)[0][0]
      }
      if user_count > 0 then
        errors.push("指定された ID は既に登録されています")
        throw :break
      end
      db.transaction {
        db.execute("INSERT INTO user VALUES(?, ?);", new_id, password)
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
    <link href="style/common.css" rel="stylesheet" type="text/css" />
    <link href="style/form.css" rel="stylesheet" type="text/css" />
    <link href="style/login.css" rel="stylesheet" type="text/css" />
    <style>
      .contents {
        display: flex;
        gap: 20px;
      }
      .signin-signup-card h2 {
        margin: 0 0 4px 0;
      }
    </style>
  </head>
  <body>
    <div id="page">
      #{header_erb.result(binding)}
      <main>
        #{errors_erb.result(binding)}
        <div class="contents">
          <div class="signin-signup-card form-card card">
            <h2>サインイン</h2>
            <form action="login.rb" method="post" class="form">
              <div>
                <label>
                  <div class="form-header">
                    <strong>ID</strong>
                    <span class="type-label required-label">必須</span>
                  </div>
                  <input type="text" name="id" class="form-input" />
                  <div class="form-description"></div>
                </label>
              </div>
              <div>
                <label>
                  <div class="form-header">
                    <strong>パスワード</strong>
                    <span class="type-label required-label">必須</span>
                  </div>
                  <input type="password" name="password" class="form-input" />
                  <div class="form-description"></div>
                </label>
              </div>
              <input type="hidden" name="method" value="signin" />
              <div><input type="submit" value="ログインする" class="submit-input" /></div>
            </form>
          </div>
          <div class="signin-signup-card form-card card">
            <h2>サインアップ</h2>
            <form action="login.rb" method="post" class="form">
              <div>
                <label>
                  <div class="form-header">
                    <strong>ID</strong>
                    <span class="type-label required-label">必須</span>
                  </div>
                  <input type="text" name="id" class="form-input" />
                  <div class="form-description">8文字以上で指定してください</div>
                </label>
              </div>
              <div>
                <label>
                  <div class="form-header">
                    <strong>パスワード</strong>
                    <span class="type-label required-label">必須</span>
                  </div>
                  <input type="password" name="password" class="form-input" />
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
