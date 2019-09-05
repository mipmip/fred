require "./spec_helper"

describe Fred do
  it "should replace includes on inside values that contain $INCLUDE" do
    tempfile = temp_filename

    FileUtils.cp "./spec/testfiles/markdown_with_include.md", tempfile
    FileUtils.cp "./spec/testfiles/frontmatter_import_2.yml", "/tmp/frontmatter_import_2.yml"

    dryrun = true
    recursive = true
    verbose = true

    fs_processor = FSProcessor.new(tempfile, dryrun, recursive, verbose)
    fs_processor.replace_includes
    fs_processor.replace_1st_level_vars

    unless dryrun
      content_new = File.read(tempfile)
      content_new.includes?("    c_string: bonjour").should eq(true)
      content_new.includes?("fuck").should eq(true)
      content_new.includes?("hallo").should eq(true)
      content_new.split("---").size.should eq(3)
    end

    FileUtils.rm_r(tempfile)
  end
end
