# frozen_string_literal: true

module RTerm
  ##
  # Screen
  class Screen
    attr_reader :terminal, :windows, :running

    def initialize(terminal = nil)
      @terminal = terminal || Terminal.new
      @windows = {}
      @running = false
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
    # Adds a window to the screen
    def add_window(id, x, y, width, height, **args)
      raise WindowError, "Window #{id} already exists" if @windows.key?(id)

      @windows[id] = Window.new(self, id, x, y, width, height, **args)
    end

    ##
    # Removes a window from the screen
    def remove_window(id)
      window_exist?(id)
      @windows.delete(id)
    end

    ##
    # Finds a window
    def find_window(id)
      @windows[id]
    end

    ##
    # Adds a box to the screen
    def add_box(window, id, x, y, width, height, **args)
      window_exist?(window)
      box = Box.new(
        self,
        find_window(window),
        id,
        x,
        y,
        width,
        height,
        **args
      )
      @windows[window].add_widget(id, box)
    end

    ##
    # Adds a list to the screen
    def add_list(window, id, x, y, width, height, **args)
      window_exist?(window)
      list = List.new(
        self,
        find_window(window),
        id,
        x,
        y,
        width,
        height,
        **args
      )
      @windows[window].add_widget(id, list)
    end

    ##
    # Adds a gauge to the screen
    def add_gauge(window, id, x, y, width, height, **args)
      window_exist?(window)
      gauge = Gauge.new(
        self,
        find_window(window),
        id,
        x,
        y,
        width,
        height,
        **args
      )
      @windows[window].add_widget(id, gauge)
    end

    ##
    # Adds a button to the screen
    def add_button(window, id, x, y, width, height, **args)
      window_exist?(window)
      button = Button.new(
        self,
        find_window(window),
        id,
        x,
        y,
        width,
        height,
        **args
      )
      @windows[window].add_widget(id, button)
    end

    ##
    # Removes a widget from the window
    def remove_widget(window, id)
      window_exist?(window)
      @windows[window].remove_widget(id)
    end

    ##
    # Finds a widget
    def find_widget(window, id)
      window_exist?(window)
      find_window(window).find_widget(id)
    end

    ##
    # Renders windows on the screen
    def render
      @windows.each_value(&:render)
    end

    ##
    # Redraws the entire screen
    def redraw
      @terminal.erase_screen
      render
    end

    ##
    # Runs the dispatcher
    def run
      @running = true
      @terminal.raw_mode
      @terminal.hide_cursor
      redraw
      yield if block_given?
      @running = false
      @terminal.show_cursor
      @terminal.erase_screen
      @terminal.move_home
      @terminal.cooked_mode
    end

    ##
    # Stops the dispatcher
    def stop
      @running = false
    end

    ##
    # Polls the events
    def poll
      key = @terminal.read
      callback(:on_key, key: key)
      window = @windows.detect { |_, v| v.focused? }
      return if window.nil?

      widget = window[1].widgets.detect { |_, v| v.focused? }
      return if widget.nil?

      widget[1].callback(:on_key, key: key)
      widget[1].key_press(key)
    end

    ##
    # Calls a callback
    def callback(name, **args)
      return unless @callbacks.key?(name)

      @callbacks[name].call(**args)
    end

    private

    ##
    # Checks if the window exists
    def window_exist?(id)
      raise WindowError, "Window #{id} doesn't exist" unless @windows.key?(id)

      true
    end
  end

  ##
  # Screen exception
  class ScreenError < StandardError; end
end
