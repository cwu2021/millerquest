#!/usr/bin/ruby
# $Id$

require 'yaml'
require 'yaml/store'

#######################################################################

PLAYER_PROFESSIONS = [
  'arborian',
  'armchair strategist',
  'blade-thrust diplomat',
  'bungie cord wizard',
  'divinity abstractifier',
  'orator paladin',
  'professional cookie cutter',
  'rogue of Hague',
  'soccerer',
]

PLAYER_RACES = [
  'man-ant',
  'giggling hyenoid',
  'out-of-focus elf',
  'flute-music-backed elf',
  'alliterative worminator',
  'dragon-trout',
  'wobblit',
  'animated broom',
  'argumentoyle'
]

SPELLS = [
  "Mormyshka's Blisters",
  "Annihilate Nose Hair",
  "Edmundus' Flagrant Aspergellation",
  "Retawesorkram's Tricky Surprise",
  "Flaming Carrot",
  "Ethereal Sweden",
  "Greydy's Clever Tax Evasion",
  "Reynard's Iron Stove",
  "Jaegermaister's Fine Abjuration",
  "Protection from Cramps",
  "Banish Bureaucracy",
  "Summon Lesser Lawyer",
  "Summon Greater Lawyer",
  "Dine Stop",
  "Horrid Whining",
  "Gassy Visage",
  "Transmute CMYK to RGB",
]

class Monster
  attr_accessor :name, :exp, :corpse, :weight
  def initialize(name, exp, corpse, weight)
    self.name = name; self.exp = exp;
    self.corpse = corpse; self.weight = weight
  end
end

# monster, xp, corpse, weight
$monsters = {
  "a goblin" =>
  Monster.new("a goblin", 1,
		 "newbieishly severed goblin head", 8),
  "a formaldehyde elemental" =>
  Monster.new("a formaldehyde elemental", 30,
	      "embalming fluid component", 10),
  "a lowland orc" =>
  Monster.new("a lowland orc", 10,
		 "assorted weapons", 20),
  "a potato assassin" =>
  Monster.new("a potato assassin", 30,
		 "a set of kitchen knifes", 20),
  "a coffee elemental" =>
  Monster.new("a coffee elemental", 30,
		 "an unwashed cup", 10),
  "a white-hatted kangaroo" =>
  Monster.new("a white-hatted kangaroo", 30,
		 "a pouched sombrero", 30),
  "an exploding cow" =>
  Monster.new("an exploding cow", 40,
	      "a ticking package", 25),
  "a vampire without a speech impediment" =>
  Monster.new("a vampire without a speech impediment", 120,
	      "shortened vampire fangs", 5),
  "a vampire without a noticeable accent" =>
  Monster.new("a vampire withot a noticeable accent", 200,
	      "a well-thumbed dictionary", 5),
  "an enchanted Wartburg" =>
  Monster.new("an enchanted Wartburg", 200,
	      "a possessed gearbox", 200),
  "a nasty forum troll" =>
  Monster.new("a nasty forum troll", 300,
	      "a broken reply button", 30),

}

WEAPONS = 
  ["sword", "dagger", "spear", "mooring hook", "trident", "pencil",
  "pea shooter", "greatsword", "axe", "battle axe", "glaive",
  "halberd", "katana", "scimitar" ]
MATERIALS =
  ["ivory", "leather", "plastic", "gold", "crystal", "mithril",
  "ruby", "ruby", "steel", "iron", "diamond", "wool", "hickory",
  "ashwood", "balsa", "oak", "bamboo"]


#######################################################################

class Player
  attr_accessor :name
  attr_accessor :race

  attr_accessor :profession

  attr_accessor :strength,:dexterity,:guts,:intelligence,:charm

  attr_accessor :weapon,:armor

  attr_accessor :spells
  attr_accessor :possessions

  attr_accessor :exp, :gold, :chapter, :quests_completed
  attr_accessor :location

  attr_accessor :current_progress, :current_activity, :current_enemy

  def level
    return (Math.sqrt(exp)/Math.sqrt(1234)).floor + 1
  end
  def to_next_level
    return ((level) ** 2 * 1234) - exp
  end
  def carrying_capacity
    return strength * 12
  end
  def loot_weight
    n = 0
    possessions.each do |p|
      n = n + p.weight
    end
    return n
  end
  def carrying_too_much?
    loot_weight > carrying_capacity
  end

  def print_character_sheet
    print_line
    puts "Character sheet for #{self.name}"
    print_stats
    puts "  Level #{self.level}, XP #{self.exp}, #{self.to_next_level} to the next level"
    print_line
    print_possessions
    print_line
  end
  def print_stats
    print_line
    puts "Strength:\t#{self.strength}"
    puts "Dexterity:\t#{self.dexterity}"
    puts "Guts:\t\t#{self.guts}"
    puts "Intelligence:\t#{self.intelligence}"
    puts "Charm:\t\t#{self.charm}"
    print_line
  end
  def print_possessions
    knap = self.possessions.collect {|i| i.corpse}
    kit = {}
    knap.each do |k|
      if kit.has_key?(k)
	kit[k] = kit[k] + 1
      else
	kit[k] = 1
      end
    end
    sorted_knap = kit.sort {|a,b| a[1]<=>b[1]}.reverse.collect { |i| "#{i[1]} x #{i[0]}" }
    
    puts "Items in knapsack:\n\t" + sorted_knap.join("\n\t")
  end

  def re_equip
    self.weapon =
      MATERIALS[rand(MATERIALS.length)] + " " +
      WEAPONS[rand(WEAPONS.length)] + " " +sprintf("%+1d",(level/3-2+rand(3)))
    self.armor =
      MATERIALS[rand(MATERIALS.length)] + " " +
      'plate' + " " +sprintf("%+1d",(level/3-2+rand(4)))
  end

  def addxp(amt)
    oldlevel = self.level
	
    self.exp = self.exp + amt
    if self.level > oldlevel
      puts "You gained one level!"
      # Increase one stat
      case rand(5)
      when 0 then 
	self.strenght = self.strength + 1
	puts "Your muscles tremble with new power."
      when 1 then
	self.dexterity = self.dexterity + 1
	puts "Your joints are nimbler."
      when 2 then
	self.guts = self.guts + 1
	puts "You feel you can survive anything now." 
      when 3 then
	self.intelligence = self.intelligence + 1
	puts "Your mind is dizzying with new possibilities." 
      when 4 then
	self.charm = self.charm + 1
	puts "You feel more confident and your hair looks better."
      else
	die "Well, that was weird. Odd stat?"
      end

      if(self.spells.keys.length >= SPELLS.length or rand(100) < 50)
	# Increase level of an existing spell
	oldspell = self.spells.keys[rand(self.spells.keys.length)]
	self.spells[oldspell] = self.spells[oldspell] + 1
	puts "Gained a new skill level in spell #{oldspell}."
      else
	# A whole new spell
	newspell = SPELLS[rand(SPELLS.length)]
	while self.spells.exists(newspell)
	  newspell = SPELLS[rand(SPELLS.length)]
	end
	self.spells[newspell] = 1
	puts "Learned a new spell #{newspell}."
      end
    end
  end
end


#######################################################################

def ask_filename
  print "Enter savegame file name: "
  return gets.chomp
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

def print_line
  puts "-" * 70
end

def new_game
  $player = Player.new
  print "Enter player name: "
  $player.name = gets.chomp

  $player.race =
    get_option(PLAYER_RACES,"Which race do you pick? ",
	       "That's a completely wrong number, my friend...")
  $player.profession =
    get_option(PLAYER_PROFESSIONS,"Which profession do you pick? ",
	       "I don't think that's really a valid option...")

  $player.exp = 0
  $player.gold = 0

  $player.location = 'prologue'
  $player.chapter = 1
  $player.quests_completed = []
  
  ok = false
  while not ok
    $player.strength = rand(16)+3
    $player.dexterity = rand(16)+3
    $player.guts = rand(16)+3
    $player.intelligence = rand(16)+3
    $player.charm = rand(16)+3

    $player.print_stats
    print "A)ccept or R)eroll? "
    response = gets.chomp
    if response == 'a' or response == 'A'
      ok = true
    end
  end

  $player.spells = { SPELLS[rand(SPELLS.length)] => 1 }

  $player.possessions = []

  $player.re_equip

  save_game(:interactive)

end

def printlist(list)
  puts
  i = 0
  list.each do |r|
    puts "#{i+1})\t#{r}"
    i = i + 1
  end
  puts
end

def get_option(list,prompt,errormsg)
  choice = nil
  while choice == nil
    printlist(list)
    print prompt
    c = gets.chomp.to_i - 1
    if c < 0 or c > list.length
      puts errormsg
      choice = nil
    else
      choice = list[c]
    end
  end
  return choice
end

def titlescreen
  puts "Miller's Quest!"
  puts "WWWWolf 2005"
end

def titlebar(title,letter)
  xlength = 70-title.length-2-(letter.length)*3
  if xlength > 0
    restbar = letter*xlength
  else
    restbar = ''
  end
  puts "#{letter*3} #{title} #{restbar}"
end

def progress(title,length)
  titlebar(title,'>')
  start_from = $player.current_progress
  if start_from.nil?
    start_from = 0
  end
  print "["
  $stdout.flush
  for i in 0..start_from
    print (i == 0 ? "" : ".")
    $stdout.flush
  end
  for i in (start_from+1)..(length-1)
    $player.current_progress = i
    print "#"
    $stdout.flush
    sleep 0.2
  end
  puts "]"
  $player.current_progress = 0
end

#######################################################################
# Main program

$player = nil

titlescreen
$filename = ARGV.pop
if $filename.nil?
  print "N)ew game, L)oad game, eX)it? "
  ans = nil
  while ans == nil
    ans = gets.chomp
    case ans
      when 'n', 'N' then new_game
      when 'l', 'L' then load_game(:interactive)
      when 'x', 'X' then exit(0)
      else ans = nil
    end
  end
else
  if(File.exists?($filename) and File.readable?($filename))
    load_game($filename)
  else
    puts "Cannot find or read #{$filename}, starting a new game"
    newgame
  end
end

begin
  while(true)
    if $player.location == 'prologue'
      titlebar("PROLOGUE",'*')
      progress("You - the lowly peasant miller - have incredible visions",20)
      progress("The local priest explains the significance of these things",40)
      progress("You sell the farm and dust off the family heirloom sword",30)
      progress("You head to the town to fullfill the prophecy and vanquish"+
	       " the evil",30)
      titlebar("CHAPTER 1",'*')
      $player.location = 'town'
      save_game($filename)
    elsif $player.location == 'town' 
      # Sell possessions
      while $player.possessions.length > 0
	p = $player.possessions.pop
	case rand(5)
	when 2 then sellverb = 'Getting a good price for'
	when 3 then sellverb = 'Mercilessly haggling up the price of'
	when 4 then sellverb = 'Trying to get a good price for'
	else sellverb = 'Selling'
	end
	progress("#{sellverb} #{p.corpse}",5)
	newgold = rand(p.weight * 2 + 1)
	puts "Got #{newgold} gp for that"
	$player.gold = $player.gold + newgold
      end
      progress("Getting some new equipment while we're at it",20)
      $player.re_equip
      cost = (rand($player.gold)/3).to_i
      $player.gold = $player.gold - cost
      puts("got a #{$player.weapon} and a #{$player.armor} for #{cost}!")
      case rand(3)
      when 0 then progress("Heading to the nearby bushes",10)
      when 1 then progress("The bloody fields do call you!",20)
      when 2 then progress("Taking a few steps out of town to find monsters",5)
      end
      $player.location = 'killingfields'
    elsif $player.location == 'killingfields'
      while not $player.carrying_too_much?
	if $player.current_enemy.nil?
	  monster = $monsters.keys[rand($monsters.keys.length)]
	  $player.current_enemy = $monsters[monster].dup
	else
	  monster = $player.current_enemy.name
	end
	progress("Killing #{monster}",40)
	drop = $player.current_enemy
	$player.current_enemy = nil
	puts "Got #{drop.exp} exp. #{$player.to_next_level} to next level."
	$player.addxp(drop.exp)
	$player.possessions.push(drop)
	puts "Currently carrying #{$player.loot_weight}/#{$player.carrying_capacity}"
      end
      progress("Dragging monster carcasses to the town",20)
      $player.location = 'town'
    end
    
  end
rescue Interrupt
  puts
  puts "Game interrupted."
  save_game($filename)
end
