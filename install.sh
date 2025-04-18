#!/bin/bash
set -ex

THREADS=192
top_dir=$(pwd)

#Assumes eigen3 has been installed, e.g., via conda/mamba as: "mamba install omnia::eigen3"
module purge
module load cmake
module load hdf5

# Comment out these variables to skip these install steps

INSTALL_BLAS=YES
INSTALL_MOAB=YES
INSTALL_EMBREE=YES
INSTALL_DOUBLE_DOWN=YES
INSTALL_DAGMC=YES

# Install OpenBLAS
if [[ -v INSTALL_BLAS ]]; then
  rm -rf OpenBLAS
  git clone --branch v0.3.29 --depth 1 https://github.com/OpenMathLib/OpenBLAS.git
  cd OpenBLAS
  rm -rf install
  mkdir install
  make -j${THREADS}
  make install PREFIX=${top_dir}/OpenBLAS/install
  cd ${top_dir}
fi

# OpenBLAS compilation seems to seg fault with newer versions of gcc, so we only
# load the up to date version once it's already compiled.
module load gcc/14.1.0

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/jtramm/dagmc_installer/OpenBLAS/install/lib

# Install MOAB
if [[ -v INSTALL_MOAB ]]; then
  rm -rf moab
  git clone https://bitbucket.org/fathomteam/moab.git
  cd moab
  mkdir build
  mkdir install
  cd build
  CC=gcc CXX=g++ cmake -DENABLE_EIGEN3=ON -DENABLE_HDF5=ON -DCMAKE_INSTALL_PREFIX=../install ..
  make -j${THREADS} install
  cd ${top_dir}
fi

# Install Embree
if [[ -v INSTALL_EMBREE ]]; then
  rm -rf embree
  git clone https://github.com/RenderKit/embree.git
  cd embree
  mkdir build
  mkdir install
  cd build
  CC=gcc CXX=g++ cmake -DCMAKE_INSTALL_PREFIX=../install \
        -DEMBREE_ISPC_SUPPORT=OFF \
        -DEMBREE_TASKING_SYSTEM=INTERNAL \
        -DEMBREE_TUTORIALS=OFF \
        -DEMBREE_TBB_ROOT=/usr \
        ..
  make -j${THREADS} install
  cd ${top_dir}
fi

# Install Double Down
if [[ -v INSTALL_DOUBLE_DOWN ]]; then
  rm -rf double-down
  git clone https://github.com/pshriwise/double-down.git
  cd double-down
  mkdir build
  mkdir install
  cd build
  CC=gcc CXX=g++ cmake \
    -DCMAKE_PREFIX_PATH="${top_dir}/embree/install;${top_dir}/moab/install" \
    -DCMAKE_INSTALL_PREFIX=../install \
    ..
  make -j${THREADS} install
  cd ${top_dir}
fi

# Install DagMC
if [[ -v INSTALL_DAGMC ]]; then
  rm -rf DAGMC
  git clone https://github.com/svalinn/DAGMC.git
  cd DAGMC
  git submodule update --init
  mkdir install
  mkdir build
  cd build
  CC=gcc CXX=g++ cmake \
    -DCMAKE_PREFIX_PATH="${top_dir}/double-down/install" \
    -DMOAB_DIR=${top_dir}/moab/install \
    -DBUILD_TALLY=ON \
    -DCMAKE_INSTALL_PREFIX=../install \
    -DDOUBLE_DOWN=ON \
    -DDOUBLE_DOWN_DIR=${top_dir}/double-down/install \
    ..
  make -j${THREADS} install
  cd ${top_dir}
fi
