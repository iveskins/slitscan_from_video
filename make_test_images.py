# It seems I forgot to import the os module. Let's correct that and run the script again.

import os
from PIL import Image, ImageDraw

# Define the directory and ensure it exists
output_dir = "./images"
os.makedirs(output_dir, exist_ok=True)

# Define the number of images and their dimensions
num_images = 10
image_size = (100, 100)

# Generate test images with a unique colored line in each to observe the slit-scan effect
for i in range(num_images):
    img = Image.new('RGB', image_size, color='white')
    draw = ImageDraw.Draw(img)
    line_y_position = int((image_size[1] / num_images) * i)
    draw.line((0, line_y_position, image_size[0], line_y_position), fill='black', width=5)
    img.save(f"{output_dir}/image-{i+1:02d}.jpg")

# Provide the path to the images for download
#output_dir, os.listdir(output_dir)

