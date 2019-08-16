class YamlHashProcessor

  def initialize(front_matter_as_yaml : YAML::Any)

    @front_matter_as_yaml = front_matter_as_yaml
    @glob_vars = {} of String => String
    setup_vars
  end

  def setup_vars

    @front_matter_as_yaml.as_h.each do |key, value|

      if value.raw.class == String
        @glob_vars[key.as_s] = value.as_s

      elsif value.raw.class == Int64
        @glob_vars[key.as_s] = value.raw.to_s

      elsif value.raw.class == Float64
        @glob_vars[key.as_s] = value.raw.to_s

      end
    end
  end

  def string_value_process(in_string : String)

    new_string = in_string
    m = in_string.match(/^\$FORMAT\ (.*)/)
    if m
      new_string = m[1]

      @glob_vars.each do |k,v|

        if new_string.includes? k
          new_string = new_string.gsub("{#{k}}",v)
        end

      end
    end

    return new_string
  end

  def process_node( node : YAML::Any)

    case node.raw

    when String

      return YAML::Any.new(string_value_process(node.as_s))

    when Array(YAML::Any)
      new_node = [] of YAML::Any
      node.as_a.each do |value|
        new_node << process_node( value )
      end
      return YAML::Any.new(new_node)

    when Hash(YAML::Any, YAML::Any)
      new_node = {} of YAML::Any => YAML::Any

      node.as_h.each do |key, value|
        new_node[YAML::Any.new(key.as_s)] = process_node( value )
      end

      return YAML::Any.new(new_node)

    else
      return node
    end

    node

  end
end

