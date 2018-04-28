module Amber::CLI
  class_property color = true

  class MainCommand < ::Cli::Supercommand
    command "b", aliased: "batch"

    class Batch < Command
      class Options
        arg "file", desc: "filename.yml", required: true
        bool "--no-color", desc: "Disable colored output", default: false
        help
      end

      class Help
        header "Generate resources based on YAML file"
        caption ""
      end

      def run
        ensure_file_argument!
        yaml = YAML.parse(File.read(args.file))
        # Loads an array of YAML hashes
        yaml.each do |request|
          # get the action name "model/scaffold/contro"
          request.each do |action, data|
            action_type = action.to_s
            templates = [] of Template
            data.each do |name, args|
              fields = [] of String
              args.each {|arg| fields.push arg.to_s} if args
              template = Template.new(name.to_s, ".", fields)
            end
            templates.each do |template|
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
          CLI.logger.info "Parsing Error: The File argument is required.", "Error", :red
          exit! help: true, error: true
        end
      end

      class Help
        caption "# Generate Amber resources from YAML file"
      end
    end
  end
end
