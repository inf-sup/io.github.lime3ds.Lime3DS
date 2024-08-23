# max build time 2h
sleep 7200 && kill -SIGKILL $$ &
# install packages
install_pkg=$(realpath "./install_pkg.sh")
include_pkg=''
exclude_pkg=''
bash $install_pkg -i -d $(realpath 'linglong/sources') -p $PREFIX -I \"$include_pkg\" -E \"$exclude_pkg\"
export LD_LIBRARY_PATH=$PREFIX/lib/$TRIPLET:$LD_LIBRARY_PATH

# build ninja
cd /project/linglong/sources/ninja.git
cmake -Bbuild
cmake --build build -j$(nproc)
ninja="$(pwd)/build/ninja"

# build Lime3DS
cd /project/linglong/sources/Lime3DS.git
# mv rapidjson
mkdir -p externals/discord-rpc/thirdparty
mv /project/linglong/sources/rapidjson.git externals/discord-rpc/thirdparty/rapidjson-1.1.0
# fix BUILD_VERSION
echo -n '' > GIT-COMMIT
echo '2117.1' > GIT-TAG
export EXTRA_CMAKE_FLAGS=(-DCITRA_USE_PRECOMPILED_HEADERS=OFF)
cmake -Bbuild \
      -G Ninja \
      -DCMAKE_MAKE_PROGRAM=$ninja \
      -DCMAKE_BUILD_TYPE=Release \
      "${EXTRA_CMAKE_FLAGS[@]}" \
      -DENABLE_QT_TRANSLATION=ON \
      -DCITRA_ENABLE_COMPATIBILITY_REPORTING=ON \
      -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON \
      -DUSE_DISCORD_PRESENCE=ON \
      -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build -j2
strip -s build/bin/Release/*
cmake --install build
# fix qt plugin path
{
  echo "[Paths]"
  echo "Prefix=$PREFIX"
  echo "Plugins=lib/$TRIPLET/qt6/plugins"
} > "$PREFIX/bin/qt.conf"

# uninstall dev packages
bash $install_pkg -u -r '\-dev|qmake6|tools' -D
