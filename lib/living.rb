# $Id: living.rb 25 2005-10-26 22:14:56Z wwwwolf $
# Code that represents monsters, players and loot.
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

# All sorts of trinket that is sold as a loot.
class Trinket
  attr_accessor :name
  attr_accessor :weight
  attr_accessor :cost
  def initialize(name,weight,cost)
    @name = name
    @weight = weight
    @cost = cost
  end
  def to_s
    return @name
  end
end

# Living thingies.
class LivingThing
  attr_accessor :name
  attr_accessor :strength, :dexterity, :guts, :intelligence, :charm
  attr_accessor :hp, :maxhp
  attr_accessor :description
  def to_s
    @name
  end
  def damage(points)
    @hp = @hp - points
  end
  def heal
    @hp = @maxhp
  end
  def add_hitdie(n)
    (1..n).each do |i|
      if @maxhp.nil? then
	@maxhp = 0
      end
      @maxhp = @maxhp + rand(guts) + 1
    end
    heal
  end
end

# A monster.
class Monster < LivingThing
  attr_accessor :exp, :corpse, :weight, :hitdie, :weapon, :armor
  # Makes sure the monster is fit to fight the player.
  def prepare_for_battle
    add_hitdie(@hitdie)
    heal
  end
  # Get all of the nice stuff you get when you kill a monster. Returns an Array of Trinket.
  def loot
    # The monster's corpse
    loot = [ Trinket.new(@corpse,@weight,@weight*2+1) ]
    # TODO: Add other random trinket to the list, like how rats usually carry gold and stuff.
    return loot
  end
end

# Player.
class Player < LivingThing
  attr_accessor :gender
  attr_accessor :race

  attr_accessor :profession

  attr_accessor :weapon, :armor

  attr_accessor :spells
  attr_accessor :possessions

  attr_reader :exp
  attr_accessor :gold, :chapter, :quests_completed
  attr_accessor :location

  attr_accessor :current_task

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

    self.gold = 200 + (rand(100)-50)
    self.re_equip
    self.add_hitdie(1)
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
    puts "  HP: #{@hp}/#{@maxhp}"
    puts "  Gold: #{gold}"
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
    knap = self.possessions.collect {|i| i.name}
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
    # FIXME: May be buggy.
    g = @gold
    unless @weapon.nil?
      @gold = @gold + @weapon.resale_value
      resale_value = @weapon.resale_value
      msg = "Your #{@weapon} is out of fashion. Time to sell it."
      @weapon = nil
      Display.sell(msg,resale_value)
    end 
    unless @armor.nil?
      @gold = @gold + @armor.resale_value
      resale_value = @armor.resale_value
      msg = "Your #{@armor} is getting rusty. Time to sell it."
      @armor = nil
      Display.sell(msg,resale_value)
    end

    # Get a new weapon and an armor
    neqcost = 0
    w = Weapon.find_good_for_cost(@gold/2,$weapons)
    if w.cost <= @gold
      @weapon = w
      @gold = @gold - w.cost
      neqcost = neqcost + w.cost
      msg = "Got my eye on that #{w}"
      Display.buy(msg,w.cost)
    end
    a = Armor.find_good_for_cost(@gold,$armors)
    if a.cost <= @gold
      @armor = a
      @gold = @gold - a.cost
      neqcost = neqcost + a.cost
      msg = "Buying a hot new #{a}"
      Display.buy(msg,w.cost)
    end
  end

  def addxp(amt)
    oldlevel = self.level
	
    @exp = @exp + amt
    if self.level > oldlevel
      for l in 1..(self.level - oldlevel)
	self.add_hitdie(1)
##	puts "You gained a level!"
##	puts "Max HP increased to #{@maxhp}!"
	# Increase one stat
	case rand(5)
	when 0 then 
	  self.strength = self.strength + 1
	  msg = "Your muscles tremble with new power."
	when 1 then
	  self.dexterity = self.dexterity + 1
	  msg = "Your joints are nimbler."
	when 2 then
	  self.guts = self.guts + 1
	  msg = "You feel you can survive anything now." 
	when 3 then
	  self.intelligence = self.intelligence + 1
	  msg = "Your mind is dizzying with new possibilities." 
	when 4 then
	  self.charm = self.charm + 1
	  msg = "You feel more confident and your hair looks better."
	else
	  die "Well, that was weird. Odd stat?"
	end

	if(self.spells.keys.length >= $spells.length or rand(100) < 50)
	  # Increase level of an existing spell
	  oldspell = self.spells.random_key
	  self.spells[oldspell].addlevel
	  spell_msg = "Gained a new skill level in spell #{oldspell}."
	else
	  # A whole new spell
	  newspell = $spells.random_item
	  while self.spells.has_key?(newspell)
	    newspell = $spells.random_item
	  end
	  self.spells[newspell] = MemorizedSpell.new_named(newspell)
	  spell_msg = "Learned a new spell #{newspell}."
	end
        Display.gain_level(msg,spell_msg)
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
