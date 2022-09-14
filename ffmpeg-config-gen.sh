echo "set(FFMPEG_PATH \"\${CMAKE_CURRENT_LIST_DIR}\")" > ffmpeg-config.cmake
echo "" >> ffmpeg-config.cmake

echo "set(FFMPEG_EXEC_DIR \"\${FFMPEG_PATH}/bin\")" >> ffmpeg-config.cmake
echo "set(FFMPEG_LIBDIR \"\${FFMPEG_PATH}/lib\")" >> ffmpeg-config.cmake
echo "set(FFMPEG_INCLUDE_DIRS \"\${FFMPEG_PATH}/include\")" >> ffmpeg-config.cmake
echo "" >> ffmpeg-config.cmake

echo "set(FFMPEG_LIBRARIES" >> ffmpeg-config.cmake

libs=()

for file in ./lib/*
do
    if [[ ${file##*.} == "a" ]]; then
        libs[${#libs[@]}]=${file##*/}
        echo "    \${FFMPEG_LIBDIR}/${file##*/}" >> ffmpeg-config.cmake
    fi
done

echo "    $1" >> ffmpeg-config.cmake
echo "    z" >> ffmpeg-config.cmake
echo ")" >> ffmpeg-config.cmake
echo "" >> ffmpeg-config.cmake

for lib in ${libs[@]}
do
    echo "set(FFMPEG_${lib%%.*}_FOUND TRUE)" >> ffmpeg-config.cmake
done

echo "" >> ffmpeg-config.cmake

for file in ./lib/pkgconfig/*
do
    if [[ ${file##*.} == "pc" ]]; then
        pc=${file##*/}
        version=`cat $file | grep Version | awk -F ':' '{print $2}'`
        echo "set(FFMPEG_${pc%%.*}_VERSION${version})" >> ffmpeg-config.cmake
    fi
done

echo "" >> ffmpeg-config.cmake

echo "set(FFMPEG_FOUND TRUE)" >> ffmpeg-config.cmake
echo "set(FFMPEG_LIBS \${FFMPEG_LIBRARIES})" >> ffmpeg-config.cmake