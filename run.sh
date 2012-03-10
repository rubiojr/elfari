#!/bin/sh
screen -L -d -m -S elfari-webservice /Users/admin/.rvm/rubies/ruby-1.9.3-p125/bin/ruby elfari-webservice.rb
screen -L -d -m -S elfari /Users/admin/.rvm/rubies/ruby-1.9.3-p125/bin/ruby elfari.rb

