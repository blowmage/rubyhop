require "rubygems"
require "hoe"

Hoe.plugin :git
Hoe.plugin :minitest

Hoe.spec "rubyhop" do
  developer "Mike Moore", "mike@blowmage.com"

  self.summary     = "Super awesome Ruby-themed game"
  self.description = "Super awesome Ruby-themed game"
  self.urls        = ["http://blowmage.com/rubyhop"]

  self.history_file = "History.txt"
  self.readme_file  = "README.txt"

  license "MIT"

  dependency "gosu", "~> 0.7.50"
end

desc "Run the game"
task :run do
  `ruby -Ilib -e "require 'rubyhop'; RubyhopGame.new.show"`
end
