module ScopedKeys
  class Enum
    attr_accessor :name, :options

    def initialize(name, options)
      self.name = name
      self.options = options
    end

    def camelcase_name
      name.cp_camelcase
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    protected

    def state
      [@name, @options]
    end
  end
end
