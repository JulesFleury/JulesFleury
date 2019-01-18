 ##############################################
# Installer le paquet pour 
#! /bin/bas

function strip_exif {
echo ' --> Stripping Exif from: ' $1
cp "$1" "$1"."_tmp"
exiftool -all= "$1"
exiftool -overwrite_original \
-TagsFromFile "$1"."_tmp" \
-ExposureTime \
-FNumber \
-ISO \
-FocalLength \
-FocalLengthIn35mmFormat \
-Make \
-Model \
"$1"

exiftool -delete_original! "$1"
rm -f "$1"."_tmp"

}

function rotate_if_needed {
echo ' --> Rotating?:' $1
wh=$(identify "$1" | cut -f 3 -d' ')
echo ' --> Detected geometry: '${wh}
w=$(echo $wh | cut -f 1 -d'x') #width
h=$(echo $wh | cut -f 2 -d'x') #height
echo ' --> WIDTH ' $w ' HEIGHT: ' $h
#width must be bigger than height
if ((${w}<${h}))
then
echo " --> NEED ROTATION. ROTATING!"
jpegtran -rot 90 $1 >$1'_rot.jpg'
#copy exif infos from original file
exiftool -TagsFromFile $1 $1'_rot.jpg'
exiftool -delete_original! $1'_rot.jpg'
mv $1'_rot.jpg' $1

fi
}



for i in $@;
do


echo '!--> Working on:' $i;
strip_exif $i;
rotate_if_needed ${i}

done;



###################################