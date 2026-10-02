#!/bin/bash
# ==========================================
# VERTEX CORE ENGINE - TỐI GIẢN & ĐỘC QUYỀN
# ==========================================
ROM_URL="$1"
WORK_DIR=$(pwd)

echo "==================================================="
echo " BẮT ĐẦU KHỞI TẠO HỆ THỐNG ROM: HÀNH TRÌNH VERTEX"
echo "==================================================="

# 1. Chuẩn bị bộ công cụ (Tự động tải ngầm, không làm rác kho lưu trữ)
echo "-> [1/5] Đang nạp bộ công cụ mổ xẻ lõi..."
git clone https://github.com/Mrbi1198/PenguinOS.git temp_tools --depth 1 -q
mv temp_tools/bin ./tools
rm -rf temp_tools
chmod -R 777 tools/

# 2. Tải bản ROM gốc
echo "-> [2/5] Đang tải ROM từ máy chủ..."
aria2c -x16 -s16 -j16 -k1M "$ROM_URL" -o baserom.tgz || { echo "LỖI CHÍ MẠNG: Tải ROM thất bại!"; exit 1; }

# 3. Giải nén và bung siêu phân vùng (Unpack)
echo "-> [3/5] Đang giải nén lớp vỏ Fastboot..."
mkdir -p build/images build/unpacked build/extracted
tar -xzf baserom.tgz -C build/ --strip-components=1 || { echo "LỖI: File ROM bị hỏng định dạng!"; exit 1; }

# Gom file super.img (Hỗ trợ cả dạng file nguyên khối hoặc bị chia nhỏ)
mv build/images/super.img.* build/ 2>/dev/null || true
mv build/images/super.img build/ 2>/dev/null || true
if ls build/super.img.* 1> /dev/null 2>&1; then
    ./tools/Linux/x86_64/simg2img build/super.img.* build/super.img
    rm -f build/super.img.*
fi

echo "-> Đang bung nén phân vùng lõi (System, Vendor, Product)..."
python3 tools/lpunpack.py build/super.img build/unpacked/ >/dev/null 2>&1 || { echo "LỖI: Không thể đọc siêu phân vùng!"; exit 1; }

for part in system system_ext product vendor odm mi_ext; do
    if [ -f "build/unpacked/${part}.img" ]; then
        mkdir -p build/extracted/${part}
        ./tools/Linux/x86_64/extract.erofs -x -i build/unpacked/${part}.img -x -T8 -o build/extracted/${part} >/dev/null 2>&1
    fi
done
rm -f build/unpacked/*.img

# 4. GỌI MODULE TÙY BIẾN (Đây là nơi phép thuật xảy ra)
echo "-> [4/5] Đang áp dụng các tinh chỉnh độc quyền..."
if [ -f "mod.sh" ]; then
    chmod +x mod.sh
    bash mod.sh "$WORK_DIR/build/extracted"
else
    echo "BỎ QUA: Không tìm thấy file mod.sh, giữ nguyên hệ điều hành gốc."
fi

# 5. Đóng gói lại (Repack)
echo "-> [5/5] Đang đóng gói lại bản ROM..."
# (Hệ thống sẽ nén lại các thư mục thành định dạng EROFS siêu nhẹ tại bước này)
# Tạm thời cấu trúc lõi đã xong, lệnh repack chi tiết sẽ được bổ sung sau khi chốt mod.sh

echo "==================================================="
echo " HOÀN TẤT XỬ LÝ LÕI HỆ THỐNG!"
echo "==================================================="
