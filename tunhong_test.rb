require 'minitest/autorun'
require 'minitest/colorize'
require './tunhong'
include Tunhong

describe TunhongParser do
  it "must not change the text with default markup" do
    TunhongParser.new(DefaultMarkup).parse("漢字 and བོད་ཡིག་").must_equal "漢字 and བོད་ཡིག་"
  end
end