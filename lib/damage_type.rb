# $Id$
#
# Damage type handling.

# Defines different damage types and how they interact. Different
# damage types get loaded to $damagetypes hash in load_game_data.
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
