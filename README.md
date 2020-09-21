# Spack configuration files for multiple HPC centers

- Download (```spack edit gcc``` set preferred gcc-8.2.0) or ```module purge; module load gcc/8.2.0```

- Download openmpi through spack, set as preferred mpi in packages.yaml

- Edit elpa and cp2k to disable mpi mod

- Edit py-matplotlib to set Image to False

```spack install py-ase cp2k +mpi~openmp+elpa+libxc smm=libxsmm lmax=5 blas=openblas ^openmpi@3.1.5~cuda+cxx_exceptions fabrics=psm2 ~java~legacylaunchers~memchecker~pmi schedulers=tm +sqlite3+thread_multiple+vt```

# Production ready HPC:
 
 - HPE: Koehr/Gaffney/Mustang

 - Cray: Centennial/Excalibur/Onyx
 
# Instructions

Download and install in ~/.spack on respective supercomputers.

# Keeping up to date

```
update_spack_configs () {
 ping=`pwd`
 if [ -d $HOME/.local_programs/spack_configs ]; then
  cd $HOME/.local_programs/spack_configs
  git pull
 else
  git clone https://github.com/pollardtp/spack_configs.git $HOME/.local_programs/spack_configs
 fi
 cd $ping
}
```

# Notes

```spack edit elpa```

```
        options = ['--disable-mpi-module']
```

```spack edit cp2k```

```
        # MPI
        if '+mpi' in self.spec:
            cppflags.extend([
                '-D__parallel',
                '-D__SCALAPACK',
                '-D__HAS_NO_MPI_MOD' # add this
            ])
```

For py-ase, matplotlib is needed which is dependent on py-pillow. py-pillow doesn't compile correctly with -O3 optimizations, so

```spack edit py-matplotlib```

# ORCA

Download binaries from website, extract (```mkdir bin; mv * bin/```), add to packages.yaml,

```  
orca:
  paths:
    orca@4.2.1: /p/home/teep/.local_programs/orca_4_2_1_linux_x86-64_openmpi314/bin
  buildable: false
```

Then execute ```spack install orca``` to generate the module file.

# Psi4

Obtain through conda.

```spack install miniconda3; spack load miniconda3; conda install -c psi4 psi4```
