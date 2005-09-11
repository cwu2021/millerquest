
class Array
  def random_item
    return self[rand(self.length)]
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

