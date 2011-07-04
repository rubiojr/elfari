#
# Needs rubygems and cinch:
#
# sudo apt-get install rubygems
# gem install cinch
# gem install rest-client
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
      title = RestClient.get('http://bigdick:4567/current_video')
      while title.nil? or title.strip.chomp.empty?
        title = RestClient.get('http://bigdick:4567/current_video')
      end
      m.reply "Tomalo, chato: #{title}"
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
    on :message, /mele/ do |m, query|
      RestClient.post "http://bigdick:4567/video", :url => 'http://gobarbra.com/hit/new-0416a9aa8de56543b149d7ffb477196f'
      m.reply "Paralo Paul!!!"
    end
    on :message, /ponme\s*argo\s*(.*)/ do |m, query|
      db = File.readlines('database')
      play = db[(rand * (db.size - 1)).to_i].split(/ /)[0]
      RestClient.post "http://bigdick:4567/youtube", :url => play
      title = RestClient.get('http://bigdick:4567/current_video')
      while title.nil? or title.strip.chomp.empty?
        title = RestClient.get('http://bigdick:4567/current_video')
      end
      m.reply "Tomalo, chato: #{title}"
    end
    on :message, /ponme\s*er\s*(.*)/ do |m, query|
        db = File.readlines('database')
        found = false
        db.each do |line|
            if line =~ /#{query}/i
                play = line.split(/ /)[0]
                RestClient.post "http://bigdick:4567/youtube", :url => play
                title = RestClient.get('http://bigdick:4567/current_video')
                while title.nil? or title.strip.chomp.empty?
                    title = RestClient.get('http://bigdick:4567/current_video')
                end
                m.reply "Tomalo, chato: #{title}"
                found = true
                break
            end
        end
        m.reply "No tengo er: #{query}" if !found
    end
end

bot.start
