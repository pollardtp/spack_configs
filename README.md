# Spack configuration files for multiple HPC centers

Uses system (gcc, intel) and (mpt, openmpi, intel).

# Supported HPC:

 - Mustang
 
 - Koehr/Gaffney
 
 - Conrad/Gordon

 - Centennial

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
