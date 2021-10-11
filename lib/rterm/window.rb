# frozen_string_literal: true

module RTerm
  ##
  # Window
  class Window
    BLANK = ' '

    attr_reader :id, :widgets
    attr_accessor :x, :y, :width, :height

    def initialize(screen, id, x, y, width, height, **options)
      @screen = screen
      @id = id
      @x = x
      @y = y
      @width = width
      @height = height
      @visible = options.fetch(:visible, true)
      @focus = options.fetch(:focus, false)
      @widgets = {}
    end

    ##
    # Shows the window
    def show
      @visible = true
    end

    ##
    # Hides the window
    def hide
      @visible = false
    end

    ##
    # Returns true if the window is visible
    def visible?
      @visible
    end

    ##
    # Focuses the window
    def focus
      @focus = true
    end

    ##
    # Unfocuses the window
    def unfocus
      @focus = false
    end

    ##
    # Focuses next widget
    def focus_next; end

    ##
    # Focuses previous widget
    def focus_prev; end

    ##
    # Returns true if the widget is focused
    def focused?
      @focus
    end

    ##
    # Adds a widget to the window
    def add_widget(id, widget)
      raise WidgetError, "Widget #{id} already exists in the window #{@id}" if @widgets.key?(id)

      @widgets[id] = widget
    end

    ##
    # Removes a widget from the window
    def remove_widget(id)
      raise WidgetError, "Widget #{id} doesn't exists in the window #{@id}" unless @widgets.key?(id)

      @widgets.delete(id)
    end

    ##
    # Finds a widget
    def find_widget(id)
      @widgets[id]
    end

    ##
    # Renders the window
    def render
      return unless @visible

      @height.times do |i|
        @screen.terminal.move_to(@x, @y + i)
        @screen.terminal.write(BLANK * @width)
      end

      @widgets.each_value do |widget|
        widget.width = widget.x + widget.width_s >= @width ? @width - widget.x - 1 : widget.width_s
        widget.height = widget.y + widget.height_s >= @height ? @height - widget.y - 1 : widget.height_s
        widget.render
      end
    end
  end

  ##
  # Window exception
  class WindowError < StandardError; end
end
