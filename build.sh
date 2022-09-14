# Linux 交叉编译 Android 库脚本
if [[ -z $ANDROID_NDK ]]; then
    echo 'Error: Can not find ANDROID_NDK path.'
    exit 1
fi

echo "ANDROID_NDK path: ${ANDROID_NDK}"

ROOT_PATH=`pwd`

OUTPUT_DIR="_output_"

rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR} && cd ${OUTPUT_DIR}

OUTPUT_PATH=`pwd`

API=21
TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
# 编译出的x264库地址
X264_ANDROID_DIR=/home/dreamgyf/compile/x264/_output_/product

EXTRA_CONFIGURATIONS="--disable-stripping \
    --disable-ffmpeg \
    --disable-doc \
    --disable-appkit \
    --disable-avfoundation \
    --disable-coreimage \
    --disable-amf \
    --disable-audiotoolbox \
    --disable-cuda-llvm \
    --disable-cuvid \
    --disable-d3d11va \
    --disable-dxva2 \
    --disable-ffnvcodec \
    --disable-nvdec \
    --disable-nvenc \
    --disable-vdpau \
    --disable-videotoolbox"

function build {
    ABI=$1

    if [[ $ABI == "armeabi-v7a" ]]; then
        ARCH="arm"
        TRIPLE="armv7a-linux-androideabi"
        CROSS_PREFIX="arm-linux-androideabi-"
    elif [[ $ABI == "arm64-v8a" ]]; then
        ARCH="arm64"
        TRIPLE="aarch64-linux-android"
        CROSS_PREFIX="aarch64-linux-android-"
    elif [[ $ABI == "x86" ]]; then
        ARCH="x86"
        TRIPLE="i686-linux-android"
        CROSS_PREFIX="i686-linux-android-"
    elif [[ $ABI == "x86-64" ]]; then
        ARCH="x86_64"
        TRIPLE="x86_64-linux-android"
        CROSS_PREFIX="x86_64-linux-android-"
    else
        echo "Unsupported ABI ${ABI}!"
        exit 1
    fi

    echo "Build ABI ${ABI}..."

    rm -rf ${ABI}
    mkdir ${ABI} && cd ${ABI}

    PREFIX=${OUTPUT_PATH}/product/$ABI

    export CC=$TOOLCHAIN/bin/${TRIPLE}${API}-clang
    export CFLAGS="-g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security  -O0 -DNDEBUG  -fPIC --gcc-toolchain=$TOOLCHAIN --target=${TRIPLE}${API}"

    ../../configure \
        --prefix=$PREFIX \
        --enable-cross-compile \
        --sysroot=$TOOLCHAIN/sysroot \
        --cc=$CC \
        --enable-static \
        --enable-shared \
        --disable-asm \
        --enable-gpl \
        --enable-libx264 \
        --extra-cflags="-I${X264_ANDROID_DIR}/${ABI}/include" \
        --extra-ldflags="-L${X264_ANDROID_DIR}/${ABI}/lib" \
        $EXTRA_CONFIGURATIONS

    make clean && make -j`nproc` && make install

    cd $PREFIX
    `$ROOT_PATH/ffmpeg-config-gen.sh ${X264_ANDROID_DIR}/${ABI}/lib/libx264.a`
    cd $OUTPUT_PATH
}

build armeabi-v7a
build arm64-v8a
