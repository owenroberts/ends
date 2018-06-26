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

GIF_NAME=social/$CAT/$CAT-$DATE-part-$PART.gif
MP4_NAME=social/$CAT/$CAT-$DATE-part-$PART.mp4

echo "making gif"
convert -delay 10 -loop 0 ~/Downloads/$PART-*.png $GIF_NAME

# scale problem .... 
echo "making mp4"
echo "mp4 width:"
read WIDTH
# try square video ... 
# ffmpeg -i social/fart/fart-2018-03-06.mp4 -filter:v "crop=512:512:128:0" -c:a copy social/fart/fart-2018-03-06_half.mp4

ffmpeg -ignore_loop 0 -i $GIF_NAME -c:v libx264 -pix_fmt yuv420p -crf 4 -b:v 300K -vf scale=$WIDTH:-1 -t 4 -movflags +faststart $MP4_NAME

echo "posting on twitter" # uses tweet.sh
echo "tweet text:"
read TWEET
GIF=$(./tweet.sh upload $GIF_NAME | jq -r .media_id_string)
./tweet.sh tw -m $GIF $TWEET http://lines.owen.cool/$CAT/`date +%Y`/`date +%m`/`date +%d`/$CAT-$PART.html

# remove downloads ? 

# post on insta (?)
# https://www.npmjs.com/package/ig-upload
# ig-upload login
# echo "ig text:"
# read IG
# ig-upload $MP4_NAME $IG