require 'cocoapods-core'
require 'cocoapods_keys'
require 'active_support/core_ext/hash/indifferent_access'
require 'mustache'
require 'cocoapods-scoped-keys/enum'
require 'cocoapods-scoped-keys/context'
require 'cocoapods-scoped-keys/string_additions'
require 'cocoapods-scoped-keys/parser'

module ScopedKeys
  class << self
    include FileUtils

    # Register for the pre-install hooks to setup & run Keys
    Pod::HooksManager.register('cocoapods-scoped-keys', :pre_install) do |context, options|
      ScopedKeys.setup(context.podfile, options)
    end

    def setup(podfile, options)
      parser = Parser.new

      CocoaPodsKeys.setup(podfile, parser.map_to_cocoapods_keys(options).with_indifferent_access)

      installation_root = Pod::Config.instance.installation_root
      keys_path = installation_root.+('Pods/CocoaPodsScopedKeys/')

      # move our podspec in to the Pods
      mkdir_p keys_path
      podspec_path = Pathname(__dir__) + 'templates' + 'ScopedKeys.podspec.json'
      cp podspec_path, keys_path

      file_name = parser.project(options) + 'Keys'
      interface_file = keys_path + (file_name + '.h')
      implementation_file = keys_path + (file_name + '.m')

      File.write(interface_file, parser.rendered_header(options))
      File.write(implementation_file, parser.rendered_implementation(options))

      # Add our template podspec
      add_keys_to_pods(podfile, keys_path.relative_path_from(installation_root), options)
    end

    def add_keys_to_pods(podfile, keys_path, options)
      keys_targets = options['target'] || options['targets']

      if keys_targets
        # Get a list of targets, even if only one was specified
        keys_target_list = ([] << keys_targets).flatten

        # Iterate through each target specified in the Keys plugin
        keys_target_list.each do |keys_target|
          # Find a matching Pod target
          pod_target = podfile.root_target_definitions.flat_map(&:children).find do |target|
            target.label == "Pods-#{keys_target}"
          end

          if pod_target
            pod_target.store_pod 'Keys', path: keys_path.to_path
          else
            Pod::UI.puts "Could not find a target named '#{keys_target}' in your Podfile. Stopping keys".red
          end
        end

      else
        # otherwise let it go in global
        podfile.pod 'ScopedKeys', path: keys_path.to_path
      end
    end
  end
end
