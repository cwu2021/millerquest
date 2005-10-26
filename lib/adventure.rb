# $Id$
#
# The code related to handling the adventurer's life. Basically, all of the
# subroutines that are called from the main game loop.
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

# This module contains all of the stuff that has something to do with
# our poor adventurer's life. Basically, all of the subroutines that are
# called from the main game loop.
module Adventure

  # Show the prologue. The prologue lines are loaded from data/prologue.yml.
  def Adventure.prologue
    titlebar("PROLOGUE",'*')
    prologueitems = YAML::load(File.open("#{$datadir}/prologue.yml"))
    prologueitems.each do |i|
      i.complete
    end
    titlebar("CHAPTER 1",'*')
    $player.location = 'town'
    save_game($filename)
  end
  
  # Sell the player's possessions
  def Adventure.sell_possessions
    while $player.possessions.length > 0
      p = $player.possessions.pop
      t = MerchantSellTask.new(p)
      t.complete
      newgold = t.get_haggled_price
      puts "Got #{newgold} gp for that"
      $player.gold = $player.gold + newgold
    end
  end

  # Re-equips the character with some brand new equipment.
  def Adventure.get_new_equipment
    m = $player.gold
    t = ReEquipTask.new
    t.complete
  end

  # *May* get a new quest for the character. Or, if the character has
  # quite enough of quests already, starts a new chapter.  
  def Adventure.get_new_quest
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
  end
  
  # Once we're in killing fields, we kill and kill and kill until the day comes
  # we kill no more. Basically, this will pick fights until we have way too much
  # stuff to carry...
  def Adventure.kill_monsters
    while not $player.carrying_too_much?
      if $player.hp <= 0
        t = HealingTask.new
        t.complete
      end
      if $player.current_task.nil?
        t = FightTask.new
        $player.current_task = t
      else
        t = $player.current_task
      end
      t.complete
      if t.player_won?
        puts "Victory!"
        
        # Heal the player after the victory
        # FIXME: Should implement potions
        $player.heal
        
        drops = t.monster.loot
        gotxp = t.monster.exp
        $player.addxp(gotxp)
        puts "Got #{gotxp} exp. #{$player.to_next_level} to next level."
        $player.possessions.push(*drops)
        puts "Currently carrying #{$player.loot_weight}/#{$player.carrying_capacity}"
      else
        puts "Defeat!..."
      end
      $player.current_task = nil
    end
  end

  # Travels to the killing fields.
  def Adventure.travel_to_killing_fields
    t = TravelTask.new('killingfields')
    t.complete  
  end

  # Travels to the town.
  def Adventure.travel_to_town
    t = TravelTask.new('town')
    t.complete  
  end

end