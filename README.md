# Spack configuration files for multiple HPC centers

- Defaults to highest available system GCC and MPI (MPT, Cray)

- Replaces conda entirely (ase, psi4)

# Production ready HPC:
 
 - Koehr/Gaffney

 - Centennial
 
# Anticipated HPC:

 - Mustang
  
 - Conrad/Gordon

# Instructions

Download and install in ~/.spack on respective supercomputers.

# Notes

### All HPC when using mpt

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
