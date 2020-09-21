#!/bin/bash

echo -e "This script installs the target starting environment for Spack on each HPC.\n \n \n"

# where is spack?
spack_exe=`which spack`

# what cluster are we on?
if uname -a | grep -q "koehr"; then cluster='koehr'; fi
if uname -a | grep -q "gaffney"; then cluster='gaffney'; fi
if uname -a | grep -q "mustang"; then cluster='mustang'; fi
if uname -a | grep -q "centennial"; then cluster='centennial'; fi

if [ -z $spack_exe ]; 
    then 
        echo -e "Please set the location of your spack binary to PATH.\n"
    break
    else
        echo -e "Spack binary found in $spack_exe, continuing...\n \n \n"
fi

if [ $cluster == "koehr" -o $cluster == "gaffney" -o $cluster == "mustang" ]; then
 # download python based packages, no mpi
 pkg_list=("py-ase" "py-mdanalysis" "git" "py-pip" "miniconda3" "py-scikit-learn" "py-scikit-optimize" "openbabel" "packmol" "py-moltemplate" "openbabel")
 for pkg in ${pkg_list[@]}; do
     $spack_exe install $pkg
 done

 # grab psi4 binary with conda
 spack load miniconda3
 conda install -c psi4 psi4
else
 echo "Cluster not currently fully supported."
fi
