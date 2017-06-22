require 'pp'

class Field
      WALL = ":black_large_square:"
      HEIGHT = 12
      WIDTH = 12
      BLOCK = ":black_large_square:"
      BLOCK_COUNT = 20
      PLAYER = ":walking:"
      ENEMY = ":skull_and_crossbones:"
      NONE = ":white_small_square:"
      BOM = ":stopwatch:"
      BOOM = ":fire:"

      # WALL = "[|]"
      # HEIGHT = 20
      # WIDTH = 20
      # BLOCK = "[|]"
      # BLOCK_COUNT = 30
      # PLAYER = "YOU"
      # ENEMY = "ENE"
      # NONE = " _ "
      # BOM = "BOM"
      # BOOM = "WMW"

      def initialize()
            _makeBlock()
            _masterField()
      end

      def updateField(player, enemy)
            _masterField()
            _setBlockPosition()
            _setBomPosition(player, enemy)
            _setPlayerPosition(player, enemy)
            _setBoomLine(player, enemy)
            text = ""
            @field.each do |line|
                  line.each do |l|
                        text += l
                  end
                  text += "\n"
            end
            #puts text
            puts "player: #{PLAYER}"
            return text
      end

      def positionIsBlock(x, y)
           return @field[y][x] == WALL || @field[y][x] == BLOCK
      end

      private
      def _masterField()
            @field = []
            @field.insert(-1, Array.new(WIDTH, WALL))

            (WIDTH-2).times do
                  line = Array.new(WIDTH - 1, NONE)
                  line[0] = WALL
                  line.push(WALL)
                  @field.insert(-1, line)
            end

            @field.insert(-1, Array.new(WIDTH, WALL))
      end


      def _makeBlock()
            blocks = []
            BLOCK_COUNT.times do
                  x = rand(1..HEIGHT - 1)
                  y = rand(1..WIDTH - 1)
                  blocks.insert(-1, [x, y])
            end
            @blocks = blocks
      end

      def _setPlayerPosition(player, enemy)
            @field[player.y][player.x] = PLAYER
            @field[enemy.y][enemy.x] = ENEMY
      end

      def _setBlockPosition()
            @blocks.each do |b|
                  @field[b[0]][b[1]] = BLOCK
            end
      end

      def _setBomPosition(player, enemy)
            if player.boms.length > 0
                  player.boms.each do |b|
                        @field[b.y][b.x] = BOM
                  end
            end
            if enemy.boms.length > 0
                  enemy.boms.each do |b|
                        @field[b.y][b.x] = BOM
                  end
            end
      end

      def _setBoomLine(player, enemy)
            boom_line = []
            if player.boms.length > 0
                  player.boms.each do |b|
                        if b.count <= 0
                              boom_line.insert(-1, b.makeBoomLine(self))
                              player.myBomBoom()
                        end
                  end
            end
            if enemy.boms.length > 0
                  enemy.boms.each do |b|
                        if b.count <= 0
                              boom_line.insert(-1, b.makeBoomLine(self))
                              enemy.myBomBoom()
                        end
                  end
            end

            boom_line.each do |line|
                  line.each do |l|
                        who = _whoIsPlayer(l[0], l[1])
                        if !who.nil?
                              _destroyPlayer(who, player, enemy)
                        end
                        @field[l[1]][l[0]] = BOOM
                  end
            end
      end

      def _destroyPlayer(who, player, enemy)
            if who == PLAYER
                  player.delete()
            elsif who == ENEMY
                  enemy.delete()
            end
      end

      def _whoIsPlayer(x, y)
            if @field[y][x] == PLAYER
                  return PLAYER
            elsif @field[y][x] == ENEMY
                  return ENEMY
            else
                  return nil
            end
      end
end
