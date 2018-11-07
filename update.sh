#!/bin/bash

echo "Category:"
read CAT
echo "Part:"
read PART
echo "Title":
read TITLE
echo "Caption (optional)"
read CAPTION
P="${CAPTION//-/<br><br>}"
echo $P

DATE=`date +%Y-%m-%d`

# make directories if not existing
mkdir -p assets/$CAT
mkdir -p _posts/$CAT
mkdir -p social/$CAT

# move json anim file from downloads to current project folder d
mv ~/Downloads/$PART.json assets/$CAT/$PART.json
W=($(jq -r '.w' assets/$CAT/$PART.json))
H=($(jq -r '.h' assets/$CAT/$PART.json))
BG=($(jq -r '.bg' assets/$CAT/$PART.json))

HTML="_posts/$CAT/$DATE-$CAT-$PART.html"

if [ -f $HTML ]; then
	echo "$HTML found"
else
echo "making html file"
touch $HTML 
cat > $HTML << EOF
---
layout: post
title: $TITLE
part: $PART
date: $DATE
categories: $CAT
---
<canvas 
	id="lines" 
	data-src="{{ site.url }}{{ site.baseurl }}/assets/{{ page.categories.first }}/$PART.json"
	width="$W"
	height="$H"
	style="background-color:#$BG"
></canvas>
<p id="caption">$P</p>
{% include post_script.html %}
EOF
fi
# 
# publish to lines.owen.cool
open http://localhost:4000
echo "Publish? y/n"
read PUBLISH

if [ "$PUBLISH" = "y" ] ; then
   	git add _posts/*
   	git add assets/*
   	git commit -m "updates $TITLE part $PART"
   	git push origin master
else
    exit
    # if already posted but need to make media just to yes
fi

# update without update.sh worked by not sure why ... is it just time?

MP4_NAME=social/$CAT/$CAT-$DATE-part-$PART.mp4

echo "making mp4"
ffmpeg -framerate 10 -pattern_type glob -i ~/Downloads/$PART"-*.png" -c:v libx264 -pix_fmt yuv420p $MP4_NAME

open social/$CAT/

# echo "posting on twitter" # uses tweet.sh
# echo "tweet text:"
# read TWEET
# POST=$(./tweet.sh upload $MP4_NAME | jq -r .media_id_string)
# ./tweet.sh tw -m $POST $TWEET http://lines.owen.cool/$CAT/`date +%Y`/`date +%m`/`date +%d`/$CAT-$PART.html
