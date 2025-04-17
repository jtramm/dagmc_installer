#!/bin/bash

THREADS=32
top_dir=$(pwd)

module purge
module load cmake
module load hdf5
module load gcc/14.1.0
mamba activate

# Comment out these variables to skip these install steps

INSTALL_BLAS=YES
INSTALL_EIGEN=YES
INSTALL_MOAB=YES
INSTALL_DAGMC=YES

# Install OpenBLAS
if [[ -v INSTALL_BLAS ]]; then
  rm -rf OpenBLAS
  git clone git@github.com:OpenMathLib/OpenBLAS.git
  cd OpenBLAS
  mkdir install
  make -j${THREADS}
  make install PREFIX=${top_dir}/OpenBLAS/install
  cd ${top_dir}
fi

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/jtramm/dagmc_installer/OpenBLAS/install/lib

# Install Eigen3
if [[ -v INSTALL_EIGEN ]]; then
  rm -rf eigen
  git clone https://gitlab.com/libeigen/eigen
  cd ${top_dir}
fi
 
export Eigen3_DIR=${top_dir}/eigen/cmake

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

# Install DagMC
if [[ -v INSTALL_DAGMC ]]; then
  rm -rf DAGMC
  git clone git@github.com:svalinn/DAGMC.git
  cd DAGMC
  git submodule update --init
  mkdir install
  mkdir build
  cd build
  CC=gcc CXX=g++ cmake -DCMAKE_PREFIX_PATH=${top_dir}/eigen -DMOAB_DIR=${top_dir}/moab/install -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=../install ..
  make -j${THREADS} install
  cd ${top_dir}
fi
