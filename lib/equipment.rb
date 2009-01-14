# $Id: equipment.rb 26 2005-10-26 22:24:53Z wwwwolf $
#
# The classes representing the equipment.
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

# A generic class for equipment in general, something that can be
# carried and such and used to defend or attack.
class Equipment
  attr_accessor :name
  attr_accessor :material
  attr_accessor :element
  attr_accessor :bonus
  def to_s
    # Fixme: Slightly convoluted
    s = ""
    unless element.nil?
      s = element.downcase + " "
    end
    unless material.nil?
      s = s + material.downcase + " "
    end
    if name.nil?       # To get around the hacked-up "funny" types.
      s = s + "#{@type.downcase} "
    else
      s = s + "#{@name.downcase} "
    end
    s = s + sprintf("%+1d",total_bonus)
  end

  def cost
    c = (@material.nil? ? 0 : $materials[@material].cost) + (@bonus * 25)
    return (c < 0 ? 0 : c)
  end

  def resale_value
    v = (cost * 0.8).to_i
    return (v < 0 ? 0 : v)
  end

  def initialize(name, bonus)
    @name = name
    @bonus = bonus
  end

  def total_bonus
    m = $materials[@material]
    b = bonus + (m.nil? ? 0 : m.bonus)
    # Triple negatives, sorry
    unless (not m.respond_to?(:magicbonus)) or (not m.magicbonus.nil?)
      b = b + m.magicbonus
    end
    return b
  end

  private
  def Equipment.do_load(filename,type)
    e = YAML::load(File.open(filename))
    eq = {}
    e.keys.each do |k|
      eq[k] = type.new(k,e[k]['bonus'])
    end
    return eq
  end

  def Equipment.find_good_for_cost(cost,choices)
    bons = ((cost / 2-rand(cost/3))/25).to_i
    if bons < 0
      bons = 0
    end
    # Pick a random base item that isn't too expensive
    c = cost
    type = nil
    while type.nil? or (choices[type].cost + bons*25) > c
      type = choices.keys.random_item
    end
    eq = choices[type].dup
    eq.bonus = bons
    c = c - eq.cost

    # Pick a random material that isn't too expensive
    type = nil
    while type.nil? or $materials[type].cost > c
      type = $materials.keys.random_item
    end
    eq.material = type
    eq.element = $damagetypes.keys.random_item

    return eq
  end
end

# A weapon. The pointy end goes into a LivingThing, causing damage.
class Weapon < Equipment
  public
  def Weapon.load(filename)
    Equipment.do_load(filename,Weapon)
  end
end

# An armor that is used to shield a LivingThing from Weapon use.
class Armor < Equipment
  public
  def Armor.load(filename)
    Equipment.do_load(filename,Armor)
  end
end
