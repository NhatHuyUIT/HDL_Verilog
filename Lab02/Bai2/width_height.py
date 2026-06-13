from PIL import Image
import numpy as np

INPUT_IMAGE = "baitap2_anhgoc.jpg"
OUTPUT_TXT  = "pic_input.txt"

img = Image.open(INPUT_IMAGE).convert("RGB")
arr = np.array(img, dtype=np.uint8)  # shape: (H, W, 3)

height, width = arr.shape[:2]
print(f"Kich thuoc anh: {width} x {height} = {width*height} pixel")

# Ghi R G B xen kẽ, mỗi byte 1 dòng
with open(OUTPUT_TXT, "w") as f:
    for pixel in arr.reshape(-1, 3):
        f.write(f"{pixel[0]:02X}\n")  # R
        f.write(f"{pixel[1]:02X}\n")  # G
        f.write(f"{pixel[2]:02X}\n")  # B

print(f"Da ghi {width*height*3} byte ra '{OUTPUT_TXT}'")
print(f"Tham so Verilog: WIDTH = {width}, HEIGHT = {height}" '\n')