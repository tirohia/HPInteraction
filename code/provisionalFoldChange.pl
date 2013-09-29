#!/usr/bin/perl

use strict;
use Spreadsheet::WriteExcel;
use Bio::SeqIO;

my $base_dir="/workspace/hrabyc/HPIneteraction/";
my $workbook  = Spreadsheet::WriteExcel->new("$base_dir/data/stemAssay/sdwMvswSdw/sdwMvsSdw-up.csv");
my $worksheet = $workbook->add_worksheet();

open (DATA, "$base_dir/data/stemAssay/sdwMvswSdw/sdwMvsSdwDE080513-up.csv") or die "couldn't open data file: $!";

my $i=0;

my %details;
my $blastDB= "$base_dir/models/actinidaModel/actinidia.fa";
my $inseq = Bio::SeqIO->new(-file   => "<$blastDB",-format => "fasta",);
my $format = $workbook->add_format( color => 'blue', underline => 1 );

while (my $seq=$inseq->next_seq){
       $details{$seq->id}=$seq->description;
}

while (<DATA>){
	chomp;
	my @data = split(',', $_);
	$data[1] =~ s/"//g;
	my $url = "https://genome.plantandfood.co.nz/cgi-bin/nph-Achinensis.cgi?action=show_accession_info&id=".$data[1];
	print $details{$data[1]}."\n";

	$worksheet->write_url($i, 0, $url, $data[1], $format);
	$worksheet->write($i,1,$data[6]);
	$worksheet->write($i,2 , $details{$data[1]});
	$i++;
}

$workbook->close();

