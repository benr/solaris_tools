#!/usr/sbin/dtrace -qs

fsinfo:::
/ zonename != "global"/
{ 
        printf("FOP %s :  Zone %s - PID: %d (%s) \t PATH: %s - %d\n", 
                                probefunc, 
                                zonename, 
                                pid, 
                                execname, 
                                args[0]->fi_pathname,
                                args[1]
                                ); 

}
