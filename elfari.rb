#
# Needs rubygems and cinch:
#
# sudo apt-get install rubygems
# gem install cinch
#
require 'rubygems'
require 'cinch'

bot = Cinch::Bot.new do
    configure do |c|
      c.server = "irc.freenode.org"
      c.channels = ["#abiquo"]
      c.nick = 'elfari'
    end

    on :privmsg, /ponmelo (http:\/\/www\.youtube\.com.*)/ do |m, query|
      `curl -X POST "http://bigdick:4567/youtube" -d url='#{query}'`
    end
    on :message, /ponmelo (http:\/\/www\.youtube\.com.*)/ do |m, query|
      `curl -X POST "http://bigdick:4567/youtube" -d url='#{query}'`
    end
    on :message, /dimelo (.*)/ do |m, query|
      `curl -X POST "http://bigdick:4567/say" -d text='#{query}'`
    end
    on :message, /ayudame/ do |m|
      m.reply 'Ahi van, chavalote!: ayudame dimelo ponmelo'
    end

end

bot.start
