# Spack configuration files for multiple HPC centers

- Download (```spack edit gcc``` set preferred gcc-8.2.0) or ```module purge; module load gcc/8.2.0```

- Download openmpi through spack, set as preferred mpi in packages.yaml

- Edit elpa and cp2k to disable mpi mod

- Edit py-matplotlib to set Image to False

```spack install py-ase cp2k +mpi~openmp+elpa+libxc smm=libxsmm lmax=5 blas=openblas ^openmpi@3.1.5~cuda+cxx_exceptions fabrics=psm2 ~java~legacylaunchers~memchecker~pmi schedulers=tm +sqlite3+thread_multiple+vt psi4```

- Psi4 install will break due to too long a shebang, just find the binary and install the module in packages.yaml

# Production ready HPC:
 
 - HPE: Koehr/Gaffney/Mustang

 - Cray: Centennial/Excalibur/Onyx
 
# Anticipated HPC:
  
 - Conrad/Gordon

# Instructions

Download and install in ~/.spack on respective supercomputers.

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
