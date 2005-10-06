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
require "#{$libdir}/typesandprops.rb"
require "#{$libdir}/equipment.rb"
require "#{$libdir}/io_help.rb"
require "#{$libdir}/task.rb"
require "#{$libdir}/task_plot.rb"
require "#{$libdir}/task_towne.rb"
require "#{$libdir}/task_fight.rb"
require "#{$libdir}/adventure.rb"

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
      Adventure.prologue
    elsif $player.location == 'town' 
      Adventure.sell_possessions
      Adventure.get_new_equipment
      Adventure.get_new_quest
      Adventure.travel_to_killing_fields
    elsif $player.location == 'killingfields'
      Adventure.kill_monsters
      Adventure.travel_to_town
    end
  end
rescue Interrupt
  puts
  puts "Game interrupted."
  puts "Character sheet at the end of the session:"
  $player.print_character_sheet
  save_game($filename)
end

