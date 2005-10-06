# $Id$

class Equipment
  attr_accessor :name
  attr_accessor :material
  attr_accessor :element
  attr_accessor :bonus
  def to_s
    "#{element.downcase} #{material.downcase} #{name.downcase} "+
      sprintf("%+1d",total_bonus)
  end

  def cost
    c = (@material.nil? ? 0 : $materials[@material].cost) + (@bonus * 25)
    return (c < 0 ? 0 : c)
  end

  def resale_value
    return cost * 0.8
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

  private
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

class Weapon < Equipment
  public
  def Weapon.load(filename)
    Equipment.do_load(filename,Weapon)
  end
end

class Armor < Equipment
  public
  def Armor.load(filename)
    Equipment.do_load(filename,Armor)
  end
end
