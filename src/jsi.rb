require 'json'

class Jsi

  attr_accessor :context

  def no_arg
    @context.toast "no_arg: nil"
    "null" # == nil.to_json
  end

  def boolean_arg b
    @context.toast "boolean_arg: #{b}"
    "#{b}" # == b.to_json
  end

  def int_arg i
    @context.toast "int_arg: #{i}"
    "#{i}" # == i.to_json
  end

  def string_arg s
    @context.toast "string_arg: #{s}"
    s      # != s.to_json ( s.to_json == "\"#{s}\"" )
  end

  def json_arg j
    obj = JSON.load(j)
    @context.toast "json_arg: #{obj.inspect}"
    obj.to_json
  end

  def multiple_arg j, s, i, b
    obj = JSON.load(j)
    @context.toast "multiple_arg: #{obj.inspect}, #{s}, #{i}, #{b}"
    [ obj, s, i, b ].to_json
  end

  def image_loaded w, h
    @context.toast "Image size: #{w}x#{h}"
  end

end

