# pixotg
Mounts an ext4 drive over usb for a rooted OG pixel to use for backup


# How to use
Format your drive as ext4, and label it PixOTG. Place the script in /data/adb/system.d and give it 755 permissions. Reboot the device, and the script will begin to run. Plug in your drive, and it will mount to /storage/emulated/0/Backup.

If you wish to change the mount directory, find and replace /storage/emulated/0/Backup in the script (make sure to only edit on a unix system, or if you use windows you can edit it and pass it through dos2unix)
