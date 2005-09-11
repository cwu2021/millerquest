#!/usr/bin/ruby
# $Id$
#######################################################################
#
# Miller's Quest!
#
# Written by WWWWolf
# Logo made with Figlet
# Thanks for the idea to Grumdrig
# with all respect to why :)
#
#######################################################################


require 'yaml'
require 'yaml/store'

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

#######################################################################

class LivingThing
  attr_accessor :strength, :dexterity, :guts, :intelligence, :charm
  attr_accessor :hp, :maxhp
  attr_accessor :description
  def damage(points)
    @hp = @hp - points
  end
end

class Monster < LivingThing
  attr_accessor :name, :exp, :corpse, :weight
end

class Player < LivingThing
  attr_accessor :name
  attr_accessor :gender
  attr_accessor :race

  attr_accessor :profession

  attr_accessor :weapon, :armor

  attr_accessor :spells
  attr_accessor :possessions

  attr_reader :exp
  attr_accessor :gold, :chapter, :quests_completed
  attr_accessor :location

  attr_accessor :current_progress, :current_enemy

  def initialize
    @gold = 0
    @exp = 0

    @location = 'prologue'
    @chapter = 1
    @quests_completed = []

    @possessions = []
    @spells = {}
  end

  def setup_for_new_game
    print "Enter player name: "
    @name = gets.chomp

    ok = false
    while not ok
      print "Art thou M)ale or F)emale? "
      gender = gets.chomp
      case gender
      when 'm', 'M' then gender = 'male'; ok = true
      when 'f', 'F' then gender = 'female'; ok = true
      end
    end
    @gender = gender

    @race =
      get_option($player_races,"Which race do you pick? ",
		 "That's a completely wrong number, my friend...")
    @profession =
      get_option($player_professions,"Which profession do you pick? ",
		 "I don't think that's really a valid option...")

    
    ok = false
    while not ok
      @strength = rand(16)+3
      @dexterity = rand(16)+3
      @guts = rand(16)+3
      @intelligence = rand(16)+3
      @charm = rand(16)+3

      self.print_stats
      print "A)ccept, R)eroll, M)unchkin? "
      response = gets.chomp
      case response
      when 'a', 'A' then ok = true
      when 'r', 'R' then ok = false
      when 'm', 'M' then self.munchkinify; ok = true      
      else puts "Uh, no idea what you meant, rerolling anyway"
      end
    end

    spell = MemorizedSpell.new_random
    @spells[spell.name] = spell

    self.re_equip
  end

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
    puts "Character sheet for #{@name}, a #{@gender} #{@race} #{@profession}"
    print_stats
    puts "  Level #{level}, XP #{@exp}, #{to_next_level} to the next level"
    print_line
    print_spells
    print_line
    print_possessions
    print_line
    print_quests
    print_line
  end
  def print_stats
    print_line
    puts "Strength:\t#{@strength}"
    puts "Dexterity:\t#{@dexterity}"
    puts "Guts:\t\t#{@guts}"
    puts "Intelligence:\t#{@intelligence}"
    puts "Charm:\t\t#{@charm}"
    print_line
  end
  def print_spells
    puts "Known spells:"
    self.spells.keys.sort.each do |s|
      puts "\t#{self.spells[s].to_s}"
    end
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
    puts "Weapon:\t#{@weapon}"
    puts "Armor:\t#{@armor}"
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
      $materials.random_item + " " +
      $weapons.random_item + " " +sprintf("%+1d",(level/3-2+rand(3)))
    self.armor =
      $materials.random_item + " " +
      $armors.random_item + " " +sprintf("%+1d",(level/3-2+rand(4)))
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

	if(self.spells.keys.length >= $spells.length or rand(100) < 50)
	  # Increase level of an existing spell
	  oldspell = self.spells.random_key
	  self.spells[oldspell].addlevel
	  puts "Gained a new skill level in spell #{oldspell}."
	else
	  # A whole new spell
	  newspell = $spells.random_item
	  while self.spells.has_key?(newspell)
	    newspell = $spells.random_item
	  end
	  self.spells[newspell] = MemorizedSpell.new_named(newspell)
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
    item = $items.random_item
    place = $places.random_item
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

class MemorizedSpell
  attr_accessor :name, :level

  def addlevel
    @level = @level + 1
  end
  def to_s
    "#{@name} #{@level}"
  end
  def MemorizedSpell.new_random
    a = MemorizedSpell.new
    a.name = $spells.random_item
    a.level = 1
    return a
  end
  def MemorizedSpell.new_named(name)
    a = MemorizedSpell.new
    a.name = name
    a.level = 1
    return a
  end
end

#######################################################################

def load_array_from_data_delimited(delim)
  start_delim = delim + '_BEGIN'
  end_delim = delim + '_END'
  content = []
  line = ''
  while line != start_delim
    line = DATA.readline.chomp
  end
  while line != end_delim
    line = DATA.readline.chomp
    if line != end_delim
      content.push(line)
    end
  end
  DATA.rewind
  return content
end

def load_string_from_data_delimited(delim)
  load_array_from_data_delimited(delim).join("\n")
end

def load_yaml_from_data_delimited(delim)
  YAML::load(load_string_from_data_delimited(delim))
end

def load_game_data
  $title_screen = load_string_from_data_delimited('TITLE')
  $monsters = load_yaml_from_data_delimited('MONSTER')

  $player_professions = load_array_from_data_delimited('PLAYER_PROFESSIONS')
  $player_races = load_array_from_data_delimited('PLAYER_RACES')
  $spells = load_array_from_data_delimited('SPELLS')
  $places = load_array_from_data_delimited('PLACES')
  $items = load_array_from_data_delimited('ITEMS')
  $weapons = load_array_from_data_delimited('WEAPONS')
  $materials = load_array_from_data_delimited('MATERIALS')
  $armors = load_array_from_data_delimited('ARMORS')
end

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
  $player.setup_for_new_game
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
  puts $title_screen
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

load_game_data

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
    new_game
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
      elsif $player.quests_completed.length > 10 and rand(10) < 2
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
      save_game($filename)
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
	$player.addxp(drop.exp)
	puts "Got #{drop.exp} exp. #{$player.to_next_level} to next level."
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
  puts "Character sheet at the end of the session:"
  $player.print_character_sheet
  save_game($filename)
end


__END__

The game data follows.

TITLE_BEGIN

                                                <>
                  /\\,/\\,    ,, ,,              )      
                 /| || ||   ' || ||
                 || || ||  \\ || ||  _-_  ,._-_    _-_,
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


TITLE_END

MONSTER_BEGIN
--- 
an exploding cow: !ruby/object:Monster 
  name: an exploding cow
  corpse: a ticking package
  strength: 16
  dexterity: 12
  guts: 10
  intelligence: 2
  charm: 2
  exp: 40
  weight: 25
  description: "Black-spotted thing of terror. Very persuasive."
a coffee elemental: !ruby/object:Monster 
  name: a coffee elemental
  corpse: an unwashed cup
  strength: 10
  dexterity: 15
  guts: 7
  intelligence: 18
  charm: 10
  exp: 30
  weight: 10
  description: "Known to keep players on toes."
a lowland orc: !ruby/object:Monster 
  name: a lowland orc
  corpse: assorted weapons
  strength: 18
  dexterity: 13
  guts: 12
  intelligence: 8
  charm: 6
  exp: 10
  weight: 20
  description: "A large green humanoid, smarter and more fierce than average goblin."
a formaldehyde elemental: !ruby/object:Monster 
  name: a formaldehyde elemental
  corpse: embalming fluid component
  strength: 12
  dexterity: 8
  guts: 14
  intelligence: 0
  charm: 4
  exp: 30
  weight: 10
  description: "A repugnant blue cloud."
a nasty forum troll: !ruby/object:Monster 
  name: a nasty forum troll
  corpse: a broken reply button
  strength: 5
  dexterity: 6
  guts: 15
  intelligence: 18
  charm: 4
  exp: 300
  weight: 30
  description: "A huge, warty, green-skinned thing not blessed with intellect."
a potato assassin: !ruby/object:Monster 
  name: a potato assassin
  corpse: a set of kitchen knifes
  strength: 10
  dexterity: 22
  guts: 10
  intelligence: 19
  charm: 17
  exp: 30
  weight: 20
  description: "No spud feels safe when these people are afoot."
a goblin: !ruby/object:Monster 
  name: a goblin
  corpse: newbieishly severed goblin head
  strength: 6
  dexterity: 10
  guts: 4
  intelligence: 1
  charm: 1
  exp: 1
  weight: 8
  description: "These things infest many a first floor of newbie dungeons."
a white-hatted kangaroo: !ruby/object:Monster 
  name: a white-hatted kangaroo
  corpse: a pouched sombrero
  strength: 16
  dexterity: 12
  guts: 14
  intelligence: 12
  charm: 6
  exp: 30
  weight: 30
  description: "Nobody knows what these things do. They look mysterious."
a vampire without a speech impediment: !ruby/object:Monster 
  name: a vampire without a speech impediment
  corpse: shortened vampire fangs
  strength: 10
  dexterity: 12
  guts: 10
  intelligence: 12
  charm: 18
  exp: 120
  weight: 5
  description: "A rare creature that seems to suffer from not having enough blood."
an enchanted Wartburg: !ruby/object:Monster 
  name: an enchanted Wartburg
  corpse: a possessed gearbox
  strength: 18
  dexterity: 6
  guts: 14
  intelligence: 7
  charm: 2
  exp: 200
  weight: 200
  description: "A four-wheeled, self-moving cart, with words 'pickled cucumbers' emblazoned on its side, and a nasty look on its 'face'."
a vampire without a noticeable accent: !ruby/object:Monster 
  name: a vampire without a noticeable accent
  corpse: a well-thumbed dictionary
  strength: 10
  dexterity: 12
  guts: 10
  intelligence: 14
  charm: 19
  exp: 200
  weight: 5
  description: "A creature of night that clearly seems to have no noble lineage whatsoever."
a group of smelly critters: !ruby/object:Monster 
  name: a group of smelly critters
  corpse: pungent hides
  strength: 13
  dexterity: 18
  guts: 10
  intelligence: 7
  charm: 2
  exp: 130
  weight: 30
  description: "While lacking in strength, their strength lies in sheer numbers and their persuasive smell."
a zombie: !ruby/object:Monster 
  name: a zombie
  corpse: twice-killed pieces
  strength: 15
  dexterity: 3
  guts: 8
  intelligence: 0
  charm: 0
  exp: 80
  weight: 10
  description: "This former person seems to wander about, looking for brains."
a scrap metal golem: !ruby/object:Monster 
  name: a scrap metal golem
  corpse: a collection of forgotten faucets
  strength: 20
  dexterity: 4
  guts: 18
  intelligence: 0
  charm: 0
  exp: 100
  weight: 100
  description: "A mysterious creature with a trashcan head and arms of drain pipe."
a zombie-summoning shaman: !ruby/object:Monster 
  name: a zombie-summoning shaman
  corpse: a painted rattler and a whole bunch of twice-killed pieces
  strength: 10
  dexterity: 12
  guts: 6
  intelligence: 17
  charm: 16
  exp: 180
  weight: 30
  description: "This person seems to do some voodoo stuff to summon a lot of zombies."


MONSTER_END

PLAYER_PROFESSIONS_BEGIN
arborian
armchair strategist
blade-thrust diplomat
bungie cord wizard
divinity abstractifier
orator paladin
professional cookie cutter
rogue of Hague
soccerer
PLAYER_PROFESSIONS_END

PLAYER_RACES_BEGIN
man-ant
giggling hyenoid
out-of-focus elf
flute-music-backed elf
alliterative worminator
dragon-trout
wobblit
animated broom
argumentoyle
PLAYER_RACES_END

SPELLS_BEGIN
Annihilate Nose Hair
Banish Bureaucracy
Dine Stop
Edmundus' Flagrant Aspergellation
Ethereal Sweden
Flaming Carrot
Gassy Visage
Greydy's Clever Tax Evasion
Horrid Whining
Jaegermaister's Fine Abjuration
Mormyshka's Blisters
Protection from Cramps
Retawesorkram's Tricky Surprise
Reynard's Iron Stove
Summon Greater Lawyer
Summon Lesser Lawyer
Transmute CMYK to RGB
SPELLS_END


Bad places courtesy of AutoREALM's generator (the Rager port)

PLACES_BEGIN
Crater of Yellow Horror
Crypt of Murac's Beholders
Den of Blue Chaos
Hiding Place of Sidina's Creeps
Lands of White Dread
Mountain of Wailing Doom
Mox's Tunnel of Scented Blasphemy
Temple of Clamorous Chaos
The Beekeeper's Den
The Chamber of Porase's Beasts
The Keeper's Village
The Troll's Disappointment
Village of Gushing Alliances
Xos's Pass
PLACES_END

ITEMS_BEGIN
bottle of mouthwash
busted shield
jar of salsa sauce
legendary sword
mysterious crystal
newspaper
pencil
rotten boots
sack of gold
telescope
toothpick
ITEMS_END

WEAPONS_BEGIN
axe
battle axe
dagger
glaive
greatsword
halberd
katana
mooring hook
pea shooter
pencil
scimitar
spear
sword
trident
WEAPONS_END

MATERIALS_BEGIN
ashwood
balsa
bamboo
crystal
diamond
gold
hickory
iron
ivory
leather
mithril
oak
plastic
ruby
ruby
steel
wool
MATERIALS_END

ARMORS_BEGIN
mail
plate
suit
ARMORS_END

