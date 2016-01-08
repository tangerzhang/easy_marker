#!perl

use Getopt::Std;
getopts "n:g:";


$cmd = "rm -rf part_*";
system($cmd);


$part_num     = $opt_n; ###how many parts you want to split
$genome       = $opt_g; ###genome file
$maker_bopts  = "maker_bopts.ctl";
$maker_evm    = "maker_evm.ctl";
$maker_exe    = "maker_exe.ctl";
$maker_opts   = "maker_opts.ctl";
$sh_script    = "maker -fix_nucleotides\n";
$pbs_script   = "#!/bin/bash
#PBS -N maker
#PBS -l nodes=1:ppn=2
#PBS -o out.log
#PBS -e err.log
#PBS -l walltime=1000:00:00
#PBS -q batch
echo `--------- date ----------`
echo HomeDirectory is $PWD
echo Current Dir is $PBS_O_WORKDIR
cd \$PBS_O_WORKDIR
maker -fix_nucleotides\n";


if ((!defined $opt_n)|| (!defined $opt_g) ) {
    die "************************************************************************
    Usage: perl maker_split.pl -n 10 -g genome_file 
      -h : help and usage.
      -n : how many part you want to split
      -g : genome file
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version 1.0\n";
  print "Copyright to Tanger, tanger.zhang\@gmail.com\n";
  print "Please modify your Maker options before running this script\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
        
        }

open(OUT, "> job.pbs") or die"";
print OUT "$pbs_script";
close OUT;
open(OUT, "> run.sh") or die"";
print OUT "$sh_script";
close OUT;

open(IN, $genome) or die"";
$/='>';
<IN>;
my $count = 0;
while(<IN>){
	chomp;
	my($name,$seq) = split(/\n/,$_,2);
	$count++;
	$infordb{$count}->{'NAME'} = $name;
	$infordb{$count}->{'SEQ'}  = $seq;
	}
close IN;

my $num_seq = int ($count/$part_num);
my $run_script;
my $dir_num = 0;
for($i=1;$i<=$count;$i=$i+$num_seq){
	$dir_num++;
	my $dir_name = "part_".$dir_num;
	mkdir $dir_name;
	my $outctg   = $dir_name."/contig.fasta"; 
	open(my $out, ">$outctg") or die"";
	my $a = $i;
	my $b = $i + $num_seq - 1;
	foreach my $j($a..$b){
		print $out ">$infordb{$j}->{'NAME'}\n$infordb{$j}->{'SEQ'}\n" if(exists($infordb{$j}));
		}
	$cmd = "cp job.pbs $dir_name/"; system($cmd);
	$cmd = "cp $maker_bopts $dir_name/"; system($cmd);
	$cmd = "cp $maker_evm $dir_name/"; system($cmd);
	$cmd = "cp $maker_exe $dir_name/"; system($cmd);
	$cmd = "cp $maker_opts $dir_name/"; system($cmd);
	$cmd = "cp run.sh $dir_name/"; system($cmd);
	$run_script .= "sh $dir_name/run.sh\n";
	close $out;
	}

open(OUT, "> run_maker.sh") or die"";
print OUT "$run_script";
close OUT;
system("rm job.pbs");
system("rm run.sh");

