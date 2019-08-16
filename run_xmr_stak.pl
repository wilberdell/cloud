#!/usr/bin/perl
use strict;
use warnings;

my $repetitions= shift;

#run 96 minutes (i.e. 96%) for the user
my $loopruntime=60*96;
#and 4 minutes (i.e. 4%) for the donation
my $donationtime=60*4;

my $Intensity=0;
my $Threads=1;



#Create cpu.txt with the given number 
#of threads and the given intensity
#current directory should be the bin-directory of xmr-stak
sub CreateConfig { 
    my $t      = shift;
    my $i = shift;
    
    
    my $BaseIntensity = int($i/$t);
    my $ExtraIntensity = $i % $t;

    
    open(my $fh, '>', "cpu.txt");

    print $fh "\"cpu_threads_conf\" :
    [\n";

    for (my $i=0; $i < $Threads; $i++) 
    {
        my $ThreadIntensity=$BaseIntensity;
        
        if ($ExtraIntensity > $i)
        {
            $ThreadIntensity++;
        }
        
        print $fh "{ \"low_power_mode\" : $ThreadIntensity, \"no_prefetch\" : true, \"asm\" : \"auto\", \"affine_to_cpu\" : $i },\n"
    }
    print $fh "],\n";
    close $fh;
    return;
}
#run xmr-stak for the given time in seconds
sub RunXMRStak{
    my $runtime=shift;
    my $configfile= shift;
    my $poolconfig = shift;
    
    #run xmr-stak in parallel
    system("./xmr-stak -c $configfile  -C $poolconfig &");

    #wait for some time
    sleep ($runtime);

    #and stop xmr-stak
    system("pkill xmr-stak");
}


#run xmr-stak for some time and 
#return the average hash-rate
sub GetHashRate{

    #delete any old logfiles, so that the results are fresh
    system 'rm logfile.txt';
    
    RunXMRStak(20, "config11.txt", "pools.txt");
        
    #get the hashrate from the logfile
    my $var;
    {
        local $/;
        open my $fh, '<', "logfile.txt";
        $var = <$fh>;
    }

    my @array=$var=~/Totals \(ALL\):\s*(\d*)/;
    
    return $array[0];
}


chdir("../bin" );


my $loopcounter=$repetitions;

do
{

    $Threads=`nproc`;
    $Intensity=$Threads;

    my $OldHash=0;
    my $CurHash=0;

    do
    {
        $OldHash=$CurHash;
        $Intensity++;
        CreateConfig($Threads, $Intensity);
        $CurHash=GetHashRate();
    }
    while($CurHash>$OldHash);

    $Intensity--;
    CreateConfig($Threads, $Intensity);
    

    #now run xmr-stak with the optimum setting 
    RunXMRStak($loopruntime, "config.txt", "pools.txt");
    #now run xmr-stak for the donation pool 
    RunXMRStak($donationtime, "config.txt", "dpool.txt");
    $loopcounter--;
}
while($loopcounter!=0);

















© 2019 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
