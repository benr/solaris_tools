#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN                  
{                               
        printf("Tracing ZIL Commits....\n\n");
}    

/* 
	zil.c:
   1185 void
   1186 zil_commit(zilog_t *zilog, uint64_t seq, uint64_t foid)


	For description of zilog_t see  zfs/sys/zil_impl.h
*/

fbt:zfs:zil_commit_writer:entry
{
        self->seq   	= arg1;
	self->foid  	= arg2;
        self->start 	= timestamp;
	self->walltime  = walltimestamp;
}


fbt:zfs:zil_commit_writer:return
/self->start/
{
        this->elapsed 	= timestamp;
        this->ms 	= (this->elapsed - self->start)/1000000;
        this->microsecs = (this->elapsed - self->start)/1000;

        printf("%Y:\tZIL Commit : Seq %d : FOID %d", self->walltime, self->seq, self->foid);
        printf("      Completed in %d ms\n", this->ms);

        this->elapsed = 0;
        self->start   = 0;
	self->seq     = 0;
	self->foid    = 0;
}
