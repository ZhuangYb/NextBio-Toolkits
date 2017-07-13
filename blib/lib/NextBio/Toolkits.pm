package NextBio::Toolkits;


use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use NextBio::Utilities ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

sub new
{
	my $self={};
	bless($self);
	return($self);
}

# Preloaded methods go here.
############################
sub Fastq_uniq
{
	shift;
	my $file=shift;
	open(FILE,"$file");
	my @content=<FILE>;
	my $line;
	my $count;
	my %bash;
	for($count=1;$count<=($#content-2);$count+=4)
	{
		chomp $content[$count-1];
		chomp $content[$count];
		chomp $content[$count+1];
		chomp $content[$count+2];
		$bash{$content[$count]}=$content[$count-1]."\n".$content[$count]."\n".$content[$count+1]."\n".$content[$count+2]."\n";
	}
	foreach my $line(keys %bash)
	{
		print $bash{$line}
	}
	close FILE;
}


############################
sub Fasta_uniq
{
	shift;
	my $file=shift;
	my $rename=shift;
	open(FILE,"$file");
	my @temp=<FILE>;
	my ($line,$count);
	my %bash;
	my @content;
	$count=0;
	foreach $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$content[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $content[$count])
			{
				$content[$count]=$content[$count].$line;
			}
			else
			{
				$content[$count]=$line;
			}
		}

	}

	for($count=1;$count<=($#content);$count+=2)
	{
		$bash{$content[$count]}=$content[$count-1]
	}
	$count=1;
	if($rename)
	{
		foreach $line(keys %bash)
		{
			print ">",$rename,"_seq_",$count,"\n",$line,"\n";
			$count++
		}
	}	
	else
	{
		foreach $line(keys %bash)
		{
			
			print $bash{$line},"\n";
			$line=~s/(.{80})/$1\n/g;
			print $line,"\n";
		}
	}
	close FILE;
}


############################
sub Fasta_sort
{
	shift;
	my $file=shift;
	my $order=shift;
	open(FILE,"$file");
	my @temp=<FILE>;
	my %hash;
	my ($key,$line);
	my @content;
	my $count=0;
	foreach $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$content[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $content[$count])
			{
				$content[$count]=$content[$count].$line;
			}
			else
			{
				$content[$count]=$line;
			}
		}

	}
	for(my $count=0;$count<$#content;$count+=2)
	{
		my $length=length($content[$count+1]);
		$content[$count+1]=~s/(.{80})/$1\n/g;
		my $temp=$content[$count]."\n".$content[$count+1]."\n";
		$hash{$temp}=$length;
	}
		
	if(defined $order eq 'down')
	{
		foreach $key(sort{ $hash{$b} <=> $hash{$a}}keys %hash)
		{
			print $key;
		}
	}
	else
	{
		foreach $key(sort{ $hash{$a} <=> $hash{$b}}keys %hash)
		{
			print $key;
		}	
	}
	close FILE;
}


############################
sub Fasta_length
{
	shift;
	my $file=shift;
	my $length=shift;
	my $order=shift;
	open(FILE,"$file");
	my @temp=<FILE>;
	my %hash;
	my $key;
	my @content;
	my $count=0;
	foreach my $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$content[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $content[$count])
			{
				$content[$count]=$content[$count].$line;
			}
			else
			{
				$content[$count]=$line;
			}
		}

	}
		for(my $count=0;$count<$#content;$count+=2)
	{
		my $leng=length($content[$count+1]);
		$content[$count+1]=~s/(.{80})/$1\n/g;
		my $temp=$content[$count]."\n".$content[$count+1]."\n";
		$hash{$temp}=$leng if $leng >= $length;
	}
		
	if(defined $order eq 'down')
	{
		foreach $key(sort{ $hash{$b} <=> $hash{$a}}keys %hash)
		{
			print $key;
		}
	}
	else
	{
		foreach $key(sort{ $hash{$a} <=> $hash{$b}}keys %hash)
		{
			print $key;
		}	
	}
	close FILE;
}



############################
# make sure all fasta file is uniq
sub Fasta_share
{
	shift;
	my $list=shift;
	open(LIST,"$list");
	my @file=<LIST>;
	my $number=@file;
	my %hash;
	my ($line,$line2);
	my $share=0;
	foreach $line(@file)
	{
		chomp $line;
		open(INPUT,"$line");
		$share++;
		my @temp=<INPUT>;
		my $count=0;
		my @content=();
		foreach $line2(@temp)
		{
			
			chomp $line2;
			if($line2=~/>/)
			{
				unless ($count==0)
				{
					$count++
				}
				$content[$count]=$line2;
				$count++;
			}
			else
			{
				if(defined $content[$count])
				{
					$content[$count]=$content[$count].$line2;
				}
				else
				{
					$content[$count]=$line2;
				}
			}

		}
		for(my $count=0;$count<$#content;$count+=2)
		{
			if(defined $hash{$content[$count+1]} && $hash{$content[$count+1]}==($share-1)) 
			{
				$hash{$content[$count+1]}=$share;
			}
			else
			{	
				unless(defined $hash{$content[$count+1]})
					{
						$hash{$content[$count+1]}=1;
					}
			}
		}
		close INPUT;
	}
	my $header=1;
	foreach my $line(keys %hash)
	{

		if($hash{$line} == $number)
		{
			$line=~s/(.{80})/$1\n/g;
			print ">shared_seq",$header,"\n",$line,"\n";
			$header++;
		}
	}
	close LIST;
	
}


############################
sub Fasta_extract
{
	shift;
	my $fasta=shift;
	my $list=shift;
	open(FASTA,"$fasta");
	open(LIST,"$list");
	my @temp=<FASTA>;
	my @list=<LIST>;
	my %hash;
	my @fasta;
	my $count=0;
	foreach my $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$fasta[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $fasta[$count])
			{
				$fasta[$count]=$fasta[$count].$line;
			}
			else
			{
				$fasta[$count]=$line;
			}
		}

	}
	for(my $count=0;$count<$#fasta;$count+=2)
	{
		chomp $fasta[$count];
		$fasta[$count]=~/>(.+)/;
		my $key=$1;
		$fasta[$count+1]=~s/(.{80})/$1\n/g;
		my $temp=$fasta[$count]."\n".$fasta[$count+1]."\n";
		$hash{$key}=$temp
	}
	foreach my $line(@list)
	{
		chomp $line;
		if($hash{$line})
		{
			print $hash{$line}
		}
	}
	close FASTA;
	close LIST;

}


############################
sub Fasta_exclude
{
	shift;
	my $fasta=shift;
	my $list=shift;
	open(FASTA,"$fasta");
	open(LIST,"$list");
	my @temp=<FASTA>;
	my @list=<LIST>;
	my %hash;
	my @fasta;
	my $count=0;
	foreach my $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$fasta[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $fasta[$count])
			{
				$fasta[$count]=$fasta[$count].$line;
			}
			else
			{
				$fasta[$count]=$line;
			}
		}

	}
	for(my $count=0;$count<$#fasta;$count+=2)
	{
		chomp $fasta[$count];
		$fasta[$count]=~/>(.+)/;
		my $key=$1;
		$fasta[$count+1]=~s/(.{80})/$1\n/g;
		my $temp=$fasta[$count]."\n".$fasta[$count+1]."\n";
		$hash{$key}=$temp;
	}
	my %hash2;
	foreach my $line(@list)
	{
		chomp $line;
		$hash2{$line}=1;
	}
	foreach my $line(keys %hash)
	{
		unless($hash2{$line})
		{
			print $hash{$line}
		}
	}
	close FASTA;
	close LIST;

}


############################
sub Fastq2Fasta
{
	shift;
	my $fastq=shift;
	open(FASTQ,"$fastq");
	my $count=3;
	my $name=1;
	foreach my $line (<FASTQ>)
	{
		if($count%4==0)
		{
			print ">seq_",$name,"\n";
			print $line;
			$name++;
		}
		$count+=1;
	}	
	close FASTQ;
}


###########################
sub phy_clean
{
	shift;
	my $phy=shift;
	my $threshold=shift;
	my $list=shift;
	unless(defined $threshold)
	{
		$threshold=0;
	}else
	{
		$threshold=1-$threshold;
	}
	open(PHY,$phy);
	open(LIST,$list) if defined $list;
	my @phy=(<PHY>);
	my (@list,%list) if defined $list;
	if (defined $list)
	{
		@list=(<LIST>);
		foreach my $line(@list)
		{
			chomp $line;
			$list{$line}=1;
		}
	}
	my %hash1;
	my %hash2;
	my @loci=split(" ",$phy[0]);
	for(my $count=1;$count<=$#phy;$count++)
	{
		my $nucleo_count=$phy[$count]=~tr/ACTGactg/ATCGactg/;
		$phy[$count]=~/(.+?)\s+(.+)/;
		my $name=$1;
		my $seq=$2;
		my $N=$seq=~tr/ACTGactg/ACTGactg/;
		$seq=~s/N/-/g if $seq=~/N/;
		$phy[$count]=$name." ".$seq."\n";
		unless ($N <= $threshold * $loci[1] || $list{$name})
		{
			$hash1{$name}=$phy[$count];
			$hash2{$name}=$nucleo_count;
		}
	}
	my $samples=scalar keys %hash1;
	print $samples," ",$loci[1],"\n";
	foreach my $key (sort{ $hash2{$b} <=> $hash2{$a} } keys %hash2)
	{
		print $hash1{$key};
	}
	close PHY;
}


###########################
sub overhang_check
{
	shift;
	my $file=shift;
	my $overhang=shift;
	open(FILE,"$file");
	my @content=<FILE>;
	my $line;
	my $count;
	my %bash;
	for($count=1;$count<=($#content-2);$count+=4)
	{
		$bash{$content[$count]}=$content[$count-1].$content[$count].$content[$count+1].$content[$count+2];
		print $bash{$content[$count]} if $content[$count]=~/^$overhang/
	}
	close FILE;
}
###########################
sub file_rename
{
	shift;
	my $list=shift;
	open(LIST,"$list");
	for my $line(<LIST>)
	{
		my @name=split("\t",$line);
		`mv "$name[0]" "$name[1]"`
	}
	close LIST;
}
###########################
sub N50_count
{
	shift;
	my $file=shift;
	open(FILE,"$file");
	my @temp=<FILE>;
	my %hash;
	my $key;
	my $sum=0;
	my $N50=0;
	my @content;
	my $count=0;
	foreach my $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{
			unless ($count==0)
			{
				$count++
			}
			$content[$count]=$line;
			$count++;
		}
		else
		{
			if(defined $content[$count])
			{
				$content[$count]=$content[$count].$line;
			}
			else
			{
				$content[$count]=$line;
			}
		}

	}
	for(my $count=0;$count<$#content;$count+=2)
	{
		my $temp=$content[$count].$content[$count+1];
		$hash{$temp}=length($content[$count+1]);
		$sum+=$hash{$temp}
	}
		
	foreach $key(sort{ $hash{$a} <=> $hash{$b}}keys %hash)
	{
		$N50+=$hash{$key};
		if($N50 > $sum/2)
		{
			print "N50 is: >= $hash{$key}\n";
			last;
		}
	}
	
	close FILE;
}

###########################
sub translate
{
	shift;
	my $fasta=shift;
	my $input='';
	my (@header,@temp);
	my $count=0;
	my %code= &store_code;
	open(FASTA,"$fasta");
	@temp=<FASTA>;
	@temp=&fasta_format(@temp);
	foreach my $line(@temp)
	{
		chomp $line;
		if($line=~/>/)
		{	
			$header[$count]=$line;
			$count++;
			if($input ne '')
			{
				$input=~tr/T/U/;
				my($out1,$out2,$out3,$out4,$out5,$out6);
				$out1=$input;
				$out2=substr($input,1,(length($input)-1));
				$out3=substr($input,2,(length($input)-2));
				$out4=reverse $input;
				$out4=~tr/ACUG/UGAC/;
				$out5=substr($out4,1,(length($out4)-1));
				$out6=substr($out4,2,(length($out4)-2));				
				print $header[$count-2],"_plus1,\n";
				while($out1=~/.../)
				{
					$out1=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";
				
				print $header[$count-2],"_plus2,\n";
				while($out2=~/.../)
				{
					$out2=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-2],"_plus3,\n";
				while($out3=~/.../)
				{
					$out3=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-2],"_minus1,\n";
				while($out4=~/.../)
				{
					$out4=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-2],"_minus2,\n";
				while($out5=~/.../)
				{
					$out5=~s/(...)//;
					print $code{$1};
				}
				print"\n";

				print $header[$count-2],"_minus3,\n";
				while($out6=~/.../)
				{
					$out6=~s/(...)//;
					print $code{$1};
				}
				print"\n";

				$input='';
			}
		}
		else
		{ 
			$input=$input.$line;
		}
	}
	$input=~tr/T/U/;
				my($out1,$out2,$out3,$out4,$out5,$out6);
				$out1=$input;
				$out2=substr($input,1,(length($input)-1));
				$out3=substr($input,2,(length($input)-2));
				$out4=reverse $input;
				$out4=~tr/ACUG/UGAC/;
				$out5=substr($out4,1,(length($out4)-1));
				$out6=substr($out4,2,(length($out4)-2));				
				print $header[$count-1],"_plus1,\n";
				while($out1=~/.../)
				{
					$out1=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";
				
				print $header[$count-1],"_plus2,\n";
				while($out2=~/.../)
				{
					$out2=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-1],"_plus3,\n";
				while($out3=~/.../)
				{
					$out3=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-1],"_minus1,\n";
				while($out4=~/.../)
				{
					$out4=~s/(...)//;
					print $code{$1} ;
				}
				print"\n";

				print $header[$count-1],"_minus2,\n";
				while($out5=~/.../)
				{
					$out5=~s/(...)//;
					print $code{$1};
				}
				print"\n";

				print $header[$count-1],"_minus3,\n";
				while($out6=~/.../)
				{
					$out6=~s/(...)//;
					print $code{$1};
				}
				print"\n";
}



sub store_code
{
	my $code ="A GCU GCC GCA GCG
R CGU CGC CGA CGG AGA AGG
N AAU AAC
D GAU GAC
C UGU UGC
Q CAA CAG
E GAA GAG
G GGU GGC GGA GGG
H CAU CAC
I AUU AUC AUA
L UUA UUG CUU CUC CUA CUG
K AAA AAG
M AUG
F UUU UUC
P CCU CCC CCA CCG
S UCU UCC UCA UCG AGU AGC
T ACU ACC ACA ACG
W UGG
Y UAU UAC
V GUU GUC GUA GUG
/// UAA UAG UGA";
	my %pcode;
	my @code=split("\n",$code);
	foreach my $line(@code)
	{
		my @coden=split(" ",$line);		
   	    for(my $count=$#coden;$count>0;$count--)
    	{
    		 $pcode{$coden[$count]}= $coden[0]
    	}
    }
	return %pcode;	
}


###########################
sub ploidy
{
	shift;
	my $fasta=shift;
	my $fastq=shift;
	my @fastq=@{$fastq};
	my $length=@fastq;
	my $depth=shift;
	my $index=shift;
	my $stage=shift;
	$stage=0 unless defined $stage;
	`mkdir Bowtie_index`;
	unless($stage==2 ||$stage==3)
	{
		open(BOWTIE2_BUILD,"|bowtie2-build $fasta ./Bowtie_index/$index" ) or die "can not open bowtie2-build\n";
		select(BOWTIE2_BUILD);
		close(BOWTIE2_BUILD);
	}
	unless($stage==3)	
	{
		if($length==1)
		{
			open(BOWTIE2,"|bowtie2 --no-unal --sensitive -x ./Bowtie_index/$index -U $fastq[0] -S  $index.mapped.sam") or die "can not open bowtie2!\n";
			select(BOWTIE2);
			close(BOWTIE2);
		}
		elsif($length ==2)
		{
			open(BOWTIE2,"|bowtie2 -p 4 --no-unal --sensitive -x ./Bowtie_index/$index -1 $fastq[0] -2 $fastq[1] -S  $index.mapped.sam") or die "Error generating $index.mapped.sam file!\n";
			select(BOWTIE2);
			close(BOWTIE2);
		}
		open(SAM1,"|samtools view -bS $index.mapped.sam >$index.map.bam") or die "Error generating $index.map.sam file!\n";
		select(SAM1);
		close(SAM1);

		open(SAM2,"|samtools view -b -F 4 $index.map.bam >$index.mapped.bam") or die "Error generating $index.mapped.bam file!\n";
		select(SAM2);
		close(SAM2);

		open(SAM3,"|samtools sort $index.mapped.bam -o $index.sorted.bam") or die "Error generating $index.sorted.bam file!\n";
		select(SAM3);
		close(SAM3);

		open(SAM4,"|samtools index $index.sorted.bam") or die "Error generating index file for $index.sorted.bam !\n";
		select(SAM4);
		close(SAM4);	
	
		open(SAM5,"|samtools mpileup -uf $fasta $index.sorted.bam|bcftools call -c -v >$index.ploidy.vcf") or die "Error generating final cvf file!\n";
		select(SAM5);
		close(SAM5);
	}		
	unless($stage==1 ||$stage==2)	
	{
		open(VCF,"$index.ploidy.vcf") or die "can't find vcf file!\n";
		open(OUT,">$index.allelic.txt");
		foreach my $line(<VCF>)
		{
			if($line=~/DP4=(\d+),(\d+),(\d+),(\d+)/ && ($3+$4+$1+$2)>0)
		 	{
	 			my $out=($1+$2)/($3+$4+$1+$2);
	 		    $line=~/DP=(\d+)/;
	 		    if($1>=$depth)
	 		    {
	 		    	print OUT $out,"\n" if ($out >=0.2 && $out <=0.8);
	 		    }	 	 
	    	}
		}
	}
	close VCF;
	close OUT;
	open(R,"|R --no-restore --no-save --slave") or die "Fail to open R binary file!\n";
	select(R);
	print <<CODE;
pdf("$index.ploidy_plot.pdf")
a<-scan("$index.allelic.txt",what="")
a<-as.numeric(a)
intervals<-cut(a,breaks=seq(0.2,0.8,by=0.05))
b<-as.data.frame(table(intervals))
lim<-with(b,max(Freq))
lim<-1.2*lim
with(b,barplot(Freq,main="$index",cex.main=0.8,las=3,ylim=c(0,lim),font.main=2,names.arg=intervals,cex.axis = 0.5,cex.names=0.45 ))
dev.off()
q()
CODE
	close(R);
}
#alternatively, with() could be substituted by 
#barplot(b[,"Freq"],main="test",cex.main=0.8,las=3,ylim=c(0,lim),font.main=2,names.arg=b[,"intervals"],cex.axis = 0.5,cex.names=0.45 )

###########################

sub fasta_format
{	
	my @seq;
	my $count=0;
	my @file=@_;
	foreach my $line(<FASTA>)
	{	
		if ($count !=0 && $line=~/>/)
		{
			$count++ ;
		}
		chomp $line;
		if ($line=~/>/)
		{
		$seq[$count]=$line;
		$count++;
		}
		else
		{
			$seq[$count]='' unless defined $seq[$count];
			$seq[$count]=$seq[$count].$line;
		}

	}
	return @seq;
}	

############################
sub phy_sub
{
	shift;
	my $phy=shift;
	my $base=shift;
	my $raise=shift;
	my $count=0;
	my (@temp,@entry,$i,@pos,%hashn,%hashm,%hashe,@sort,@pos_f);
	open (PHY,$phy);
	
	foreach my $line(<PHY>)
	{	
		@pos=();
		my $pos=0;	
		if($count==0)
		{
			print $line;
			$count++;
		}
		elsif($count>0)
		{
			@temp=split(" ",$line);
			@entry=split("",$temp[1]);
			for($i=0;$i<=$#entry;$i++)
			{
				
				unless($entry[$i] eq '-' )
				{
					push @pos,$i;
					$pos=$pos.":".$i;
				}
			}
			$hashn{$temp[0]}=$pos;
			$hashm{$temp[0]}=$temp[1];
			$hashe{$temp[0]}=scalar @pos;
			$count++;
		}
	
	}
	close PHY;
	#sort entry by number of allels
	foreach my $key(sort{$hashe{$a} <=> $hashe{$b}} keys %hashe)
	{
		push @sort,$key;
	}
	
	$count=0;
	for my $name(@sort)
	{
		my @temp=split(":",$hashn{$name});
		my $limit= 1- $count*$raise;
		$limit=$base if $limit<$base;
		if($count==0)
		{
			@pos_f=@temp;
			$count++;
		}
		else
		{
			my @uniq= array2uniq(\@pos_f,\@temp);
			my $all_pos_length=@temp;
			print "here is all_pos_length: $name :",$all_pos_length,"\n";
			my $uniq_pos_length=@uniq;
			print "here is uniq_pos_length: ",$uniq_pos_length,"\n";

			my $p=1-($uniq_pos_length/$all_pos_length);
			print "here is p: ",$p," ","here is limit: ","$limit","\n";
			if($p<$limit)
			{
			
				my $add_p= $limit-$p;
				my $add_index=int($uniq_pos_length*$add_p);
				print "here is add_index: ",$add_index,"\n";
				@pos_f=(@pos_f,@uniq[0..$add_index]);
				#@pos_f=uniq_array(\@pos_f);
			}
		}
	}
	#@pos_f=sort @pos_f;
#print 
	#foreach my $name(@sort)
	#{
	#	my @seq=split("",$hashm{$name});
		#print $name,"\t";
	#	foreach my $final_pos(@pos_f)
	#	{
			
		#	print $seq[$final_pos];
	#	}
		#print "\n";
#	}
}

sub array2uniq
{	
	my @uniq;
	my $array1=shift;
	my $array2=shift;
	for my $ele1(@{$array2})
	{
		my $check =0; 
		for my $ele2(@{$array1})
		{
			$check=1 if $ele1 == $ele2;
		}
		push @uniq,$ele1 if $check ==0;
	}
	return @uniq;
}
sub uniq_array
{
	my $array=shift;
	my @array=@{$array};
	my %seen;
    my @array2= grep !$seen{$_}++, @array;
 	return @array2
}

1;
__END__

=head1 NAME

NextBio::Utilities - Perl extension for Next generation sequencing data manipulation

=head1 SYNOPSIS

  use NextBio::Utilities;

=head1 DESCRIPTION

Stub documentation for NextBio::Utilities, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.


=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Yongbin, E<lt>Yongbin.zhuang@colorado.edu<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Yongbin Zhuang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
