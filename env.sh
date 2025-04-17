#!/bin/bash
top_dir=$(pwd)
export LD_LIBRARY_PATH=${top_dir}/OpenBLAS/install/lib:$LD_LIBRARY_PATH
export PATH=${top_dir}/moab/install/bin:$PATH
export LD_LIBRARY_PATH=${top_dir}/moab/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${top_dir}/DAGMC/install/lib:$LD_LIBRARY_PATH

echo "When building OpenMC, you will need to add: -DOPENMC_USE_DAGMC=on -DCMAKE_PREFIX_PATH=${top_dir}/DAGMC/install"
