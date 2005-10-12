# $Id$
#
# Code related to display management.
#
# FIXME: All of the terminal stuff needs tput. Is there
# a ruby module to use terminfo?

# A crudimentary class for setting up display modes.
class Display
  attr_reader :clear_attributes
  attr_reader :erase_line
  attr_reader :bold
  attr_reader :color_codes

  public
    def Display.set_up
      if $use_term then
        @@clear_attributes = `tput sgr0`
        @@erase_line = `tput cr` + `tput el`
        @@bold = `tput bold`
        @@color_codes = {}
        @@color_codes[:foreground] = {}
        @@color_codes[:background] = {}
        @@color_codes[:foreground][:black] = `tput setaf 0`
        @@color_codes[:foreground][:red] = `tput setaf 1`
        @@color_codes[:foreground][:green] = `tput setaf 2`
        @@color_codes[:foreground][:yellow] = `tput setaf 3`
        @@color_codes[:foreground][:blue] = `tput setaf 4`
        @@color_codes[:foreground][:magenta] = `tput setaf 5`
        @@color_codes[:foreground][:cyan] = `tput setaf 6`
        @@color_codes[:foreground][:white] = `tput setaf 7`
        @@color_codes[:background][:black] = `tput setab 0`
        @@color_codes[:background][:red] = `tput setab 1`
        @@color_codes[:background][:green] = `tput setab 2`
        @@color_codes[:background][:yellow] = `tput setab 3`
        @@color_codes[:background][:blue] = `tput setab 4`
        @@color_codes[:background][:magenta] = `tput setab 5`
        @@color_codes[:background][:cyan] = `tput setab 6`
        @@color_codes[:background][:white] = `tput setab 7`
      end
    end
    def Display.clear_attributes
      @@clear_attributes
    end
    def Display.erase_line
      @@erase_line
    end
    def Display.bold
      @@bold
    end
    def Display.color_codes
      @@color_codes
    end
end

Display.set_up

# A small debug thing that uses all of the display attributes, employing
# Display class to do all of that stuff.
def debug_display_attributes
  for n in 1..10 do
    sleep 1
    print Display.erase_line, Display.bold
    print Display.color_codes[:foreground][:magenta]
    print "Completed:"
    print Display.clear_attributes
    case n
      when 0..3 then
        print Display.color_codes[:foreground][:red]
      when 4..6 then
        print Display.color_codes[:foreground][:yellow]
      else
        print Display.color_codes[:foreground][:green]
    end
    print " #{n*10}%"
    $stdout.flush
  end
  print Display.clear_attributes
  print Display.erase_line
  $stdout.flush
  puts "Done!"
end
