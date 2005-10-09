
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
