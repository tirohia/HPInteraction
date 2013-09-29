#!/usr/bin/perl 

use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::Sam;
#use Spreadsheet::WriteExcel;  
#use Spreadsheet::XLSX;
use Excel::Writer::XLSX;
use Spreadsheet::ParseExcel;


my %details;
my %freq;

#get descriptions from blast fasta file.
my $blastDB= "/workspace/hrabyc/transcriptome/actinidaModel/actinidia.fa";
my $inseq = Bio::SeqIO->new(-file   => "<$blastDB",-format => "fasta",);
while (my $seq=$inseq->next_seq){
       $details{$seq->id}=$seq->description;
       #print $seq->id."\t".$seq->description."\n";
}

#get the mapped files from the intermediate results directories. 
#my $directory="/workspace/hrabyc/transcriptome/trimmed/actinidia";
my $directory="/data/genomic/plant/Actinidia/chinensis/hort16A/Transcriptome/Infected/bacterial/Pseudomonas/syringae/stem_assay/trimmed/actinidia";
#my $directory="/data/genomic/plant/Actinidia/chinensis/hort16A/Transcriptome/Infected/bacterial/Pseudomonas/syringae/bion_experiment/aligned/actinidia";

opendir(DIR, $directory);
my @samples= readdir(DIR);
foreach (@samples){
	#print $_."\n";
        next if (m/^\./);
        #print $_."\n";

	my $sam = Bio::DB::Sam->new(-bam  =>"$directory/$_/mapped_$_.bam");
	my $iterator = $sam->features(-iterator => 1,  -flags    => {M_UNMAPPED=>0});
	#my $iterator = $sam->features(-type=>'read_pair');
	#my $iterator = $sam->get_seq_stream(-type=>'read_pair');


	while (my $align = $iterator->next_seq) { 
		if ( defined($freq{$align->seq->id}{$_})){	
			$freq{$align->seq->id}{$_}++;
			#print $freq{$align->seq->id}{$_}."\n";
			#print $freq{$align->seq->id}{$_}."\t".$details{$align->seq->id}."\n";
		}
		else {
			$freq{$align->seq->id}{$_}=1;
		}
	#	$num++;
	}
	
}
#my @targets = $sam->seq_ids;
#print $targets[0];
#foreach (@targets){
#	$freq{$_}++;
#	print $_ ."\n";
#}

#dump results into a file that R/deseq can use
open OUT, ">/workspace/hrabyc/transcriptome/trimmed/results/frequencyMatrixStem" or die $!;
open OUT1, ">/workspace/hrabyc/transcriptome/trimmed/results/frequencyMatrix_noheadersStem" or die $!;	
print OUT "gene\t";
print OUT1 "gene\t";

#wtf is going on here? samplename doesn't change?
#my $sampleName;
#for my $thing ( @samples ) {
#	next if (m/^\./);
#	print $sampleName."\n";
#	print OUT "$sampleName\t";
#	print OUT1 "$sampleName\t";
#	print $thing."\n";
#}


print OUT "gene description\n";
print OUT1 "\n";

foreach my $gene ( sort keys %freq ) {

	if ($details{$gene}!~/ribosom/){
	print OUT "$gene:\t";
	print OUT1 "$gene:\t";
	
	for my $sampleID ( @samples ) {
		next if (m/^\./);
		if (defined($freq{$gene}{$sampleID})){
			print OUT "$freq{$gene}{$sampleID}\t";
			print OUT1 "$freq{$gene}{$sampleID}\t";
		}
		else {
			print OUT "0\t";
			print OUT1 "0\t";
		}
	}
	print OUT "$details{$gene}\n";
	print OUT1 "\n";
	}
}


#foreach (%freq){
 #       print OUT $_."\t".$freq{$_}."\t".$details{$_}."\n";
	
	#print $_."\n";
	#print $freq{$_}."\n";
	#print $details{$_}."\n";

	#print OUT $_."\t".$freq{$_}."\t".$details{$_}."\n";
#}

#get hits from samfile and do frequency count;




#write everything to a bloody excell spreadsheet.
##my $i=0;
##my $format = $workbook1->add_format( color => 'blue', underline => 1 );
#
##writing to an excell spreadsheet
##while ($i<70000){
##       my $seq=$inseq->next_seq;
##       $details{$seq->id}=$seq->description;
##       #print $seq->id."\t".$seq->description."\n";
##       my $url = "https://genome.plantandfood.co.nz/cgi-bin/nph-actinidia.cgi?action=show_accession_info&id=".$seq->id;
##       $worksheet1->write($i, 0, $url,$format, $seq->id);
##       $worksheet1->write($i, 1, $seq->description);
##       $i++;
##}
##$workbook1->close();
#
#
