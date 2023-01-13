#! /usr/bin/env ruby
# coding: utf-8

require 'nkf'


# ==============================================================================
# filter_unsuitable_entries
# ==============================================================================

def filter_unsuitable_entries
	# Mozc形式に変換した辞書を読み込む
	# なかいまさひろ	1917	1917	6477	中居正広
	file = File.new($filename, "r")
		lines = file.read.split("\n")
	file.close

	# フィルタリング対象のIDを取得
	# 品詞IDを取得
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	id = id.grep(/\ 名詞,固有名詞,一般,\*,\*,\*,\*/)
	id = id[0].split(" ")[0]

	# 単語フィルタを読み込む
	file = File.new("../src/unsuitable-entries.txt", "r")
		filter = file.read.split("\n")
	file.close

	filter.length.times do |i|
		# エントリが正規表現になっているときは正規表現を作る
		# /\Aバカ/
		if filter[i].index("/") == 0
			filter[i] = /#{filter[i][1..-2]}/
		end
	end

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		s = lines[i].split("	")

		# フィルタリング対象のIDの場合は実行
		if s[1] == id
			filter.length.times do |c|
				if s[4].index(filter[c]) != nil
					s[4] = nil
					break
				end
			end
		end

		if s[4] == nil
			next
		end

		dicfile.puts s.join("	")
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
	$dicname = $filename + ""

	filter_unsuitable_entries
end
