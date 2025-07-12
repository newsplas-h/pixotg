#mount ext4 with label - /data/adb/service.d/ android 10 (later versions don't use sdcardfs afaik)
#set up logging
LOGFILE="/data/local/tmp/otg_mount_debug.log"
exec >> "$LOGFILE" 2>&1
echo "=== OTG mount script started at $(date) ==="

#variables
TARGET_LABEL="PixOTG"
MOUNT_POINT="/mnt/otg"
SELINUX_CONTEXT="u:object_r:sdcardfs:s0"

#wait for magisk
sleep 60

#check for /mnt/otg in case it's missing on a reboot
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point: $MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"
    chmod 775 "$MOUNT_POINT"
    chown root:media_rw "$MOUNT_POINT" 2>/dev/null
fi

while true; do
  #gets device from blkid
  DEVICE_PARTITION=$(blkid | awk -F: -v label="$TARGET_LABEL" '$0 ~ "LABEL=\""label"\"" { print $1; exit }')
  echo "[$(date)] Checked blkid. Found: $DEVICE_PARTITION"

  #unmount on unplug
  if mount | grep -q "$MOUNT_POINT"; then
    if [ -z "$DEVICE_PARTITION" ]; then
      echo "[$(date)] Device removed but still mounted. Unmounting $MOUNT_POINT"
      #not sure if all 3 are necessary, but works
      umount -l /mnt/runtime/default/emulated/0/Backup
      umount -l /mnt/runtime/read/emulated/0/Backup
      umount -l /mnt/runtime/write/emulated/0/Backup
      umount -l "$MOUNT_POINT"
    fi
  fi

  #mount if PixOTG is found
  if [ -n "$DEVICE_PARTITION" ]; then
    if ! mount | grep -q "$MOUNT_POINT"; then
      echo "[$(date)] Mounting $DEVICE_PARTITION to $MOUNT_POINT with SELinux context"
      mount -t ext4 -o context=$SELINUX_CONTEXT "$DEVICE_PARTITION" "$MOUNT_POINT"

      if mount | grep -q "$MOUNT_POINT"; then
        echo "[$(date)] Mount SUCCESSFUL."
        #may be unnecessary
        chmod -R 775 "$MOUNT_POINT"
        chown -R root:media_rw "$MOUNT_POINT"
	#bind mounts here - unnecessary?
	#mount --rbind "$MOUNT_POINT" /mnt/runtime/default/emulated/0/Backup
	#mount --rbind "$MOUNT_POINT" /mnt/runtime/read/emulated/0/Backup
	#mount --rbind "$MOUNT_POINT" /mnt/runtime/write/emulated/0/Backup
        mount -t sdcardfs "$MOUNT_POINT" /mnt/runtime/default/emulated/0/Backup
        #
	echo "[$(date)] Symlink SUCCESSFUL."	
      else
        echo "[$(date)] Mount FAILED."
      fi
    else
      echo "[$(date)] Already mounted."
    fi
  else
    echo "[$(date)] Device not found. Waiting..."
  fi

  sleep 10
done
