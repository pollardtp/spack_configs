# Spack configuration files for multiple HPC centers

- Defaults to highest available system GCC and MPI (MPT, Cray)

- Replaces conda entirely (ase, psi4)

# Production ready HPC:
 
 - HPE: Koehr/Gaffney/Mustang

 - Cray: Centennial
 
# Anticipated HPC:
  
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

For py-ase, matplotlib is needed which is dependent on py-pillow. py-pillow doesn't compile correctly with -O3 optimizations, so

```spack edit py-matplotlib```

Change image from True to False. I don't need it anyways.
