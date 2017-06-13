#!/usr/bin/perl -w
# Usage perl  GenomeCut.pl Enzyme.list.txt genome.fasta -Min 2000
use strict;
use Getopt::Long;
my ($enzyme,$file,$line,$lineE,$lineS,$length,$size,$random,$all,$count,$sum);
my (@fasta,@temp,@enz,@size,@temp1,@name,@out,@a1,@a2);
my (%positions,%opts,%cutsite);

# Set min length of contigs used with -Min
GetOptions(
		   'Min=s'		 =>\$opts{Min},
		  );
$opts{Min}=1000 if !defined $opts{Min};

# Read files
$enzyme=shift @ARGV;
$file=shift @ARGV;

# Open genome file in fasta
open(ENZ,"$enzyme") or die "Please check your input file containing enzyme cutting sites!\n";
open(FILE,"$file") or die "Please check your input file containg genome sequence in fasta format!\n";
mkdir "GenomeEcutter" unless ( -e "./GenomeEcutter") ;
$size=`wc $file`;
@size=split(" ",$size);
$all='';
# reformat fasta file in to one-line/contig
my $count1=0;
open (TMP1,">./GenomeEcutter/$file.temp") or die "Sorry, you don't have the permisison for writing files!\n";
print "Modifying file format...\n";
foreach  $line(<FILE>)
{
	chomp $line;
	if($line=~/>/ && $count1==0)
	{
		$count1++;
		next;
	}
	elsif($line=~/>/ && $count1!=0)
	{
		print TMP1 "\n"; 
	}
	else
	{
		print TMP1 $line;
	}
}
print "Temporary sequence file created!\n";
close FILE;
close TMP1;
undef $line;

open (TMP2,">./GenomeEcutter/$file.single") or die "Sorry, you don't have the permisison for writing files!\n";
print TMP2 "Enzyme","\t","Sites","\t","#ofsites","\t","#ofNormalized/kb","\t","MeanLength","\t","100bp-","\t","100-200bp","\t","200-400bp","\t","400-600bp","\t","600-800bp","\t","800-1000bp","\t","1000bp+","\n";

# Read in enzyme cutting sites and transform umbigous sites
my ($temps1);
foreach $lineE(<ENZ>)
{	
	@temp=();
	my @Sinterval=();
	@enz=split("\t",$lineE);
	push @name,$enz[0];
	open(ENZYMETEMP,">./GenomeEcutter/$file.$enz[0].temp");
	$enz[2]=~s/R/\[GA\]/g;
	$enz[2]=~s/Y/\[TC\]/g;
	$enz[2]=~s/K/\[GT\]/g;
	$enz[2]=~s/M/\[AC\]/g;
	$enz[2]=~s/S/\[GC\]/g;
	$enz[2]=~s/W/\[AT\]/g;
	$enz[2]=~s/B/\[GTC\]/g;
	$enz[2]=~s/H/\[ACT\]/g;
	$enz[2]=~s/D/\[GAT\]/g;
	$enz[2]=~s/V/\[GCA\]/g;
	$enz[2]=~s/N/\[ATCG\]/g;
	$length=0;
	$count=0;
	$sum=0;
	$cutsite{$enz[0]}=$enz[2];
	open(TMP4,"./GenomeEcutter/$file.temp") or die "can't find temp file containing sequence!\n";
	my $num=0;	
	foreach $temps1(<TMP4>)
	{
		my $int=0;
		if(length($temps1)>=$opts{Min})
		{
			my $tt=$temps1;
			if($tt=~/$enz[2]/g)
			{	
				while ($temps1=~/$enz[2]/g)
				{	
					push @temp,pos($temps1)-$enz[3]+$enz[1]," ";
					$count++;
					unless($int==0)
					{
						$num++;
						push @Sinterval,pos($temps1)-$enz[3]+$enz[1]-$int;
						$sum+=(pos($temps1)-$enz[3]+$enz[1]-$int);
					}
					$int=pos($temps1)-$enz[3]+$enz[1]; 
				}
				push @temp,"\n";
			}
			else
			{
				push @temp,"X","\n"
			}
		}	
	}
	@Sinterval= dInterval(\@Sinterval);
	if($num>0)
	{	
		print TMP2 $enz[0],"\t",$enz[2],"\t",$count,"\t",$count*1000/$size[2],"\t",$sum/($num),"\t",join("\t",@Sinterval),"\n";
	}
	else
	{
		print TMP2 $enz[0],"\t",$enz[2],"\t",$count,"\t",$count*1000/$size[2],"\t",0,"\t",join("\t",@Sinterval),"\n";
	}
	print ENZYMETEMP @temp;
	undef @Sinterval;
	close ENZYMETEMP;
}
print "Single enzyme cutting sites calculation finished","\n";
close TMP2;
undef $all;
undef @temp;
#unlink "./GenomeEcutter/$file.temp";

print "calculating pairwised interval of enzyme cutting sites......\n\n";
print "#" x 60,"\n";
print "Attention: for large dataset (>1GB),this step could be slow!\nPlease consider increasing -Min (default 1000) or edit enzyme \nlist file to only select enzymes of your interest!\n";
print "#" x 60,"\n\n";
open (TMP3,">./GenomeEcutter/$file.double") or die "Sorry, you don't have the permisison for writing files!\n";
print TMP3 "EnzymePair","\t","CutsiteI","\t","CutsiteII","\t","MeanInterval","\t","100bp-","\t","100-200bp","\t","200-400bp","\t","400-600bp","\t","600-800bp","\t","800-1000bp","\t","1000bp+","\t","Total\n";
@name=sort @name;
my @name2=@name;
my($key,$key2,$index,@double);
foreach $key(@name)
{	
	shift @name2;
	foreach $key2(@name2)
	{
		
		if($key ne $key2 && $cutsite{$key}!~/$cutsite{$key2}/ && $cutsite{$key2}!~/$cutsite{$key}/)
		{
			open(EFILE1,"./GenomeEcutter/$file.$key.temp");
			open(EFILE2,"./GenomeEcutter/$file.$key2.temp");
			@a1=<EFILE1>;
			@a2=<EFILE2>;
			for($index=0;$index<=$#a1;$index++)
			{
				chomp $a1[$index];
				chomp $a2[$index];
				unless($a1[$index]=~/X/ || $a2[$index]=~/X/)
				{
					@temp=ddInterval1($a1[$index],$a2[$index]);
					push @temp1,@temp;
				}
			}
			@double=ddInterval2(\@temp1);
			print TMP3 $key,"-",$key2,"\t",$cutsite{$key},"\t",$cutsite{$key2},"\t",join("\t",@double),"\n"; 
			undef @temp;
			undef @temp1;
			undef @a1;
			undef @a2;
		}
		else
		{
			next;
		}
	}
}
print "Pairwised interval of cutting sites calculation finished!\nYour results could be found in GenomeEcutter dir!\n";
undef @temp;
undef @temp1;
close TMP3;
close EFILE1;
close EFILE2;

foreach $key(@name)
{
	#unlink "./GenomeEcutter/$file.$key.temp";
}

sub dInterval
{
	my($pos1,$ele);
	my($iless,$i200,$i400,$i600,$i800,$i1000,$ilarge);
	$iless=0;
	$i200=0;
	$i400=0;
	$i600=0;
	$i800=0;
	$i1000=0;
	$ilarge=0;
	$pos1=shift;
	my(@pos1)=@{$pos1};
	shift @pos1;
	foreach $ele(@pos1)
	{
		if($ele eq "X")
		{
			next;
		}
		else
		{
			if($ele<100)
			{
				$iless++;
			}
			elsif($ele>=100 && $ele<200)
			{
				$i200++;
			}
			elsif($ele>=200 && $ele<400)
			{
				$i400++;
			}
			elsif($ele>=400 && $ele<600)
			{
				$i600++;
			}
			elsif($ele>=600 && $ele<800)
			{
				$i800++;
			}
			elsif($ele>=800 && $ele<1000)
			{
				$i1000++;
			}
			elsif($ele>=1000)
			{
				$ilarge++;
			}
		}
	}
 	undef @pos1;
	return($iless,$i200,$i400,$i600,$i800,$i1000,$ilarge);
}


sub ddInterval1                                                                   
{
	my($pos1,$pos2,$ele1,$ele2);
	my(@interval,@pos);
	my(%post);
	$pos1=shift;
	$pos2=shift;
	my(@pos1)=split(" ",$pos1);
	my(@pos2)=split(" ",$pos2);
	my $sum=0;
	if(scalar @pos1 > scalar @pos2)
	{
		foreach $ele1(@pos1)
		{
			$post{$ele1}=1
		}
		foreach $ele2(@pos2)
		{
			$post{$ele2}=2
		}
	}
	else
	{

		foreach $ele2(@pos2)
		{
			$post{$ele2}=2
		}
		foreach $ele1(@pos1)
		{
			$post{$ele1}=1
		}

	}

	@pos=(@pos1,@pos2);
	@pos=sort{$a<=>$b}@pos;
	for(my $i=0;$i<$#pos;$i++)
	{
		if($post{$pos[$i]} != $post{$pos[$i+1]})
		{
			my $interval=$pos[$i+1]-$pos[$i];
			push @interval,$interval;
		}
	}
	return(@interval);
	undef @interval;
	undef @pos1;
	undef @pos2;
}

sub ddInterval2
{
	my($pos1,$ele,$sum,$mean,$length);
	my($iless,$i200,$i400,$i600,$i800,$i1000,$ilarge);
	my(@pos1);
	$iless=0;
	$i200=0;
	$i400=0;
	$i600=0;
	$i800=0;
	$i1000=0;
	$ilarge=0;
	$pos1=shift;
	@pos1=@{$pos1};
	$length=@pos1;
	$sum=0;
	if($length==0)
	{
		return("NA","NA","NA","NA","NA","NA","NA","NA","NA");
		undef @pos1;
	}
	else
	{
		foreach $ele(@pos1)
		{
			$sum+=$ele;
			if($ele<100)
			{
				$iless++;
			}
			elsif($ele>=100 && $ele<200)
			{
				$i200++;
			}
			elsif($ele>=200 && $ele<400)
			{
				$i400++;
			}
			elsif($ele>=400 && $ele<600)
			{
				$i600++;
			}
			elsif($ele>=600 && $ele<800)
			{
				$i800++;
			}
			elsif($ele>=800 && $ele<1000)
			{
				$i1000++;
			}
			elsif($ele>=1000)
			{
				$ilarge++;
			}
		}
		$mean=$sum/$length;
 		undef @pos1;
		return($mean,$iless,$i200,$i400,$i600,$i800,$i1000,$ilarge,$length);
	}
}

