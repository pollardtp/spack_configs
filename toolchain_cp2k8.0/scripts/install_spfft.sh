#!/bin/bash -e
[ "${BASH_SOURCE[0]}" ] && SCRIPT_NAME="${BASH_SOURCE[0]}" || SCRIPT_NAME=$0
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_NAME")" && pwd -P)"

spfft_ver="0.9.12"
spfft_sha256="4bf879c6b3914bf5e462ef04a43656be559a8402755180301d99a080834d8fb3"
source "${SCRIPT_DIR}"/common_vars.sh
source "${SCRIPT_DIR}"/tool_kit.sh
source "${SCRIPT_DIR}"/signal_trap.sh
source "${INSTALLDIR}"/toolchain.conf
source "${INSTALLDIR}"/toolchain.env

[ -f "${BUILDDIR}/setup_SpFFT" ] && rm "${BUILDDIR}/setup_SpFFT"

! [ -d "${BUILDDIR}" ] && mkdir -p "${BUILDDIR}"
cd "${BUILDDIR}"

case "$with_spfft" in
    __INSTALL__)
        echo "==================== Installing spfft ===================="
        pkg_install_dir="${INSTALLDIR}/SpFFT-${spfft_ver}"
        install_lock_file="$pkg_install_dir/install_successful"
        if verify_checksums "${install_lock_file}" ; then
            echo "SpFFT-${spfft_ver} is already installed, skipping it."
        else
            if [ -f SpFFT-${spfft_ver}.tar.gz ] ; then
                echo "SpFFT-${spfft_ver}.tar.gz is found"
            else
                download_pkg ${DOWNLOADER_FLAGS} ${spfft_sha256} \
                             "https://github.com/eth-cscs/SpFFT/archive/v${spfft_ver}.tar.gz" \
                              -o SpFFT-${spfft_ver}.tar.gz

            fi
            echo "Installing from scratch into ${pkg_install_dir}"
            [ -d SpFFT-${spfft_ver} ] && rm -rf SpFFT-${spfft_ver}
            tar -xzf SpFFT-${spfft_ver}.tar.gz
            cd SpFFT-${spfft_ver}
            mkdir build-cpu
            cd build-cpu
            cmake -DCMAKE_INSTALL_PREFIX="${pkg_install_dir}" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DSPFFT_OMP=ON -DSPFFT_MPI=ON -DSPFFT_INSTALL=ON .. > cmake.log 2>&1
            make -j $NPROCS > make.log 2>&1
            make -j $NPROCS install > install.log 2>&1
            cd ..
            write_checksums "${install_lock_file}" "${SCRIPT_DIR}/$(basename ${SCRIPT_NAME})"
            if [ "$ENABLE_CUDA" = "__TRUE__" ] ; then
                [ -d build-cuda ] && rm -rf "build-cuda"
                mkdir build-cuda
                cd build-cuda
                cmake -DCMAKE_INSTALL_PREFIX="${pkg_install_dir}" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DSPFFT_OMP=ON -DSPFFT_MPI=ON -DSPFFT_INSTALL=ON -DSPFFT_GPU_BACKEND=CUDA .. > cmake.log 2>&1
                make -j $NPROCS > make.log 2>&1
                install -d ${pkg_install_dir}/lib/cuda
                [ -f src/libspfft.a ] && install -m 644 src/*.a ${pkg_install_dir}/lib/cuda >> install.log 2>&1
                [ -f src/libspfft.a ] && install -m 644 src/*.so ${pkg_install_dir}/lib/cuda >> install.log 2>&1
            fi
        fi
        SPFFT_ROOT="${pkg_install_dir}"
        SPFFT_CFLAGS="-I'${pkg_install_dir}/include'"
        SPFFT_LDFLAGS="-L'${pkg_install_dir}/lib' -Wl,-rpath='${pkg_install_dir}/lib'"
        SPFFT_CUDA_LDFLAGS="-L'${pkg_install_dir}/lib/cuda' -Wl,-rpath='${pkg_install_dir}/lib/cuda'"
        if [ -d "${SPFFT_ROOT}/lib64" ]; then
           cd ${SPFFT_ROOT}
           ln -sf lib64 lib
           cd ${BUILDDIR}
        fi
        ;;
    __SYSTEM__)
        echo "==================== Finding psfft from system paths ===================="
        check_command pkg-config --modversion psfft
        add_include_from_paths SPFFT_CFLAGS "spfft.h" $INCLUDE_PATHS
        add_lib_from_paths SPFFT_LDFLAGS "libspfft.*" $LIB_PATHS
        ;;
    __DONTUSE__)
        ;;
    *)
        echo "==================== Linking psfft to user paths ===================="
        pkg_install_dir="$with_spfft"
        check_dir "$pkg_install_dir/lib"
        check_dir "$pkg_install_dir/include"
        SPFFT_CFLAGS="-I'${pkg_install_dir}/include'"
        SPFFT_LDFLAGS="-L'${pkg_install_dir}/lib' -Wl,-rpath='${pkg_install_dir}/lib'"
        ;;
esac
if [ "$with_spfft" != "__DONTUSE__" ] ; then
    SPFFT_LIBS="-lspfft"
    if [ "$with_spfft" != "__SYSTEM__" ] ; then
        cat << EOF > "${BUILDDIR}/setup_spfft"
prepend_path LD_LIBRARY_PATH "$pkg_install_dir/lib"
prepend_path LD_RUN_PATH "$pkg_install_dir/lib"
prepend_path LIBRARY_PATH "$pkg_install_dir/lib"
prepend_path CPATH "$pkg_install_dir/include"
export SPFFT_INCLUDE_DIR="$pkg_install_dir/include"
export SPFFT_LIBS="-lspfft"
export SPFFT_ROOT="${pkg_install_dir}"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$pkg_install_dir/lib64/pkgconfig:$pkg_install_dir/lib/pkgconfig"
EOF
    fi
    cat << EOF >> "${BUILDDIR}/setup_spfft"
export SPFFT_CFLAGS="${SPFFT_CFLAGS}"
export SPFFT_LDFLAGS="${SPFFT_LDFLAGS}"
export SPFFT_CUDA_LDFLAGS="${SPFFT_CUDA_LDFLAGS}"
export CP_DFLAGS="\${CP_DFLAGS} IF_MPI(-D__SPFFT|)"
export CP_CFLAGS="\${CP_CFLAGS} ${SPFFT_CFLAGS}"
export CP_LDFLAGS="\${CP_LDFLAGS} IF_CUDA(${SPFFT_CUDA_LDFLAGS}|${SPFFT_LDFLAGS})"
export SPFFT_LIBRARY="-lspfft"
export SPFFT_ROOT="$pkg_install_dir"
export SPFFT_INCLUDE_DIR="$pkg_install_dir/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$pkg_install_dir/lib64/pkgconfig:$pkg_install_dir/lib/pkgconfig"
export SPFFT_VERSION=${spfft-ver}
export CP_LIBS="IF_MPI(${SPFFT_LIBS}|) \${CP_LIBS}"
EOF
    cat "${BUILDDIR}/setup_spfft" >> $SETUPFILE
fi

# update toolchain environment
load "${BUILDDIR}/setup_spfft"
export -p > "${INSTALLDIR}/toolchain.env"

cd "${ROOTDIR}"
report_timing "spfft"
