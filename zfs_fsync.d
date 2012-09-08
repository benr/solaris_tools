#!/usr/sbin/dtrace -qs

fbt:zfs:zfs_fsync:entry
{ 
	printf("%Y:\t Fsync\n", walltimestamp); 
} 

fbt:zfs:zfs_fsync:return
{ 
	printf("%Y: ... done.\n", walltimestamp); 
}
