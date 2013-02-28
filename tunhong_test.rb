require 'minitest/autorun'
require 'minitest/colorize'
require './tunhong'
include Tunhong

describe TunhongParser do
  it "must not change the text with default markup" do
    TunhongParser.new(DefaultMarkup).parse("漢字 and བོད་ཡིག་").must_equal(
      "漢字 and བོད་ཡིག་")
  end
  
  it "must add html tags with tag markup with default settings" do
    TunhongParser.new(TagMarkup).parse("Some 漢字 and བོད་ཡིག་.").must_equal(
      %q{Some <span lang="zh">漢字</span> and <span lang="bo">བོད་ཡིག་</span>.})
  end
  
  it "must add custom tags with tag markup" do
    TunhongParser.new(TagMarkup, :chinese => ['[c]', '[ↄ]'], :tibetan => ['[t]','[ʇ]']).parse("Some 漢字 and བོད་ཡིག་.").must_equal(
      'Some [c]漢字[ↄ] and [t]བོད་ཡིག་[ʇ].')
  end
end