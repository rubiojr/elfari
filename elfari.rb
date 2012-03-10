#
# Needs rubygems and cinch:
#
# sudo apt-get install rubygems
# gem install cinch
# gem install rest-client
#
$: << File.dirname(__FILE__) + "/modules"
require 'rubygems'
require 'webee'
require 'cinch'
require 'yaml'
require 'rest-client'
require 'alchemist'
require 'rufus/scheduler'
require 'abiquo-deployer'
require 'uri'

#$SAFE = 4

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
      changes.each do |l|
        tokens = l.split
        commit_range = tokens[0]
        branch_name = tokens[1]
        commit_messages = `git log #{commit_range} --pretty=format:'%s (%an)'`
        ElFari::Config.config[:channels].each do |c|
          commit_messages.each_line do |l|
            Channel(c.split.first).send  "* [#{r[:name]}] #{l}\n\n"
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
WeBee::Api.user = conf[:abiquo][:user]
WeBee::Api.password = conf[:abiquo][:password]
WeBee::Api.url = "http://#{conf[:abiquo][:host]}/api"

class ControlWS
  
  def self.say(text, voice = :spanish)
    if voice == :english
      RestClient.post "http://bigdick.local:4567/say", :text => text, :voice => 'Alex'
    else
      RestClient.post "http://bigdick.local:4567/say", :text => text
    end
  end

end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = conf[:server]
    c.channels = conf[:channels]
    c.nick = conf[:nick]
    c.plugins.plugins = [Motherfuckers]
  end

  on :message, /ponmelo\s*(http:\/\/www\.youtube\.com.*)/ do |m, query|
    RestClient.post "http://bigdick.local:4567/youtube", :url => query
    title = RestClient.get('http://bigdick.local:4567/current_video')
    while title.nil? or title.strip.chomp.empty?
      title = RestClient.get('http://bigdick.local:4567/current_video')
    end
    m.reply "Tomalo, chato: #{title}"
  end
  on :message, /dimelo (.*)/ do |m, query|
    RestClient.post "http://bigdick.local:4567/say", :text => query
  end
  on :message, /in-inglis (.*)/ do |m, query|
    RestClient.post "http://bigdick.local:4567/say", :text => query, :voice => 'Alex'
  end
  on :message, /ayudame/ do |m|
    m.reply 'Ahi van los comandos, chavalote!: ayudame dimelo ponmelo volumen mele in-inglis ponmeargo ponmeer quetiene'
  end
  on :message, /volumen (.*)/ do |m, query|
    RestClient.post "http://bigdick.local:4567/volume", :vol => query
  end
  on :message, /mele/ do |m, query|
    RestClient.post "http://bigdick.local:4567/video", :url => 'http://gobarbra.com/hit/new-0416a9aa8de56543b149d7ffb477196f'
    m.reply "Paralo Paul!!!"
  end
  on :message, /vino/ do |m, query|
    RestClient.post "http://bigdick.local:4567/video", :url => 'http://www.youtube.com/watch?v=-nQgsEbU9C4'
    m.reply "Viva el vino!!!"
  end
  on :message, /ponme\s*argo\s*(.*)/ do |m, query|
    db = File.readlines('database')
    play = db[(rand * (db.size - 1)).to_i].split(/ /)[0]
    RestClient.post "http://bigdick.local:4567/youtube", :url => play
    title = RestClient.get('http://bigdick.local:4567/current_video')
    while title.nil? or title.strip.chomp.empty?
      title = RestClient.get('http://bigdick.local:4567/current_video')
    end
    m.reply "Tomalo, chato: #{title}"
  end

  on :message, /ponme\s*er\s*(.*)/ do |m, query|
    db = File.readlines('database')
    found = false
    db.each do |line|
      if line =~ /#{query}/i
        play = line.split(/ /)[0]
        RestClient.post "http://bigdick.local:4567/youtube", :url => play
        title = RestClient.get('http://bigdick.local:4567/current_video')
        while title.nil? or title.strip.chomp.empty?
            title = RestClient.get('http://bigdick.local:4567/current_video')
        end
        m.reply "Tomalo, chato: #{title}"
        found = true
        break
      end
    end
  	RestClient.post "http://bigdick.local:4567/say", :text => "No tengo er #{query}" if !found
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

  on :message, /rimamelo (.*)/ do |m, query|
  	uri = "http://rimamelo.herokuapp.com/web/api?model.rhyme=#{URI.escape(query)}"
        rhyme = RestClient.get(uri)
        rhyme["<rhyme>"] = ""
        rhyme["</rhyme>"] = ""
        rhyme["<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"] = ""
        m.reply "#{rhyme}"
        RestClient.post "http://bigdick.local:4567/say", :text => "#{rhyme}"
  end

  on :message, /mothership abusers/ do  |m, query|
    abusers = {}
    WeBee::Enterprise.all.each do |ent|
      ent.users.each do |user|
        vms = (user.virtual_machines.find_all{ |vm| vm.state == 'RUNNING'})
        abusers[user.name] = { :full_name => "#{user.name} #{user.surname}", :email => user.email, :vms_number => vms.size, :vms => vms }
      end
    end

    abusers = abusers.sort do |a,b|
      a[1][:vms_number] <=> b[1][:vms_number]
    end.reverse

    m.reply "Running VMs, per user"
    abusers.each do |a|
      if a[1][:vms_number] > 0
        m.reply "User: " + "#{a[1][:full_name]}".ljust(40) + "VMs: " + "#{a[1][:vms_number]}"
      end
    end
  end

  on :message, /mothership cloud-stats/ do |m, query|
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

  on :message, /!deploy (.*)/ do |m|
    if not AbiquoDeployer.authorized?(m.user.nick)
      m.reply "I'm sorry folk, you are not authorized to deploy"
    else
      AbiquoDeployer.client = m
      AbiquoDeployer.deploy
    end
  end
  
  on :message, /!list vms (.*)/ do |m, query|
    #require 'pp'
    AbiquoDeployer.list_vms(:host => query)
    #m.reply "#{vm.name} #{vm.memory_size}"
    #rescue Exception => e
    #  m.reply "** Error when talking to the hypervisor"
    #end
  end
  
  #on :message, /eval (.*)/ do |m, query|
  #  begin
  #  rs = ControlWS
  #  eval query
  #  rescue SyntaxError
  #end
end

bot.start
