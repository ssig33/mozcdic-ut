#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# generate_chimei_for_mozcdic
# ==============================================================================

def generate_chimei_for_mozcdic
	# Mozcの品詞IDを取得
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	id = id.grep(/\ 名詞,固有名詞,地域,一般,\*,\*,\*/)
	id = id[0].split(" ")[0]

	dicfile = File.new($filename, "r")
		lines = dicfile.read.split("\n")
	dicfile.close

	# 半角数字をひらがなに変換する配列を作成
	d1 = ["", "いち", "に", "さん", "よん", "ご", "ろく", "なな", "はち", "きゅう"]

	# d1[10] から d1[59] までのひらがなを作成
	# さっぽろしひがしくきた51じょうひがし
	d2 = ["じゅう", "にじゅう", "さんじゅう", "よんじゅう", "ごじゅう"]

	5.times do |p|
		10.times do |q|
			d1[((p + 1) * 10) + q] = d2[p] + d1[q]
		end
	end

	l2 = []
	p = 0

	lines.length.times do |i|
		s = lines[i].gsub("\"", "")
		s = s.split(",")

		# 並びの例
		# "トヤマケン","タカオカシ","ミハラマチ","富山県","高岡市","美原町"
		# s[3], s[4], s[5], s[6], s[7], s[8]

		# 読みをひらがなに変換
		# 「tr('ァ-ヴ', 'ぁ-ゔ')」よりnkfのほうが速い
		s[3] = NKF.nkf("--hiragana -w -W", s[3])
		s[4] = NKF.nkf("--hiragana -w -W", s[4])
		s[5] = NKF.nkf("--hiragana -w -W", s[5])

		# 読みの「・」を取る
		s[5] = s[5].gsub("・", "")

		# 市を出力
		t = [s[4], id, id, "9000", s[7]]
		l2[p] = t.join("	")
		p = p + 1

		# 町の読みが半角数字を含むか確認
		c = s[5].scan(/\d/).join.to_i

		# 町の読みの半角数字が59以下の場合はひらがなに変換
		# さっぽろしひがしくきた51じょうひがし
		if c > 0 && c < 60
			s[5] = s[5].gsub(c.to_s, d1[c])
		end

		# 町の読みがひらがな以外を含む場合はスキップ
		# 「自由が丘(3～7丁目)」「OAPたわー」
		if s[5] != s[5].scan(/[ぁ-ゔー]/).join ||
		# 町の表記が空の場合はスキップ
		s[8] == ""
			next
		end

		# 町を出力
		t = [s[5], id, id, "9000", s[8]]
		l2[p] = t.join("	")
		p = p + 1

		# 市+町を出力
		t = [s[4..5].join, id, id, "9000", s[7..8].join]
		l2[p] = t.join("	")
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

$filename = "KEN_ALL.CSV.fixed"
$dicname = "mozcdic-ut-chimei.txt"
generate_chimei_for_mozcdic
