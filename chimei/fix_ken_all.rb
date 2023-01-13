#! /usr/bin/env ruby
# coding: utf-8


# ==============================================================================
# fix_ken_all
# ==============================================================================

def fix_ken_all
	dicfile = File.new($filename, "r")
		lines = dicfile.read.encode("UTF-8", "SJIS")
		lines = lines.split("\n")
	dicfile.close

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		# 並びの例
		# 46201,"89112","8911275","カゴシマケン","カゴシマシ", "カワカミチョウ(3649)",
		# "鹿児島県","鹿児島市","川上町（３６４９）

		s = lines[i].split(",")
		s[8] = s[8].tr('０-９ａ-ｚＡ-Ｚ（）　−','0-9a-zA-Z() \-')

		# 除外する文字列
		# (例) 「3701、3704、」「4710〜4741」「坪毛沢「2」」
		ng = ["○", "〔", "〜", "、", "「", "を除く", "以外", "その他", \
			"地割", "不明", "以下に掲載がない場合"]

		# 町域表記の () 内に除外文字列があるかチェック
		if s[8].index("(") != nil
			t = s[8].split("(")[1..-1].join("(")

			ng.length.times do |c|
				if t.index(ng[c]) != nil
					# 該当する場合は町域の読みと表記の「(」以降を削除
					s[5] = s[5].split("(")[0]
					s[8] = s[8].split("(")[0]
					break
				end
			end
		end

		# 町域表記の () 外に除外文字列があるかチェック
		ng.length.times do |c|
			if s[8].index(ng[c]) != nil
				# 該当する場合は町域の読みと表記を "" にする
				s[5] = ""
				s[8] = ""
				break
			end
		end

		# 町域の読みの () を取る
		# (例) 「"ハラ(ゴクラクザカ)","原(極楽坂)"」を
		# 「"ハラゴクラクザカ","原(極楽坂)"」にする。
		# 表記の () はそのままにする。「原極楽坂」だと読みにくいので
		s[5] = s[5].gsub("(", "")
		s[5] = s[5].gsub(")", "")

		dicfile.puts s.join(",")
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

`rm -f KEN_ALL.CSV`
`wget -N https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip`
`unzip ken_all.zip`
$filename = "KEN_ALL.CSV"
$dicname = "KEN_ALL.CSV.fixed"
fix_ken_all

`rm -f KEN_ALL.CSV`
