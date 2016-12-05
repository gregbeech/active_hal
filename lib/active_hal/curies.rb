module ActiveHal
  class Curies
    def initialize(array)
      @data = (array || []).map { |h| [h[:name].to_s, h[:href]] }.to_h
    end

    def expand(curie)
      name, rel = curie.to_s.split(':', 2)
      return name unless rel

      href = @data.fetch(name)
      href.gsub('{rel}', rel)
    end
  end
end
