# frozen_string_literal: true

class Array
  def sum(start = 0)
    inject(start, &:+)
  end
end
