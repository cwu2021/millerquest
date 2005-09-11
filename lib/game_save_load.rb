
def new_game
  $player = Player.new
  $player.setup_for_new_game
  save_game(:interactive)
end

def ask_filename
  print "Enter savegame file name: "
  return gets.chomp
end

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
  e = YAML::load(File.open("#{$datadir}/equipment.yml"))
  $items = e['items']
  $weapons = e['weapons']
  $materials = e['materials']
  $armors = e['armors']
end

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

