#!/usr/bin/env ruby
# encoding: utf-8
#
# Tunhong parser
#
# A library for Ruby 2.0 to mark Chinese and Tibetan strings up inside the text
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

module Tunhong
  class TunhongParser

    # Initialize the parser
    #
    # `markup` is the markup object. It should be or derive from `DefaultMarkup`
    # class and should implement methods `#chinese`, `#tibetan`, and `#other`
    # which process chunks of text given to it by the parser and a finalize
    # method which provides the value returned by the parser `#parse` method if
    # any.
    #
    # `zh_start` and `zh_end` designate opening and closing tags for Chinese
    # and `bo_start` and `bo_end` for Tibetan
    #
    # the default values are html `<span>` tags with the corresponding `lang`
    # attributes
    def initialize(markup=DefaultMarkup, zh_start='<span lang="zh">', zh_end='</span>', bo_start='<span lang="bo">', bo_end='</span>')
      @markup = markup

      @zh_start = zh_start
      @zh_end = zh_end
      @bo_start = bo_start
      @bo_end = bo_end
    end
  
    # parses `str` calling corresponding `markup
    def parse(str)
      markup = @markup.new
      # define start conditions in the beginning
      start, original_mode = 0, detect_mode(str[0])
      str.chars.each_with_index do |c, i|
        mode = detect_mode(c)
        # if mode changed, give the preceding chunk to the parser and reset
        # `start` and `original_mode`
        if mode!=original_mode
          s = str[start..i-1]
          markup.send(original_mode, s) unless s==""
          start, original_mode = i, mode
        end
        # in the end, give the last chunk to the parser, finalize markup object
        # and return
        if i==str.size-1
          s = str[start..i]
          markup.send(original_mode, s) unless s==""
          return markup.finalize
        end
      end
      #output = ""
      ## mode designates the current language, it can be :chinese, :tibetan, or :other
      #mode = :other
      #str.each_char do |chr|
      #  old_mode = mode
      #  # first try to see if the mode changes
      #  if chinese?(chr)
      #    mode = :chinese
      #  elsif tibetan?(chr)
      #    mode = :tibetan
      #  else
      #    mode = :other
      #  end
      #  # then decide if any tags are to input due to mode change
      #  if mode!=old_mode
      #    # first the closing tags
      #    if old_mode==:chinese
      #      output << @zh_end
      #    elsif old_mode==:tibetan
      #      output << @bo_end
      #    end
      #    # then the opening tags
      #    if mode==:chinese
      #      output << @zh_start
      #    elsif mode==:tibetan
      #      output << @bo_start
      #    end
      #  end
      #  output << chr
      #end
      ## add closing tags at the end of the string
      #if mode==:chinese
      #  output << @zh_end
      #elsif mode==:tibetan
      #  output << @bo_end
      #end
      #output
    end
  
    private

    # detect current mode for character c
    def detect_mode(c)
      if chinese?(c)
       return :chinese
      elsif tibetan?(c)
       return :tibetan
      else
       return :other
      end
    end
  
    # returns true if the character is in one of CJK Unicode ranges  
    def chinese?(chr)
      (0x2e80..0x2fff).include?(chr.ord) || # CJK Radicals Supplement, Kangxi 
                                            # Radicals, Ideographic Description 
                                            # Characters
      (0x3100..0x312f).include?(chr.ord) || # Bopomofo
      (0x3190..0x31ef).include?(chr.ord) || # Kanbun, Bopomofo Extended, CJK  
                                            # Strokes
      (0x4e00..0x9fff).include?(chr.ord) || # CJK Unified Ideographs
      (0xf900..0xfaff).include?(chr.ord) || # CJK Compatibility Ideographs
      (0x3400..0x4dbf).include?(chr.ord) || # CJK Unified Ideographs Extension A
      (0x20000..0x2fa1f).include?(chr.ord)  # CJK Unified Ideographs Extension B,
                                            # C, D, CJK Compatibility
                                            # Ideographs Supplement 
    end
  
    # returns true if the character is in Tibetan Unicode range
    def tibetan?(chr)
      (0x0f00..0xfff).include?(chr.ord)
    end
  end
  
  # This is the default markup class to derive from.
  # It does not really change the text.
  # 
  # The markup object should respond to methods corresponding to the modes of
  # the `TunhongParser` class, and a finalize method that provides a return
  # value for the parser’s `#parse` method.
  class DefaultMarkup
    def initialize
      @output = ""
    end

    def method_missing(method, *args, &block)
      @output << args[0]
    end
    
    def finalize
      return @output
    end
  end
end

# test_string = "Dunhuang spells 燉煌 in Chinese and ཏུན་ཧོང་ in Tibetan."
# puts(Tunhong.new('[c]','[ↄ]','[t]','[ʇ]').parse(test_string))
# puts(Tunhong::TunhongParser.new().parse(test_string))