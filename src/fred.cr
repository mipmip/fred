require "clim"
require "front_matter"
require "yaml"
require "./fred/*"

WORKAROUND_YAML_UNICODE_BUG = true

module Fred
  class Cli < Clim
    main do
      desc "help"
      usage "fred help"
      run do |opts, args|
        puts opts.help_string
      end

      sub "version" do
        desc "version"
        usage "fred version"
        run do |opts, args|
          puts Fred::VERSION
        end
      end

      sub "echo" do
        desc "echo display one node by key"
        usage "fred echo [key] [PATH]"
        run do |opts, args|
          if args.size == 2
            path = args[1]
            markdown_doc = MarkdownDoc.new(path, true)
            print markdown_doc.front_matter_as_yaml[args[0]]
          else
            puts opts.help_string
          end
        end
      end


      sub "process_frontmatter_specials" do
        desc "replace $FORMAT and $INCLUDE inside the front matter"

        option "-d", "--dryrun", type: Bool, desc: "Dry run. Output only"
        option "-r", "--recursive", type: Bool, desc: "Path is a directory. All .md files in the directory will be processed"
        option "-v", "--verbose", type: Bool, desc: "Be verbose"

        usage "fred process_frontmatter_specials [PATH]"
        run do |opts, args|
          if args.size == 1
            path = args[0]
            fs_processor = FSProcessor.new(path, opts.dryrun, opts.recursive, opts.verbose)
            fs_processor.process_all_specials
          else
            puts opts.help_string
          end
        end
      end

      sub "replace_1st_level_vars" do
        desc "replace 1st level variables in inside the front matter"

        option "-d", "--dryrun", type: Bool, desc: "Dry run. Output only"
        option "-r", "--recursive", type: Bool, desc: "Path is a directory. All .md files in the directory will be processed"
        option "-v", "--verbose", type: Bool, desc: "Be verbose"

        usage "fred replace_1st_level_vars [PATH]"
        run do |opts, args|
          if args.size == 1
            path = args[0]
            fs_processor = FSProcessor.new(path, opts.dryrun, opts.recursive, opts.verbose)
            fs_processor.replace_1st_level_vars
          else
            puts opts.help_string
          end
        end
      end

      sub "replace_includes" do
        desc "replace includes inside the front matter"

        option "-d", "--dryrun", type: Bool, desc: "Dry run. Output only"
        option "-r", "--recursive", type: Bool, desc: "Path is a directory. All .md files in the directory will be processed"
        option "-v", "--verbose", type: Bool, desc: "Be verbose"

        usage "fred replace_includes [PATH] [options]"
        run do |opts, args|
          if args.size == 1
            path = args[0]
            fs_processor = FSProcessor.new(path, opts.dryrun, opts.recursive, opts.verbose)
            fs_processor.replace_includes
          else
            puts opts.help_string
          end
        end
      end

      sub "rename_taxo_key" do
        desc "rename a taxo string val"

        option "-d", "--dryrun", type: Bool, desc: "Dry run. Output only"
        option "-r", "--recursive", type: Bool, desc: "Path is a directory. All .md files in the directory will be processed"
        option "-v", "--verbose", type: Bool, desc: "Be verbose"

        usage "fred rename_taxo_key [taxo_key_old] [taxo_key_new] [PATH]"

        run do |opts, args|
          if args.size == 3
            path = args[2]
            fs_processor = FSProcessor.new(path, opts.dryrun, opts.recursive, opts.verbose)
            fs_processor.rename_taxo_key(args[0], args[1])
          else
            puts opts.help_string
          end
        end
      end

      sub "rename_taxo_val" do
        desc "rename a taxo string val in a single file"
        option "-d", "--dryrun", type: Bool, desc: "Dry run. Output only"
        option "-r", "--recursive", type: Bool, desc: "Path is a directory. All .md files in the directory will be processed"
        option "-v", "--verbose", type: Bool, desc: "Be verbose"
        usage "fred rename_taxo_val [taxo_key] [taxo_val_old] [taxo_val_new] [PATH]"

        run do |opts, args|
          if args.size == 4
            path = args[3]
            fs_processor = FSProcessor.new(path, opts.dryrun, opts.recursive, opts.verbose)
            fs_processor.rename_taxo_val(args[0], args[1], args[2])
          else
            puts opts.help_string
          end
        end
      end
    end
  end
end

{% if !@type.has_constant? "TESTING" %}
  Fred::Cli.start(ARGV)
{% end %}
