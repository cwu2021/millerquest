class Equipment
  attr_accessor :material
  attr_accessor :type
  attr_accessor :bonus
  def to_s
    "#{material} #{type} "+sprintf("%+1d",bonus)
  end
end

def bogus_level_eq(n,ary)
  l = ((n / 100)*ary.length).to_i
  if l < 0
    l = 0
  elsif l > ary.length
    l = ary.length
  end
  return l
end

class Weapon < Equipment
  def Weapon.new_random_of_level(n)
    i = Weapon.new
    i.material = $materials[bogus_level_eq(n,$materials)]
    i.type = $weapons[bogus_level_eq(n,$weapons)]
    i.bonus = (n/3-2+rand(3)).to_i
    return i
  end
end

class Armor < Equipment
  def Armor.new_random_of_level(n)
    i = Armor.new
    i.material = $materials[bogus_level_eq(n,$materials)]
    i.type = $armors[bogus_level_eq(n,$armors)]
    i.bonus = (n/3-2+rand(3)).to_i
    return i
  end
end
