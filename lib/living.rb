
class LivingThing
  attr_accessor :name
  attr_accessor :strength, :dexterity, :guts, :intelligence, :charm
  attr_accessor :hp, :maxhp
  attr_accessor :description
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
  end
end

class Monster < LivingThing
  attr_accessor :exp, :corpse, :weight, :hitdie
  def prepare_for_battle
    add_hitdie(@hitdie)
    heal
  end
end

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

    self.gold = 200 + (rand(100)-50)
    self.re_equip
    self.add_hitdie(1)
    self.heal
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
    self.weapon = Weapon.find_good_for_cost(self.gold/2,$weapons)
    self.gold = self.gold - self.weapon.cost
    self.armor = Armor.find_good_for_cost(self.gold,$armors)
    self.gold = self.gold - self.armor.cost
  end

  def addxp(amt)
    oldlevel = self.level
	
    @exp = @exp + amt
    if self.level > oldlevel
      for l in 1..(self.level - oldlevel)
	puts "You gained a level!"
	self.add_hitdie(1)
	puts "Max HP increased to #{@maxhp}!"
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

