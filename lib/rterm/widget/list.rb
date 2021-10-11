# frozen_string_literal: true

module RTerm
  ##
  # Widget list
  class List < Widget
    SELECTED_COLOR = :green
    BORDER_COLOR = :cyan
    TITLE_COLOR = :magenta
    TEXT_COLOR = :white
    BLANK = ' '
    SCROLL = 3

    attr_reader :selected
    attr_accessor :title, :items

    def initialize(screen, window, id, x, y, width, height, **options)
      super
      @title = options.fetch(:title, '')
      @items = options.fetch(:items, [])
      @selected_color = options.fetch(:selected_color, SELECTED_COLOR)
      @border_color = options.fetch(:border_color, BORDER_COLOR)
      @title_color = options.fetch(:title_color, TITLE_COLOR)
      @text_color = options.fetch(:text_color, TEXT_COLOR)
      @selected = 0
      @offset = 0
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
    # Moves up the list
    def move_up(step = 1)
      @selected -= step
      @selected = 0 if @selected.negative?
      @offset -= step if @offset.positive? && @selected < @offset
      @offset = 0 if @offset.negative?
    end

    ##
    # Moves down the list
    def move_down(step = 1)
      @selected += step
      @selected = @items.length - 1 if @selected > @items.length - 1
      @offset += step if @selected > @offset + @height - 1
      @offset = @items.length - @height if @items.length > @height && @offset + @height > @items.length - 1
    end

    ##
    # Moves to the first item
    def move_first
      @selected = 0
      @offset = 0
    end

    ##
    # Moves to the last item
    def move_last
      @selected = @items.length - 1
      @offset = @items.length - @height if @items.length > @height
    end

    ##
    # Returns the selected item
    def selected_item
      @items[@selected]
    end

    ##
    # Adds an item
    def add_item(index, item)
      @items.insert(index, item)
      @offset += 1 if @offset.positive?
      @offset = @items.length - @height if @items.length > @height && @offset + @height > @items.length - 1
      @selected += 1 if @selected >= index
      @selected = @items.length - 1 if @selected > @items.length - 1
    end

    ##
    # Adds an item to the first position
    def add_item_first(item)
      add_item(0, item)
    end

    ##
    # Adds an item to the last position
    def add_item_last(item)
      add_item(@items.length, item)
    end

    ##
    # Deletes an item
    def delete_item(index)
      @offset -= 1 if @offset.positive?
      @offset = 0 if @offset.negative?
      @selected -= 1
      @selected = 0 if @selected.negative?
      @items.delete_at(index)
    end

    ##
    # Handles key press
    def key_press(key)
      case key
      when :enter
        callback(:on_select, item: selected_item) unless @items.empty?
      when :up
        move_up
      when :down
        move_down
      when :right, :end
        move_last
      when :left, :home
        move_first
      when :pgup
        move_up(SCROLL)
      when :pgdown
        move_down(SCROLL)
      end
      render
    end

    ##
    # Renders the list
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

      @height.times do |i|
        @screen.terminal.move_to(@x + @window.x, @y + @window.y + i)
        if i < @items.length
          item = @items[i + @offset]
          @screen.terminal.bg_color(@selected_color) if i + @offset == @selected
          n = @width - item.length
          n = 0 if n.negative?
          item = item[0..(@width - 1)] + BLANK * n
          @screen.terminal.fg_color(@text_color)
          @screen.terminal.write(item)
          @screen.terminal.reset
          next
        end
        @screen.terminal.write(BLANK * @width)
      end
    end
  end
end
