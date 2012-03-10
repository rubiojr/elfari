require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'rufus/scheduler'

post '/say' do
	voice = params['voice'] || 'Cepstral Miguel'
	`osascript -e "set volume #{params[:vol]}" > /dev/null 2>&1` if params[:vol]
	if params[:text]
		`say -v '#{voice}' '#{params['text']}'`
	end
end

post '/houston' do
	puts 'Houston we have a problem...'
	`afplay houston.wav`
end

post '/cant_takeit' do
	puts 'cant take it anymore...'
	`afplay cant_takeit.wav`
end

post '/youtube' do
	`osascript backend-scripts/youtube.scpt #{params[:url]}` if params[:url] =~ /youtube\.com.*watch/
end

post '/video' do
	puts "opening youtube video #{params[:url]}"
	`osascript backend-scripts/youtube.scpt #{params[:url]}` 
end

post '/volume' do 
	puts "opening video #{params[:url]}"
	`osascript -e "set volume #{params[:vol]}" > /dev/null 2>&1` if params[:vol]
end

get '/current_video' do
	`osascript backend-scripts/get_page_title.scpt 2> /dev/null`
end
