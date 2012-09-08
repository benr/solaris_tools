#!/usr/perl5/bin/perl -w

## Ben Rockwood, March 11th, 2008 (c)
## retrans_reporter.pl
## LICENSE: CDDL

## TODO : 
##      x Divide by zero bug, on slow systems script freaks.
##      x Should be able to report sub 1% deltas, ie: 0.005%
##      x Should have a help message
##      x Interval should be configurable


### TCP Retransmit Stats in Real Time:
### 
### tcp:0:tcp:retransBytes  163797543
### tcp:0:tcp:retransSegs   967731519
### tcp:0:tcp:outDataSegs   2120569978
### tcp:0:tcp:outDataBytes  3018897573
###
###  Get those 4, then delta for ratio of retrans.

use strict;
use Sun::Solaris::Kstat;

my $interval = 1;
my $ARGS = @ARGV;

# Parse Args

if($ARGS > 0 && $ARGV[0] =~ m/\d+/) {
	$interval = $ARGV[0];
} elsif($ARGS > 0 && $ARGV[0] eq "-h") {
	die("Usage: $0 <interval>\n");
} 



# Print Header:
print("    PACKETS \t   KBYTES  \t\n");
print("Total\tRetrans\tTotal\tRetrans\t%\n");
print("-----\t-------\t-----\t-------\t--\n");


my $Kstat = Sun::Solaris::Kstat->new();

my $last_RetransBytes = 0;
my $last_RetransSegs = 0;
my $last_OutBytes = 0;
my $last_OutSegs = 0;

while (1) {

        # Get tcp:0:tcp:retransBytes
        my $RetransBytes = ${Kstat}->{tcp}->{0}->{tcp}->{retransBytes};

        # Get tcp:0:tcp:retransSegs
        my $RetransSegs = ${Kstat}->{tcp}->{0}->{tcp}->{retransSegs};

        # Get tcp:0:tcp:outDataBytes
        my $OutBytes = ${Kstat}->{tcp}->{0}->{tcp}->{outDataBytes};

        # Get tcp:0:tcp:outDataSegs
        my $OutSegs = ${Kstat}->{tcp}->{0}->{tcp}->{outDataSegs};

        # Caluclate the current packet deltas
        my $interval_OutSegs = $OutSegs - $last_OutSegs; 
        my $interval_RetransSegs = $RetransSegs - $last_RetransSegs; 

	# Calculate Ratio
	my $retrans_ratio = $interval_RetransSegs / $interval_OutSegs;
	$retrans_ratio =~ s/.*\.(\d{2})(\d*)/$1\.$2/;

                # Output: 
                printf("%d\t%d\t%d\t%d\t%.3f%%\n",  
                                        $interval_OutSegs,                                      # Column 1; Total Packet Out
                                        $interval_RetransSegs,                                  # Column 2; Packet Retransmits
                                        int( ($OutBytes - $last_OutBytes) / 1024),              # Column 3; Total Bytes Out
                                        int( ($RetransBytes - $last_RetransBytes) / 1024),      # Column 4; Retransmit Bytes Out
                                        $retrans_ratio				               # Out vs Retrans Delta
                                        );

        sleep($interval);
        $Kstat->update();
        $last_RetransBytes = $RetransBytes;
        $last_RetransSegs = $RetransSegs;
        $last_OutBytes = $OutBytes;
        $last_OutSegs = $OutSegs;
}
