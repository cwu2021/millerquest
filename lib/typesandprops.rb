# $Id$

class DamageType
  private
  DAMAGE_TYPES = ['Holy','Evil','File','Earth','Water','Air',
    'Ice','Electricity']

  public
  def initialize(name,attackbonuses)
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

end

