#!/bin/bash
password=$(zenity --title="QEMU" --text="请输入 $USER 密码" --password)
echo ${password} | sudo -S chown $USER /dev/ubuntu-vg/qemu-windows-lv >> /dev/null
sudo chown $USER /dev/ubuntu-vg/qemu-windows-disk-lv >> /dev/null
qemu-system-x86_64 \
	-machine type=q35,hmat=on \
	-cpu host \
	-accel kvm \
	-smp 16 \
	-m 4G,slots=4,maxmem=8G \
		-numa node,nodeid=0,memdev=mem0 \
			-object memory-backend-ram,size=1G,id=mem0,share=on \
		-numa node,nodeid=1,memdev=mem1 \
			-object memory-backend-ram,size=1G,id=mem1,share=on \
		-numa node,nodeid=2,memdev=mem2 \
			-object memory-backend-ram,size=1G,id=mem2,share=on \
		-numa node,nodeid=3,memdev=mem3 \
			-object memory-backend-ram,size=1G,id=mem3,share=on \
	-bios OVMF.fd \
	-boot c,menu=off \
	-device pcie-root-port,addr=01.0,bus=pcie.0,chassis=1,id=pcie.1,port=1,slot=1 \
		-device virtio-vga-gl,addr=00.0,bus=pcie.1,xres=2560,yres=1600 \
	-device pcie-root-port,addr=02.0,bus=pcie.0,chassis=1,id=pcie.2,port=1,slot=2 \
		-device virtio-net-pci,addr=00.0,bus=pcie.2,netdev=net0 \
			-netdev user,id=net0,ipv4=on,ipv6=on,hostfwd=tcp::2121-:2121 \
	-device pcie-root-port,addr=03.0,bus=pcie.0,chassis=3,id=pcie.3,port=3,slot=3 \
	-device pcie-root-port,addr=04.0,bus=pcie.0,chassis=4,id=pcie.4,port=4,slot=4 \
		-device virtio-scsi-pci,addr=00.0,bus=pcie.4,id=scsi \
			-device scsi-hd,bus=scsi.0,drive=hd0,scsi-id=0 \
				-drive file=/dev/ubuntu-vg/qemu-windows-lv,id=hd0,if=none,index=0,format=raw \
			-device scsi-hd,bus=scsi.0,drive=hd1,scsi-id=1 \
				-drive file=/dev/ubuntu-vg/qemu-windows-disk-lv,id=hd1,if=none,index=1,format=raw \
		-drive file=virtio-win-0.1.229.iso,id=cd0,index=2,format=raw,media=cdrom \
	-device pcie-root-port,addr=05.0,bus=pcie.0,chassis=5,id=pcie.5,port=5,slot=5 \
		-device virtio-rng-pci,addr=00.0,bus=pcie.5 \
		-device virtio-tablet-pci,addr=01.0,bus=pcie.5 \
	-device pcie-root-port,addr=06.0,bus=pcie.0,chassis=6,id=pcie.6,port=6,slot=6 \
	-display "gtk",full-screen="on",gl="on" \
	-name "Windows Server 2022"
echo ${password} | sudo -S chown root /dev/ubuntu-vg/qemu-windows-lv >> /dev/null
