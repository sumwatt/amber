module Amber::CLI
  class_property color = true

  class MainCommand < ::Cli::Supercommand
    command "b", aliased: "batch"

    class Batch < Command
      class Options
        arg "file", desc: "/path/to/filename.yml", required: true
        bool "--no-color", desc: "Disable colored output", default: false
        help
      end

      class Help
        header "Generate resources based on YAML file"
        caption "# Generate resources based on YAML file"
      end

      def run
        ensure_file_argument!
        yaml = YAML.parse_all(File.read(args.file))
        # Loads an YAML Array
        yaml.each do |request|
          request.each do |action, data|
            action_type = action.to_s.downcase
            templates = [] of Template
            data.each do |name, args|
              fields = [] of String
              args.to_a.each {|arg| fields.push arg.to_s} if args
              templates.push(Template.new(name.to_s.downcase, ".", fields))
            end
            templates.each do |template|
              puts template
              template.generate action_type
            end
          end
        end
        #
        # template.generate args.type
      rescue e
        exit! e.message, error: true
      end

      def recipe
        CLI.config.recipe
      end

      private def ensure_file_argument!
        unless args.file?
          CLI.logger.info "File Error: A file path is required", "Error", :red
          exit! help: true, error: true
        end
      end

      class Help
        caption "# Generate Amber resources from YAML file"
      end
    end
  end
end
