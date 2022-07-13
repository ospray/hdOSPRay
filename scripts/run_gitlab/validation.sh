#!/bin/bash
## ======================================================================== ##
## Copyright 2022 Intel Corporation                                    ##
##                                                                          ##
## Licensed under the Apache License, Version 2.0 (the "License");          ##
## you may not use this file except in compliance with the License.         ##
## You may obtain a copy of the License at                                  ##
##                                                                          ##
##     http://www.apache.org/licenses/LICENSE-2.0                           ##
##                                                                          ##
## Unless required by applicable law or agreed to in writing, software      ##
## distributed under the License is distributed on an "AS IS" BASIS,        ##
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. ##
## See the License for the specific language governing permissions and      ##
## limitations under the License.                                           ##
## ======================================================================== ##
set -x

# launch X
Xvfb :0 -screen 0 "1920x1080x24" -ac -nolisten tcp &

#build hdospray
mkdir build
cd build
mkdir testing
mkdir testing/external
ls /
cp -r /NAS/projects/hdospray/scenes/* testing/external/.
cp -r /NAS/projects/hdospray/golden_images testing/.

cmake -GNinja \
  -D CMAKE_CXX_FLAGS="-std=c++17" \
  -D pxr_DIR=/gitlab/USD-install \
  -D ospray_DIR=/usr \
  -D embree_DIR=/usr \
  -D ospcommon_DIR=/usr \
  -D openvkl_DIR=/usr \
  -D PXR_BUILD_OPENIMAGEIO_PLUGIN=ON \
  -D OIIO_BASE_DIR=/gitlab/USD-install \
  -D HDOSPRAY_ENABLE_DENOISER=OFF \
  -D CMAKE_INSTALL_PREFIX=/gitlab/USD-install \
  -D GLEW_LIBRARY=/gitlab/USD-install/lib64/libGLEW.so \
  -D GLEW_INCLUDE_DIR=/gitlab/USD-install/include \
  -D PXR_ENABLE_PTEX_SUPPORT=OFF \
  -D PXR_BUILD_USD_IMAGING=ON \
  -D PXR_BUILD_USDVIEW=ON \
  -D ENABLE_TESTING=ON \
  "$@" ..

ninja
ninja install

export PATH=/gitlab/USD-install/bin:$PATH
export LD_LIBRARY_PATH=/gitlab/USD-install/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/gitlab/USD-install/lib/python
export MESA_GLSL_VERSION_OVERRIDE="450"
export MESA_GL_VERSION_OVERRIDE="4.5"

cd testing
# make sure that ctest is the final command to return for CI job success/fail
ctest -VV