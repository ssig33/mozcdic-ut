#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# remove_unnecessary_entries
# ==============================================================================

def remove_unnecessary_entries
	file = File.new($filename, "r")
		lines = file.read.split("\n")
	file.close

	# 重複行を削除
	lines = lines.uniq

	l2 = []
	p = 0

	lines.length.times do |i|
		s = lines[i].split("	")
		yomi = s[0]
		hyouki = s[4]

		# 表記の全角英数を半角に変換
		hyouki = NKF.nkf("-m0Z1 -W -w", hyouki)

		# 表記の「~」を「〜」に置き換える
		# jawiki-latest-all-titles の表記に合わせる。
		hyouki = hyouki.gsub("~", "〜")

		# 表記の最初が空白の場合は取る
		if hyouki[0] == " "
			hyouki = hyouki[1..-1]
		end

		# 表記の全角カンマを半角に変換
		hyouki = hyouki.gsub("，", ", ")

		# 表記の最後が空白の場合は取る（「, 」もここで処理）
		if hyouki[-1] == " "
			hyouki = hyouki[0..-2]
		end

		# 読みにならない文字を削除したhyouki2を作る
		hyouki2 = hyouki.tr(' !?=:・。★☆', '')

		# hyouki2がひらがなとカタカナだけの場合は、読みをhyouki2から作る
		# さいたまスーパーアリーナ
		if hyouki2 == hyouki2.scan(/[ぁ-ゔァ-ヴー]/).join
			yomi = NKF.nkf("--hiragana -w -W", hyouki2)
			yomi = yomi.tr("ゐゑ", "いえ")
		end

		# 読みが2文字以下の場合はスキップ
		if yomi[2] == nil ||
		# hyouki2が1文字の場合はスキップ
		hyouki2[1] == nil ||
		# hyoukiが26文字以上の場合はスキップ
		hyouki[25] != nil ||
		# 読みの文字数がhyouki2の4倍を超える場合はスキップ
		# けやきざかふぉーてぃーしっくす（15文字） 欅坂46（4文字）
		yomi.length > hyouki2.length * 4 ||
		# hyouki2の文字数が読みの文字数より多い場合はスキップ
		# 英数字表記が削除されるのを防ぐため、hyouki2の文字数は (bytesize / 3) とする。
		# みすたーちるどれんりふれくしょん（16文字） Mr.Children REFLECTION（22bytes / 3）
		# あいしす（16文字） アイシス（48bytes / 3）
		yomi.length < hyouki2.bytesize / 3 ||
		# 読みがひらがな以外を含む場合はスキップ
		yomi != yomi.scan(/[ぁ-ゔー]/).join ||
		# hyoukiがコードポイントを含む場合はスキップ
		# デコードする場合
		# hyouki = hyouki.gsub(/\\u([\da-fA-F]{4})/){[$1.hex].pack("U")}
		hyouki.index("\\u") != nil ||
		# hyouki2の数字が101以上の場合はスキップ（100円ショップを残す）
		# 国道120号, 3月26日
		hyouki2.scan(/\d/).join.to_i > 100
			next
		end

		l2[p] = yomi + "	" + s[1..3].join("	") + "	" + hyouki
		p = p + 1
	end

	lines = l2
	l2 = []

	# UT辞書の並びを変える
	# (変更前) げんかん	1823	1823	5278	玄関
	# (変更後) げんかん	玄関	5278	1823	1823
	lines.length.times do |i|
		s = lines[i].split("	")
		s = [s[0], s[4], s[3], s[1], s[2]]
		lines[i] = s.join("	")
	end

	file = File.new("../mozc/mozcdic.txt", "r")
		mozcdic = file.read.split("\n")
	file.close

	# Mozc辞書の並びを変えてマークをつける
	# (変更前) げんかん	1823	1823	6278	玄関
	# (変更後) げんかん	玄関	*6278	1823	1823
	mozcdic.length.times do |i|
		s = mozcdic[i].split("	")
		s = [s[0], s[4], "*" + s[3], s[1], s[2]]
		mozcdic[i] = s.join("	")
	end

	lines = lines + mozcdic
	mozcdic = []
	lines = lines.sort

	# この時点での並び。Mozc辞書が先になる
	# げんかん	玄関	*6278	1823	1823
	# げんかん	玄関	5278	1823	1823

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		s1 = lines[i].split("	")
		s2 = lines[i - 1].split("	")

		# Mozc辞書はスキップ
		if s1[2][0] == "*"
			next
		# Mozc辞書と「読み+表記+ID」が重複するUT辞書はスキップ
		elsif s2[2][0] == "*" && s1[0..1] == s2[0..1] && s1[3..4] == s2[3..4]
			next
		# UT辞書内で重複するエントリをコスト順にスキップ
		elsif s2[2][0] != "*" && s1[0..1] == s2[0..1]
			next
		end

		s1 = [s1[0], s1[3], s1[4], s1[2], s1[1]]
		dicfile.puts s1.join("	")
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

targetfiles = ARGV

if ARGV == []
	puts "Usage: ruby script.rb [FILE]"
	exit
end

targetfiles.length.times do |i|
	$filename = targetfiles[i]
	$dicname = $filename + ".need"

	remove_unnecessary_entries
end
