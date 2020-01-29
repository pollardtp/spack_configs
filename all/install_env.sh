#!/bin/bash

echo -e "This script installs the target starting environment for Spack on each HPC.\n \n \n"

# where is spack?
spack_exe=`which spack`

# what cluster are we on?
if uname -a | grep -q "koehr"; then cluster='koehr'; fi
if uname -a | grep -q "gaffney"; then cluster='gaffney'; fi
if uname -a | grep -q "mustang"; then cluster='mustang'; fi
if uname -a | grep -q "centennial"; then cluster='centennial'; fi
if uname -a | grep -q "conrad"; then cluster='conrad'; fi
if uname -a | grep -q "gordon"; then cluster='gordon'; fi

if [ -z $spack_exe ]; 
    then 
        echo -e "Please set the location of your spack binary to PATH.\n"
    break
    else
        echo -e "Spack binary found in $spack_exe, continuing...\n \n \n"
fi

if [ $cluster == "koehr" -o $cluster == "gaffney" ]; then
 # openmpi for PBS and optimized for omnipath
 $spack_exe install openmpi fabrics=psm2 schedulers=tm +thread_multiple+sqlite3+vt

 # download python based packages
 pkg_list=("py-ase" "py-mdanalysis" "git" "py-pip" "miniconda3" "py-pint" "py-phonopy" "py-scikit-learn" "py-scikit-optimize" "openbabel")
 for pkg in ${pkg_list[@]}; do
     $spack_exe install $pkg
 done

 # chemistry
 $spack_exe install cp2k +mpi~openmp+elpa+libxc lmax=5 blas=openblas smm=libxsmm
 
 # grab psi4 binary with conda
 spack load miniconda3
 conda install -c psi4 psi4
else
 echo "Cluster not currently fully supported."
fi

