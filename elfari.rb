#
# Needs rubygems and cinch:
#
# sudo apt-get install rubygems
# gem install cinch
# gem install rest-client
#
require 'rubygems'
require 'webee'
require 'cinch'
require 'yaml'
require 'rest-client'
require 'alchemist'
require 'rufus/scheduler'

module ElFari

  class Config

    def self.config
      YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/config.yml')
    end

  end

end

class Motherfuckers
  include Cinch::Plugin

  timer 900, method: :say
  def say
    ElFari::Config.config[:channels].each do |c|
      Channel(c.split.first).send "Any news, motherfuckers?"
    end
  end

end

class GitDude
  include Cinch::Plugin

  timer 5, method: :new_stuff
  def new_stuff
    conf = ElFari::Config.config[:gitdude]
    conf[:repos].each do |r|
      next if not File.directory?(r[:path])
      ENV['GIT_DIR'] = r[:path] + '/.git'
      changes = []
      `git fetch -v 2>&1 | grep -F -- '->'`.each_line do |l|
        if l =~ /.*\.\..*/
          changes << l
        end
      end
      Channel(c.split.first).send("New commits in repo: #{r[:name]}") if not changes.empty?
      changes.each do |l|
        tokens = l.split
        commit_range = tokens[0]
        branch_name = tokens[1]
        commit_messages = `git log #{commit_range} --pretty=format:'%s (%an)'`
        ElFari::Config.config[:channels].each do |c|
          commit_messages.each_line do |l|
            Channel(c.split.first).send  "* #{l}\n\n"
          end
        end
      end
    end
  end
end


if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

conf = ElFari::Config.config

bot = Cinch::Bot.new do
  configure do |c|
    c.server = conf[:server]
    c.channels = conf[:channels]
    c.nick = conf[:nick]
    c.plugins.plugins = [GitDude, Motherfuckers]
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
    m.reply 'Ahi van los comandos, chavalote!: ayudame dimelo ponmelo volumen mele in-inglis ponmeargo ponmeer quetiene'
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
  	RestClient.post "http://bigdick:4567/say", :text => "No tengo er #{query}" if !found
  	m.reply "No tengo er: #{query}" if !found
  end

  on :message, /que\s*tiene/ do |m, query|
	  db = File.readlines('database')
	  list = "Tengo esto piltrafa:\n"
	  i=1
	  db.each do |line|
		  f=line.split(/ - /)[0].length + 3
		  list += i.to_s() + " " + line[f..line.length]
		  i+=1
	  end
	  m.reply "#{list}"
  end

  on :message, /mothership (.*)/ do |m, query|
    WeBee::Api.user = conf[:abiquo][:user]
    WeBee::Api.password = conf[:abiquo][:password]
    WeBee::Api.url = "http://#{conf[:abiquo][:host]}/api"
    tokens = query.split
    command = tokens[0].strip.chomp
    case command
    when 'cloud-stats'
      stats = {
        :free_hd => 0, 
        :real_hd => 0,
        :used_hd => 0, 
        :hypervisors => 0,
        :free_ram => 0,
        :real_ram => 0,
        :used_ram => 0,
        :available_cpus => 0
      }
      WeBee::Datacenter.all.each do |dc|
        dc.racks.each do |rack|
          rack.machines.each do |m|
            stats[:hypervisors] += 1
            stats[:used_ram] += m.ram_used.to_i
            stats[:real_ram] += m.real_ram.to_i
            stats[:available_cpus] += m.real_cpu.to_i
            stats[:used_hd] += m.hd_used.to_i.bytes.to.gigabytes.to_f.round
            stats[:real_hd] += m.real_hd.to_i.bytes.to.gigabytes.to_f.round
          end
        end
      end
      stats[:free_ram] = stats[:real_ram] - stats[:used_ram]
      stats[:free_hd] = stats[:real_hd] - stats[:used_hd]
      m.reply 'Cloud Statistics for ' + conf[:abiquo][:host].upcase
      m.reply "Hypevisors:        #{stats[:hypervisors]}"
      m.reply "Available CPUs:    #{stats[:available_cpus]}"
      m.reply "Total RAM:         #{stats[:real_ram].megabytes.to.gigabytes} GB"
      m.reply "Free RAM:          #{stats[:free_ram].megabytes.to.gigabytes} GB"
      m.reply "Used RAM:          #{stats[:used_ram].megabytes.to.gigabytes} GB"
      m.reply "Total HD:          #{stats[:real_hd]} GB"
      m.reply "Free HD:           #{stats[:free_hd]} GB"
      m.reply "Used HD:           #{stats[:used_hd]} GB"
    end
  end
end

bot.start
