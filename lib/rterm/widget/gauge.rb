# frozen_string_literal: true

module RTerm
  ##
  # Widget gauge
  class Gauge < Widget
    BORDER_COLOR = :cyan
    TITLE_COLOR = :magenta
    GAUGE_COLOR = :red
    BLANK = ' '

    attr_accessor :title, :gauge_color

    def initialize(screen, window, id, x, y, width, height, **options)
      super
      @title = options.fetch(:title, '')
      @border_color = options.fetch(:border_color, BORDER_COLOR)
      @title_color = options.fetch(:title_color, TITLE_COLOR)
      @gauge_color = options.fetch(:gauge_color, GAUGE_COLOR)
      @percent = options.fetch(:percent, 0)
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
    # Sets the value of the percent
    def percent(value)
      @percent = value
      @percent = 0 if @percent.negative?
      @percent = 100 if @percent > 100
    end

    ##
    # Increments the value of the percent
    def increment(value = 1)
      percent(@percent + value)
    end

    ##
    # Decrements the value of the percent
    def decrement(value = 1)
      percent(@percent - value)
    end

    ##
    # Returns the value of the percent
    def value
      @percent
    end

    ##
    # Returns true if the gauge has done job (100%)
    def done?
      @percent == 100
    end

    ##
    # Resets the gauge
    def reset
      @percent = 0
    end

    ##
    # Renders the gauge
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

      length = (@width / 100.to_f * @percent).round
      line_blank = BLANK * @width
      line_value = line_blank.dup
      value = "#{@percent}%"
      offset_x = @width / 2 - value.length / 2
      offset_x = 0 if offset_x.negative?
      offset_y = @height / 2
      value.each_char.with_index do |char, i|
        break if i + offset_x > @width

        line_value[i + offset_x] = char
      end

      @height.times do |i|
        s = length - 1
        s = 0 if s.negative?
        e = s
        e += 1 if e.positive?
        line = i == offset_y ? line_value : line_blank
        @screen.terminal.move_to(@x + 1, @y + i + 1)
        unless s.zero?
          @screen.terminal.bg_color(@gauge_color)
          @screen.terminal.write(line[0..s])
        end
        @screen.terminal.reset
        @screen.terminal.write(line[e..-1])
      end
    end
  end
end
