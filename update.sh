#!/bin/bash

echo "Category:"
read CAT
echo "Part:"
read PART
echo "Title":
read TITLE

DATE=`date +%Y-%m-%d`

# make directories if not existing
mkdir -p assets/$CAT
mkdir -p _posts/$CAT
mkdir -p social/$CAT

# move json anim file from downloads to current project folder d
mv ~/Downloads/$PART.json assets/$CAT/$PART.json

echo "making html file"
HTML="_posts/$CAT/$DATE-$CAT-$PART.html"
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
></canvas>
{% include post_script.html %}
EOF

# publish to lines.owen.cool
open http://localhost:4000
echo "Publish? y/n"
read PUBLISH

if [ "$PUBLISH" = "y" ] ; then
   	git add .
   	git commit -m "updates $TITLE part $PART"
   	git push origin master
else
    exit
fi

echo "making gif"
convert -delay 10 -loop 0 ~/Downloads/$PART-*.png social/$CAT/$CAT-$DATE.gif

# scale problem .... 
echo "making mp4"
echo "mp4 width:"
read WIDTH
ffmpeg -ignore_loop 0 -i social/$CAT/$CAT-$DATE.gif -c:v libx264 -pix_fmt yuv420p -crf 4 -b:v 300K -vf scale=$WIDTH:-1 -t 4 -movflags +faststart social/$CAT/$CAT-$DATE.mp4

echo "posting on twitter" # uses tweet.sh
echo "tweet text:"
read TWEET
GIF=$(./tweet.sh upload social/$CAT/$CAT-$DATE.gif | jq -r .media_id_string)
./tweet.sh tw -m $GIF $TWEET http://lines.owen.cool/$CAT/`date +%Y`/`date +%m`/`date +%d`/$CAT-$PART.html

# remove downloads ? 

# post on insta (?)