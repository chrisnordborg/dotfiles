obj-m += rtk_btusb.o

rtk_btusb-objs := rtk_bt.o rtk_coex.o rtk_misc.o

all:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

install:
	sudo cp rtk_btusb.ko /lib/modules/$(shell uname -r)/kernel/drivers/bluetooth/
	sudo depmod
	echo "rtk_btusb installed!"

