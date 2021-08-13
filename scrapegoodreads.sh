#!/bin/bash 

curl https://www.goodreads.com/genres/fiction > tmpdata
cat tmpdata | grep "class=\"bookImage\""  | cut -d'"' -f2

my_array=$(cat tmpdata | grep "class=\"bookImage\""  | cut -d'"' -f2 | uniq -u )
IFS=$'\n' array=($my_array);
array=( "${array[@]/#/https://www.goodreads.com}" )

# Go through each hyperlink under GoodReads genre book list, 
# and extract book details. 
bookdetails() {
	curl  $1 |	\
	grep -F '<title>' |     \
	sed 's/<\/title>*//;s/<title>*//'       \
	>> tmpout
}

echo "Details" > tmpout
# Using sem from GNU parallel,
# This schedules the loop commands to run in parallel
for booklink in "${array[@]}"
do
	$(bookdetails $booklink)
	sem -j +0 sleep 2
done
sem --wait

cp --preserve=timestamp tmpout titlesAndAuthors.txt

# Remove tmp files
exec find . -type f -name 'tmp*' -ls -delete 
