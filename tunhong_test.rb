# Tunhong parser tests
#
# Copyright © 2012-2013 Demian Terentev <demian@infusiastic.me>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
  
  it "must output empty string with silent markup" do
    TunhongParser.new(SilentMarkup).parse("I like 香蕉!").must_equal ""
  end
end