# $Id$
#
# Some extensions to the base Array and Hash classes.
# Note: These things are howwible hacks.
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

# Plain ordinary everyday Ruby array. From hell.
class Array
  # Finds a random item from the array.
  def random_item
    return self[rand(self.length)]
  end
  # Returns true if the array contains an item that matches the regular expression regex.
  def contains?(regex)
    self.each do |i|
      if i =~ regex
	return true
      end
    end
    return false
  end
end

# Plain ordinary run-of-the-mill Ruby hash. Designed by a lunatic.
class Hash
  # Returns a random item from the hash.
  def random_item
    return self[random_key]
  end
  # Returns a random key from the hash.
  def random_key
    return self.keys[rand(self.keys.length)]
  end
end

