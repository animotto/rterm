# frozen_string_literal: true

module RTerm
  ##
  # Widget
  class Widget
    attr_reader :id
    attr_accessor :x, :y, :width, :height, :width_s, :height_s

    def initialize(screen, window, id, x, y, width, height, **options)
      @screen = screen
      @window = window
      @id = id
      @x = x
      @y = y
      @width = @width_s = width
      @height = @height_s = height
      @visible = options.fetch(:visible, true)
      @focus = options.fetch(:focus, false)
      @callbacks = {}
    end

    ##
    # Handles callbacks
    def method_missing(method, **_args, &block)
      return unless method.start_with?('on_')

      @callbacks[method] = block
    end

    ##
    # Returns true if callback exists
    def respond_to_missing?(method)
      @callbacks.key?(method)
    end

    ##
    # Calls a callback
    def callback(name, **args)
      return unless @callbacks.key?(name)

      @callbacks[name].call(**args)
    end

    ##
    # Shows the widget
    def show
      @visible = true
    end

    ##
    # Hides the widget
    def hide
      @visible = false
    end

    ##
    # Returns true if the widget is visible
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

    # Returns true if the widget is focused
    def focused?
      @focus
    end

    ##
    # Handles key press
    def key_press(key); end

    ##
    # Renders the widget
    def render; end
  end

  ##
  # Widget exception
  class WidgetError < StandardError; end
end
