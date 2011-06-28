#
# Needs rubygems and cinch:
#
# sudo apt-get install rubygems
# gem install cinch
#
require 'rubygems'
require 'cinch'
require 'yaml'
require 'rest-client'

conf = YAML.load_file 'config.yml'

bot = Cinch::Bot.new do
    configure do |c|
      c.server = conf[:server]
      c.channels = conf[:channels]
      c.nick = conf[:nick]
    end

    on :message, /ponmelo\s*(http:\/\/www\.youtube\.com.*)/ do |m, query|
      RestClient.post "http://bigdick:4567/youtube", :url => query
    end
    on :message, /dimelo (.*)/ do |m, query|
      RestClient.post "http://bigdick:4567/say", :text => query
    end
    on :message, /in-inglis (.*)/ do |m, query|
      RestClient.post "http://bigdick:4567/say", :text => query, :voice => 'Alex'
    end
    on :message, /ayudame/ do |m|
      m.reply 'Ahi van los comandos, chavalote!: ayudame dimelo ponmelo volumen'
    end
    on :message, /volumen (.*)/ do |m, query|
      RestClient.post "http://bigdick:4567/volume", :vol => query
    end

end

bot.start
