#!/bin/bash
# ==========================================
# VERTEX CORE ENGINE - TỐI GIẢN & ĐỘC QUYỀN
# ==========================================
ROM_URL="$1"
WORK_DIR=$(pwd)

echo "==================================================="
echo " BẮT ĐẦU KHỞI TẠO HỆ THỐNG ROM: HÀNH TRÌNH VERTEX"
echo "==================================================="

# 1. Chuẩn bị bộ công cụ
echo "-> [1/5] Đang nạp bộ công cụ mổ xẻ lõi..."
git clone https://github.com/Mrbi1198/PenguinOS.git temp_tools --depth 1 -q
mv temp_tools/bin ./tools
rm -rf temp_tools
chmod -R 777 tools/

# 2. Tải bản ROM gốc
echo "-> [2/5] Đang tải ROM từ máy chủ..."
aria2c -x16 -s16 -j16 -k1M "$ROM_URL" -o baserom.zip || { echo "LỖI CHÍ MẠNG: Tải ROM thất bại!"; exit 1; }

# 3. Giải nén trực tiếp file ZIP
echo "-> [3/5] Đang giải nén file ROM định dạng ZIP..."
mkdir -p build/images build/unpacked build/extracted

unzip -q baserom.zip -d build/ || { echo "LỖI: Giải nén file .zip thất bại!"; exit 1; }

if [ -f "build/payload.bin" ]; then
    echo "-> Phát hiện payload.bin, đang trích xuất phân vùng..."
    python3 tools/Linux/x86_64/payload-extractor/extract.py build/payload.bin --output build/images/
elif [ -f "build/images/super.img" ]; then
    echo "-> Đã có sẵn file super.img"
else
    found_super=$(find build/ -name "super.img" | head -n 1)
    if [ -n "$found_super" ]; then
        cp "$found_super" build/super.img
    fi
fi

if [ -f "build/super.img" ]; then
    echo "-> Đang bung nén siêu phân vùng super.img..."
    python3 tools/lpunpack.py build/super.img build/unpacked/ >/dev/null 2>&1 || true
fi

for part in system system_ext product vendor odm mi_ext; do
    if [ -f "build/unpacked/${part}.img" ]; then
        mkdir -p build/extracted/${part}
        ./tools/Linux/x86_64/extract.erofs -x -i build/unpacked/${part}.img -x -T8 -o build/extracted/${part} >/dev/null 2>&1
    fi
done
rm -rf build/unpacked/*.img

# 4. GỌI MODULE TÙY BIẾN
echo "-> [4/5] Đang áp dụng các tinh chỉnh độc quyền..."
if [ -f "mod.sh" ]; then
    chmod +x mod.sh
    bash mod.sh "$WORK_DIR/build/extracted"
else
    echo "BỎ QUA: Không tìm thấy file mod.sh"
fi

# 5. Đóng gói lại thành file ROM hoàn chỉnh (Repack)
echo "-> [5/5] Đang đóng gói lại thành file ROM thành phẩm..."
mkdir -p output_rom

for part in system system_ext product vendor odm mi_ext; do
    if [ -d "build/extracted/${part}" ]; then
        echo "   [+] Đang nén lại phân vùng: ${part}..."
        ./tools/Linux/x86_64/mkfs.erofs "output_rom/${part}.img" "build/extracted/${part}" >/dev/null 2>&1 || true
    fi
done

cd output_rom && zip -r9 ../VertexOS_Custom_ROM.zip ./* && cd ..

echo "==================================================="
echo " HOÀN TẤT XỬ LÝ VÀ ĐÓNG GÓI HỆ THỐNG!"
echo "==================================================="
