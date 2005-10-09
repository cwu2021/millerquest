# $Id$
# Some extensions to the base Array and Hash classes.
# Note: These things are howwible hacks.

class Array
  # Finds a random item from the array.
  def random_item
    return self[rand(self.length)]
  end
  # Returns true if the array contains an item that matches the regular expression regex.
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
  # Returns a random item from the hash.
  def random_item
    return self[random_key]
  end
  # Returns a random key from the hash.
  def random_key
    return self.keys[rand(self.keys.length)]
  end
end

