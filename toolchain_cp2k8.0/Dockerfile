ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

ARG MPI_MODE=mpich
ARG LIBINT_LMAX=5
ARG BASE_IMAGE

# author: Ole Schuett

# Installs complete toolchain including packages which are skipped by default.

USER root

# install Linux packages.
COPY ./install_requirements*.sh ./
RUN ./install_requirements.sh ${BASE_IMAGE}

ENV LANG en_US.UTF-8

# copy helper scripts
WORKDIR /opt/cp2k-toolchain
RUN mkdir scripts
COPY ./scripts/VERSION \
     ./scripts/parse_if.py \
     ./scripts/tool_kit.sh \
     ./scripts/common_vars.sh \
     ./scripts/signal_trap.sh \
     ./scripts/

# Dry-run leaves behind config files for the followup install scripts.
# This breaks up the lengthy installation into smaller docker build steps.
COPY ./install_cp2k_toolchain.sh .
RUN ./install_cp2k_toolchain.sh  \
    --install-all \
    --mpi-mode=${MPI_MODE} \
    --libint-lmax=${LIBINT_LMAX} \
    --dry-run

COPY ./scripts/install_gcc.sh \
     ./scripts/get_openblas_arch.sh \
     ./scripts/setup_buildtools.sh \
     ./scripts/openblas-0.3.6-disable-avx512.patch \
     ./scripts/
COPY ./scripts/files/gcc-10.2.0-cpp-__has_include.patch \
     ./scripts/files/
RUN ./scripts/install_gcc.sh && \
    ./scripts/setup_buildtools.sh && \
    rm -rf ./build

COPY ./scripts/install_cmake.sh ./scripts/
RUN ./scripts/install_cmake.sh && rm -rf ./build

COPY ./scripts/install_mpich.sh \
     ./scripts/install_openmpi.sh \
     ./scripts/install_intelmpi.sh \
     ./scripts/
RUN ./scripts/install_openmpi.sh && \
    ./scripts/install_mpich.sh && \
    ./scripts/install_intelmpi.sh && \
    rm -rf ./build

COPY ./scripts/install_valgrind.sh ./scripts/
RUN ./scripts/install_valgrind.sh && rm -rf ./build

COPY ./scripts/install_reflapack.sh \
     ./scripts/install_mkl.sh \
     ./scripts/install_acml.sh \
     ./scripts/install_openblas.sh \
     ./scripts/install_mathlibs.sh \
     ./scripts/
RUN ./scripts/install_mathlibs.sh && rm -rf ./build

COPY ./scripts/install_fftw.sh ./scripts/
RUN ./scripts/install_fftw.sh && rm -rf ./build

COPY ./scripts/install_libint.sh ./scripts/
RUN ./scripts/install_libint.sh && rm -rf ./build

COPY ./scripts/install_libxc.sh ./scripts/
RUN ./scripts/install_libxc.sh && rm -rf ./build

COPY ./scripts/install_libsmm.sh \
     ./scripts/install_libxsmm.sh \
     ./scripts/install_scalapack.sh \
     ./scripts/install_cosma.sh \
     ./scripts/
COPY ./scripts/files/scalapack-2.1.0-gcc10.patch \
     ./scripts/files/
RUN ./scripts/install_libsmm.sh && \
    ./scripts/install_libxsmm.sh && \
    ./scripts/install_scalapack.sh && \
    ./scripts/install_cosma.sh && \
    rm -rf ./build

COPY ./scripts/install_elpa.sh ./scripts/
RUN ./scripts/install_elpa.sh && rm -rf ./build

COPY ./scripts/install_ptscotch.sh \
     ./scripts/install_superlu.sh \
     ./scripts/install_pexsi.sh \
     ./scripts/
RUN ./scripts/install_ptscotch.sh && \
    ./scripts/install_superlu.sh && \
    ./scripts/install_pexsi.sh && \
    rm -rf ./build

COPY ./scripts/install_quip.sh \
     ./scripts/install_plumed.sh \
     ./scripts/
RUN ./scripts/install_quip.sh && \
    ./scripts/install_plumed.sh && \
    rm -rf ./build

COPY ./scripts/install_gsl.sh \
     ./scripts/install_hdf5.sh \
     ./scripts/
RUN ./scripts/install_gsl.sh && \
    ./scripts/install_hdf5.sh && \
    rm -rf ./build

COPY ./scripts/install_libvdwxc.sh \
     ./scripts/install_spglib.sh \
     ./scripts/install_spfft.sh \
     ./scripts/
RUN ./scripts/install_libvdwxc.sh && \
    ./scripts/install_spglib.sh && \
    ./scripts/install_spfft.sh && \
    rm -rf ./build

COPY ./scripts/install_sirius.sh ./scripts/
RUN ./scripts/install_sirius.sh && rm -rf ./build

COPY ./scripts/arch_base.tmpl \
     ./scripts/generate_arch_files.sh \
     ./scripts/
RUN ./scripts/generate_arch_files.sh && rm -rf ./build

#EOF
