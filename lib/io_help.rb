# $Id$
#
# Things that help printing out stuff.
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


def print_line
  puts "-" * 70
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


def titlebar(title,letter)
  xlength = 70-title.length-2-(letter.length)*3
  if xlength > 0
    restbar = letter*xlength
  else
    restbar = ''
  end
  puts "#{letter*3} #{title} #{restbar}"
end



def titlescreen
  puts $title_screen
end
