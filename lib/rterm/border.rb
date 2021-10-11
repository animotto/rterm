# frozen_string_literal: true

module RTerm
  ##
  # Border
  class Border
    HORIZONTAL = "\u2500"
    VERTICAL = "\u2502"
    TOP_LEFT = "\u250c"
    TOP_RIGHT = "\u2510"
    BOTTOM_LEFT = "\u2514"
    BOTTOM_RIGHT = "\u2518"

    attr_accessor :x, :y, :width, :height, :title

    def initialize(screen, x, y, width, height, **options)
      @screen = screen
      @x = x
      @y = y
      @width = width
      @height = height
      @title = options[:title]
      @border_color = options[:border_color]
      @title_color = options[:title_color]
    end

    ##
    # Renders the border
    def render
      return if @width <= 1 || @height <= 1

      @screen.terminal.move_to(@x, @y)
      @screen.terminal.fg_color(@border_color)
      @screen.terminal.write(TOP_LEFT)
      w = @width - @title.length - 2
      w = 0 if w.negative?
      unless @title.empty?
        @screen.terminal.fg_color(@title_color)
        @screen.terminal.write(@title[0..(@width - 3)])
        @screen.terminal.fg_color(@border_color)
      end
      @screen.terminal.write(HORIZONTAL * w)
      @screen.terminal.write(TOP_RIGHT)
      (@height - 2).times do |i|
        @screen.terminal.move_to(@x, @y + i + 1)
        @screen.terminal.write(VERTICAL)
        @screen.terminal.move_to(@x + @width - 1, @y + i + 1)
        @screen.terminal.write(VERTICAL)
      end
      @screen.terminal.move_to(@x, @y + @height - 1)
      @screen.terminal.write(BOTTOM_LEFT)
      @screen.terminal.write(HORIZONTAL * (@width - 2))
      @screen.terminal.write(BOTTOM_RIGHT)
      @screen.terminal.reset
    end
  end
end
