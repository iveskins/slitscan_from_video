#!/bin/bash

# Usage: ./slitscan.sh <image_dir> <output_image> <image_width> <image_height> <num_strips>

# Check for correct number of arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <image_dir> <output_image> <image_width> <image_height> <num_strips>"
    exit 1
fi

# Assign parameters to variables
IMAGE_DIR="$1"
OUTPUT_IMAGE="$2"
IMAGE_WIDTH="$3"
IMAGE_HEIGHT="$4"
NUM_IMAGES="$5"
STRIP_WIDTH=$((IMAGE_WIDTH / NUM_IMAGES))

# Create an array to hold the file names of the strips
declare -a STRIP_FILES

# Loop through the images and create a strip from each
for ((i=0; i<NUM_IMAGES; i++)); do
    # Generate the filename assuming they are named sequentially like image-01.jpg, image-02.jpg, ...
    FILENAME="$IMAGE_DIR/image-$(printf "%02d" $((i+1))).jpg"
    
    # Check if the image file exists
    if [ ! -f "$FILENAME" ]; then
        echo "Image file does not exist: $FILENAME"
        continue
    fi
    
    # The offset for cropping is constant and equal to the strip width multiplied by the index
    OFFSET=$((i * STRIP_WIDTH))
    
    # Define the output filename for the strip
    STRIP_FILE="strip_$i.jpg"
    STRIP_FILES+=("$STRIP_FILE")
    
    # Use ImageMagick to crop the strip out of the image
    convert "$FILENAME" -crop "${STRIP_WIDTH}x${IMAGE_HEIGHT}+${OFFSET}+0" +repage "$STRIP_FILE"
done

# Concatenate all the strips into one final image
convert "${STRIP_FILES[@]}" +append "$OUTPUT_IMAGE"

# Clean up the strip files
rm "${STRIP_FILES[@]}"

echo "Slit-scan image created as $OUTPUT_IMAGE"


