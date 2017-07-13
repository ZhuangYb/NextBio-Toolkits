#!/usr/bin/perl -w
# perl ddRad_alignment.pl cluster.file sample.list presious.sample.list[optional] -Min [default 10%samples] -T [default -1] -Mis [default 0.5]
# example: perl ddRad_alignment.pl -Seq test.seq -S1 sample.list -Mis 0.1 -Min 60
use strict;
use Getopt::Long;

my($file,$list,$line,$list2,$sseq);
my(@content,@list,@content2,@content3);
my(%opts,%samples,%precious);

mkdir "Alignment" unless ( -e "./Alignment");
undef %precious;

GetOptions(
		   'Seq=s'		 =>\$opts{Seq},
	       'S1=s'		 =>\$opts{S1},
		   'S2=s'		 =>\$opts{S2},
		   'Min=s'		 =>\$opts{Min},
		   'T=i'		 =>\$opts{T},
		   'Mis=f'		 =>\$opts{Mis},
		  );
$file= $opts{Seq};
$list= $opts{S1};
$list2= $opts{S2}; #list of presious samples you want to keep regardless the min samples involved
open(LIST,"$list") or die "can't find the file containing list of samples!\n";
@list=<LIST>;

$opts{Min}=$#list*0.1 if !defined $opts{Min};
$opts{T}=-1 if !defined $opts{T};
$opts{Mis}=0.5 if !defined $opts{Mis};

foreach $line(@list)
{
	chomp $line;
	$samples{$line}=1;
}
close LIST;

open(LIST2,"$list2") if defined $list2;
if (defined $list2)
{
	foreach $line(<LIST2>)
	{
		chomp $line;
		$precious{$line}=1;
	}
}

$/="//";
open(FILE,"$file") or die "can't open input file!\n";
@content=(<FILE>);
close FILE;
foreach $line(@content)
{
	$line=~s/\/\///g;
	unless ($line=~/^\s+$/)
	{
		push @content2,$line;
	}
} 

my $index=1;
for(my $i=0;$i<=$#content2;$i++) 
{
	chomp $content2[$i];
	@content3=split("\n",$content2[$i]);
	my $countAATT=0;
	if($#content3/2>=$opts{Min})
	{
		for($sseq=2;$sseq<=$#content3;$sseq+=2)
		{
				if($content3[$sseq]=~/^AATT/)
				{
					$countAATT++;
				}
		}
		if($countAATT > $#content3/4)
		{
			my %temphash=();
			my $switch=0;
			open (FILE,">Alignment/$index.temp.seq");
			for($sseq=1;$sseq<=$#content3;$sseq++)
			{
				if ($sseq%2 !=0)
				{
					$content3[$sseq]=~/(.+?)\_\d+/;
					if(defined $temphash{$1})
					{
						$switch=2;
					}
					else
					{
						print FILE ">",$content3[$sseq],"\n";											
						$temphash{$1}=1;
						$switch=1;

					} 
				}
				if ($sseq%2 ==0 && $switch==1)
				{
					$content3[$sseq]=~s/-//g;
					$content3[$sseq]=~s/[RYKMSWBHDVrykmswbhdv]/N/g;
					print FILE $content3[$sseq],"\n" 
				}
			}
			close FILE;
			$index++;
		}
	}
	elsif($#content3/2>=2 && $#content3/2<=$opts{Min} && %precious)
	{
		my $check=0;
		for($sseq=1;$sseq<=$#content3;$sseq+=2)
		{
			$content3[$sseq]=~/(.+?)\_\d+/;
			if(defined $1 && $precious{$1})
			{
				$check=1;
			}
		}
		if($check==1)
		{
			for($sseq=2;$sseq<=$#content3;$sseq+=2)
			{
				if($content3[$sseq]=~/^AATT/)
				{
					$countAATT++;
				}
			}
			if($countAATT > $#content3/4)
			{
				my %temphash=();
				my $switch=0;
				open (FILE,">Alignment/$index.temp.seq");
				for($sseq=1;$sseq<=$#content3;$sseq++)
				{
					if ($sseq%2 !=0)
					{
						$content3[$sseq]=~/(.+?)\_\d+/;
						if(defined $temphash{$1})
						{
							$switch=2;
						}
						else
						{
							print FILE ">",$content3[$sseq],"\n";											
							$temphash{$1}=1;
							$switch=1;
						} 
					}
					if ($sseq%2 ==0 && $switch==1)
					{
						$content3[$sseq]=~s/-//g;
						$content3[$sseq]=~s/[RYKMSWBHDVrykmswbhdv]/N/g;
						print FILE $content3[$sseq],"\n" 
					}
				}
				close FILE;
				$index++;
			}
		}

	}
}

#create alignment with mafft local
$/="\n";
my($key,$length);
my (@entry);
opendir(DIR,"./Alignment") or die "can't open dir!\n";
while (defined($file = readdir(DIR))) 
{
	if($file=~/(\d+)\.temp\.seq/)
	{
		print "processing $file .....","\n";
		`mafft --maxiterate 1000 --localpair --clustalout --thread $opts{T} --quiet ./Alignment/$file >./Alignment/$1.align`;
		unlink "./Alignment/$file" ;
		open(ALIGN,"./Alignment/$1.align") or die "can't open temp alignment file!\n";
		my %name;
		undef %name;
		foreach $line(<ALIGN>)
		{	
			unless($line=~/^\s+$/ || $line=~/\*/)
			{
				if($line=~/(.+)\_\d+/)
				{		
					@entry=split(" ",$line);			
					if($name{$1})
					{
						$name{$1}=$name{$1}.$entry[1];
					}
					else
					{
						$name{$1}=$entry[1];
					}
				}
			}
		}
		#check missing bases rate and remove if the site is not informative
		my ($i,$dashB,$dashC,$ele);
		my (@tempname1,@dashP);
		foreach $key(keys %name)
		{
			push @tempname1,$key;
			$length=length $name{$key};
		}
		
		for($i=0;$i<=$length-1;$i++)
		{
			$dashC=0;
			my @samebase=();
			my $checker=0;
			my @nonNbase=();
			foreach $key(keys %name)
			{
				$dashB=substr($name{$key},$i,1);
				push @samebase,$dashB;
				if($dashB eq "-")
				{
					$dashC++;
				}
			}
			foreach my $base(@samebase)
			{
				if($base=~/[ATCGatcg]/)
				{
					push @nonNbase,$base;
				}			
			}

			for(my $tt=1;$tt<=$#nonNbase;$tt++)
			{
				$checker++ if $nonNbase[$tt] ne $nonNbase[$tt-1]
			}

			if($dashC > ($#tempname1+1)*$opts{Mis} || $checker ==0)
			{
				push @dashP,$i;
			}
		}
		foreach $ele(@dashP)
		{
			foreach $key(keys %name)
			{
				substr($name{$key},$ele,1)="X";
			}
		}

		foreach $key(keys %name)
		{
			$name{$key}=~s/X//g;
			$length=length $name{$key};
		}

		foreach $key(keys %samples)
		{
			if($name{$key})
			{
				open(OUT,">>./Alignment/$key.final") or die "can't open final output file!\n";
				print OUT $name{$key};
			}
			else
			{
				open(OUT,">>./Alignment/$key.final") or die "can't open final output file!\n";
				print OUT "-" x $length;
			}
			close OUT;
		}
		close ALIGN;
		unlink "./Alignment/$1.align";

	}
}
#Prepare final phylip file
my ($bases,$sname);
my (@final);
opendir(DIR,"./Alignment") or die "can't open dir!\n";
while (defined($file = readdir(DIR))) 
{
	if($file=~/(.+?)\.final/)
	{
		push @final,$file;
	}
}
open(FINAL,">./Alignment/Final.phylip") or die "can't prepare file for writng final alignment!\n";
open(HEADER,"./Alignment/$final[0]") or die "can't open header file!\n" ;
my @temp1=<HEADER>;
chomp $temp1[0];
$bases=length $temp1[0];
close HEADER;

print FINAL $#final+1," ",$bases,"\n";

foreach $sname(@final)
{
	$sname=~/(.+?)\.final/;
	my $l1=length $1;
	print FINAL $1;
	print FINAL " " x (10-$l1);
	open (FTMP,"./Alignment/$sname") or die "can't open file!\n";
	my @ff=(<FTMP>);
	chomp $ff[0];
	print FINAL $ff[0],"\n";
	close FTMP;
	unlink "./Alignment/$sname";
}
close FINAL;















