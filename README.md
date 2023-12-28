# Slit-Scan Image Creation Script

## Motivation
The slit-scan photography technique is a unique way to capture the passage of time in a single image. Traditionally used in still photography and filmmaking, it creates a sense of motion and transformation. This script automates the process of creating a slit-scan image from a series of still frames extracted from a video. It is useful for artists, photographers, and anyone interested in experimental image processing techniques.

## Description
This script uses `ffmpeg` to extract frames from a specified segment of a video and then processes those frames using ImageMagick to create a slit-scan image. Each frame contributes a vertical strip to the final image, showing a progression of time or motion.

## Prerequisites
- You must have `ffmpeg` installed on your system for video processing.
- ImageMagick is required for image manipulation tasks.
- Ensure you have `git` and `gh` (GitHub CLI) installed if you plan to version control and push this script to a GitHub repository.

## Usage

To use this script, you need to provide the path to the source video, the desired output image name, the number of strips to be included in the final image, the start time, and the duration of the video segment.

### Syntax

```bash
./slitscan_from_video.sh <video_path> <output_image> <num_strips> <start_time> <duration>
```

### Parameters

- `<video_path>`: The file path to the source video.
- `<output_image>`: The desired file name for the output slit-scan image.
- `<num_strips>`: The number of vertical strips (and frames) you want to extract for the slit-scan.
- `<start_time>`: The start time in the video from which to begin extracting frames (in seconds or hh:mm:ss format).
- `<duration>`: The duration of the video segment to use for the slit-scan (in seconds or hh:mm:ss format).

### Example

```bash
./slitscan_from_video.sh /path/to/video.mp4 my_slitscan.jpg 10 00:00:05 10
```

This command will process the video file `video.mp4`, starting at 5 seconds into the video, and will use a 10-second segment to create a slit-scan image with 10 strips named `my_slitscan.jpg`.

## Output
The script will output a single image with the slit-scan effect applied, composed of the specified number of vertical strips from the video frames.

## Contributing
Feel free to fork this repository and submit pull requests to contribute to the development of this script. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)

