TMP="tmp-$1"
OUTPUT="./package-$1"

if [ "$1" == "linux64" ]; then 
    ARCH="linux64";
else
    ARCH="linuxarm64";
fi

if [ ! -d "$TMP" ]; then
    mkdir "$TMP"
fi

cd "$TMP"

rm -rf "$OUTPUT"
mkdir ".$OUTPUT"

CEFZIP="cef.tar.bz2"
CEFBINARIES="cef_binaries"

if [ ! -f "$CEFZIP" ]; then
    URL="https://cef-builds.spotifycdn.com/cef_binary_139.0.28%2Bg55ab8a8%2Bchromium-139.0.7258.139_${ARCH}_minimal.tar.bz2"
    echo "downloading cef binaries"
    if ! command -v aria2c &> /dev/null
    then
        curl -o "$CEFZIP" "$URL"
    else
        aria2c -c -o "$CEFZIP" "$URL"
    fi
fi

if [ ! -d "$CEFBINARIES" ]; then
    echo "unzipping cef binaries"
    mkdir "$CEFBINARIES"
    tar -jxvf "$CEFZIP" -C "./$CEFBINARIES"
fi
echo "copying cef binaries"
cp -va "${PWD}/$(find $CEFBINARIES -name "Release")/." ".$OUTPUT/CEF/"
cd .. || exit 1
echo "stripping cef binaries"
if [ "$1" == "linux64" ]; then 
	strip -v -s "${OUTPUT}/CEF/libcef.so"
	strip -v -s "${OUTPUT}/CEF/libEGL.so"
	strip -v -s "${OUTPUT}/CEF/libGLESv2.so"
	strip -v -s "${OUTPUT}/CEF/libvk_swiftshader.so"
	strip -v -s "${OUTPUT}/CEF/libvulkan.so.1"
else
	aarch64-linux-gnu-strip -v -s "${OUTPUT}/CEF/libcef.so"
	aarch64-linux-gnu-strip -v -s "${OUTPUT}/CEF/libEGL.so"
	aarch64-linux-gnu-strip -v -s "${OUTPUT}/CEF/libGLESv2.so"
	aarch64-linux-gnu-strip -v -s "${OUTPUT}/CEF/libvk_swiftshader.so"
	aarch64-linux-gnu-strip -v -s "${OUTPUT}/CEF/libvulkan.so.1"
fi
cd "$TMP" || exit 1
cp -Rv "${PWD}/$(find $CEFBINARIES -name "Resources")/." ".$OUTPUT/CEF/"
