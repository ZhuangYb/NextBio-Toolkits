#!/usr/bin/perl -w
use strict;
use NextBio::Utilities;
use Getopt::Long;
my  %opts;
my  $handle;
GetOptions(
		   'help'	    =>\$opts{help},
		   'function=s' =>\$opts{function},
		   'fastq=s'    =>\$opts{fastq},
		   'fasta=s'    =>\$opts{fasta},
		   'header=s'   =>\$opts{header},
		   'order=s'    =>\$opts{order},
		   'length=i'   =>\$opts{length},
		   'list=s'		=>\$opts{list},
		   'phy=s'		=>\$opts{phy},
		   'overhang=s'	=>\$opts{overhang},
		   'threshold=f'  =>\$opts{threshold},

		  );
 
$handle=NextBio::Utilities->new();

if($opts{help} or !defined $opts{function})
{
 	print "\n There is somthing wrong with your command line !!!!\n";
 	print &help;
}
elsif($opts{function} eq 'Fastq_uniq')
{
	$handle->Fastq_uniq($opts{fastq})
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
	$handle->Fastq2Fasta($opts{fastq})
}

elsif($opts{function} eq 'phy_clean')
{
	$handle->phy_clean($opts{phy},$opts{threshold})
}

elsif($opts{function} eq 'overhang_check')
{
	$handle->overhang_check($opts{fastq},$opts{overhang})
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

sub help
{ 
my $usage=	
"===================================================================================
--help 		print this usage
--function	select function to use
--fastq 	fastq file to process
--fasta		fasta file to process
--header	string used to modify fasta header, use with fasta_uniq
--order		up or down used with fasta_sort, default is upward
--length    	read length less than specified value will be removed
--list		Contains list of file names or fasta header
--phy 		.phy file to process
--overhang 	enzyme overhang you want to detect on 5'
--threshold 	floating point value of missing data allowed for samples (default 0.9999)

Deamon uage:
#################################  Build-in function ##############################
#get help message 
./NextBio.pl --help

#get uniq fastq file
./NextBio.pl --Function Fastq_uniq --fastq test.fq

#get uniq fasta file and rename header
./NextBio.pl --Function Fasta_uniq --fasta test.fa --header Mine

#sort fasta file based on their length
./NextBio.pl --function Fasta_sort --fasta test.fa --order down

#filter fasta file based on length
./NextBio.pl --function Fasta_length --fasta test.fa --length 10

#extract fasta file by providing a list of header ID (no >)
./NextBio.pl --function Fasta_extract --fasta test.fa --list

#exclude entries from fasta file by providing a list of header ID (no >)
./NextBio.pl --function Fasta_exclude --fasta test.fa --list

#transform fastq to fasta
./NextBio.pl --function Fastq2Fasta --fastq test.fq

#find sequences shared by multiple fasta file, by providing a list of file names, each filename on one line
./NextBio.pl --function Fasta_share --list list.txt

#remove samples contains only Ns and sort the samples based on number of informative bases
./NextBio.pl --function phy_clean --phy ../Pcp.phy --threshold 0.8 >../Pcp_60_cleaned.phy 

#remove sequences not start with expected enzyme cutting overhang in fastq file
./NextBio.pl --function overhang_check --fastq test.q --overhang TTCA

#rename files in current dir, format for list 'currentname	newname', seperate by tab
./NextBio.pl --function file_rename --list list.

#calculate cotig N50
./NextBio.pl --function N50_count --fasta test.fa

#translate DNA into protein with all six reading file_rename
./NextBio.pl --function translate --fasta test.fa


################################# Function requires dependency ####################

===================================================================================


";
	print $usage;
}
































