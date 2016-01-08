#!/usr/bin/env ruby

# Slack webhook URL
SLACK_URL = "???"

require 'open-uri'
require 'json'
require 'slack-notifier'

@path = "/root/TeezilyNotifier"
@data = JSON.parse(open("#{@path}/data.json").read)

def check campaign
	shirt = JSON.parse( open("https://www.teezily.com/#{campaign}.json").read )

	@data[shirt["slug"]] = {} if @data[shirt["slug"]].nil?
	@data[shirt["slug"]]["sold"] = 0 if @data[shirt["slug"]]["sold"].nil?	

	if @data[shirt["slug"]]["sold"] != shirt["funded_count"]
		@data[shirt["slug"]]["sold"] = shirt["funded_count"]
	
		send "Shirt sold: #{shirt["detail"]["name"]} <http://teezily.com/#{shirt["slug"]}|[~]>", 
		     "#{shirt["funded_count"]} of #{shirt["sales_goal"]}. Time left #{shirt["days_left"]} days, #{shirt["days_hours_left"]} hours"
	end
end

def send msg, sub
	notifier = Slack::Notifier.new SLACK_URL, channel: '#notification', username: 'ShirtPanda'

	a_ok_note = {
		fallback: sub,
		text: sub,
		color: "good"
	}
	notifier.ping msg, attachments: [a_ok_note]
end

open("#{@path}/campaigns").read.split("\n").each do |c|
	check c
end

File.open("#{@path}/data.json", "w") do |f|
	f.write @data.to_json
end
