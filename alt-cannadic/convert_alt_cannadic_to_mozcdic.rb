#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# convert_alt_cannadic_to_mozcdic
# ==============================================================================

def convert_alt_cannadic_to_mozcdic
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
		s = lines[i].chomp.split(" ")

		# あきびん #T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン #T35*150 空きびん
		yomi = s[0]
		yomi = yomi.gsub("う゛", "ゔ")

		# 読みがひらがな以外を含む場合はスキップ
		if yomi != yomi.scan(/[ぁ-ゔー]/).join
			next
		end

		hinsi = ""

		(s.length - 1).times do |c|
			# cannadicの品詞を取得
			if s[c + 1].index("#") == 0
				hinsi = s[c + 1]
				next
			end

			hyouki = s[c + 1]

			# cost を作成
			# alt-cannadicのコストは大きいほど優先度が高い。
			cost = hinsi.split("*")[1].to_i
			cost = 7000 - cost

			# 収録する品詞を選択
			if hinsi.index("#T3") == 0 ||
			hinsi.index("#T0") == 0 ||
			hinsi.index("#JN") == 0 ||
			hinsi.index("#KK") == 0 ||
			hinsi.index("#CN") == 0
				l2[p] = yomi + "	" + hyouki + "	" + cost.to_s
				p = p + 1
			else
				next
			end
		end
	end

	lines = l2
	l2 = []
	lines = lines.sort

	p = 0

	lines.length.times do |i|
		s1 = lines[i].chomp.split(" ")
		s2 = lines[i - 1].chomp.split(" ")

		# 「読み+表記」が重複するエントリはスキップ
		if s1[0..1] == s2[0..1]
			next
		end

		l2[p] = s1[0] + "	" + id + "	" + id + "	" + s1[2] + "	" + s1[1]
		p = p + 1
	end

	lines = l2
	l2 = []

	dicfile = File.new($dicname, "w")
		dicfile.puts lines
	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

`wget -nc https://ja.osdn.net/dl/alt-cannadic/alt-cannadic-110208.tar.bz2`
`rm -rf alt-cannadic-110208`
`tar xf alt-cannadic-110208.tar.bz2`
`mv alt-cannadic-110208/{gcanna.ctd,g_fname.ctd} .`

$filename = "gcanna.ctd"
$dicname = "mozcdic-ut-alt-cannadic.txt"
convert_alt_cannadic_to_mozcdic

$filename = "g_fname.ctd"
$dicname = "mozcdic-ut-alt-cannadic-jinmei.txt"
convert_alt_cannadic_to_mozcdic

`rm -rf alt-cannadic-110208/`
`rm -f *.ctd`
