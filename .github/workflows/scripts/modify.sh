#!/bin/bash
set -e

WORK_DIR="$1"
echo "=== BẮT ĐẦU CAN THIỆP & TỐI ƯU HỆ THỐNG ==="

# 1. Quét và gỡ bỏ ứng dụng rác, quảng cáo nội địa (Debloat)
BLOATWARES=(
    "AnalyticsCore"
    "MSA-Global"
    "Joyose"
    "MiuiBugReport"
    "YellowPage"
    "Weather"
    "MiService"
)

echo "-> Tiến hành lọc và loại bỏ bloatware..."
for bloat in "${BLOATWARES[@]}"; do
    find "$WORK_DIR" -type d -name "*$bloat*" -exec rm -rf {} + 2>/dev/null || true
done

# 2. Tích hợp cấu hình Google Photos Unlimited (Pixel Spoof Profile)
echo "-> Tích hợp Google Photos Unlimited..."
SYSCONFIG_DIR="$WORK_DIR/product/etc/sysconfig"
mkdir -p "$SYSCONFIG_DIR"
cat << 'EOF' > "$SYSCONFIG_DIR/nexus.xml"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <feature name="com.google.android.apps.photos.NEXUS_PRELOAD" />
    <feature name="com.google.android.apps.photos.nexus_preload" />
</config>
EOF
chmod 644 "$SYSCONFIG_DIR/nexus.xml"

# 3. Patch thông số build.prop (tắt giảm giật lag animation, mượt mà hơn)
echo "-> Patch cờ build.prop..."
BUILD_PROP="$WORK_DIR/system/system/build.prop"
if [ -f "$BUILD_PROP" ]; then
    echo "" >> "$BUILD_PROP"
    echo "# Tinh chỉnh Vertex" >> "$BUILD_PROP"
    echo "persist.sys.miui_animator_sched.enable=false" >> "$BUILD_PROP"
    echo "ro.config.low_ram=false" >> "$BUILD_PROP"
fi

echo "=== HOÀN TẤT BƯỚC CAN THIỆP ==="
