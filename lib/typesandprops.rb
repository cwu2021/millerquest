# $Id$

class DamageType
  private
  DAMAGE_TYPES = ['Holy','Evil','File','Earth','Water','Air',
    'Ice','Electricity']

  public
  def initialize(name,attackbonuses)
    @name = name
    @bonus = {}
    DAMAGE_TYPES.each do |t|
      # Each damage type is 0 unless defined otherwise in the attackbonuses
      # parameter. Does not copy weird damage types from attackbonuses.
      if attackbonuses.has_key?(t)
	@bonus[t] = attackbonuses[t]
      else
	@bonus[t] = 0
      end
    end
  end

  def bonus_against(type)
    return @bonus[type]
  end

  def DamageType.damage_types
    DAMAGE_TYPES
  end
  def DamageType.valid_damage_type?(t)
    DAMAGE_TYPES.contains? /#{t}/
  end

  def DamageType.load(filename)
    dmg = YAML::load(File.open(filename))
    types = {}
    dmg.keys.each do |k|
      bonuses = dmg[k]
      types[k] = DamageType.new(k,bonuses)
    end
    return types
  end
end

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
    c = (@bonus * 5) + (@magicbonus * 20) - (number_of_weaknesses * 10)
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
