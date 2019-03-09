#!/bin/bash

#####################################################################
# Split and crop PDFs that contain 2 slides per page                #
# Usage:                                                            #
#   $ ./unbouka.sh [input.pdf] [output.pdf]                         #
# Dependencies:                                                     #
#   - ImageMagick                                                   #
#   - GhostScript                                                   #
# Notes:                                                            #
# - An extra white page will appear at end if odd                   #
#   number of pages                                                 #
# - Must add this line to /etc/ImageMagick-7/policy,xml :           #
#    <policy domain="coder" rights="read | write" pattern="PDF" />  #
# Author:   Simon Brown                                             #
# Date:     09/03/2019                                              #
#####################################################################

SLIDE_DIMENTIONS="1000x750" # Size of slide in pixels
SLIDE1_POSITION="+350+246"  # Position of top left corner, slide 1
SLIDE2_POSITION="+350+1203" # Position of top left corner, slide 2
RESOLUTION=200              # Conversion resolution in dots/inch
JPEG_FOLDER="/tmp/jpgs"
CROPED_FOLDER="/tmp/pdfs"

# Parameter validation
if [ ! -f "$1" ] || [ -z "$2" ]; then
    echo "Unvalid parameters, exiting"
    exit 1
fi

mkdir -p "$JPEG_FOLDER" "$CROPED_FOLDER"
COUNT=0
echo "Converting $1"
convert -density "$RESOLUTION" "$1" $JPEG_FOLDER/out-%03d.jpg
echo "Splitting slides"
for FILE in "$JPEG_FOLDER"/*
do
    COUNT=$((COUNT + 1))
    if [ -f "$FILE" ]; then
        convert -crop "$SLIDE_DIMENTIONS$SLIDE1_POSITION" -page "$SLIDE_DIMENTIONS" \
            "$FILE" "$CROPED_FOLDER/out$COUNT".pdf
        COUNT=$((COUNT + 1))
        convert -crop "$SLIDE_DIMENTIONS$SLIDE2_POSITION" -page "$SLIDE_DIMENTIONS" \
            "$FILE" "$CROPED_FOLDER/out$COUNT".pdf
    fi
done
echo "Merging croped and splitted slides"
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$2" \
    $(ls -rt "$CROPED_FOLDER"/*pdf)
rm -rf "$JPEG_FOLDER" "$CROPED_FOLDER"
