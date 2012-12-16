#!/usr/bin/env ruby
# encoding: utf-8
#
# Tunhong parser
#
# A benchmark for Tunhong parser

require './tunhong.rb'

t = Tunhong.new('[c]','[ↄ]','[t]','[ʇ]')

s = File.read('test.txt')

puts t.parse(s)