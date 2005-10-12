# $Id$
#
# Various tools to debug game behavior.

# This should be called after loading the data. Will print out all loaded data
# and exit.
def debug_dump_loaded_data
  puts $title_screen
  puts $monsters.inspect
  puts $player_professions.inspect
  puts $player_races.inspect
  puts $spells.inspect
  puts $places.inspect
  puts $items.inspect
  puts $weapons.inspect
  puts $materials.inspect
  puts $armors.inspect
  exit(1)
end

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
