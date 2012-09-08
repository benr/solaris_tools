solaris_tools
=============

This is a variety of tools I've cooked up over the years for solving one problem or another.  Most of these are very very old, so use with caution.

Most of these focus on working with zones in one way or another.

----

CPU:

* zwhoq.d: Examine run queue based on processes and zonename 

Networking:

* jnetstat: Globalzone Public/Private Network Usage
* retrans_reporter.pl: 	Report per second retransmit rate as ratio of total traffic 

ZFS/Storage:

* zdump: Dump a ZFS dataset to a file 
* zonefsstat: fsstat wrapper to view per-zone VFS activity
* arc_summary: Examines various ZFS ARC statistics.
* fsinfo-zones.d: Displays all VFS Operations in non-globalzones, including zonename, process, and file path with IO length. Demonstrates undocumented DTrace fsinfo provider. 
* txg_list_watch.d: Traces transactions being added to transaction groups.
* zfs_fsync.d: Traces ZFS Fsync elapsed time. 
* prefetch.d: Observe prefetch requests, including fetch size, time to complete, blockid, and calling process. 
* iostat.pl: iostat re-implemented in PERL  (just as a learning exercize)
