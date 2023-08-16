# NixOS running on RK3588/RK3588s

> :warning: Work in progress, use at your own risk...

A minimal flake that makes NixOS running on RK3588/RK3588s based SBCs.

![](_img/nixos-on-orangepi5.webp)

## Boards

| Singal Board Computer | minimal bootable image | 
| --------------------- | ---------------------- | 
| Orange Pi 5           | :heavy_check_mark:     | 
| Orange Pi 5 Plus      | :no_entry_sign:        | 
| Rock 5A               | :no_entry_sign:        | 

## TODO

- [ ] build u-boot with nix
- [ ] support boot from emmc
- [ ] verify all the hardware features available by RK3588/RK3588s
  - [x] ethernet (rj45)
  - wifi/bluetooth
  - audio
  - [x] gpio
  - [x] uart/ttl
  - gpu(mali-g610-firmware + [panfrok/mesa](https://gitlab.com/panfork/mesa))
  - npu
  - ...

## Flash into SD card

1. You should get the uboot from the vendor and flash it to the SPI flash before doing anything NixOS
   1. [Armbian on Orange Pi 5](https://www.armbian.com/orange-pi-5/) as an example:
      1. download the image and flash it to a sd card first
      2. boot the board with the sd card, and then run `sudo armbian-install` to flash the uboot to the SPI flash(maybe named as `MTD devices`)
2. build an sdImage by `nix build`, and then flash it to a sd card using `dd`:
   ```shell
   nix build .#sdImage-opi5
   zstdcat result/sd-image/orangepi5-sd-image-*.img.zst | sudo dd bs=4M of=/dev/sdX status=progress
   ```
3. insert the sd card to the board, and power on
4. resize the root partition to the full size of the sd card.
5. then having fun with NixOS

Once the system is booted, you can use `nixos-rebuild` to update the system.

## Flash into SSD

TODO

## Debug via serial port(UART)

See [Debug.md](./Debug.md)

## Custom Deployment

You can use this flake as an input to build your own configuration.
Here is an example configuration that you can use as a starting point: [Demo - Deployment](./demo)


## How this flake works

A complete Linux system typically consists of five components: U-Boot, the kernel, device trees, firmwares, and the root file system (rootfs).

Among these, U-Boot, the kernel, device trees, and firmwares are hardware-related and require customization for different SBCs.
On the other hand, the majority of content in the rootfs is hardware-independent and can be shared across different SBCs.

Hence, the fundamental approach here is to use the hardware-specific components(U-Boot, kernel, and device trees, firmwares) provided by the vendor(orangepi/rockpi/...), and combine them with the NixOS rootfs to build a comprehensive system.

Regarding RK3588/RK3588s, a significant amount of work has been done by Armbian on their kernel, and device tree.
Therefore, by integrating these components from Armbian with the NixOS rootfs, we can create a complete NixOS system.

The primary steps involved are:

1. Build U-Boot using this Flake.
   - Since no customization is required for U-Boot, it's also possible to directly use the precompiled U-Boot from Armbian or the hardware vendor.
2. Build the NixOS rootfs using this Flake, leveraging the kernel and device tree provided by Armbian.
   - To make all the hardware features available, we need to add its firmwares to the rootfs. Since there is no customization required for the firmwares too, we can directly use the precompiled firmwares from Armbian & Vendor.

Related Armbian projects:

- <https://github.com/armbian/build>
- <https://github.com/armbian/linux-rockchip>

## References

The projects that inspired me:

- [K900/nix](https://gitlab.com/K900/nix)
- [aciceri/rock5b-nixos](https://github.com/aciceri/rock5b-nixos)
- [fb87/nixos-orangepi-5x](https://github.com/fb87/nixos-orangepi-5x): NixOS build for Orangepi 5B, based on my work, but adds bootloader and more firmwares into the sdImage, great work!

And I also got a lot of help in the [NixOS on ARM Matrix group](https://matrix.to/#/#nixos-on-arm:nixos.org)!
