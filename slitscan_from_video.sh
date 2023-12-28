#!/bin/bash

# Usage: ./slitscan_from_video.sh <video_path> <output_image> <num_strips> <start_time> <duration>

# Check for correct number of arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <video_path> <output_image> <num_strips> <start_time> <duration>"
    exit 1
fi

# Assign parameters to variables
VIDEO_PATH="$1"
OUTPUT_IMAGE="$2"
NUM_STRIPS="$3"
START_TIME="$4"   # Start time for video frame extraction (in seconds or hh:mm:ss format)
DURATION="$5"     # Duration for video frame extraction (in seconds or hh:mm:ss format)

# Temporary directory for frames
FRAME_DIR="./frames"
mkdir -p "$FRAME_DIR"

# Calculate frame rate (fps) for frame extraction
FPS=$(echo "$NUM_STRIPS / $DURATION" | bc -l)

# Extract frames from the video using the specified start time and duration
ffmpeg -ss "$START_TIME" -t "$DURATION" -i "$VIDEO_PATH" -q:v 2 -vf "fps=$FPS" "$FRAME_DIR/frame_%04d.jpg"

# Verify if frames were created
if [ $(ls "$FRAME_DIR" | wc -l) -eq 0 ]; then
    echo "No frames were created. Check if the video file path, start time, and duration are correct."
    exit 1
fi

# Get image dimensions from the first frame
FIRST_FRAME=$(ls "$FRAME_DIR" | head -n 1)
IMAGE_DIMENSIONS=$(identify -format "%wx%h" "$FRAME_DIR/$FIRST_FRAME")
IMAGE_WIDTH=$(echo $IMAGE_DIMENSIONS | cut -dx -f1)
IMAGE_HEIGHT=$(echo $IMAGE_DIMENSIONS | cut -dx -f2)
STRIP_WIDTH=$((IMAGE_WIDTH / NUM_STRIPS))

# Create an array to hold the file names of the strips
declare -a STRIP_FILES

# Loop through the frames and create a strip from each
for ((i=0; i<NUM_STRIPS; i++)); do
    FRAME="$FRAME_DIR/frame_$(printf "%04d" $i).jpg"
    if [ ! -f "$FRAME" ]; then
        echo "Frame does not exist: $FRAME"
        continue
    fi
    OFFSET=$((i * STRIP_WIDTH))
    STRIP_FILE="strip_$i.jpg"
    STRIP_FILES+=("$STRIP_FILE")
    convert "$FRAME" -quality 100 -crop "${STRIP_WIDTH}x${IMAGE_HEIGHT}+${OFFSET}+0" +repage "$STRIP_FILE"
done

# Concatenate all the strips into one final image
convert "${STRIP_FILES[@]}" +append "$OUTPUT_IMAGE"

# Clean up the strip files and the frames
rm -rf "${STRIP_FILES[@]}" "$FRAME_DIR"

echo "Slit-scan image created as $OUTPUT_IMAGE"

