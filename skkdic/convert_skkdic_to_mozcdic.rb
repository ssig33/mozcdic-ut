#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# convert_skkdic_to_mozcdic
# ==============================================================================

def convert_skkdic_to_mozcdic
	# Mozcの品詞IDを取得
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	# 「名詞,固有名詞,人名,一般,*,*」は優先度が低いので使わない。
	# 「名詞,固有名詞,一般,*,*,*」は後でフィルタリングする。
	id = id.grep(/\ 名詞,一般,\*,\*,\*,\*,\*/)
	id = id[0].split(" ")[0]

	file = File.new($filename, "r")
		lines = file.read.encode("UTF-8", "EUC-JP")
		lines = lines.split("\n")
	file.close

	l2 = []
	p = 0

	lines.length.times do |i|
		# わりふr /割り振/割振/
		# いずみ /泉/和泉;地名,大阪/出水;地名,鹿児島/
		s = lines[i].split(" /")
		yomi = s[0]
		yomi = yomi.gsub("う゛", "ゔ")

		# 読みが英数字を含む場合はスキップ
		if yomi.bytesize != yomi.length * 3
			next
		end

		hyouki = s[1].split("/")

		hyouki.length.times do |c|
			hyouki[c] = hyouki[c].split(";")[0]

			# 表記に優先度をつける
			cost = 7000 + (10 * c)

 			# 2個目以降の表記が前のものと重複している場合はスキップ
			# ＩＣカード/ICカード/
			if c > 0 && hyouki[c] == hyouki[c - 1]
				next
			end

			l2[p] = yomi + "	" + id + "	" + id + "	" + cost.to_s + "	" + hyouki[c]
			p = p + 1
		end
	end

	lines = l2
	l2 = []

	# 重複行を削除
	lines = lines.uniq.sort

	dicfile = File.new($dicname, "w")
		dicfile.puts lines
	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

`wget -N https://skk-dev.github.io/dict/SKK-JISYO.L.gz`
`rm -f SKK-JISYO.L`
`gzip -dk SKK-JISYO.L.gz`
$filename = "SKK-JISYO.L"
$dicname = "mozcdic-ut-skkdic.txt"

convert_skkdic_to_mozcdic

`rm -f SKK-JISYO.L`
