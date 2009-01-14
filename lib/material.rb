# $Id: material.rb 25 2005-10-26 22:14:56Z wwwwolf $
#
# Equipment material handling.
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

# Defines a kind of a material.
class Material
  attr_reader :name
  attr_reader :bonus
  attr_reader :magicbonus

  def initialize(name,bonus,magicbonus,weaknesses)
    @name = name
    @bonus = bonus
    @magicbonus = magicbonus
    @weaknesses = {}
    DamageType.damage_types.each do |t|
      if weaknesses.has_key?(t)
	@weaknesses[t] = weaknesses[t]
      else
	@weaknesses[t] = 0
      end
    end
  end

  def number_of_weaknesses
    n = 0
    @weaknesses.keys do |k|
      if @weaknesses[k] != 0
        n = n + 1
      end
    end
    return n
  end

  def cost
    c = 0
    # Bonus and magic bonus
    c = c + ((@bonus > 1 ? @bonus : 1) * 5)
    unless @magicbonus.nil?
      c = c + ((@magicbonus > 0 ? @bonus : 0) * 25)
    end
    # Weaknesses
    c = c - number_of_weaknesses * 10
    # And value has to be zero or more
    return (c <= 0 ? 0 : c)
  end

  def Material.load(filename)
    mats = YAML::load(File.open(filename))
    materials = {}
    mats.keys.each do |k|
      props = mats[k]

      bonus = 0
      magicbonus = 0
      weaknesses = {}
      bonus = props['bonus'] if props.has_key?('bonus')
      magicbonus = props['magic'] if props.has_key?('magic')
      weaknesses = props['weak'] if props.has_key?('weak')

      materials[k] = Material.new(k,bonus,magicbonus,weaknesses)
    end
    return materials
  end
end
