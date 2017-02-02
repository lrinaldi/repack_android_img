#!/usr/bin/perl

use strict;
use warnings;

use XML::Simple;

use Fcntl qw(SEEK_SET);
use File::stat;

#
# Globals
#
use vars qw/ %opt $xml_file $selected_label $parsed_xml_file $result_folder $result_filename $magic_byte /;

#
# Touch file
#
sub touch_file {
    my $f = shift;
    open my $fh, '>>', $f or die "Can't write to $f: $!\n";
    close $fh;
}

#
# Command line options processing
#
sub init() {
    use Getopt::Std;
    my $opt_string = 'f:l:m';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if $opt{h};
    
    $xml_file = "rawprogram_unsparse.xml";
    $xml_file = $opt{f} if $opt{f};
    
    $selected_label = "system";
    $selected_label = $opt{l} if $opt{l};
    
    $magic_byte = 1 if $opt{m};
    
    $parsed_xml_file = XMLin($xml_file);
    
    $result_folder = "rom";
    mkdir $result_folder unless -d $result_folder;
    
    $result_filename = $result_folder."/".$selected_label.".raw";
    unlink $result_filename if -f $result_filename;
    touch_file($result_filename);
}

#
# Message about how to use script
#
sub usage() {

print <<EOF;
    
    usage: $0 [-l label] [-f file]

     -l label  : partition label
     -f file   : xml file data (default : rawprogram_unsparse.xml)
     -m        : write missing byte at the end of the file

    example: $0 -l system -f rawprogram_unsparse.xml
EOF
    exit;
}

#
# Proceed image file from xml datas
#
sub main {
    open(my $result_fh, "+<", $result_filename) or die "Could not open file '$result_filename' $!";
    binmode($result_fh) or die "$!";

    my $img_start_sector = 0;
    my $partition_length = 0;
    my $start_position = 0;
    
    foreach my $program (@{$parsed_xml_file->{program}}) {
                
        my $label = $program->{label};
        my $filename = $program->{filename};
        my $start_sector = $program->{start_sector};
        my $num_partition_sectors = $program->{num_partition_sectors};
        my $sector_size_byte = $program->{SECTOR_SIZE_IN_BYTES};
        my $file_id;
        
        if($label eq $selected_label) {
            
            if ($filename =~ m/(_)(\d+)(.)/) {
                $file_id = $2;
            }
            
            if($file_id eq "1") {
                $img_start_sector = $start_sector;
            }
            
            $partition_length = $num_partition_sectors * $sector_size_byte;
            $start_position = ($start_sector - $img_start_sector) * $sector_size_byte;
            
            seek($result_fh, $start_position, SEEK_SET);
            
            open(my $imgpart_fh, "+<", $filename) or die "Could not open file '$filename' $!";
            binmode($imgpart_fh) or die "$!";
            
            my $stat = stat($filename);
            my $size = $stat->size;
            
            my $bytes_read = read ($imgpart_fh, my $bytes, $size);
                die "Got $bytes_read but expected $size" unless $bytes_read == $size;
            
            print $result_fh $bytes;
                        
            close $imgpart_fh;
            
            printf("file : %s, positions is %d, length is %d\n", $filename, $start_position, $partition_length);
        }
    }
    
    #
    # TODO : magick truncating
    #
    if($magic_byte) {
        print "Magick byte not implemented yet!";
    }
    
    close $result_fh;
    print "File $result_filename generated !\n";
    exit(0);
}

init();

main();





