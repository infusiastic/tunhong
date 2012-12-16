#!/usr/bin/env ruby
# encoding: utf-8
#
# Tunhong parser
#
# A ruby library to markup Chinese and Tibetan strings inside the text
# written in another language.
#
# The name is taken after Dunhuang Caves in China, containing important
# manuscripts in both Chinese and Tibetan.
# 
# Dunhuang spells 燉煌 in Chinese and ཏུན་ཧོང་ in Tibetan. We prefer the
# Tibetan reading as the name for the parser.
#
# To illustrate the idea, the result of parsing the previous paragraph
# could be:
#
# Dunhuang spells <span lang="zh">燉煌</lang> in Chinese and <span lang="bo">
# ཏུན་ཧོང་</span> in Tibetan. We prefer the Tibetan reading as the name
# for the parser.
#
# or it could be:
#
# Dunhuang spells [c]燉煌[ↄ] in Chinese and [t]ཏུན་ཧོང་[ʇ] in
# Tibetan. We prefer the Tibetan reading as the name for the parser.
#
# depending on the user preference.

class Tunhong

  def initialize(zh_start='<span lang="zh">', zh_end='</span>', bo_start='<span lang="zh">', bo_end='</span>')
    @zh_start = zh_start
    @zh_end = zh_end
    @bo_start = bo_start
    @bo_end = bo_end
  end
  
  def parse(str)
    output = ""
    # mode designates the current language, it can be :chinese, :tibetan, or :other
    mode = :other
    str.each_char do |chr|
      old_mode = mode
      # first try to see if the mode changes
      if chinese?(chr)
        mode = :chinese
      else
        mode = :other
      end
      # then decide if any tags are to input due to mode change
      if mode!=old_mode # if no mode change occured
        if mode==:chinese # if the text switched to chinese
          output << @zh_start # then add a chinese opening tag
        elsif old_mode==:chinese # if the text switched back from chinese
          output << @zh_end # then add a chinese closing tag
        end
      end
      output << chr
    end
    output
  end
  
  private
  
  def chinese?(chr)
    chr=="c"
  end
  
  def tibetan?(chr)
    chr=="t"
  end
end

puts "Hello, ཏུན་ཧོང་!"
puts(Tunhong.new("[c]","[ↄ]","[t]","[ʇ]").parse("A test string of characccters."))