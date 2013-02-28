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
    def initialize(*args)
      @markup = args.shift || DefaultMarkup
      @markup_args = args
    end
  
    # Parse `str` calling corresponding `markup` methods
    def parse(str)
      markup = @markup.new(*@markup_args)
      # define start conditions in the beginning
      start, original_mode = 0, detect_mode(str[0])
      str.chars.each_with_index do |c, i|
        mode = detect_mode(c)
        # If mode changed, give the preceding chunk to the parser and reset
        # `start` and `original_mode`.
        if mode!=original_mode
          s = str[start..i-1]
          markup.send(original_mode, s) unless s==""
          start, original_mode = i, mode
        end
        # In the end, give the last chunk to the parser, finalize markup object
        # and return.
        if i==str.size-1
          s = str[start..i]
          markup.send(original_mode, s) unless s==""
          return markup.finalize
        end
      end
    end
  
    private

    # Detect current mode for character c.
    def detect_mode(c)
      if chinese?(c)
       return :chinese
      elsif tibetan?(c)
       return :tibetan
      else
       return :other
      end
    end
  
    # Return true if the character is in one of CJK Unicode ranges
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
  
    # Return true if the character is in Tibetan Unicode range
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
    def initialize(*args)
      @output = ""
    end

    def method_missing(method, *args, &block)
      @output << args[0]
    end
    
    def finalize
      return @output
    end
  end
  
  # Tag markup delimits chuncks with opening and closing tags.
  #
  # Tags can be given as hash of `{:mode => ['opening_tag','closing_tag'],...}`
  #
  # By default Chinese and Tibetan text is enclosed in html `span` tags with the
  # appropriate `lang` attribute. This is more of a tribute to the original
  # version of the parser.
  class TagMarkup < DefaultMarkup
    def initialize(*args)
      @tags = args[0] || {:chinese => ['<span lang="zh">', '</span>'], :tibetan => ['<span lang="bo">', '</span>']}
      super
    end
    
    def method_missing(method, *args, &block)
      if @tags.has_key? method
        @output << @tags[method][0] << args[0] << @tags[method][1]
      else
        super
      end
    end
  end
end