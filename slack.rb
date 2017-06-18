require 'slack-ruby-client'
require 'pp'
require './player.rb'
require './bom.rb'
require './field.rb'

up = "point_up"
down = "point_down"
right = "point_right"
left = "point_left"
bom = "game_die"

field = Field.new()
you = Player.new()
enemy = Player.new()

Slack.configure do |conf|
      conf.token = "" #slack token
end

client = Slack::RealTime::Client.new

client.on :hello do
      puts 'connected!'
end

ts = ""
# message eventを受け取った時の処理
client.on :message do |data|
      case data['text']
      when 'start' then
            post_field = field.updateField(you, enemy)
            #pp post_field
            #pp data
            posts = client.web_client.chat_postMessage channel: data["channel"], text: post_field
            ts = posts['ts']
            client.web_client.reactions_add channel: data['channel'],  name: up, timestamp: ts
            client.web_client.reactions_add channel: data['channel'],  name: down, timestamp: ts
            client.web_client.reactions_add channel: data['channel'],  name: left, timestamp: ts
            client.web_client.reactions_add channel: data['channel'],  name: right, timestamp: ts
            client.web_client.reactions_add channel: data['channel'],  name: bom, timestamp: ts
      end
end

#reactionされた時 入力に使える
i = 0;
client.on :reaction_added do |data|
      channel = data['item']['channel']
      reaction = data['reaction']
      i += 1
      if i > 5
            pp data
            input_array = [up, down, right, left, bom]
            if input_array.include?(reaction)
                  you.inputCommandFromSlack(reaction)
                  you.moveYou(field)
                  you.myBomCountDown()

                  enemy.inputCommandRandom()
                  enemy.moveYou(field)
                  enemy.myBomCountDown()

                  post_field = field.updateField(you, enemy)

                  client.web_client.chat_update channel: channel, text: post_field, ts: ts
                  if you.is_exist == false
                        puts "you lose"
                        posts = client.web_client.chat_postMessage channel: channel, text: "you lose"
                  elsif enemy.is_exist == false
                        puts "you win"
                        posts = client.web_client.chat_postMessage channel: channel, text: "you win"
                  end
            end
      end

end

#再接続処理
client.on :closed do |_|
      puts "connection closed"
      client.start!
end

#pp client
# Slackに接続
client.start!

