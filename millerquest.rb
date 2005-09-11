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

# Standard libraries
require 'yaml'
require 'yaml/store'

# Figure out the app library directory, through symlinks if necessary
script_file_name = __FILE__
while File.symlink?(script_file_name)
  script_file_name = File.readlink(script_file_name)
end
$libdir = File.dirname(script_file_name) + "/lib"
$datadir = File.dirname(script_file_name) + "/data"
  
require "#{$libdir}/array_ext.rb"
require "#{$libdir}/game_save_load.rb"
require "#{$libdir}/debug_tools.rb"
require "#{$libdir}/living.rb"
require "#{$libdir}/quest.rb"
require "#{$libdir}/spells.rb"
require "#{$libdir}/equipment.rb"
require "#{$libdir}/io_help.rb"
require "#{$libdir}/progress.rb"

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
	  $player.current_enemy.prepare_for_battle
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

