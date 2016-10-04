require 'cocoapods-scoped-keys/enum'
require 'cocoapods-scoped-keys/string_additions'

module ScopedKeys
  class Context
    attr_accessor :class_name, :enums, :keys, :detailed_keys

    def initialize(name, enums, keys, detailed_keys)
      self.class_name = name + 'Keys'
      self.enums = enums
      self.keys = keys
      self.detailed_keys = detailed_keys
    end

    def private_class_name
      "Private#{class_name}Keys".capitalize
    end

    def render_header
      template = File.read(Pathname(__dir__) + '../templates/header.mustache')
      Mustache.render(template, self)
    end

    def render_implementation
      template = File.read(Pathname(__dir__) + '../templates/implementation.mustache')
      Mustache.render(template, self)
    end

    def init_declaration
      return nil if enums.empty?

      formatted_enums = enums.map(&:name).each_with_index.map do |e, idx|
        argument = idx.zero? ? e : e.cp_camelcase
        enum_name = class_name + e
        "#{argument}:(#{enum_name})#{e.cp_camelcase}"
      end

      'initWith' + formatted_enums.join(' ')
    end

    def keys_implementations
      keys.map do |key|
        all_keys = detailed_keys.select { |k, _| k.cp_camelcase.start_with? key }

        conditions = all_keys.map do |k, v|
          if_clause = v.map do |h|
            'self.' + h[:key] + ' == ' + class_name + h[:key].capitalize + h[:value]
          end.join(' && ')

          { private_key: k.cp_camelcase, if_clause: if_clause }
        end

        conditions = nil if conditions.all? { |c| c[:if_clause].empty? }

        { key: key, conditions: conditions }
      end
    end
  end
end
