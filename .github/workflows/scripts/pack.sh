#!/bin/bash
set -e

EXTRACTED_DIR="$1"
DEVICE="$2"
OUTPUT_DIR="workspace/output"
mkdir -p "$OUTPUT_DIR"

echo "=== BẮT ĐẦU ĐÓNG GÓI BẢN ROM THÀNH PHẨM ==="

BUILD_DATE=$(date +%Y%m%d_%H%M)
ZIP_NAME="${DEVICE}_Custom_ROM_${BUILD_DATE}.zip"

# Di chuyển vào thư mục chứa các img và nén thành gói ZIP
cd "$EXTRACTED_DIR"
echo "-> Đang nén các file img thành $ZIP_NAME..."
zip -r9 "$ZIP_NAME" *.img

mv "$ZIP_NAME" "../output/"
echo "-> Đã tạo gói cài đặt thành công tại: $OUTPUT_DIR/$ZIP_NAME"
echo "=== HOÀN TẤT ĐÓNG GÓI ==="
