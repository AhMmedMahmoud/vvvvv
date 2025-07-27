set -e # exist at occurs of any error

if [ -z "$ANDROID_NDK" ]; then
  echo "ANDROID_NDK is not set. please set ANDROID_NDK"
  exit 1  
fi

# Clone Boost with submodules
git clone https://github.com/boostorg/boost.git -b boost-1.84.0
cd boost
git submodule update --init --recursive

# Create minimal user-config.jam without Python
cat > user-config.jam <<EOF
using clang : 21 :
  $ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++ :
  <compileflags>"--target=aarch64-linux-android21 -std=c++17"
  <linkflags>"--target=aarch64-linux-android21 -lc++_shared -pthread" ;
EOF

cd ..


