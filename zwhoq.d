#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option nspec=4
#pragma D option specsize=100k

int maxlen;
int spec[int];

sched:::enqueue
{
        this->len = ++qlen[this->cpu = args[2]->cpu_id];
        in[args[0]->pr_addr] = timestamp;
}

sched:::enqueue
/this->len > maxlen && spec[this->cpu]/
{
        /*
         * There is already a speculation for this CPU.  We just set a new
         * record, so we'll discard the old one.
         */
        discard(spec[this->cpu]);
}

sched:::enqueue
/this->len > maxlen/
{
        /*
         * We have a winner.  Set the new maximum length and set the timestamp
         * of the longest length.
         */
        maxlen = this->len;
        longtime[this->cpu] = timestamp;        

        /*
         * Now start a new speculation, and speculatively trace the length.
         */
        this->spec = spec[this->cpu] = speculation();
        speculate(this->spec);
        printf("Run queue of length %d:\n", this->len);
}

sched:::dequeue
/(this->in = in[args[0]->pr_addr]) &&
    this->in <= longtime[this->cpu = args[2]->cpu_id]/
{
        speculate(spec[this->cpu]);
        printf("  %d/%d (%s) %d\n", 
            args[1]->pr_pid, args[0]->pr_lwpid,
            stringof(args[1]->pr_fname), args[1]->pr_zoneid);
}

sched:::dequeue
/qlen[args[2]->cpu_id]/
{
        in[args[0]->pr_addr] = 0;
        this->len = --qlen[args[2]->cpu_id];
}

sched:::dequeue
/this->len == 0 && spec[this->cpu]/
{
        /*
         * We just processed the last thread that was enqueued at the time
         * of longest length; commit the speculation, which by now contains
         * each thread that was enqueued when the queue was longest.
         */
        commit(spec[this->cpu]);
        spec[this->cpu] = 0;
}
