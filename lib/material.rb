# $Id$
#
# Equipment material handling.

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
    c = (@bonus * 5) + (@magicbonus * 25) - (number_of_weaknesses * 10)
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
