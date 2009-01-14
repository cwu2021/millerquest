# The combat system.
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

# This thing will fight a nasty monster.
class FightTask < Task
  # The monster we're fighting currently.
  attr_accessor :monster
  private
    # This will make the fight happen. This method will directly update the victim's
    # HP, and will return one of the following:
    # * If missed: :miss
    # * If hit: :hit, :fatal (fatal hit), :critical (non-fatal critical),
    #   :critical_fatal
  def resolve_attack(attacker,defender)
    awb = attacker.weapon.total_bonus
    astr = attacker.strength
    dwb = defender.weapon.total_bonus
    adex = attacker.dexterity
    ddex = defender.dexterity
    
    # Hit? Dexterity-based comparison and some freak luck too.
    if ((adex/ddex) * rand(20) < 15)
      # Should miss.
      if rand(20) <= 1
        # Beginner's luck...
        miss = false
      else
        # The dice have no mercy.
        miss = true
      end
    end
    if miss == true
      return [:miss, 0]
    end
    
    # Okay, we hit. For how much?
    dmg = rand(astr) + awb
    
    # critical hit?
    critical = false
    if rand(20) >= 19-(awb/2)
      critical = true
      dmg = dmg * 2
    end
    
    defender.hp = defender.hp - dmg
    if defender.hp <= 0
      return [(critical ? :critical_fatal : :fatal), dmg]
    else
      return [(critical ? :critical : :hit), dmg]
    end
  end
  
  public
  def initialize
    # General administrativia
    super()
    @length_of_progress = nil
    
    # A nasty monster, is it not?
    m = $monsters.random_key
    @monster = $monsters[m].dup
    @monster.prepare_for_battle
    
    # Tell the world that we're killing that thing!
    @quiet = 1
    Display.begin_fight("Killing #{m}")
    @title = "Killing #{m}"
    
    # Whose turn it is to attack?
    case rand(2)
    when 0 then
      @attack_turn = :player
    when 1 then
      @attack_turn = :monster
    end
  end
  
  # Plays one round of combat. Will return true or false depending if the last hit
  # was fatal.
  def advance_task
    Display.begin_fight_round(@attack_turn == :player)
    
    super() # Increment counter and shit
    
    if @attack_turn == :player
      r = resolve_attack($player,@monster)
    elsif @attack_turn == :monster
      r = resolve_attack(@monster,$player)
    end
    result = true
    Display.attack_message(@attack_turn == :player,r)
    case r[0]
    when :miss then
      ## Display.shady_dots
    when :hit then
      ## hit_message(false)
      ## $stdout.flush
      ## Display.shady_dots 
    when :critical then
      ## hit_message(true)
      ## $stdout.flush
      ## Display.shady_dots 
    when :fatal then
      ## death_scream
      @complete = true
      result = false
    when :critical_fatal then
      ## puts "<WHA-BOOM! What a hit!>"
      ## death_scream
      @complete = true
      result = false
    end
##    $stdout.flush
    if not @complete
      if @attack_turn == :player
        @attack_turn = :monster
      else
        @attack_turn = :player
      end
    end
    return result
  end
  
  # Returns who won - true if player, false if monster.
  def player_won?
    if @attack_turn == :player
      return true
    end
    return false
  end
end

# class HealingTask < PlotTask
#   def initialize
#     super("Visiting the healing springs",10)
#   end
#   def finished
#     $player.heal
#     puts "Hitpoints restored to #{$player.hp}/#{$player.maxhp}"
#   end
# end

# class HealingTask < PlotTask
#   def initialize
# ##    Display.healing_springs
#   end
#   def finished
#     ## $player.heal
#     ## puts "Hitpoints restored to #{$player.hp}/#{$player.maxhp}"
#     Display.healing_springs
#   end
# end
