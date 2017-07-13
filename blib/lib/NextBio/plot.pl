#!/usr/bin/perl -w
use strict;
my @files = readdir $dir;
closedir $dir;
foreach $file (@files)
{
	open(R,"|R --no-restore --no-save --slave") or die "Fail to open R binary file!\n";
	select(R);
	print <<CODE;
	pdf("$$file.pdf")
	a<-read.table("$file",header=F)
	with(a,plot(a))
	dev.off()
	q()
CODE
	close(R);

}