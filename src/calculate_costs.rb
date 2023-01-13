#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# calculate_costs
# ==============================================================================

def calculate_costs
	# jawikiの見出し語ヒット数を読み込む
	# jawikititles	0	0	34	中居正広
	file = File.new("../jawiki-titles/jawiki-latest-all-titles-in-ns0.hits", "r")
		lines = file.read.split("\n")
	file.close

	# 追加辞書を加える
	# なかいまさひろ	1916	1916	6477	中居正広
	file = File.new($filename, "r")
		lines = lines + file.read.split("\n")
	file.close

	# jawikiヒット数の下に追加辞書が来るよう並べ替える
	# 中居正広	jawikititles	0	0	34
	# 中居正広	なかいまさひろ	1847	1847	5900
	# 中居正広	なかいまさひろ	1917	1917	6477
	lines.length.times do |i|
		s = lines[i].split("	")
		lines[i] = s[-1] + "	" + s[0..3].join("	")
	end

	lines = lines.sort
	jawiki = []

	lines.length.times do |i|
		s = lines[i].split("	")
		s[4] = s[4].to_i

		# jawikiの見出し語を取得
		# 中居正広	jawikititles	0	0	34
		if s[1] == "jawikititles"
			jawiki = s
			# jawikiの見出し語は後でまとめて削除
			lines[i] = nil

			# jawikiのヒット数が大きいときは抑制
			if jawiki[4] > 30
				jawiki[4] = 30
			end

			next
		end

		# jawikiの見出し語にヒットしない英数字のみの表記は除外
		if s[0] != jawiki[0] && s[0].length == s[0].bytesize
			lines[i] = nil
			next
		end

		# jawikiの見出し語にヒットしない表記はコストのベースを8000にする
		# コスト = 8000 + (元のコスト/10)
		if s[0] != jawiki[0]
			s[4] = (8000 + (s[4] / 10)).to_s
			lines[i] = s.join("	")
			next
		end

		# jawikiの見出し語に1回ヒットする表記はコストのベースを7000にする
		# 中居正広	なかいまさひろ	1917	1917	6477
		# コスト = 7000 + (元のコスト/10)
		if jawiki[4] == 1
			s[4] = (7000 + (s[4] / 10)).to_s
			lines[i] = s.join("	")
			next
		end

		# jawikiの見出し語に2回以上ヒットする表記はコストのベースを6000にする
		# コスト = 6000 + (元のコスト/10) - (ヒット数*30)
		s[4] = (6000 + (s[4] / 10) - (jawiki[4] * 30)).to_s
		lines[i] = s.join("	")
	end

	lines = lines.compact

	# Mozc形式の並びに戻す
	lines.length.times do |i|
		s = lines[i].split("	")
		lines[i] = s[1..-1].join("	") + "	" + s[0]
	end

	lines = lines.sort

	dicfile = File.new($dicname, "w")
		dicfile.puts lines
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
	$dicname = $filename + ".costs"

	calculate_costs
end
