#!/bin/bash

echo -e "This script installs the target starting environment for Spack on each HPC.\n \n \n"

spack_exe=`which spack`

if [ -z $spack_exe ]; 
	then 
		echo -e "Please set the location of your spack binary to PATH.\n"
		break
	else
		echo -e "Spack binary found in $spack_exe, continuing...\n \n \n"
fi

# python
pkg_list=("python@3.7.4" "python@2.7.16" "py-ase" "py-mdanalysis" "py-matplotlib" "py-maestrowf" "py-gpaw+mpi+fftw+scalapack")
for pkg in ${pkg_list[@]}; do
	$spack_exe install $pkg
done

# chemistry
$spack_exe install cp2k +mpi~openmp+elpa+libxc+plumed lmax=5 blas=mkl
