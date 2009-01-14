# Code related to display management.
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


# A crudimentary class for setting up display modes.
class Terminal
  attr_reader :clear_attributes
  attr_reader :erase_line
  attr_reader :erase_char
  attr_reader :bold
  attr_reader :color_codes

  public
    def Terminal.set_up
      if $use_term then
        @@clear_attributes = `tput sgr0`
        @@erase_line = `tput cr` + `tput el`
        @@bold = `tput bold`
        @@color_codes = {}
        @@color_codes[:foreground] = {}
        @@color_codes[:background] = {}
        # These work at least for ANSIlike terminals, not sure about
        # the rest...
        @@color_codes[:foreground][:black] = `tput setaf 0`
        @@color_codes[:foreground][:red] = `tput setaf 1`
        @@color_codes[:foreground][:green] = `tput setaf 2`
        @@color_codes[:foreground][:yellow] = `tput setaf 3`
        @@color_codes[:foreground][:blue] = `tput setaf 4`
        @@color_codes[:foreground][:magenta] = `tput setaf 5`
        @@color_codes[:foreground][:cyan] = `tput setaf 6`
        @@color_codes[:foreground][:white] = `tput setaf 7`
        @@color_codes[:background][:black] = `tput setab 0`
        @@color_codes[:background][:red] = `tput setab 1`
        @@color_codes[:background][:green] = `tput setab 2`
        @@color_codes[:background][:yellow] = `tput setab 3`
        @@color_codes[:background][:blue] = `tput setab 4`
        @@color_codes[:background][:magenta] = `tput setab 5`
        @@color_codes[:background][:cyan] = `tput setab 6`
        @@color_codes[:background][:white] = `tput setab 7`
      else
        @@clear_attributes = ''
        @@erase_line = ''
        @@bold = ''
        @@color_codes = {}
        @@color_codes[:foreground] = {}
        @@color_codes[:background] = {}
        # These work at least for ANSIlike terminals, not sure about
        # the rest...
        @@color_codes[:foreground][:black] = ''
        @@color_codes[:foreground][:red] = ''
        @@color_codes[:foreground][:green] = ''
        @@color_codes[:foreground][:yellow] = ''
        @@color_codes[:foreground][:blue] = ''
        @@color_codes[:foreground][:magenta] = ''
        @@color_codes[:foreground][:cyan] = ''
        @@color_codes[:foreground][:white] = ''
        @@color_codes[:background][:black] = ''
        @@color_codes[:background][:red] = ''
        @@color_codes[:background][:green] = ''
        @@color_codes[:background][:yellow] = ''
        @@color_codes[:background][:blue] = ''
        @@color_codes[:background][:magenta] = ''
        @@color_codes[:background][:cyan] = ''
        @@color_codes[:background][:white] = ''
      end
    end
    def Terminal.clear_attributes
      @@clear_attributes
    end
    def Terminal.erase_line
      @@erase_line
    end
    def Terminal.bold
      @@bold
    end
    def Terminal.color_codes
      @@color_codes
    end
end

