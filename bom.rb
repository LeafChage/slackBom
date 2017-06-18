require './field.rb'

class Bom
      @@count_bom_in_field = 0;

      attr_reader :count, :x, :y

      def initialize(x, y)
            @count = 5
            @x = x
            @y = y
            @@count_bom_in_field += 1
      end

      def countDown()
            @count -= 1
      end

      def boom()
            @@count_bom_in_field -= 1
      end

      def getBomCount()
            return @@count_bom_in_field
      end

      def makeBoomLine(field)
            bom_line = []
            h = @y
            while h > 0
                  h -= 1
                  if field.positionIsBlock(x, h)
                        break
                  end
                  bom_line.insert(-1, [@x, h])
            end

            (@y..Field::HEIGHT).each do |h|
                  if field.positionIsBlock(@x, h)
                        break
                  end
                  bom_line.insert(-1, [@x, h])
            end

            w = @x
            while w > 0
                  w -= 1
                  if field.positionIsBlock(w, @y)
                        break
                  end
                  bom_line.insert(-1, [w, @y])
            end

            (@x..Field::HEIGHT).each do |w|
                  if field.positionIsBlock(w, @y)
                        break
                  end
                  bom_line.insert(-1, [w, @y])
            end
            return bom_line
      end

      private
      def _isBoom()
            return @count <= 0
      end
end
