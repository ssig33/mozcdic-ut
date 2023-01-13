---
title: Mozc UT Dictionary
date: 2022-07-23
---

## Overview

Mozc UT Dictionary is a collection of dictionaries for Mozc. It will add over 1,000,000 entries to Mozc. See [this page](http://linuxplayers.g1.xrea.com/mozc-ut.html) for the latest information.

## License

File | License | Note
-- | -- | --
chimei | [public domain](http://www.post.japanpost.jp/zipcode/dl/readme.html) | Placenames from ZIP codes.
jawiki-articles | [CC-BY-SA 3.0](https://ja.wikipedia.org/wiki/Wikipedia:ウィキペディアを二次利用する) | Generated from Japanese Wikipedia.
jinmei-ut | [Apache-2.0](http://linuxplayers.g1.xrea.com/mozc-ut.html) | Japanese name dictionary.
neologd | [Apache-2.0](https://github.com/neologd/mecab-ipadic-neologd) | Modified mecab-user-dict-seed entries.
jawiki-titles | [CC-BY-SA 3.0](https://ja.wikipedia.org/wiki/Wikipedia:ウィキペディアを二次利用する) | For cost adjustment.
mozc | [BSD-3-Clause](https://github.com/google/mozc) | For checking duplicates.
.rb, .sh | [Apache-2.0](http://linuxplayers.g1.xrea.com/mozc-ut.html) | Codes to generate dictionaries.

## Optional dictionaies

They are not included in Mozc UT Dictionary by default.

File | License | Note
-- | -- | --
alt-cannadic | [GPL-2.0](https://ja.osdn.net/projects/alt-cannadic/wiki/FrontPage) | 
edict2 | [CC-BY-SA 3.0](http://www.edrdg.org/jmdict/edict.html) | 
skkdic | [GPL-2.0-or-later](http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1) | 
sudachidict | [Apache-2.0](https://github.com/WorksApplications/SudachiDict) | 

## Download

[OSDN](https://osdn.net/users/utuhiro/pf/utuhiro/files/)

## Install

Download Mozc from [GitHub](https://github.com/google/mozc) and add Mozc UT Dictionary to Mozc.

```
cat mozcdic-ut-20220723/mozcdic-ut-20220723.txt >> mozc-master/src/data/dictionary_oss/dictionary00.txt
```

Build Mozc as usual.

## Install (Arch Linux)

Get "fcitx5-mozc-ut-20220723.PKGBUILD" from [OSDN](https://osdn.net/users/utuhiro/pf/utuhiro/files/) and run it.

```
rm -rf ~/.cache/bazel/
makepkg -is -p fcitx5-mozc-ut-20220723.PKGBUILD
```

## Option: Rebuild Mozc UT Dictionary

NOTE: `sh make-dictionaries.sh` downloads "jawiki-latest-pages-articles.xml.bz2" (over 3.0GB).

```
yay -S --needed ruby rubygems rsync
gem install bzip2-ffi parallel

tar xf mozcdic-ut-20220723.tar.bz2
mv mozcdic-ut-20220723 mozcdic-ut-dev
cd mozcdic-ut-dev/src/
mousepad make-dictionaries.sh
```

Comment out unnecessary dictionaries. If you want to use only chimei and neologd dictionaries, edit the lines like this.

```
#altcannadic="true"
chimei="true"
#edict="true"
#jawikiarticles="true"
#jinmeiut="true"
neologd="true"
#skkdic="true"
#sudachidict="true"
```

Update Mozc UT Dictionary.

```
sh make-dictionaries.sh
```

The new "mozcdic-ut-20220723.tar.bz2" is generated.

```
ls ../../mozcdic-ut-20220723.tar.bz2
```

## 更新の概要

2010-11-03: Mozc UT辞書をリリース。

2016-01-14: Mozc NEologd UT辞書をリリース。コストは mecab-ipadic-NEologd のものをベースにした。

2016-10-13: Mozc UT2辞書をリリース。Mozc UT辞書を入れたパーティションを壊してしまったので作り直した。

2016-10-20: Mozc UT2辞書のコスト計算を変更。ウィキペディア全記事（解凍前で3GB）から単語を完全一致検索して、ヒット数が2ならコストを6000-(100*2)、ヒット数が0ならコストを8000、のようにした（コストを上げると優先度が下がる。計算式はダミー）。この検索には長い時間と高い負荷がかかった。

2020-01-15: NEologd辞書を公式Mozcにマージした形で配布するのをやめた。当時は公式Mozcにパッチがいくつか必要になっていたので、辞書も追加ファイルの1つにするほうが扱いやすいと判断した。

2020-02-06: NEologd辞書のコストを独自に計算することにした。元のコストだと「三浦大知」より「三浦大地」が優先される。ウィキペディア全見出し（解凍前で12MB）から「三浦大知」を前方一致検索して、そのヒット数から「三浦大知」のコストを計算するようにした。これはウィキペディア全記事（解凍前で3GB）から「三浦大知」を完全一致検索するより遥かに処理が軽い。

2020-06-11: 2代目Mozc UT辞書をリリース。UT2辞書とNEologd辞書をまとめた形だが、辞書作成用のコードはほとんど書き直した。UT2辞書に相当する部分はコストの計算方法をNEologd辞書と同じものにした。辞書の組み合わせを変えて配布するときは、「mozcdic-utからの派生」という意味でファイル名を「mozcdic-ut-neologd」のようにした。

2020-06-22: jawiki-articles辞書を追加。ウィキペディア全見出しを表記とし、対応する記事本文から読みを得て、辞書を作成した。コストの計算方法はNEologd辞書と同じ。jawiki-articles辞書はユーザー自身でアップデートでき、新しい人名や用語への対応が容易。1人の努力に頼り切らない仕組みが必要だと考えた。

2021-02-15: SudachiDict を追加。

[HOME](http://linuxplayers.g1.xrea.com/index.html)
