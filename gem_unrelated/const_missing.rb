class Object
  def self.const_missing(_c)
    # warn "Missing constant #{c.inspect}!"
    require './bobo'
    Bobo
  end
end

Bobo.new.print_bobo
