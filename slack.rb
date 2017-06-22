require 'slack-ruby-client'
require 'pp'
require './player.rb'
require './bom.rb'
require './field.rb'

field = Field.new()
you = Player.new()
enemy = Player.new()

buttons = {
      up:  "point_up",
      down:  "point_down",
      right:  "point_right",
      left:  "point_left",
      bom:  "game_die",
}

bot = {
      channel: "test",
      name: "bommer",
      id: "",
      ts: ""
}

player = {
      player: "",
      enemy: "",
}

Slack.configure do |conf|
      conf.token = "" # slack token
end

client = Slack::RealTime::Client.new


client.on :hello do
      puts 'connected!'
      users = client.users
      users.each do |_, value|
            bot[:id] = value['id'] if value['name'] == bot[:name]
      end
      if bot[:id] == ""
            puts "i can't"
            client.stop!
      end

      puts "channel #{bot[:name]} / #{bot[:id]}"
      client.web_client.chat_postMessage channel: bot[:channel], text: "hello! I am bom-man! Who Join?"
end

# message eventを受け取った時の処理
client.on :message do |data|
      channel = data['channel']
      case data['text']
      when 'join' then
            if player[:player] == "" then
                  player[:player] = data['user']
                  client.web_client.chat_postMessage channel: channel, text: "Thank you! you are #{player[:player]} and player"
            elsif player[:enemy] == "" then
                  player[:enemy] = data['user']
                  client.web_client.chat_postMessage channel: channel, text: "Thank you! you are #{player[:enemy]} and enemy"
            else
                  client.web_client.chat_postMessage channel: channel, text: "Who are you?"
            end
      when 'start' then
            if player[:player] == "" || player[:enemy] == ""
                  client.web_client.chat_postMessage channel: channel, text: "who is join?"
            else
                  post_field = field.updateField(you, enemy)
                  posts = client.web_client.chat_postMessage channel: channel, text: post_field
                  bot[:ts] = posts['ts']
                  buttons.each do |_, value|
                        client.web_client.reactions_add channel: data['channel'],  name: value, timestamp: bot[:ts]
                  end
            end
      end
end

#reactionされた時 入力に使える
client.on :reaction_added do |data|
      #pp data
      channel = data['item']['channel']
      reaction = data['reaction']
      if data['user'] != bot[:id]
            if buttons.has_value?(reaction)
                  if data['user'] == player[:player]
                        you.inputCommandFromSlack(reaction)
                        you.moveYou(field)
                        you.myBomCountDown()
                  elsif data['user'] == player[:enemy]
                        enemy.inputCommandFromSlack(reaction)
                        enemy.moveYou(field)
                        enemy.myBomCountDown()
                  end

                  post_field = field.updateField(you, enemy)

                  client.web_client.chat_update channel: channel, text: post_field, ts: bot[:ts]
                  if you.is_exist == false
                        puts "enemy win"
                        posts = client.web_client.chat_postMessage channel: channel, text: "enemy win"
                        client.stop!
                  elsif enemy.is_exist == false
                        puts "player win"
                        posts = client.web_client.chat_postMessage channel: channel, text: "player win"
                        client.stop!
                  end
            end
      end

end

#reaction外された時 入力に使える
client.on :reaction_removed do |data|
      #pp data
      channel = data['item']['channel']
      reaction = data['reaction']
      if data['user'] != bot[:id]
            if buttons.has_value?(reaction)
                  if data['user'] == player[:player]
                        you.inputCommandFromSlack(reaction)
                        you.moveYou(field)
                        you.myBomCountDown()
                  elsif data['user'] == player[:enemy]
                        enemy.inputCommandFromSlack(reaction)
                        enemy.moveYou(field)
                        enemy.myBomCountDown()
                  end

                  post_field = field.updateField(you, enemy)

                  client.web_client.chat_update channel: channel, text: post_field, ts: bot[:ts]
                  if you.is_exist == false
                        puts "enemy win"
                        posts = client.web_client.chat_postMessage channel: channel, text: "enemy win"
                        client.stop!
                  elsif enemy.is_exist == false
                        puts "player win"
                        posts = client.web_client.chat_postMessage channel: channel, text: "player win"
                        client.stop!
                  end
            end
      end
end

#再接続処理
client.on :closed do |_|
      puts "reconnenct!"
      client.start!
end

#pp client
# Slackに接続
client.start!
