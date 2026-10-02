#!/bin/bash
# ==========================================
# VERTEX MODS - CÁC TÍNH NĂNG ĐỘC QUYỀN
# ==========================================
EXTRACTED_DIR="$1"

echo "==================================================="
echo " BẮT ĐẦU BƠM TÍNH NĂNG ĐỘC QUYỀN VÀO ROM..."
echo "==================================================="

# Tìm tất cả các file cấu hình hệ thống (build.prop)
PROPS=$(find "$EXTRACTED_DIR" -type f -name "build.prop")

echo "-> [1/7] Áp dụng Fix Play Integrity & TrickyStore..."
for prop in $PROPS; do
    sed -i 's/ro.boot.flash.locked=.*/ro.boot.flash.locked=1/g' "$prop"
    sed -i 's/ro.boot.vbmeta.device_state=.*/ro.boot.vbmeta.device_state=locked/g' "$prop"
    echo "persist.sys.spoof_pi=true" >> "$prop"
done

echo "-> [2/7] Ẩn trạng thái Gỡ lỗi (Qua mặt app chống Root)..."
for prop in $PROPS; do
    sed -i 's/ro.debuggable=.*/ro.debuggable=0/g' "$prop"
    sed -i 's/ro.secure=.*/ro.secure=1/g' "$prop"
done

echo "-> [3/7] Ép xung Tần số quét màn hình (Luôn 120Hz/144Hz)..."
for prop in $PROPS; do
    echo "persist.vendor.dfps.level=120" >> "$prop"
    echo "ro.vendor.display.default_fps=120" >> "$prop"
    echo "persist.sys.min_refresh_rate=120" >> "$prop"
done

echo "-> [4/7] Kích hoạt Google Photos không giới hạn (Giả lập Pixel)..."
if [ -f "$EXTRACTED_DIR/product/etc/build.prop" ]; then
    sed -i 's/^ro.product.product.brand=.*/ro.product.product.brand=google/g' "$EXTRACTED_DIR/product/etc/build.prop"
    sed -i 's/^ro.product.product.manufacturer=.*/ro.product.product.manufacturer=Google/g' "$EXTRACTED_DIR/product/etc/build.prop"
    sed -i 's/^ro.product.product.model=.*/ro.product.product.model=Pixel 8 Pro/g' "$EXTRACTED_DIR/product/etc/build.prop"
fi

echo "-> [5/7] Vô hiệu hóa cờ bảo mật (Chụp ảnh màn hình mọi app)..."
for prop in $PROPS; do
    echo "ro.secureui.enable=false" >> "$prop"
    echo "persist.sys.secure_ui=false" >> "$prop"
done

echo "-> [6/7] Đóng dấu thương hiệu: Hành Trình Vertex..."
for prop in $PROPS; do
    sed -i 's/^ro.build.display.id=.*/ro.build.display.id=VertexOS - Built by Phương/g' "$prop"
    sed -i 's/^ro.mi.os.version.name=.*/ro.mi.os.version.name=VertexOS 1.0/g' "$prop"
    sed -i 's/MIUI/VertexUI/g' "$prop"
    sed -i 's/HyperOS/VertexOS/g' "$prop"
done

echo "-> [7/7] Cấy ghép Trình cài đặt InstallerX-Revived..."
# Lấy link tải file APK bản release mới nhất từ GitHub
LATEST_APK_URL=$(curl -s https://api.github.com/repos/wxxsfxyzm/InstallerX-Revived/releases/latest | grep "browser_download_url.*\.apk" | cut -d '"' -f 4 | head -n 1)

if [ -n "$LATEST_APK_URL" ]; then
    wget -qO installerx.apk "$LATEST_APK_URL"
    
    # Tìm và tiêu diệt trình cài đặt gốc của Xiaomi, thay thế bằng InstallerX
    INSTALLER_PATHS=$(find "$EXTRACTED_DIR" -type d \( -name "MIUIPackageInstaller" -o -name "PackageInstaller" \))
    for path in $INSTALLER_PATHS; do
        rm -f "$path"/*.apk
        cp installerx.apk "$path/InstallerX.apk"
        chmod 644 "$path/InstallerX.apk"
        echo "   [+] Đã thay thế thành công tại: $path"
    done
    rm -f installerx.apk
else
    echo "   [!] Lỗi mạng: Không thể lấy file InstallerX từ GitHub, bỏ qua bước này."
fi

echo "==================================================="
echo " HOÀN TẤT BƠM TÍNH NĂNG VÀO HỆ THỐNG!"
echo "==================================================="
