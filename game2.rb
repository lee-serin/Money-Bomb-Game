require 'gosu'

module ZOrder
    BACKGROUND, PLAYER, MONEY, BOMB, UI = *0..4
end

class Money_Game < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Money Game"

        @background_image = Gosu::Image.new("background.png", :tileable => true)

        @player = Player.new
        @player.warp(320)

        @money_image = Gosu::Image.new("money.png")
        @money = Array.new

        @bomb_image = Gosu::Image.new("bomb.png")
        @bomb = Array.new

        @font = Gosu::Font.new(20)
    end

    def update
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.accelerate
            @player.move_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.accelerate
            @player.move_right
        end
        
        @player.collect_money(@money)
        @money.each {|mon| mon.move}

        if rand(100) < 4 && @money.size < 25
            @money.push(Money.new(@money_image, 0, rand, rand * 640)) 
        end
        
        @money.each do |mon|
            if mon.y > 480
                @money.delete(mon)
            end
        end

        @player.avoid_bomb(@bomb)
        @bomb.each {|b| b.move}

        if rand(100) < 4 && @bomb.size < 25
            @bomb.push(Bomb.new(@bomb_image, 0, rand * 640, rand))
        end

        @bomb.each do |b|
            if b.y > 480
                @bomb.delete(b)
            end
        end
    end

    def draw
        @player.draw
        @background_image.draw(0, 0, 0, factor_x = 2.5, factor_y = 2.9)
        @money.each {|mon| mon.draw}
        @bomb.each {|b| b.draw}
        @font.draw_markup("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

class Player
    attr_reader :x, :score

    def initialize
        @image = Gosu::Image.new("luigi.png")
        @x = @vel_x = 0.0
        @score = 0
    end

    def warp(x)
        @x = x
    end

    def accelerate
        @vel_x += 0.5
    end

    def move_left
        @x -= @vel_x
        @x %= 640

        @vel_x *= 0.95
    end

    def move_right
        @x += @vel_x
        @x %= 640

        @vel_x *= 0.95
    end

    def draw
        @image.draw(@x, 350, ZOrder::PLAYER, factor_x = 0.05, factor_y = 0.05)
    end

    def collect_money(money)
        money.reject! do |mon|
            if Gosu.distance(@x, 350, mon.x, mon.y) < 35
                @score += (mon.big_ness * 10).to_i
                true
            else
                false
            end
        end
    end

    def avoid_bomb(bomb)
        bomb.reject! do |b|
            if Gosu.distance(@x, 350, b.x, b.y) < 35
                @score -= 100
                true
            else
                false
            end
        end
    end
end

class Money
    attr_reader :x, :y, :img, :big_ness

    def initialize(img, y, size = 1, x)
        @img = img
        @x = x
        @y = y
        @big_ness = size

        @velocityY = 25 - rand(60)
    end

    def move
        @y += @big_ness * 2
    end

    def draw
        @img.draw(@x, @y, ZOrder::MONEY, factor_x = @big_ness / 2, factor_y = @big_ness / 2)
    end
end

class Bomb
    attr_reader :x, :y, :img, :big_ness

    def initialize(img, y, x, size = 1)
        @img = img
        @x = x
        @y = y
        @big_ness = size

        @velocityY = 25 - rand(60)
    end

    def move
        @y += @big_ness * 2
    end

    def draw
        @img.draw(@x, @y, ZOrder::BOMB, factor_x = @big_ness / 0.5, factor_y = @big_ness / 0.5)
    end
end


Money_Game.new.show