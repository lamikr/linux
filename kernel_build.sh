#origin	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
#stable	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

OPT_JCPU=-j12
OPT_BDIR=../b_6_13_0

if [ ! -d $OPT_BDIR ]; then
    mkdir -p $OPT_BDIR
    cp config.kernel_613 $OPT_BDIR/.config
fi

if [ ! -z "$1" ]; then
    if [[ $1 == "c" ]]; then
        make O=$OPT_BDIR oldconfig
    fi
    if [[ $1 == "b" ]]; then
        make O=$OPT_BDIR $OPT_JCPU
    fi
    if [[ $1 = "i" ]]; then
        sudo make O=$OPT_BDIR INSTALL_MOD_STRIP=1 modules_install
        if [ $? -eq 0 ]; then
            sudo make O=$OPT_BDIR INSTALL_MOD_STRIP=1 install
        fi
    fi
    if [[ $1 = "h" ]]; then
        # hack, to save time for module install when only modifying the amdgpu sources
        # copy only the amdgpu to expected location after build
        # remember to change to install directory depending from the kernel version in use
        make O=$OPT_BDIR $OPT_JCPU
        res=$?
        if [ $res -eq 0 ]; then
            DRIVER_TARGET_DIR=/lib/modules/6.12.0+/kernel/drivers/gpu/drm/amd/amdgpu
            DRIVER_TARGET_PATH=$DRIVER_TARGET_DIR/amdgpu.ko
            echo "copying driver to $DRIVER_TARGET_PATH"
            cp -f $OPT_BDIR/drivers/gpu/drm/amd/amdgpu/amdgpu.ko .
            strip --strip-debug amdgpu.ko
            if [ ! -d $DRIVER_TARGET_DIR ]; then
                sudo mkdir $DRIVER_TARGET_DIR
            fi
            sudo mv -f amdgpu.ko $DRIVER_TARGET_DIR
        else
            echo "skipping driver copy"
        fi
    fi
else
    make O=$OPT_BDIR $OPT_JCPU
    if [ $? -eq 0 ]; then
        sudo make O=$OPT_BDIR INSTALL_MOD_STRIP=1 modules_install
	    if [ $? -eq 0 ]; then
                sudo make O=$OPT_BDIR INSTALL_MOD_STRIP=1 install
        fi
    fi
fi
