savedcmd_rtk_btusb.mod := printf '%s\n'   rtk_bt.o rtk_coex.o rtk_misc.o | awk '!x[$$0]++ { print("./"$$0) }' > rtk_btusb.mod
