class MemorizedSpell
  attr_accessor :name, :level

  def addlevel
    @level = @level + 1
  end
  def to_s
    "#{@name} #{@level}"
  end
  def MemorizedSpell.new_random
    a = MemorizedSpell.new
    a.name = $spells.random_item
    a.level = 1
    return a
  end
  def MemorizedSpell.new_named(name)
    a = MemorizedSpell.new
    a.name = name
    a.level = 1
    return a
  end
end

