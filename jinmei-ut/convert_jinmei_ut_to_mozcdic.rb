#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# convert_jinmei_ut_to_mozcdic
# ==============================================================================

def convert_jinmei_ut_to_mozcdic
	# Mozcの品詞IDを取得
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	# 「名詞,固有名詞,人名,一般,*,*」は優先度が低いので使わない。
	# 「名詞,固有名詞,一般,*,*,*」は後でフィルタリングする。
	id = id.grep(/\ 名詞,一般,\*,\*,\*,\*,\*/)
	id = id[0].split(" ")[0]

	file = File.new($filename, "r")
		lines = file.read.split("\n")
	file.close

	lines.length.times do |i|
		s = lines[i].split("	")
		yomi = s[0]
		hyouki = s[-1]

		lines[i] =  yomi + "	" + id + "	" + id + "	6000	" + hyouki
	end

	# 重複行を削除
	lines = lines.uniq.sort

	dicfile = File.new($dicname, "w")
		dicfile.puts lines
	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

$filename = "jinmei-ut.txt"
$dicname = "mozcdic-ut-jinmei.txt"

convert_jinmei_ut_to_mozcdic
