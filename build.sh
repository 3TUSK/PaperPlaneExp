#!/usr/bin/env bash

DRAWIO_FALLBACK=""
# https://stackoverflow.com/questions/394230
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  DRAWIO_FALLBACK="" # TODO
elif [[ "$OSTYPE" == "darwin"* ]]; then
  DRAWIO_FALLBACK=/Applications/draw.io.app/Contents/MacOS/draw.io
fi

if ! which -s pandoc; then
  echo "You need pandoc to convert Markdown to HTML." >&2
  exit 1
fi
if ! [[ ${DRAWIO_PATH:-$DRAWIO_FALLBACK} ]]; then
  echo "Cannot determine location of draw.io, you need Draw.io client to build svg." >&2
  exit 1
fi

for s in `ls | grep Step | grep .drawio`;
do
  ${DRAWIO_PATH:-$DRAWIO_FALLBACK} --export --format svg $s
done

# https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#index-IFS
IFS_BACKUP=$IFS
IFS=$'\n'

for lang in `cat lang_list | sed "s/en,/,/g"`; do
  IFS=','
  entry=($lang)
  lang_code=${entry[0]}
  pandoc --standalone --css=style.css --metadata title=${entry[1]} -o index${lang_code:+"-$lang_code"}.html README${lang_code:+"-$lang_code"}.md
  pandoc --standalone --css=style.css -o Instructions${lang_code:+"-$lang_code"}.html Instructions${lang_code:+"-$lang_code"}.md
done

if ! [[ -d pages ]]; then
  mkdir pages
fi

mv *.svg *.html ./pages/
cp *.css ./pages/
IFS=$IFS_BACKUP
