# borrowed with modifications from https://github.com/karaken12/pandoc-filters-ruby
require 'json'

module Pandoc # :nodoc:
  def self.filter(&block)
    doc = JSON.parse(STDIN.read)
    @block = block
    puts JSON.dump(walk(doc))
  end

  def self.walk(x)
    if x.is_a?(Array)
      result = []
      x.each do |item|
        if item.is_a?(Hash) && item.key?('t')
          res = @block.call(item['t'], item['c'], nil, nil)
          if !res
            result.push(walk(item))
          elsif res.is_a?(Array)
            res.each do |z|
              result.push(walk(z))
            end
          else
            result.push(walk(res))
          end
        else
          result.push(walk(item))
        end
      end
      result
    elsif x.is_a?(Hash)
      result = {}
      x.each do |key, value|
        result[key] = walk(value)
      end
      result
    else
      x
    end
  end

  class << self
    alias dsm define_singleton_method
  end

  [
    ['Plain', 1],
    ['Para', 1],
    ['CodeBlock', 2],
    ['RawBlock', 2],
    ['BlockQuote', 1],
    ['OrderedList', 2],
    ['BulletList', 1],
    ['DefinitionList', 1],
    ['Header', 3],
    ['HorizontalRule', 0],
    ['Table', 5],
    ['Div', 2],
    ['Null', 0],
    ['Str', 1],
    ['Emph', 1],
    ['Strong', 1],
    ['Strikeout', 1],
    ['Superscript', 1],
    ['Subscript', 1],
    ['SmallCaps', 1],
    ['Quoted', 2],
    ['Cite', 2],
    ['Code', 2],
    ['Space', 0],
    ['SoftBreak', 0],
    ['LineBreak', 0],
    ['Math', 2],
    ['RawInline', 2],
    ['Link', 3],
    ['Image', 3],
    ['Note', 1],
    ['Span', 2]
  ].each do |n, params|
    case params
    when 0 then dsm(n) {                 { 't' => n, 'c' => [] } }
    when 1 then dsm(n) { |a|             { 't' => n, 'c' => a } }
    when 2 then dsm(n) { |a, b|          { 't' => n, 'c' => [a, b] } }
    when 3 then dsm(n) { |a, b, c|       { 't' => n, 'c' => [a, b, c] } }
    when 4 then dsm(n) { |a, b, c, d|    { 't' => n, 'c' => [a, b, c, d] } }
    when 5 then dsm(n) { |a, b, c, d, e| { 't' => n, 'c' => [a, b, c, d, e] } }
    else raise
    end
  end
end
