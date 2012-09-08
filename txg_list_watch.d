#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN                  
{                               
        printf("Tracing transaction group list additions....\n\n");
}    

fbt:zfs:txg_list_add:entry
{
	self->txg = arg3;
	self->start = timestamp;
}


fbt:zfs:txg_list_add:return
/self->start/
{
	printf("TXG %d List Added to.  New: %d\n", self->txg, args[1]);
}
