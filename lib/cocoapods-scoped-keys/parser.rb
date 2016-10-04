require 'cocoapods-scoped-keys/context'

module ScopedKeys
  class Parser
    def map_to_cocoapods_keys(options)
      options = options.with_indifferent_access
      mapped_options = options.reject { |k, _| k == :config || k == 'config' }
      mapped_options[:keys] = keys_from_config(options)
      mapped_options[:project] = 'Private' + project(options)

      mapped_options.deep_symbolize_keys
    end

    def keys_from_config(config)
      keys_and_conditions_from_config(config).keys
    end

    def append_option(str, option)
      if !option.nil? && !option.empty?
        "#{str}__#{option}"
      else
        str
      end
    end

    def keys_and_conditions_from_config(config, previous_options = [[]])
      return {} if config.nil?
      options = config[:options] || [{}]
      options = previous_options.product(options).map do |existing, option|
        if config[:name].nil?
          existing
        else
          result = existing.clone
          result << { key: config[:name].cp_camelcase, value: option }
          result
        end
      end

      keys = config[:keys].product(options).map do |key, conditions|
        suffix = conditions.map { |h| h[:value] }.reverse
        name = ([key] + suffix).join('__')
        [name, conditions]
      end.to_h

      keys.merge(keys_and_conditions_from_config(config[:config], options))
    end

    def enums_from_config(config)
      return [] if config.nil?

      if config[:name].nil? || config[:options].nil?
        return enums_from_config(config[:config])
      end

      [Enum.new(config[:name], config[:options])] + enums_from_config(config[:config])
    end

    def all_keys(config)
      return [] if config.nil?

      keys = config[:keys] || []
      keys + all_keys(config[:config])
    end

    def camelcased_keys(config)
      all_keys(config).map(&:cp_camelcase)
    end

    def context(config)
      Context.new(project(config), enums_from_config(config), camelcased_keys(config),
                  keys_and_conditions_from_config(config))
    end

    def rendered_header(config)
      context(config).render_header
    end

    def rendered_implementation(config)
      context(config).render_implementation
    end

    def project(config)
      config.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }
    end
end
end
