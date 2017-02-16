module Caches; end

class Caches::UsersStore
  def initialize
    @store = Concurrent::Atom.new Concurrent::Hash.new
  end

  def store
    @store.value
  end

  def set(key, value)
    @store.swap { |s| s.merge(key => value) }
  end

  def get(key)
    store[key]
  end

end