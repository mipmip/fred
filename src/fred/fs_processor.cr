class FSProcessor
  def initialize(path, dryrun, recursive, verbose)
    @changed_docs_num = 0

    @recursive = false
    @recursive = recursive

    @dryrun = false
    @dryrun = dryrun

    if (@dryrun)
      @only_output_when_changed = false
    else
      @only_output_when_changed = true
    end

    @verbose = false
    @verbose = verbose

    @files = [] of String
    @files = validate_path_with_option(path)
  end

  def validate_path_with_option(path)
    path = File.expand_path(path)
    if File.directory?(path) && @recursive
      return Dir.glob(path + "/*.md")
    elsif File.directory?(path)
      raise path + " is directory. You may need need the --recursive option"
    elsif !File.exists?(path)
      raise path + " does not exists."
    else
      return [path]
    end
  end

  def process_all_specials
    @files.each do |in_file|
      begin
        process_all_specials_in_file(in_file)
      rescue
        p in_file + " has invalid Front Matter."
      end
    end

    report_command_stats if @verbose
  end

  def replace_1st_level_vars
    @files.each do |in_file|
      begin
        replace_1st_level_vars_in_file(in_file)
      rescue
        p in_file + " has invalid Front Matter."
      end
    end

    report_command_stats if @verbose
  end

  def replace_includes
    @files.each do |in_file|
      begin
        replace_includes_in_file(in_file)
      rescue
        p in_file + " has invalid Front Matter."
      end
    end

    report_command_stats if @verbose
  end

  def rename_taxo_key(key_old, key_new)
    @files.each do |in_file|
      begin
        rename_taxo_key_in_file(in_file, key_old, key_new)
      rescue
        p in_file + " has invalid Front Matter."
      end
    end

    report_command_stats if @verbose
  end

  def rename_taxo_val(key, val_old, val_new)
    @files.each do |in_file|
      begin
        in_file = File.expand_path(in_file)

        if File.file?(in_file)
          rename_taxo_val_in_file(in_file, key, val_old, val_new)
        end
      rescue
        p in_file + " has invalid Front Matter."
      end
    end
  end

  private def process_all_specials_in_file(in_file)
    markdown_doc = MarkdownDoc.new(in_file, @only_output_when_changed)
    markdown_doc.replace_includes_in_frontmatter
    markdown_doc.replace_1st_level_frontmatter_variables
    output_markdown_doc(in_file, markdown_doc)
  end

  private def replace_1st_level_vars_in_file(in_file)
    markdown_doc = MarkdownDoc.new(in_file, @only_output_when_changed)
    markdown_doc.replace_1st_level_frontmatter_variables
    output_markdown_doc(in_file, markdown_doc)
  end

  private def replace_includes_in_file(in_file)
    markdown_doc = MarkdownDoc.new(in_file, @only_output_when_changed)
    markdown_doc.replace_includes_in_frontmatter
    output_markdown_doc(in_file, markdown_doc)
  end

  private def rename_taxo_key_in_file(in_file, key_old, key_new)
    markdown_doc = MarkdownDoc.new(in_file, @only_output_when_changed)
    markdown_doc.rename_taxo_key(key_old, key_new)
    output_markdown_doc(in_file, markdown_doc)
  end

  private def rename_taxo_val_in_file(in_file, key, val_old, val_new)
    markdown_doc = MarkdownDoc.new(in_file, @only_output_when_changed)
    markdown_doc.rename_taxo_val(key, val_old, val_new)
    output_markdown_doc(in_file, markdown_doc)
  end

  private def output_markdown_doc(in_file, markdown_doc)
    if markdown_doc.changed
      if @dryrun
        markdown_doc.dump_markdown
      else
        write_to_file(in_file, markdown_doc.markdown_string)
      end
      markdown_doc.report_doc_stats if @verbose
      @changed_docs_num += 1
    end
  end

  private def write_to_file(out_file, contents)
    puts "changing original file: " + out_file if @verbose
    out_file = File.expand_path(out_file)
    file_h = File.open out_file, "w"
    file_h.puts contents
    file_h.close
  end

  private def report_command_stats
    print "Stats for command:\n"
    print "  Changed files: " + @changed_docs_num.to_s + "\n"
  end
end
