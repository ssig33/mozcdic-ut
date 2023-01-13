#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# convert_edict2_to_mozcdic
# ==============================================================================

def convert_edict2_to_mozcdic
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
		# 全角スペースで始まるエントリはスキップ
		if lines[i][0] == "　" ||
		# 名詞のみを収録
		lines[i].index(" /(n") == nil
			next
		end

		s = lines[i].split(" /(n")[0]

		# 表記と読みに分ける。表記または読みが複数あるときはそれぞれ最初のものを採用する
		# 脇見(P);わき見;傍視 [わきみ(P);ぼうし(傍視)] /
		if s.index(" [") != nil
			s = s.split(" [")
			yomi = s[1].split(";")[0]
			yomi = yomi.sub("]", "")
			hyouki = s[0].split(";")[0]
		# カタカナ語には読みがないので表記から読みを作る
		# ブラスバンド(P);ブラス・バンド /(n) brass band/
		else
			hyouki = s.split(";")[0]
			yomi = hyouki
		end

		hyouki = hyouki.split("(")[0]
		yomi = yomi.split("(")[0]
		yomi = yomi.tr(" ・=", "")

		# 読みのカタカナをひらがなに変換
		yomi = NKF.nkf("--hiragana -w -W", yomi)
		yomi = yomi.tr("ゐゑ", "いえ")

		l2[p] = yomi + "	" + id + "	" + id + "	6000	" + hyouki
		p = p + 1
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

`rm -f edict2`
`wget -N http://ftp.edrdg.org/pub/Nihongo/edict2.gz`
`gzip -dk edict2.gz`
$filename = "edict2"
$dicname = "mozcdic-ut-edict2.txt"

convert_edict2_to_mozcdic

`rm -f edict2`
