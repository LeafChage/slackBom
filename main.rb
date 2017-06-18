
require './player.rb'
require './bom.rb'
require './field.rb'

field = Field.new()
you = Player.new()
enemy = Player.new()

field.updateField(you, enemy)

loop do
      you.inputCommand()
      you.moveYou(field)
      you.myBomCountDown()

      enemy.inputCommandRandom()
      enemy.moveYou(field)
      enemy.myBomCountDown()

      field.updateField(you, enemy)

      if you.is_exist == false
            puts "you lose"
            break
      elsif enemy.is_exist == false
            puts "you win"
            break
      end
end

