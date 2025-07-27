set -e # exist at occurs of any error

if [ -z "$ANDROID_NDK" ]; then
  echo "ANDROID_NDK is not set. please set ANDROID_NDK"
  exit 1  
fi

export BOOST_INSTALL_ROOT=$(pwd)/install/boost
export SOMEIP_INSTALL_ROOT=$(pwd)/install/vsomeip

# Build and install with proper parameters
mkdir -p install/boost
mkdir -p install/vsomeip

cd boost

./bootstrap.sh

./b2 -q -j8 \
  --build-type=minimal \
  target-os=android \
  toolset=clang-21 \
  runtime-link=shared \
  link=shared \
  variant=release \
  abi=aapcs \
  address-model=64 \
  architecture=arm \
  define=BOOST_SYSTEM_NO_DEPRECATED \
  --user-config=user-config.jam \
  --prefix=../install/boost \
  --with-system \
  --with-thread \
  --with-filesystem \
  install

cd ..

cd vsomeip

rm -rf build

mkdir build

cd build

cmake \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_CXX_STANDARD=14 \
  -DCMAKE_INSTALL_PREFIX=$SOMEIP_INSTALL_ROOT \
  -DINSTALL_INCLUDE_DIR=$SOMEIP_INSTALL_ROOT \
  -DBoost_INCLUDE_DIR=$BOOST_INSTALL_ROOT/include \
  -DBoost_LIBRARY_DIR=$BOOST_INSTALL_ROOT/lib \
  ..

make -j 64

make install

cd ..