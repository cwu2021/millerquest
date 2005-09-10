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
end

# monster, xp, corpse, weight
$monsters = YAML::load(<<MONSTERS)
--- 
an exploding cow: !ruby/object:Monster 
  name: an exploding cow
  corpse: a ticking package
  exp: 40
  weight: 25
a coffee elemental: !ruby/object:Monster 
  name: a coffee elemental
  corpse: an unwashed cup
  exp: 30
  weight: 10
a lowland orc: !ruby/object:Monster 
  name: a lowland orc
  corpse: assorted weapons
  exp: 10
  weight: 20
a formaldehyde elemental: !ruby/object:Monster 
  name: a formaldehyde elemental
  corpse: embalming fluid component
  exp: 30
  weight: 10
a nasty forum troll: !ruby/object:Monster 
  name: a nasty forum troll
  corpse: a broken reply button
  exp: 300
  weight: 30
a potato assassin: !ruby/object:Monster 
  name: a potato assassin
  corpse: a set of kitchen knifes
  exp: 30
  weight: 20
a goblin: !ruby/object:Monster 
  name: a goblin
  corpse: newbieishly severed goblin head
  exp: 1
  weight: 8
a white-hatted kangaroo: !ruby/object:Monster 
  name: a white-hatted kangaroo
  corpse: a pouched sombrero
  exp: 30
  weight: 30
a vampire without a speech impediment: !ruby/object:Monster 
  name: a vampire without a speech impediment
  corpse: shortened vampire fangs
  exp: 120
  weight: 5
an enchanted Wartburg: !ruby/object:Monster 
  name: an enchanted Wartburg
  corpse: a possessed gearbox
  exp: 200
  weight: 200
a vampire without a noticeable accent: !ruby/object:Monster 
  name: a vampire withot a noticeable accent
  corpse: a well-thumbed dictionary
  exp: 200
  weight: 5
a group of smelly critters: !ruby/object:Monster 
  name: a group of smelly critters
  corpse: pungent hides
  exp: 130
  weight: 30
a zombie: !ruby/object:Monster 
  name: a zombie
  corpse: twice-killed pieces
  exp: 80
  weight: 10
a scrap metal golem: !ruby/object:Monster 
  name: a scrap metal golem
  corpse: a collection of forgotten faucets
  exp: 100
  weight: 100
a zombie-summoning shaman: !ruby/object:Monster 
  name: a zombie-summoning shaman
  corpse: a painted rattler and a whole bunch of twice-killed pieces
  exp: 180
  weight: 30
MONSTERS


WEAPONS = 
  ["sword", "dagger", "spear", "mooring hook", "trident", "pencil",
  "pea shooter", "greatsword", "axe", "battle axe", "glaive",
  "halberd", "katana", "scimitar" ]
MATERIALS =
  ["ivory", "leather", "plastic", "gold", "crystal", "mithril",
  "ruby", "ruby", "steel", "iron", "diamond", "wool", "hickory",
  "ashwood", "balsa", "oak", "bamboo"]
ARMORS =
  ["plate", "mail", "suit"]


# Bad places courtesy of AutoREALM's generator (the Rager port)
PLACES = [
  "Mountain of Wailing Doom",
  "Xos's Pass",
  "Temple of Clamorous Chaos",
  "Mox's Tunnel of Scented Blasphemy",
  "Village of Gushing Alliances",
  "Den of Blue Chaos",
  "Lands of White Dread",
  "Crypt of Murac's Beholders",
  "Crater of Yellow Horror",
  "The Keeper's Village",
  "Hiding Place of Sidina's Creeps",
  "The Beekeeper's Den",
  "The Chamber of Porase's Beasts",
  "The Troll's Disappointment",
]
ITEMS = [
  "sack of gold", "newspaper", "legendary sword", "busted shield",
  "bottle of mouthwash", "toothpick", "rotten boots", "pencil",
  "jar of salsa sauce", "telescope", "mysterious crystal"
]

#######################################################################

class Array
  def random_item
    return self[rand(self.length)]
  end
end

class Hash
  def random_item
    return self[random_key]
  end
  def random_key
    return self.keys[rand(self.keys.length)]
  end
end


class Player
  attr_accessor :name
  attr_accessor :gender
  attr_accessor :race

  attr_accessor :profession

  attr_accessor :strength,:dexterity,:guts,:intelligence,:charm

  attr_accessor :weapon,:armor

  attr_accessor :spells
  attr_accessor :possessions

  attr_reader :exp
  attr_accessor :gold, :chapter, :quests_completed
  attr_accessor :location

  attr_accessor :current_progress, :current_enemy

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
    print_quests
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
    sorted_knap = kit.sort {|a,b|
      a[1]<=>b[1]}.reverse.collect { |i|
      "#{i[1]} x #{i[0]}" 
    }
    puts "Items in knapsack:\n\t" + sorted_knap.join("\n\t")
  end
  def print_quests
    puts "Current chapter: #{self.chapter}"
    puts "Quests in this chapter:"
    self.quests_completed.each do |q|
      puts "\t#{q.description}"
    end
  end

  def re_equip
    self.weapon =
      MATERIALS.random_item + " " +
      WEAPONS.random_item + " " +sprintf("%+1d",(level/3-2+rand(3)))
    self.armor =
      MATERIALS.random_item + " " +
      ARMORS.random_item + " " +sprintf("%+1d",(level/3-2+rand(4)))
  end

  def addxp(amt)
    oldlevel = self.level
	
    @exp = @exp + amt
    if self.level > oldlevel
      for l in 1..(self.level - oldlevel)
	puts "You gained a level!"
	# Increase one stat
	case rand(5)
	when 0 then 
	  self.strength = self.strength + 1
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
	  oldspell = self.spells.random_key
	  self.spells[oldspell] = self.spells[oldspell] + 1
	  puts "Gained a new skill level in spell #{oldspell}."
	else
	  # A whole new spell
	  newspell = SPELLS.random_item
	  while self.spells.has_key?(newspell)
	    newspell = SPELLS.random_item
	  end
	  self.spells[newspell] = 1
	  puts "Learned a new spell #{newspell}."
	end
      end
    end
  end

  def munchkinify
    if self.strength < 10 then self.strength = 10 end
    if self.dexterity < 10 then self.dexterity = 10 end
    if self.guts < 10 then self.guts = 10 end
    if self.intelligence < 10 then self.intelligence = 10 end
    if self.charm < 10 then self.charm = 10 end
  end

end

class Quest
  attr_reader :description
  def initialize
    item = ITEMS.random_item
    place = PLACES.random_item
    monster = $monsters.random_item.name
    case rand(5)
    when 0 then @description = "find a #{item} from #{place}"
    when 1 then @description = "search the #{place} for #{item}"
    when 2 then @description = "locate a #{item}"
    when 3 then @description = "wipe out #{monster} in #{place}"
    when 4 then @description = "destroy #{monster}"
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
    print "A)ccept, R)eroll, M)unchkin? "
    response = gets.chomp
    case response
      when 'a', 'A' then ok = true
      when 'r', 'R' then ok = false
      when 'm', 'M' then $player.munchkinify; ok = true      
    end
  end

  $player.spells = { SPELLS.random_item => 1 }

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
  puts DATA.readlines
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
      # Get new equipment
      progress("Getting some new equipment while we're at it",20)
      $player.re_equip
      cost = (rand($player.gold)/3).to_i
      $player.gold = $player.gold - cost
      puts("Got a #{$player.weapon} and a #{$player.armor} for #{cost} gp!")
      # A quest?
      if $player.quests_completed.length <= 10 and rand(10) < 5
	if $player.quests_completed.length > 0
	  lastquest = $player.quests_completed.last
	  puts "You have completed the quest to #{lastquest.description}!"
	end
	quest = Quest.new
	$player.quests_completed.push(quest)
	puts "You have a new quest: #{quest.description}!"
      end
      if $player.quests_completed.length > 10 and rand(10) < 2
	$player.quests_completed = []
	$player.chapter = $player.chapter + 1
	puts "You have completed all quests in this chapter!"
	titlebar("CHAPTER #{$player.chapter}",'*')	
      end

      # Head to the fields
      case rand(3)
      when 0 then progress("Heading to the nearby bushes",10)
      when 1 then progress("The bloody fields do call you!",20)
      when 2 then progress("Taking a few steps out of town to find monsters",5)
      end
      $player.location = 'killingfields'
    elsif $player.location == 'killingfields'
      while not $player.carrying_too_much?
	if $player.current_enemy.nil?
	  monster = $monsters.random_key
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
	puts "Currently carrying " +
	  "#{$player.loot_weight}/#{$player.carrying_capacity}"
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

__END__
                                                <>
                  /\\,/\\,    ,, ,,              )      
                 /| || ||   ' || ||                              logo made
                 || || ||  \\ || ||  _-_  ,._-_    _-_,        with Figlet
                 ||=|= ||  || || || || \\  ||     ||_.  
                ~|| || ||  || || || ||/    ||      ~ || 
                 |, \\,\\, \\ \\ \\ \\,/   \\,    ,-_-  
                _-   __                               
                   ,-||-,                       ,  /\ 
                  ('|||  )                     ||  \/ 
                 (( |||--)) \\ \\  _-_   _-_, =||= }{ 
                 (( |||--)) || || || \\ ||_.   ||  \/ 
                  ( / |  )  || || ||/    ~ ||  ||     
                   -____-\\ \\/\\ \\,/  ,-_-   \\, <> 
                                                          
                                                          
                           MILLER'S QUEST!
                     (c) Urpo Lankinen sep-2005
                    A Weyfour WWWWolf production
                    Distributed under GNU GPL v2
              Inspired by "Progress Quest" by Grumdrig

