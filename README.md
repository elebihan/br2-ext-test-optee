# br2-ext-test-optee - Buildroot External Customisation

This Buildroot external configuration provides items to test OP-TEE on QEMU
(Aarch64).

Currently, it provides a package for [hello_ta][HELLO_TA], a simple Trusted
Application. It is signed with a custom key.

# Installation

Clone [Buildroot][BR2] along with this repository:

```sh
mkdir -p ~/Projects
git clone https://git.buildroot.net/buildroot
git clone https://github.com/elebihan/buildroot-ext-test-optee
cd buildroot
```

# Build firmware

```sh
make O=$HOME/build/test-optee/qemu/aarch64_virt \
    BR2_EXTERNAL=$HOME/Projects/br2-ext-test-optee \
    qemu_aarch64_virt_optee_defconfig
make O=$HOME/build/test-optee/qemu/aarch64_virt
```

# Run firmware

## Start QEMU

```sh
cd ~/build/test-optee/qemu/aarch64_virt/images
~/build/test-optee/qemu/aarch64_virt/host/bin/qemu-system-aarch64 \
    -nographic \
    -serial tcp:localhost:54320 \
    -serial tcp:localhost:54321 \
    -smp 2 -s -S \
    -machine virt,secure=on,gic-version=2,virtualization=false \
    -cpu cortex-a57 \
    -d unimp \
    -semihosting-config enable=on,target=native \
    -m 1057 \
    -bios bl1.bin \
    -initrd rootfs.cpio.gz \
    -kernel Image \
    -no-acpi \
    -append 'console=ttyAMA0,38400 keep_bootcon root=/dev/vda2' \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
    -netdev user,id=vmnic \
    -device virtio-net-device,netdev=vmnic
```

## Start pseudo terminals

Install [soc_term.py][SOC_TERM], and launch one instance on port 54320, the
other on port 54321, to get the TEE serial output and the REE serial console.

[BR2]: https://buildroot.org
[HELLO_TA]: https://github.com/elebihan/hello-ta
[SOC_TERM]: https://github.com/OP-TEE/build/blob/master/soc_term.py


