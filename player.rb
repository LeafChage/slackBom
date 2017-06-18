require './field.rb'
require './bom.rb'

class Player
      HAVE_BOM = 5
      # UP = 'u'
      # DOWN = 'd'
      # RIGHT = 'r'
      # LEFT = 'l'
      # BOM = 'b'


      UP = "point_up"
      DOWN = "point_down"
      RIGHT = "point_right"
      LEFT = "point_left"
      BOM = "game_die"



      attr_reader :boms, :x, :y, :is_exist
      def initialize()
            @x = rand(1..Field::WIDTH - 2)
            @y = rand(1..Field::HEIGHT - 2)
            @boms = []
            @command = ""
            @is_exist = true
      end

      def inputCommandFromSlack(slack_command)
            @command = slack_command
      end

      def inputCommand()
            commands = [UP, DOWN, RIGHT, LEFT, BOM]
            puts "how do you do? (u: up, d: down, r: right, l: left, b: bom)"
            command = gets().chomp()
            if commands.include?(command)
                  @command  = command
            else
                  return inputCommandRandom()
            end
      end

      def inputCommandRandom()
            commands = [UP, DOWN, RIGHT, LEFT]
            @command = commands[rand(0..commands.length)]
      end

      def moveYou(field)
            x = @x
            y = @y
            case @command
            when UP then y -= 1
            when DOWN then y += 1
            when RIGHT then x += 1
            when LEFT then x -= 1
            when BOM
                  if @boms.length < HAVE_BOM
                        _makeBom()
                  end
            end
            if !field.positionIsBlock(x, y)
                  @x = x
                  @y = y
            end
      end

      def myBomCountDown()
            if @boms.length > 0
                  i = 0
                  while i < @boms.length
                        @boms[i].countDown()
                        i += 1
                  end
            end
      end

      def myBomBoom()
            @boms[0].boom()
            @boms.delete_at(0)
      end

      def delete()
            @is_exist = false
      end

      private

      def _makeBom()
            bom = Bom.new(@x, @y)
            @boms.push(bom)
      end
end

