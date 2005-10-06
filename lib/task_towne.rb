# $Id$

# Interaction with the merchant.
class MerchantTask < PlotTask
  def initialize(title)
    super(title,5 + rand(9))
    @saveable = false
  end
end

# Selling stuff to the merchant.
class MerchantSellTask < MerchantTask
  private
  def random_sell_verb
    case rand(5)
	 when 2 then 'Getting a good price for'
	 when 3 then 'Mercilessly haggling up the price of'
	 when 4 then 'Trying to get a good price for'
	 else 'Selling'
	end
  end
  public
  def initialize(item_to_sell)
    super("#{random_sell_verb} #{item_to_sell}")
    @item = item_to_sell
  end
  def get_haggled_price
    rand((@item.cost*1.5).to_i+1)
  end
end

# Get new equipment. (Not used much yet.)
class ReEquipTask < PlotTask
  def initialize
    super("Getting some new equipment while we're at it",20)
  end
  def finished
    $player.re_equip
  end
end

# Travel to a new location.
class TravelTask < PlotTask
  def initialize(direction)
    @targetlocation = direction
    if direction == 'killingfields'
      case rand(3)
        when 0 then @title = "Heading to the nearby bushes"
                    @length_of_progress = 10
        when 1 then @title = "The bloody fields do call you!"
                    @length_of_progress = 20
        when 2 then @title = "Taking a few steps out of town to find monsters"
                    @length_of_progress = 5
      end
    elsif direction == 'town'
      @title = "Dragging monster carcasses to the town"
      @length_of_progress = 20
    else
      @title = "Travelling to some damn other place altogether"
      @length_of_progress = 10
    end
  end
  def finished
    $player.location = @targetlocation
    save_game($filename)
  end
end
