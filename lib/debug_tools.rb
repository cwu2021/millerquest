# Various tools to debug game behavior.
#
# ============================================================================
# Miller's Quest!, a role-playing game simulator.
# Copyright (C) 2005  Urpo 'WWWWolf' Lankinen.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# ============================================================================

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
