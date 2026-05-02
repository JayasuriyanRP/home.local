Based on our progress, here is the complete step-by-step procedure to resolve the "unable to set superblock flags" error by manually bypassing the corrupted journal.
## Phase 1: Break the Corrupted Journal Link
Since e2fsck is failing due to an inconsistent journal, we must manually disconnect it using low-level tools.

   1. Kill hidden processes: Ensure no background service is locking the drive.
   
   sudo fuser -mk /dev/sdb1
   
   2. Clear journal references in debugfs:
   * Open the disk for writing: sudo debugfs -w /dev/sdb1
      * Set the journal inode to zero: ssv journal_inum 0
      * Exit the tool: quit
   3. Formally disable the journal feature: This tells the filesystem to stop looking for a journal altogether, which clears the stuck "recovery needed" flags.
   
   sudo tune2fs -f -O ^has_journal /dev/sdb1
   
   
## Phase 2: Perform the Filesystem Repair
Now that the journal is removed, the filesystem is in a "simple" state that e2fsck can handle.

   1. Run the main repair:
   
   sudo e2fsck -fy /dev/sdb1
   
   Note: If this still gives a "Bad magic number," run it using a backup superblock: sudo e2fsck -fy -b 32768 /dev/sdb1.

## Phase 3: Restore Stability
Once the repair is successful and the filesystem is clean, you must recreate the journal to protect your data from future power failures.

   1. Re-enable journaling:
   
   sudo tune2fs -j /dev/sdb1
   
   2. Verify the fix: Try mounting the drive to a temporary folder.
   
   sudo mkdir -p /mnt/temp_data
   sudo mount /dev/sdb1 /mnt/temp_data
   ls /mnt/temp_data
   
   