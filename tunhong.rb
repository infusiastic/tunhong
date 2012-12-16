#!/usr/bin/env ruby
# encoding: utf-8
#
# Tunhong parser
#
# A library for Ruby 1.9 to mark Chinese and Tibetan strings up inside the text
# written in another language.
#
# The name is taken after Dunhuang Caves in China, containing important
# manuscripts in both Chinese and Tibetan.
# 
# Dunhuang spells 燉煌 in Chinese and ཏུན་ཧོང་ in Tibetan. The Tibetan reading
# was chosen as the name for the parser.
#
# To illustrate the idea, the result of parsing the first sentence of the
# previous paragraph could be:
#
# Dunhuang spells <span lang="zh">燉煌</span> in Chinese and <span lang="bo">
# ཏུན་ཧོང་</span> in Tibetan.
#
# or it could be:
#
# Dunhuang spells [c]燉煌[ↄ] in Chinese and [t]ཏུན་ཧོང་[ʇ] in Tibetan.
#
# depending on the user preference.
#
# Version 42
#
# Copyright © 2012 Demian Terentev
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

class Tunhong

  # Initialize the parser
  #
  # `zh_start` and `zh_end` designate opening and closing tags for Chinese
  # and `bo_start` and `bo_end` for Tibetan
  #
  # the default values are html `<span>` tags with the corresponding `lang`
  # attributes
  def initialize(zh_start='<span lang="zh">', zh_end='</span>', bo_start='<span lang="bo">', bo_end='</span>')
    @zh_start = zh_start
    @zh_end = zh_end
    @bo_start = bo_start
    @bo_end = bo_end
  end
  
  # returns the copy of `str` where Tibetan or Chinese substrings are enclosed in corresponding tags 
  def parse(str)
    output = ""
    # mode designates the current language, it can be :chinese, :tibetan, or :other
    mode = :other
    str.each_char do |chr|
      old_mode = mode
      # first try to see if the mode changes
      if chinese?(chr)
        mode = :chinese
      elsif tibetan?(chr)
        mode = :tibetan
      else
        mode = :other
      end
      # then decide if any tags are to input due to mode change
      if mode!=old_mode
        # first the closing tags
        if old_mode==:chinese
          output << @zh_end
        elsif old_mode==:tibetan
          output << @bo_end
        end
        # then the opening tags
        if mode==:chinese
          output << @zh_start
        elsif mode==:tibetan
          output << @bo_start
        end
      end
      output << chr
    end
    # add closing tags at the end of the string
    if mode==:chinese
      output << @zh_end
    elsif mode==:tibetan
      output << @bo_end
    end
    output
  end
  
  private
  
  # returns true if the character is in one of CJK Unicode ranges  
  def chinese?(chr)
    (0x4e00..0x9fff).include?(chr.ord) || # CJK Unified Ideographs
    (0x3400..0x4dbf).include?(chr.ord) || # CJK Unified Ideographs Extension A
    (0x20000..0x2a6df).include?(chr.ord) || # CJK Unified Ideographs Extension B
    (0x2a700..0x2b73f).include?(chr.ord) || # CJK Unified Ideographs Extension C
    (0x2b740..0x2b81f).include?(chr.ord) || # CJK Unified Ideographs Extension D
    (0xf900..0xfaff).include?(chr.ord) # CJK Compatibility Ideographs
  end
  
  # returns true if the character is in Tibetan Unicode range
  def tibetan?(chr)
    (0x0f00..0xfff).include?(chr.ord)
  end
end

# test_string = "Dunhuang spells 燉煌 in Chinese and ཏུན་ཧོང་ in Tibetan."
# puts(Tunhong.new('[c]','[ↄ]','[t]','[ʇ]').parse(test_string))
# puts(Tunhong.new().parse(test_string))