
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

