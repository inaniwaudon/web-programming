#!/usr/bin/env ruby
# encoding: utf-8

require "cgi"
require "cgi/session"

cgi = CGI.new
session = CGI::Session.new(cgi)
session.delete
print cgi.header({ "status" => "REDIRECT", "Location" => "index.rb" })
