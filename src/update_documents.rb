#! /usr/bin/env ruby
# coding: utf-8


# ==============================================================================
# Get date, mozcver, utdicdate, sha256sum
# ==============================================================================

# Get date
date = `date +"%Y-%m-%d"`.chomp

# Get mozcver
mozcver = Dir.glob("../mozc/mozc-*.*.*.102.*.tar.bz2")[0]
mozcver = mozcver.split("../mozc/mozc-")[1]
mozcver = mozcver.split(".tar.bz2")[0]
puts "mozcver = " + mozcver

mozcdate = mozcver.split(".")[-1]

# Get utdicdate
file = File.new("make-dictionaries.sh", "r")
	utdicdate = file.read.split("UTDICDATE=\"")[1]
file.close

utdicdate = utdicdate.split("\"")[0]
puts "utdicdate = " + utdicdate

# Get sha256sum of Mozc
sha256 = `sha256sum ../mozc/mozc-#{mozcver}.tar.bz2`.split(" ")[0]
puts "mozc sha256sum = " + sha256


# ==============================================================================
# Update README.md
# ==============================================================================

file = File.new("../README.md", "r")
	lines = file.read
file.close

lines = lines.sub(/date:\ \d{4}-\d{2}-\d{2}/, "date: " + date)
lines = lines.gsub(/mozc-\d\.\d{2}\.\d{4}\.102/, "mozc-" + mozcver)
lines = lines.gsub(/mozcdic-ut-\d{8}/, "mozcdic-ut-" + utdicdate)
lines = lines.gsub(/fcitx5-mozc-ut-\d{8}/, "fcitx5-mozc-ut-" + utdicdate)

file = File.new("../README.md", "w")
	file.puts lines
file.close


# ==============================================================================
# Make LICENSE
# ==============================================================================

Dir.chdir("../")
`awk '/## License/,/## Download/' README.md > LICENSE`
`head -n -2 LICENSE > LICENSE.new`
`mv LICENSE.new LICENSE`
Dir.chdir("src/")


# ==============================================================================
# Update PKGBUILD
# ==============================================================================

pkgbuild = Dir.glob("../pkgbuild/*.PKGBUILD")[-1]

# Update filenames
pkgbuild_new = "../pkgbuild/fcitx5-mozc-ut-" + mozcdate + ".PKGBUILD" 

File.rename(pkgbuild, pkgbuild_new)
pkgbuild = pkgbuild_new

file = File.new(pkgbuild, "r")
	lines = file.read
file.close

# Update mozcver
lines = lines.sub(/^_mozcver=.*\n/, "_mozcver=" + mozcver + "\n")

# Update utdicver
lines = lines.sub(/_utdicver=\d{8}/, "_utdicver=" + utdicdate)

# Update sha256sum
lines = lines.sub(/sha256sums=\('.{64}\'\n/, "sha256sums=('" + sha256 + "'\n")

file = File.new(pkgbuild, "w")
	file.puts lines
file.close
