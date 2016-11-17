package NextBio::Utilities;


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
		$bash{$content[$count]}=$content[$count-1].$content[$count].$content[$count+1].$content[$count+2]
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
sub Fasta_stastic
{

}


###########################
sub phy_clean
{
	shift;
	my $phy=shift;
	my $threshold=shift;
	unless(defined $threshold)
	{
		$threshold=0;
	}else
	{
		$threshold=1-$threshold;
	}
	open(PHY,$phy);
	my @phy=(<PHY>);
	my %hash1;
	my %hash2;
	my @loci=split(" ",$phy[0]);
	for(my $count=1;$count<=$#phy;$count++)
	{
		my $nucleo_count=$phy[$count]=~tr/ACTG/ATCG/;
		$phy[$count]=~/(.+?)\s+(.+)/;
		my $name=$1;
		my $seq=$2;
		my $N=$seq=~tr/ACTG/ACTG/;
		unless ($N <= $threshold * $loci[1])
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


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

NextBio::Utilities - Perl extension for blah blah blah

=head1 SYNOPSIS

  use NextBio::Utilities;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for NextBio::Utilities, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

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

Yongbin, E<lt>Yongbin@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Yongbin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
