#!/usr/bin/perl -w
use strict;
use NextBio::Utilities;
use Getopt::Long;
my  (%opts,@fastq);
my  ($handle);
GetOptions(
		   'h|help'	    =>\$opts{help},
		   'f|function=s' =>\$opts{function},
		   'fq|fastq=s{1,2}'    =>\@fastq,
		   'fa|fasta=s'    =>\$opts{fasta},
		   'header=s'   =>\$opts{header},
		   'order=s'    =>\$opts{order},
		   'length=i'   =>\$opts{length},
		   'l|list=s'	 =>\$opts{list},
		   'phy=s'		 =>\$opts{phy},
		   'overhang=s'	 =>\$opts{overhang},
		   't|threshold=f'  =>\$opts{threshold},
		   'depth=i'  =>\$opts{depth},	
		   'stage=i'  =>\$opts{stage},
		   'base=f'	  =>\$opts{base},
		   'raise=f'   =>\$opts{raise}
		  );
 
$handle=NextBio::Utilities->new();

# Set default values
$opts{base}=10 if !defined $opts{base};
$opts{raise}=1.5 if !defined $opts{raise};

# Main call
if($opts{help} or !defined $opts{function})
{
 	print "\n There is somthing wrong with your command line !!!!\n";
 	print &help;
}
elsif($opts{function} eq 'Fastq_uniq')
{
	$handle->Fastq_uniq($fastq[0])
}

elsif($opts{function} eq 'Fasta_uniq')
{
	$handle->Fasta_uniq($opts{fasta},$opts{header})
}

elsif($opts{function} eq 'Fasta_sort')
{
	$handle->Fasta_sort($opts{fasta},$opts{order})
}

elsif($opts{function} eq 'Fasta_length')
{
	$handle->Fasta_length($opts{fasta},$opts{length},$opts{order})
}

elsif($opts{function} eq 'Fasta_share')
{
	$handle->Fasta_share($opts{list})
}

elsif($opts{function} eq 'Fasta_extract')
{
	$handle->Fasta_extract($opts{fasta},$opts{list})
}

elsif($opts{function} eq 'Fasta_exclude')
{
	$handle->Fasta_exclude($opts{fasta},$opts{list})
}

elsif($opts{function} eq 'Fastq2Fasta')
{
	$handle->Fastq2Fasta($fastq[0])
}

elsif($opts{function} eq 'phy_clean')
{
	$handle->phy_clean($opts{phy},$opts{threshold},$opts{list})
}

elsif($opts{function} eq 'overhang_check')
{
	$handle->overhang_check($fastq[0],$opts{overhang})
}

elsif($opts{function} eq 'file_rename')
{
	$handle->file_rename($opts{list})
}

elsif($opts{function} eq 'N50_count')
{
	$handle->N50_count($opts{fasta})
}

elsif($opts{function} eq 'translate')
{
	$handle->translate($opts{fasta})
}

elsif($opts{function} eq 'ploidy')
{
	$handle->ploidy($opts{fasta},\@fastq,$opts{depth},$opts{header},$opts{stage})
}
elsif($opts{function} eq 'physub')
{
	$handle->phy_sub($opts{phy},$opts{base},$opts{raise})
}


sub help
{ 
my $usage=	
"===================================================================================
--help 			print this usage
--function or -f	select function to use
--fastq or -fq		fastq file to process
--fasta	or -fa		fasta file to process
--header		string used to modify fasta header, use with fasta_uniq
--order			up or down used with fasta_sort, default is upward
--length    		read length less than specified value will be removed
--list or -l			Contains list of file names or fasta header
--phy 			.phy file to process
--overhang 		enzyme overhang you want to detect on 5'
--threshold 		floating point value of missing data allowed for samples (default 0.9999)
--depth			minimum depth for a snp to be involved in ploidy analysis

Deamon uage:
#################################  Build-in function ##############################
# get help message 
./NextBio.pl --help

# get uniq fastq file
./NextBio.pl -f Fastq_uniq --fastq test.fq

# get uniq fasta file and rename header
./NextBio.pl -f Fasta_uniq --fasta test.fa --header Mine

# sort fasta file based on their length
./NextBio.pl -f Fasta_sort --fasta test.fa --order down

# filter fasta file based on length
./NextBio.pl -f Fasta_length --fasta test.fa --length 10

# extract fasta file by providing a list of header ID (no >)
./NextBio.pl -f Fasta_extract --fasta test.fa --list

# exclude entries from fasta file by providing a list of header ID (no >)
./NextBio.pl -f Fasta_exclude --fasta test.fa --list

# transform fastq to fasta
./NextBio.pl -f Fastq2Fasta --fastq test.fq

# find sequences shared by multiple fasta file, by providing a list of file names, each filename on one line
./NextBio.pl -f Fasta_share --list list.txt

# remove samples contains only Ns and names in list.txt and sort the samples based on number of informative bases
./NextBio.pl -f phy_clean --phy ../Pcp.phy --list list.txt --threshold 0.8 >../Pcp_60_cleaned.phy 

# remove sequences not start with expected enzyme cutting overhang in fastq file
./NextBio.pl -f overhang_check --fastq test.q --overhang TTCA

# rename files in current dir, format for list 'currentname	newname', seperate by tab
./NextBio.pl -f file_rename --list list.

# calculate cotig N50
./NextBio.pl -f N50_count --fasta test.fa

# translate DNA into protein with all six reading file_rename
./NextBio.pl -f translate --fasta test.fa


################################# Function requires dependency ####################
****###########################  R, samtools, bcftools, bowtie2####################

# ploidy_plot
# stage1:buiding bowtie2 index
# stage2:generate mapping file
# stage3:generating vcf file and making the plot 
# you can change depth value and just run step3 to see the difference
# ploidy_plot analysis: single end read
./NextBio.pl -f ploidy --fasta ref.fa --fastq test.fq --depth 30 --header test --stage 3
# ploidy_plot analysis: paired end reads
./NextBio.pl -f ploidy --fasta ref.fa --fastq forward.fq reverse.fq --depth 30 --header test  --stage 3


===================================================================================


";
	print $usage;
}
































