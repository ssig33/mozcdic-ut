#!/bin/bash

UTDICDATE="20220723"

#altcannadic="true"
chimei="true"
#edict2="true"
jawikiarticles="true"
jinmeiut="true"
neologd="true"
#skkdic="true"
#sudachidict="true"


# ==============================================================================
# Make each dictionary
# ==============================================================================

rm -f ../mozcdic-ut-*.txt
rm -f ../*/mozcdic-*.txt*

echo "Get Mozc and make mozc-*.tar.bz2..."
cd ../mozc/
ruby get_mozc_git.rb

echo "Get jawiki-titles and add search results to each title..."
cd ../jawiki-titles/
ruby add_search_results_to_each_title.rb

echo "Generate alt-cannadic entries..."
cd ../alt-cannadic/
ruby convert_alt_cannadic_to_mozcdic.rb

echo "Generate chimei entries..."
cd ../chimei/
ruby fix_ken_all.rb
ruby generate_chimei_for_mozcdic.rb

echo "Generate edict2 entries..."
cd ../edict2/
ruby convert_edict2_to_mozcdic.rb

echo "Generate jawiki-articles entries..."
cd ../jawiki-articles/
ruby generate_jawiki_ut.rb
ruby convert_jawiki_ut_to_mozcdic.rb
ruby ../src/filter_unsuitable_entries.rb mozcdic-ut-jawiki.txt

echo "Generate jinmei-ut entries..."
cd ../jinmei-ut/
ruby convert_jinmei_ut_to_mozcdic.rb

echo "Generate neologd entries..."
cd ../neologd/
ruby convert_neologd_to_mozcdic.rb
ruby ../src/filter_unsuitable_entries.rb mozcdic-ut-neologd.txt

echo "Generate skkdic entries..."
cd ../skkdic/
ruby convert_skkdic_to_mozcdic.rb

echo "Generate sudachidict entries..."
cd ../sudachidict/
ruby convert_sudachidict_to_mozcdic.rb
ruby ../src/filter_unsuitable_entries.rb mozcdic-ut-sudachidict-*.txt

cd ../src/


# ==============================================================================
# Extract new entries and calculate costs
# ==============================================================================

if [[ $altcannadic = "true" ]]; then
echo "Add alt-cannadic entries..."
cat ../alt-cannadic/mozcdic-ut-alt-cannadic*.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $chimei = "true" ]]; then
echo "Add chimei entries..."
cat ../chimei/mozcdic-ut-chimei.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $edict2 = "true" ]]; then
echo "Add edict2 entries..."
cat ../edict2/mozcdic-ut-edict2.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $jawikiarticles = "true" ]]; then
echo "Add jawiki-articles entries..."
cat ../jawiki-articles/mozcdic-ut-jawiki.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $jinmeiut = "true" ]]; then
echo "Add jinmei-ut entries..."
cat ../jinmei-ut/mozcdic-ut-jinmei.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $neologd = "true" ]]; then
echo "Add neologd entries..."
cat ../neologd/mozcdic-ut-neologd.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $skkdic = "true" ]]; then
echo "Add skkdic entries..."
cat ../skkdic/mozcdic-ut-skkdic.txt >> mozcdic-ut-$UTDICDATE.txt
fi

if [[ $sudachidict = "true" ]]; then
echo "Add sudachidict entries..."
cat ../sudachidict/mozcdic-ut-sudachidict-*.txt >> mozcdic-ut-$UTDICDATE.txt
fi

echo "Remove unnecessary entries..."
ruby remove_unnecessary_entries.rb mozcdic-ut-$UTDICDATE.txt

echo "Calculate costs..."
ruby calculate_costs.rb mozcdic-ut-$UTDICDATE.txt.need

mv mozcdic-ut-$UTDICDATE.txt.need.costs ../mozcdic-ut-$UTDICDATE.txt

echo "Update documents..."
ruby update_documents.rb

echo "Copy mozc-*.tar.bz2 and PKGBUILD..."
cp -f ../mozc/mozc-*.tar.bz2 ../../
cp -f ../pkgbuild/*.PKGBUILD ../../


# ==============================================================================
# Make mozcdic-ut-*.tar.bz2
# ==============================================================================

echo "Copy files to mozcdic-ut-$UTDICDATE..."
cd ../../
rm -rf mozcdic-ut-$UTDICDATE
rsync -a mozcdic-ut-dev/* mozcdic-ut-$UTDICDATE --exclude=id.def --exclude=*.bzl \
--exclude=jawiki-latest* --exclude=jawiki-ut*.txt --exclude=KEN_ALL.* --exclude=*.csv \
--exclude=*.xml --exclude=*.gz --exclude=*.bz2 --exclude=*.xz --exclude=*.zip \
--exclude=*.html --exclude=_*.rb --exclude=*/mozcdic*.txt*

echo "Compress mozcdic-ut-$UTDICDATE..."
tar -cjf mozcdic-ut-$UTDICDATE.tar.bz2 mozcdic-ut-$UTDICDATE

echo "Done."
