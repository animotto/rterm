# frozen_string_literal: true

module RTerm
  ##
  # Widget button
  class Button < Widget
    # LEFT = "\u231c"
    # RIGHT = "\u231f"
    LEFT = "\u27e8"
    RIGHT = "\u27e9"
    CORNER_COLOR = :blue
    TEXT_COLOR = :red
    FOCUS_COLOR = :green

    attr_accessor :text

    def initialize(screen, window, id, x, y, width, height, **options)
      super
      @text = options.fetch(:text, '')
      @corner_color = options.fetch(:corner_color, CORNER_COLOR)
      @text_color = options.fetch(:text_color, TEXT_COLOR)
      @focus_color = options.fetch(:focus_color, FOCUS_COLOR)
    end

    ##
    # Handles key press
    def key_press(key)
      return unless key == :enter

      callback(:on_click)
    end

    ##
    # Renders the box
    def render
      return unless @window.visible? && visible?
      return if @width < 4

      @screen.terminal.move_to(@x, @y)
      @screen.terminal.bg_color(@focus_color) if focused?
      @screen.terminal.fg_color(@corner_color)
      @screen.terminal.write(LEFT)
      e = @width - 3
      if e >= 0
        @screen.terminal.fg_color(@text_color)
        @screen.terminal.write(@text[0..e])
      end
      @screen.terminal.fg_color(@corner_color)
      @screen.terminal.write(RIGHT)
      @screen.terminal.reset
    end
  end
end
