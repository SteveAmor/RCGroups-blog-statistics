#!/bin/bash

if [ -z $1 ] 
then
	echo ""
	echo "Please provide a User Id (eg 367321)"
	echo ""
	exit 0
fi

curl -silent "http://www.rcgroups.com/forums/member.php?u=$1&page=10000" > "pages.txt"
echo ""
echo "RC Groups User's Blog Stats"
echo ""
echo "User $1"

more pages.txt | grep "<title>" | sed 's/<title>//g' | awk 'BEGIN { FS = "-" } ; { print $1 }'
pages=$(more pages.txt | grep '<title>' | awk 'BEGIN { FS = "-" } ; { print $2 }' | sed 's/Page//' | sed 's/ //' | awk '{ pages += $1 } END { printf pages }')

curl -silent "http://www.rcgroups.com/forums/member.php?u=$1&page=1" > "dump.txt"
for ((c=2; c<(pages+1); c++))
do
curl -silent "http://www.rcgroups.com/forums/member.php?u=$1&page=$c" >> "dump.txt"
done 

posts=$(awk '$1 ~ /<div class="blogPost"/ {++posts} END {printf posts}' FS=: dump.txt)
if [ -z $posts ] 
then
	echo "0 attachments"
else
	echo $posts" posts"
fi

comments=$(more dump.txt | grep ">Comments (" | awk 'BEGIN { FS = "\"" } ; { print $7 }' | sed 's/>Comments (//g' | sed 's/)<\/a>//g' | awk '{ comments += $1 } END { printf comments }')
if [ -z $comments ] 
then
	echo "0 comments"
else
	echo $comments" comments"
fi

attachments=$(awk '$1 ~ /<div class="attach_filename">/ {++attachments} END {printf attachments}' FS=: dump.txt)
if [ -z $attachments ] 
then
	echo "0 attachments"
else
	echo $attachments" attachments"
fi

views=$(more dump.txt | grep "&nbsp;Views" | sed 's/&/ /g' | sed 's/,//g' | awk '{print $8;}' | awk '{ views += $1 } END { printf views }')
if [ -z $views ] 
then
	echo "0 views"
else
	echo $views" views"
fi
date
echo ""

rm pages.txt
rm dump.txt
