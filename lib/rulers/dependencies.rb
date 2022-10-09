class Object
  @cached_constants = {}

  def self.const_missing(const)
    return nil if @cached_constants[const]

    require Rulers.to_underscore(const.to_s)
    @cached_constants[const] ||= true
    klass = Object.const_get(const)
    @cached_constants[const] = false

    klass
  end
end
