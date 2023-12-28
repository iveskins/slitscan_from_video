#!/bin/bash

# Script to create a slit-scan image from a video file using ffmpeg and ImageMagick.

# Default parameters
VIDEO_FILE="$1"
IN_TIME=0                  # Start time of the video clip to process, in seconds.
OUT_TIME=""                # End time of the video clip to process, to be calculated if not provided.
IMAGE_WIDTH=1920           # The width of the final image.
SLIT_NUMBER=120            # The number of slits to extract.
ORIENTATION="horizontal"   # Orientation of the slits, can be 'horizontal' or 'vertical'.
OUTPUT_DIR="./slitscan_frames"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FINAL_IMAGE="slitscan_result_$TIMESTAMP.jpg"

# Function to calculate frame interval based on video duration and number of slits
calculate_frame_interval() {
    # Calculate total duration if OUT_TIME not provided
    if [ -z "$OUT_TIME" ]; then
        OUT_TIME=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
        OUT_TIME=${OUT_TIME%.*}  # Convert to integer
    fi
    FRAME_INTERVAL=$(echo "scale=2; ($OUT_TIME - $IN_TIME) / $SLIT_NUMBER" | bc)
    echo "$FRAME_INTERVAL"
}

# Parse command-line arguments for in-time and out-time
while getopts ":i:o:w:n:vh" opt; do
  case $opt in
    i) IN_TIME="$OPTARG"
    ;;
    o) OUT_TIME="$OPTARG"
    ;;
    w) IMAGE_WIDTH="$OPTARG"
    ;;
    n) SLIT_NUMBER="$OPTARG"
    ;;
    v) ORIENTATION="vertical"
    ;;
    h) ORIENTATION="horizontal"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Calculate the frame interval and total video duration
FRAME_INTERVAL=$(calculate_frame_interval)

# Create output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# Extract frames from the video at the calculated interval
ffmpeg -ss "$IN_TIME" -t "$((OUT_TIME - IN_TIME))" -i "$VIDEO_FILE" -vf "fps=1/${FRAME_INTERVAL}" "$OUTPUT_DIR/frame_%04d.jpg"

# Process each frame to create the slit-scan effect
FINAL_SLICES=()

for FRAME in $(ls "$OUTPUT_DIR"/frame_*.jpg | sort -V); do
    SLIT="${FRAME%.jpg}_slit.jpg"
    if [ "$ORIENTATION" == "horizontal" ]; then
        # Extract a horizontal slit
        convert "$FRAME" -crop "100%x${SLIT_NUMBER}+0+50%" +repage "$SLIT"
    else
        # Extract a vertical slit
        convert "$FRAME" -crop "${SLIT_NUMBER}x100%+50%+0" +repage "$SLIT"
    fi
    FINAL_SLICES+=("$SLIT")
done

# Concatenate all the slits into one final image
if [ "$ORIENTATION" == "horizontal" ]; then
    convert "${FINAL_SLICES[@]}" -append "$FINAL_IMAGE"
else
    convert "${FINAL_SLICES[@]}" +append "$FINAL_IMAGE"
fi

# Resize the final image to the desired width
convert "$FINAL_IMAGE" -resize "$IMAGE_WIDTH"x "$FINAL_IMAGE"

# Clean up frames
rm -rf "$OUTPUT_DIR"

echo "Slit-scan image created as $FINAL_IMAGE"


