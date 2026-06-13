from PIL import Image
import numpy as np

OUTPUT_TXT     = "pic_output.txt"
ORIGINAL_IMAGE = "baitap2_anhgoc.jpg"
RESULT_IMAGE   = "baitap2_ketqua.png"

# Lấy kích thước từ ảnh gốc
ref = Image.open(ORIGINAL_IMAGE).convert("L")
width, height = ref.size

# Đọc file hex
with open(OUTPUT_TXT, "r") as f:
    pixels = [int(line.strip(), 16) for line in f if line.strip()]

if len(pixels) != width * height:
    print(f"[CANH BAO] So pixel doc duoc ({len(pixels)}) "
          f"khac kich thuoc anh ({width*height})")

arr = np.array(pixels, dtype=np.uint8).reshape(height, width)
img = Image.fromarray(arr, mode="L")
img.save(RESULT_IMAGE)
print(f"Da luu anh ket qua: '{RESULT_IMAGE}' ({width}x{height})" '\n')