#!/usr/perl5/bin/perl -w

## benr.

### To Fix:
###   -> Fix rounding on asvc_t

use strict;
use Sun::Solaris::Kstat;

if ( !$ARGV[1] ) {
        print "Usage: $0 <sd0> <interval>\n";
        exit 1;
}

my $Device = $ARGV[0];
my $Interval = $ARGV[1];

my $Instance = $Device;
$Instance =~ s/\D+//;

my $Driver = $Device;
$Driver =~ s/\d+//;


 # Debugging:
 #print "Device is: $Device \nInterval is: $Interval \nInstance is: $Instance \nDriver is: $Driver \n";

## Initialize Values:
my $Reads_Prev = 0;
my $Writes_Prev = 0;
my $BytesRead_Prev = 0; 
my $BytesWritten_Prev = 0;
my $ActiveOps_Prev = 0;
my $WaitingOps_Prev = 0;
my $Iteration = 0;

print_header();

my $Kstat = Sun::Solaris::Kstat->new();

while(1) {

        ## Number of Read/Write Ops
        my $Reads = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{reads};
        my $Writes = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{writes};

        ## Number of Bytes Read/Written
        my $BytesRead = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{nread};
        my $BytesWritten = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{nwritten};

        ## Queue Lengths for Ops Waiting or Running. ("wait" and "actv")
        my $ActiveOps = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{rlentime};
        my $WaitingOps = ${Kstat}->{$Driver}->{$Instance}->{$Device}->{wlentime};

        my $tps = ($Reads - $Reads_Prev) + ($Writes - $Writes_Prev);
        my $WaitServiceTime = 0.0;
        my $ActiveServiceTime = 0.0;
        my $i = $WaitingOps - $WaitingOps_Prev; 
        my $x = $ActiveOps - $ActiveOps_Prev;

        if ( $tps > 0 ) {
                my $mtps = 1000.0 / $tps;
                $WaitServiceTime = $mtps * $i;
                $ActiveServiceTime = $mtps * $x;
        
     #   print("DEBUG:  (mtps= 1000.0 / $tps) $mtps * (rlentime) $x = (asvc_t) $ActiveServiceTime \n");
        } 
        

        printf("%s:\t%5.1f\t%5.1f\t%10.1f\t%10.1f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n", $Device,      
                                                $Reads - $Reads_Prev, 
                                                $Writes - $Writes_Prev, 
                                                ($BytesRead - $BytesRead_Prev) / 1024,
                                                ($BytesWritten - $BytesWritten_Prev) / 1024,
                                                $i,
                                                $x,
                                                $WaitServiceTime,
                                                $ActiveServiceTime
                                                );
        

        sleep($Interval);
        $Kstat->update();
        
        ## Save Values for re-use next time through the loop
        $Reads_Prev = $Reads;
        $Writes_Prev = $Writes;
        $BytesRead_Prev = $BytesRead;
        $BytesWritten_Prev = $BytesWritten;
        $ActiveOps_Prev = $ActiveOps;
        $WaitingOps_Prev = $WaitingOps;

        if ( $Iteration > 9 ) {
                print_header();
        }
        $Iteration++;
        
}

sub print_header {
        $Iteration = 0;

        print("Dev       r/s     w/s         kr/s            kw/s      wait    actv    wsvc_t  asvc_t \n");
        #      sd0:      0.0     0.0          0.0             0.0       0.0     0.0     0.0     0.0

        ##print("Dev\tr/s\tw/s\tkr/s\tkw/s\twait\tactv\twsvc_t\tasvc_t \n");

}

