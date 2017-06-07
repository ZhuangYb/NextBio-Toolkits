#!/usr/bin/perl -w
# Usage perl  GenomeCut.pl Enzyme.list.txt genome.fasta -Min 2000
use strict;
use Getopt::Long;
my ($enzyme,$file,$line,$lineE,$lineS,$length,$size,$random,$all,$count,$sum);
my (@fasta,@temp,@enz,@size,@temp1,@name,@out,@a1,@a2);
my (%positions,%opts);
GetOptions(
		   'Min=s'		 =>\$opts{Min},
		  );
$opts{Min}=1000 if !defined $opts{Min};

$enzyme=shift @ARGV;
$file=shift @ARGV;

# Open genome file in fasta
open(ENZ,"$enzyme") or die "Please check your input file containing enzyme cutting sites!\n";
open(FILE,"$file") or die "Please check your input file containg genome sequence in fasta format!\n";

$size=`wc $file`;
@size=split(" ",$size);
$all='';
# reformat fasta file
my $count1=0;
open (TMP1,">$file.temp") or die "Sorry, you don't have the permisison for writing files!\n";
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

open (TMP2,">$file.single") or die "Sorry, you don't have the permisison for writing files!\n";
print TMP2 "Enzyme","\t","#ofsites","\t","#ofNormalized","\t","MeanLength","\t","windowSize100-","\t","windowSize200","\t","windowSize400","\t","windowSize600","\t","windowSize800","\t","windowSize1000","\t","windowSize1000+","\n";
open (TMP31,">$file.double.temp") or die "Sorry, you don't have the permisison for writing files!\n";

my($temps1,$temps2,$templength);
my(@temps1,@temps2);
foreach $lineE(<ENZ>)
{	
	@temp=();
	my @Sinterval=();
	print "Reading Enzyme file!\n";
	@enz=split("\t",$lineE);
	push @name,$enz[0];
	push @temp,$enz[0],"\t";
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
	open(TMP4,"$file.temp") or die "can't find temp file containing sequence!\n";
	print "Calculating statistics for Enzyme $enz[0], searching for $enz[2]...\n";
	my $num=0;	
	foreach $temps1(<TMP4>)
	{
		my $int=0;
		if(length($temps1)>=$opts{Min})
		{
			if($temps1=~/$enz[2]/g)
			{	
				while ($temps1=~/$enz[2]/g)
				{	
					push @temp,pos($temps1)-$enz[3]+1+$enz[1]," ";
					$count++;
					unless($int==0)
					{
						$num++;
					}
					push @Sinterval,pos($temps1)-$enz[3]+1+$enz[1]-$int;
					$sum+=(pos($temps1)-$enz[3]+1+$enz[1]-$int);
					$int=pos($temps1)-$enz[3]+1+$enz[1]; 
				}
				push @temp,"\t";
			}
			else
			{
				push @temp,"X","\t"
			}	
		}	
	}
	@Sinterval= dInterval(\@Sinterval);
	if($num>0)
	{	
		print TMP2 $enz[0],"\t",$count,"\t",$count*1000/$size[2],"\t",$sum/($num),"\t",join("\t",@Sinterval),"\n";
	}
	else
	{
		print TMP2 $enz[0],"\t",$count,"\t",$count*1000/$size[2],"\t",0,"\t",join("\t",@Sinterval),"\n";
	}
	print TMP31 @temp,"\n";
}
print "Single enzyme cutting sites calculation finished","\n";
close TMP2;
undef $all;
undef @temp;
close TMP31;
unlink "$file.temp";

open(POSITION,"$file.double.temp") or die "Can't find the file contains enzyme cutting sites info!\n";
@temp=<POSITION>;
{
	foreach $line(@temp)
	{
		@temp1=split("\t",$line);
		$positions{$temp1[0]}=[@temp1[1..$#temp1]];
	}
}
undef @temp;
undef @temp1;
unlink "$file.double.temp";

print "calculating pairwised interval of cutting sites......\n";
open (TMP3,">$file.double") or die "Sorry, you don't have the permisison for writing files!\n";
print TMP3 "EnzymePair","\t","MeanInterval","\t","windowSize100-","\t","windowSize200","\t",,"windowSize400","\t","windowSize600","\t","windowSize800","\t","windowSize1000","\t","windowSize1000+","\t","Total\n";
@name=sort @name;
my @name2=@name;
my($key,$key2,$index,@double);
foreach $key(@name)
{	
	shift @name2;
	foreach $key2(@name2)
	{
		if($key ne $key2)
		{
			@a1=@{$positions{$key}};
			@a2=@{$positions{$key2}};
			for($index=0;$index<=$#a1;$index++)
			{
				unless($a1[$index] eq "X" || $a2[$index] eq "X")
				{
					@temp=ddInterval1($a1[$index],$a2[$index]);
					push @temp1,@temp;
				}
			}
			@double=ddInterval2(\@temp1);
			print TMP3 $key,"-",$key2,"\t",join("\t",@double),"\n"; 
			undef @temp;
			undef @temp1;
		}
		else
		{
			next;
		}
	}
}
print "Pairwised interval of cutting sites calculation finished\n";
close TMP3;

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
	foreach $ele1(@pos1)
	{
		$post{$ele1}=1
	}

	foreach $ele2(@pos2)
	{
		$post{$ele2}=2
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

