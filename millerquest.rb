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
require 'optparse'

# Probe defaults and parse options here, because the user might
# supply an alternate library location etc...
ARGV.options do |opts|
  script_file_name = __FILE__
  script_name = File.basename($0) # $0 might be different from __FILE__

  # PROBE DEFAULT VALUES
  
  # Figure out the app library directory, through symlinks if necessary
  while File.symlink?(script_file_name)
    script_file_name = File.readlink(script_file_name)
  end
  $libdir = File.dirname(script_file_name) + "/lib"
  $datadir = File.dirname(script_file_name) + "/data"

  # Do we use terminal stuff?
  # FIXME: All of the terminal stuff needs tput. Is there
  # a ruby module to use terminfo?
  $use_term = true
  termname = `tput longname 2>/dev/null`
  if $? != 0
    $use_term = false
  end

  # PARSE OPTIONS
  
  opts.banner = "Usage: #{script_name} [options] [savefile]"
  opts.separator ""
  if $use_term then
    opts.on("-n", "--no-term",
            "Disable color and attribute support.") { $use_term = false }
  end
  opts.on("-L", "--library=directory", String,
          "Location of Miller's Quest code library.",
          "Auto-detected as: #{$libdir}") { |$libdir| }
  opts.on("-D", "--data=directory", String,
          "Location of Miller's Quest data files.",
          "Auto-detected as: #{$datadir}") { |$datadir| }
  opts.separator ""
  opts.on("-h", "--help",
          "Show this help message.") { puts opts; exit }
  opts.parse!
end

# Load all library files
%w{
  array_ext terminal debug_tools io_help
  game_save_load 
  living
  damage_type material equipment spells
  task task_plot task_towne task_fight
  quest adventure
}.each do |f|
   require "#{$libdir}/#{f}.rb"
end

#######################################################################
# Main program

Display.set_up

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

