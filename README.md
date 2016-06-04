# Ruby-on-Rails-Web-Services-and-Integration-with-MongoDB
Ruby on Rails Web Services and Integration with MongoDB

I have created Gemfiles for each assignment to allow bundler to manage gem dependencies.  Once you have run bundler you only need these lines at the top of assignment.rb

require 'bundler/setup'

Bundler.require #without this line bundler will manage gems, but you will still need to require each one individually

*This change caused Module1 Practice Assignment 1 to fail the rspec tests because it is looking for require 'mongo' in the assignment.rb file. 
