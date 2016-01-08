#!perl

use Getopt::Std;
getopts "g:";

$genome    = $opt_g;

if (!defined $opt_g ) {
    die "************************************************************************
    Usage: perl step02harvest.pl -g genome.fasta 
      -h : help and usage.
      -g : genome file
************************************************************************\n";
}else{
  print "************************************************************************\n";
  print "Version 1.0\n";
  print "Copyright to Tanger, tanger.zhang\@gmail.com\n";
  print "RUNNING...\n";
  print "************************************************************************\n";
        }


system("rm -rf GFF");
mkdir GFF;
system("rm -rf FASTA");
mkdir FASTA;
$content = `find -name "*_index.log"`;
@linedb = split(/\n/,$content);
foreach $line(@linedb){
	@tmp = split(/\//,$line);
	$dir_name = $tmp[1];
	$cmd = "gff3_merge -g -n -d $line";
	system($cmd);
	$orig_gff = `ls *.all.gff`;
	$orig_gff =~ s/\s+//g;
	$rena_gff = $dir_name.".rename.gff";
	$cmd = "mv $orig_gff GFF/$rena_gff";
	system($cmd);
	
	}

$cmd = "cat GFF/*.rename.gff > GFF/contig.all.gff";
system($cmd);
$cmd = "perl maker_gff_sep_features_by_type.pl GFF/contig.all.gff";
system($cmd);
system("mv *.gff GFF/");
system("mv GFF/maker.gff ./");
open(OUT, "> FASTA/genome.fasta") or die"";
open(IN, $genome) or die"";
$/='>';
<IN>;
while(<IN>){
	chomp;
	($gene,$seq) = split(/\n/,$_,2);
	$seq =~ s/\s+//g;
	print OUT ">$gene\n$seq\n";
	}
close IN;
close OUT;

###below need install EVidenceModeler
$cmd = "perl gff3_file_to_proteins.pl GFF/contig.all.gff FASTA/genome.fasta CDS > FASTA/cds.fasta";
system($cmd);
$cmd = "perl gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta prot > FASTA/protein.fasta";
system($cmd);
$cmd = "perl gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta cDNA > FASTA/cDNA.fasta";
system($cmd);
$cmd = "perl gff3_file_to_proteins.pl GFF/contig.all.gff  FASTA/genome.fasta gene > FASTA/gene.fasta";
system($cmd);

