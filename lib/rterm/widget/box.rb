# frozen_string_literal: true

module RTerm
  ##
  # Widget box
  class Box < Widget
    BORDER_COLOR = :cyan
    TITLE_COLOR = :magenta

    attr_accessor :text, :title

    def initialize(screen, window, id, x, y, width, height, **options)
      super
      @text = options.fetch(:text, '')
      @text_wrap = options.fetch(:text_wrap, true)
      @title = options.fetch(:title, '')
      @border_color = options.fetch(:border_color, BORDER_COLOR)
      @title_color = options.fetch(:title_color, TITLE_COLOR)
      return unless options.fetch(:border, true)

      @border = Border.new(
        @screen,
        @x + @window.x - 1,
        @y + @window.y - 1,
        @width + 2,
        @height + 2,
        title: @title,
        border_color: @border_color,
        title_color: @title_color
      )
    end

    ##
    # Renders the box
    def render
      return unless @window.visible? && visible?

      unless @border.nil?
        @border.x = @x + @window.x - 1
        @border.y = @y + @window.y - 1
        @border.width = @width + 2
        @border.height = @height + 2
        @border.title = @title
        @border.render
      end

      if @text.length <= @width || !@text_wrap
        @screen.terminal.move_to(@x + @window.x, @y + @window.y)
        @screen.terminal.write(@text[0..(@width - 1)])
        return
      end

      n = @text.length / @width + 1
      n = @height if n > @height
      n.times do |i|
        @screen.terminal.move_to(@x + @window.x, @y + @window.y + i)
        s = i * @width
        e = s + @width - 1
        @screen.terminal.write(@text[s..e])
      end
    end
  end
end
