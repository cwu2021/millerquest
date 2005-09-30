# $Id$
# Note: These things are howwible hacks.

class Array
  def random_item
    return self[rand(self.length)]
  end
  def contains?(regex)
    self.each do |i|
      if i =~ regex
	return true
      end
    end
    return false
  end
end

class Hash
  def random_item
    return self[random_key]
  end
  def random_key
    return self.keys[rand(self.keys.length)]
  end
end

