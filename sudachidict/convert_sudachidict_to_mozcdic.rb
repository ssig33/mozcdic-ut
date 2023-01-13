#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# Check sudachidict version
# ==============================================================================

`wget https://github.com/WorksApplications/SudachiDict/commits/develop/src/main/text/core_lex.csv -O sudachidict.html`

file = File.new("sudachidict.html", "r")
	dictver = file.read.split("/WorksApplications/SudachiDict/commit/")[1]
file.close

`rm -f sudachidict.html`

dictver = dictver[0..6]
puts "sudachidict = " + dictver

corelex = "core_lex." + dictver + ".csv"
notcorelex = "notcore_lex." + dictver + ".csv"

if FileTest.exist?(corelex) == false
	`rm -f core_lex.*`
	`wget https://github.com/WorksApplications/SudachiDict/raw/develop/src/main/text/core_lex.csv -O #{corelex}`
else
	puts corelex + " already exists."
end

if FileTest.exist?(notcorelex) == false
	`rm -f notcore_lex.*`
	`wget -nc https://github.com/WorksApplications/SudachiDict/raw/develop/src/main/text/notcore_lex.csv -O #{notcorelex}`
else
	puts notcorelex + " already exists."
end


# ==============================================================================
# convert_sudachidict_to_mozcdic
# ==============================================================================

def convert_sudachidict_to_mozcdic
	# mecab-user-dict-seedを読み込む
	file = File.new($filename, "r")
		lines = file.read.split("\n")
	file.close

	l2 = []
	p = 0

	# sudachidict のエントリから読みと表記を取得
	lines.length.times do |i|
		# https://github.com/WorksApplications/Sudachi/blob/develop/docs/user_dict.md
		# 見出し (TRIE 用),左連接ID,右連接ID,コスト,見出し (解析結果表示用),\
		# 品詞1,品詞2,品詞3,品詞4,品詞 (活用型),品詞 (活用形),\
		# 読み,正規化表記,辞書形ID,分割タイプ,A単位分割情報,B単位分割情報,※未使用

		# little glee monster,4785,4785,5000,Little Glee Monster,名詞,固有名詞,一般,*,*,*,\
		# リトルグリーモンスター,Little Glee Monster,*,A,*,*,*,*
		# モーニング娘,5144,5142,10320,モーニング娘,名詞,固有名詞,一般,*,*,*,\
		# モーニングムスメ,モーニング娘。,*,C,*,*,*,*
		# 新型コロナウィルス,5145,5144,13856,新型コロナウィルス,名詞,普通名詞,一般,*,*,*,\
		# シンガタコロナウィルス,新型コロナウイルス,*,C,*,*,*,*
		# アイアンマイケル,5144,4788,9652,アイアンマイケル,名詞,固有名詞,人名,一般,*,*,\
		# アイアンマイケル,アイアン・マイケル,*,C,*,*,*,*

		s = lines[i].split(",")
		# 「読み」を取得
		yomi = s[11]
		yomi = yomi.tr("=・", "")
		# 「見出し (解析結果表示用)」を表記にする
		hyouki = s[4]

		# 読みのカタカナをひらがなに変換
		# 「tr('ァ-ヴ', 'ぁ-ゔ')」よりnkfのほうが速い
		yomi = NKF.nkf("--hiragana -w -W", yomi)
		yomi = yomi.tr('ゐゑ', 'いえ')

		# 読みがひらがな以外を含む場合はスキップ
		if yomi != yomi.scan(/[ぁ-ゔー]/).join
			next
		end

		# 表記が英数字のみで、表記と「見出し (TRIE 用)」の downcase が同じ場合は表記に揃える
		if hyouki.length == hyouki.bytesize && hyouki.downcase == s[0].downcase
			s[0] = hyouki
		end

		# 表記が「見出し (TRIE 用)」と異なる場合はスキップ
		if hyouki != s[0] ||
		# 名詞以外の場合はスキップ
		s[5] != "名詞" ||
		# 「地名」をスキップ。地名は郵便番号ファイルから生成する
		s[7] == "地名" ||
		# 「名」をスキップ
		s[8] == "名"
			next
		end

		# [読み, 表記, コスト] の順に並べる
		l2[p] = [yomi, hyouki, s[3].to_i]
		p = p + 1
	end

	lines = l2.sort
	l2 = []

	# Mozcの品詞IDを取得
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	# 「名詞,固有名詞,人名,一般,*,*」は優先度が低いので使わない。
	# 「名詞,固有名詞,一般,*,*,*」は後でフィルタリングする。
	id = id.grep(/\ 名詞,固有名詞,一般,\*,\*,\*,\*/)
	id = id[0].split(" ")[0]

	# Mozc形式で書き出す
	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		s1 = lines[i]
		s2 = lines[i - 1]

		# [読み..表記] が重複する場合はスキップ
		if s1[0..1] == s2[0..1]
			next
		end

		# コストがマイナスの場合は8000にする
		if s1[2] < 0
			s1[2] = 8000
		end

		# コストが10000を超える場合は10000にする
		if s1[2] > 10000
			s1[2] = 10000
		end

		# コストを 6000 < cost < 7000 に調整する
		s1[2] = 6000 + (s1[2] / 10)

		# [読み,id,id,コスト,表記] の順に並べる
		t = [s1[0], id, id, s1[2].to_s, s1[1]]
		dicfile.puts t.join("	")
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

$filename = corelex
$dicname = "mozcdic-ut-sudachidict-core.txt"
convert_sudachidict_to_mozcdic

$filename = notcorelex
$dicname = "mozcdic-ut-sudachidict-notcore.txt"
convert_sudachidict_to_mozcdic
