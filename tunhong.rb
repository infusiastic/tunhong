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
# Dunhuang spells [chn]燉煌[/chn] in Chinese and [tib]ཏུན་ཧོང་[/tib] in
# Tibetan. We prefer the Tibetan reading as the name for the parser.
#
# depending on the user preference.

# require "active_support"

class Tunhong

  def initialize(zh_start='<span lang="zh">', zh_end='</span>', bo_start='<span lang="zh">', bo_end='</span>')
    @zh_start = zh_start
    @zh_end = zh_end
    @bo_start = bo_start
    @bo_end = bo_end
  end
  
  def parse(str)
    puts "Hello, ཏུན་ཧོང་!"
    puts str
  end
end

Tunhong.new("[c]","[ↄ]","[t]","[ʇ]").parse("A test string of characters.")