#! /usr/bin/env ruby
# coding: utf-8


# ==============================================================================
# convert_jawiki_ut_to_mozcdic
# ==============================================================================

# jawikiの日付を取得
file = File.new("jawiki-index.html", "r")
	jawiki_index = file.read
file.close

date = jawiki_index.split('jawiki-latest-pages-articles.xml.bz2</a>               ')[1]
jawiki_index = ""
date = date.split(" ")[0]

$filename = "jawiki-ut-" + date + ".txt"
$dicname = "mozcdic-ut-jawiki.txt"

# Mozcの品詞IDを取得
file = File.new("../mozc/id.def", "r")
	id = file.read.split("\n")
file.close

# 「名詞,固有名詞,一般,*,*,*,*」の品詞IDを取得。
# 「名詞,固有名詞,人名,一般,*,*」は上位候補になりにくいで使わない
id = id.grep(/\ 名詞,固有名詞,一般,\*,\*,\*,\*/)
id = id[0].split(" ")[0]

file = File.new($filename, "r")
	lines = file.read.split("\n")
file.close

dicfile = File.new($dicname, "w")

lines.length.times do |i|
	# 品詞IDを付与する。コストは後で計算
	# せいぶつがく	0	0	6000	生物学
	s = lines[i]
	s = s.split("	")
	s = [s[0], id, id, s[3], s[4]]
	dicfile.puts s.join("	")
end

dicfile.close
