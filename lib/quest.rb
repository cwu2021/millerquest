# Quest handling.
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

# A Quest.
class Quest
  attr_reader :description
  def initialize
    item = $items.random_item
    place = $places.random_item
    monster = $monsters.random_item.name
    case rand(5)
    when 0 then @description = "find a #{item} from #{place}"
    when 1 then @description = "search the #{place} for #{item}"
    when 2 then @description = "locate a #{item}"
    when 3 then @description = "wipe out #{monster} in #{place}"
    when 4 then @description = "destroy #{monster}"
    end
  end
end

