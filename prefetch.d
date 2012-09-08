#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Function proto
    573 void
    574 dmu_zfetch(zfetch_t *zf, uint64_t offset, uint64_t size, int prefetched)

    272 static int
    273 dmu_zfetch_find(zfetch_t *zf, zstream_t *zh, int prefetched)

    146 static void
    147 dmu_zfetch_dofetch(zfetch_t *zf, zstream_t *zs)

    224 static uint64_t
    225 dmu_zfetch_fetch(dnode_t *dn, uint64_t blkid, uint64_t nblks)
*/

dtrace:::BEGIN
{
        printf("Tracing prefetch....\n\n");
}


/* This should look at the arguments to dmu_zfetch_fetch */
fbt:zfs:dmu_zfetch_fetch:entry 
{ 
	self->object 	= args[0]->dn_object;
	self->blockid 	= arg1;
	self->blocks  	= arg2;
	self->exec      = execname;
	self->pid	= pid;
	self->start 	= timestamp;
	/* printf("Fetching %d blocks for blockid %d\n", arg2, arg1);  */
}


/* This should look at the return value of dmu_zfetch_fetch */
fbt:zfs:dmu_zfetch_fetch:return
/self->start/
{ 
	this->elapsed = timestamp;
	this->ms = (this->elapsed - self->start)/1000000;
	this->microsecs = (this->elapsed - self->start)/1000;

	printf("Prefetched %d blocks in %d microseconds from blockid %d on object %d for %s (%d) - Fetchsize: %d blocks.\n", 
			self->blocks, this->microsecs, self->blockid, self->object, self->exec, self->pid, args[1]);
        this->elapsed = 0;
        self->start = 0;
}
