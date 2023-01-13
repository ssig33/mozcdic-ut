#! /usr/bin/env ruby
# coding: utf-8

`wget -N https://raw.githubusercontent.com/google/mozc/master/src/data/version/mozc_version_template.bzl`

file = File.new("mozc_version_template.bzl", "r")
	lines = file.read.split("\n")
file.close

version = ""

lines.length.times do |i|
	if lines[i].index("MAJOR = ") == 0
			version = lines[i].split("MAJOR = ")[1] + "."
			next
	end

	if lines[i].index("MINOR = ") == 0
			version = version + lines[i].split("MINOR = ")[1] + "."
			next
	end

	if lines[i].index("BUILD_OSS = ") == 0
			version = version + lines[i].split("BUILD_OSS = ")[1]
			break
	end
end

date = `date "+%Y%m%d"`.chomp
mozcdir = "mozc-" + version + ".102." + date


# ==============================================================================
# get_mozc_git
# ==============================================================================

if FileTest.exist?(mozcdir + ".tar.bz2") == true
	puts mozcdir + ".tar.bz2 already exists."
	exit
end

`rm -f {mozc-*.tar.bz2,mozc-*.zip}`
`rm -rf {mozc,mozc-fcitx,#{mozcdir}}`
`git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/fcitx/mozc.git`
`rm -rf mozc/.git/`

`cp mozc/src/data/dictionary_oss/id.def .`
`cat mozc/src/data/dictionary_oss/dictionary*.txt > mozcdic.txt`

puts "Compress " + mozcdir + "..."
`mv mozc #{mozcdir}`
`tar -cjf #{mozcdir}.tar.bz2 #{mozcdir}`
`rm -rf #{mozcdir}`
