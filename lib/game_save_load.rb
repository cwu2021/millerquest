# $Id: game_save_load.rb 26 2005-10-26 22:24:53Z wwwwolf $
#
# Saving and loading the game.
#
# FIXME: Some of this stuff is REALLY dumb.
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

# Start a new game.
def new_game
  $player = Player.new
  $player.setup_for_new_game
  save_game(:interactive)
end

# Asks file name from user.
def ask_filename
  print "Enter savegame file name: "
  return gets.chomp
end

# Load all game data from the various YAML files to the global variables.
def load_game_data
  f = File.open("#{$datadir}/title.txt")
  $title_screen = f.readlines.join("")
  f.close

  $monsters = YAML::load(File.open("#{$datadir}/monsters.yml"))

  p = YAML::load(File.open("#{$datadir}/player.yml"))
  $player_professions = p['player_professions']
  $player_races = p['player_races']

  $spells = YAML::load(File.open("#{$datadir}/spells.yml"))
  $places = YAML::load(File.open("#{$datadir}/places.yml"))

  $damagetypes = DamageType.load("#{$datadir}/damagetypes.yml")
  $materials = Material.load("#{$datadir}/materials.yml")
  $weapons = Weapon.load("#{$datadir}/weapons.yml")
  $armors = Armor.load("#{$datadir}/armor.yml")
  $items = YAML::load(File.open("#{$datadir}/items.yml"))

  # debug_dump_loaded_data

end

# Load the game.
def load_game(filename)
  puts "Loading game."
  if filename == :interactive
    filename = ask_filename
    $filename = filename
  end
  y = YAML::Store.new(filename)
  y.transaction do
    $player = y['player']
  end
  $player.print_character_sheet
end

# Save the game.
def save_game(filename)
  puts "Saving game."
  if filename == :interactive
    filename = ask_filename
    $filename = filename
  end
  if File.exists?(filename)
    File.delete(filename)
  end
  y = YAML::Store.new(filename)
  y.transaction do
    y['player'] = $player
  end
end

