require "rubygems"
require "hoe"

Hoe.plugin :git
Hoe.plugin :minitest

Hoe.spec "rubyhop" do
  developer "Mike Moore", "mike@blowmage.com"
end

desc "Run the game"
task :run do
  `ruby -Ilib -e "require 'rubyhop'; RubyhopGame.new.show"`
end
