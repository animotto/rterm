# frozen_string_literal: true

require 'io/console'

module RTerm
  ##
  # VT100 terminal
  class Terminal
    # CSI sequence
    CSI = "\e["

    # Move cursor up
    CUU = 'A'
    # Move cursor down
    CUD = 'B'
    # Move cursor left
    CUF = 'C'
    # Move cursor right
    CUB = 'D'
    # Move cursor down the indicated number of rows
    CNL = 'E'
    # Move cursor up the indicated number of rows
    CPL = 'F'
    # Move cursor the indicated column
    CHA = 'G'
    # Move cursor the indicated row and column
    CUP = 'H'
    # Erase display
    ED = 'J'
    # Erase line
    EL = 'K'
    # Set Graphics Rendition
    SGR = 'm'
    # Save cursor location
    SAVE = 's'
    # Restore cursor location
    RESTORE = 'u'
    # Hide cursor
    HIDE = '?25l'
    # Show cursor
    SHOW = '?25h'

    # Reset all SGR attributes
    SGR_RESET = 0
    # Bold
    SGR_BOLD = 1
    # Underscore
    SGR_UNDERSCORE = 4
    # Blink
    SGR_BLINK = 5
    # Foreground color
    SGR_FG = 30
    # Background color
    SGR_BG = 40

    # List of colors
    COLORS = {
      black: 0,
      red: 1,
      green: 2,
      yellow: 3,
      blue: 4,
      magenta: 5,
      cyan: 6,
      white: 7
    }.freeze

    # Char mapping
    CHAR_MAP = {
      "\x01" => :ctrl_a,
      "\x02" => :ctrl_b,
      "\x03" => :ctrl_c,
      "\x04" => :ctrl_d,
      "\x05" => :ctrl_e,
      "\x06" => :ctrl_f,
      "\x07" => :ctrl_g,
      "\x08" => :ctrl_h,
      "\x09" => :tab,
      "\x0a" => :ctrl_j,
      "\x0b" => :ctrl_k,
      "\x0c" => :ctrl_l,
      "\r" => :enter,
      "\x0e" => :ctrl_n,
      "\x0f" => :ctrl_o,
      "\x10" => :ctrl_p,
      "\x11" => :ctrl_q,
      "\x12" => :ctrl_r,
      "\x13" => :ctrl_s,
      "\x14" => :ctrl_t,
      "\x15" => :ctrl_u,
      "\x16" => :ctrl_v,
      "\x17" => :ctrl_w,
      "\x18" => :ctrl_x,
      "\x19" => :ctrl_y,
      "\x1a" => :ctrl_z,
      "\e\e" => :esc,
      "\x7f" => :backspace,
      "\eOP" => :f1,
      "\eOQ" => :f2,
      "\eOR" => :f3,
      "\eOS" => :f4,
      "#{CSI}1~" => :home,
      "#{CSI}2~" => :ins,
      "#{CSI}3~" => :del,
      "#{CSI}4~" => :end,
      "#{CSI}5~" => :pgup,
      "#{CSI}6~" => :pgdown,
      "#{CSI}15~" => :f5,
      "#{CSI}17~" => :f6,
      "#{CSI}18~" => :f7,
      "#{CSI}19~" => :f8,
      "#{CSI}20~" => :f9,
      "#{CSI}21~" => :f10,
      "#{CSI}23~" => :f11,
      "#{CSI}24~" => :f12,
      "#{CSI}#{CUU}" => :up,
      "#{CSI}#{CUD}" => :down,
      "#{CSI}#{CUF}" => :right,
      "#{CSI}#{CUB}" => :left
    }.freeze

    ##
    # Creates new instance of terminal
    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
      @sgr = []
    end

    ##
    # Reads the input
    def read
      input = @input.readchar
      if input == "\e"
        input += @input.readchar
        case input
        when CSI
          loop do
            char = @input.readchar
            input += char
            break unless char.ord.between?(0x30, 0x39)
          end

        when "\eO"
          input += @input.readchar
        end
      end

      CHAR_MAP.fetch(input, input)
    end

    ##
    # Writes a data to output with SGR attributes
    def write(data = '')
      @output.write("#{CSI}#{@sgr.join(';')}#{SGR}") unless @sgr.empty?
      @output.write(data)
    end

    ##
    # Writes a data with newline at the end
    def puts(data = '')
      write("#{data}\n")
    end

    ##
    # Sets foreground color
    def fg_color(color)
      check_color(color)
      @sgr << COLORS[color] + SGR_FG
    end

    ##
    # Sets background color
    def bg_color(color)
      check_color(color)
      @sgr << COLORS[color] + SGR_BG
    end

    ##
    # Resets all SGR attributes
    def reset
      @output.write("#{CSI}#{SGR_RESET}#{SGR}")
      @sgr.clear
    end

    ##
    # Sets the bold style
    def bold
      @sgr << SGR_BOLD
    end

    ##
    # Sets the underscore style
    def underscore
      @sgr << SGR_UNDERSCORE
    end

    ##
    # Sets the blinking style
    def blink
      @sgr << SGR_BLINK
    end

    ##
    # Moves cursor the indicated location X, Y
    def move_to(x, y)
      @output.write("#{CSI}#{y};#{x}#{CUP}")
    end

    ##
    # Moves cursor to the location 1, 1
    def move_home
      move_to(1, 1)
    end

    ##
    # Erases whole screen
    def erase_screen
      @output.write("#{CSI}2#{ED}")
    end

    ##
    # Hides cursor
    def hide_cursor
      @output.write("#{CSI}#{HIDE}")
    end

    ##
    # Shows cursor
    def show_cursor
      @output.write("#{CSI}#{SHOW}")
    end

    ##
    # Enables raw mode
    def raw_mode
      @input.raw! if @input.respond_to?(:raw!)
    end

    ##
    # Enables cooked mode
    def cooked_mode
      @input.cooked! if @input.respond_to?(:cooked!)
    end

    private

    ##
    # Checks if color exists, otherwise raise exception
    def check_color(color)
      raise TerminalError, "Unknown color #{color}" unless COLORS.key?(color)
    end
  end

  ##
  # Terminal exception
  class TerminalError < StandardError; end
end
