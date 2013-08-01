#! /usr/bin/env perl
# url-encode.pl
########################################################################

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

########################################################################
# GET OPTIONS
#
my ( $input, $help, $wants_docs );

GetOptions (
    "input=s"		=> \$input,
    "help"		=> \$help,
    "documentation"	=> \$wants_docs,
) or die pod2usage ( -msg => "Invalid parameter" -exitval => 2 );

if ( $help ) {
    pod2usage ( -exitval => 0, -verbose => 0 );
}

if ( $wants_docs ) {
    pod2usage ( -verbose => 2 );
}
#
########################################################################

########################################################################
# MAIN PROGRAM
#
if ( not $input ) { #Getting from STDIN
    my @input = <STDIN>;
    chomp @input;
    $input = join "\r\n", @input;
    chomp $input;
}

for my $char ( split //, $input ) {
    if ( ord $char < ord "0" ) {
	printf "%%%02x", ord $char;
    }
    else {
	print "$char";
    }
}
print "\n";

#
# DONE
########################################################################

=pod

=head1 NAME

urlencode.pl

=head1 SYNOPSIS

    url-encode -input "my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode <<<"my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode "my string to URL encode" | url-encode.pl
    my%20string%20to%20URL%20encode

=head1 DESCRIPTION

This program takes a string and URL encodes it

It returns the string onto STDOUT

=head1 OPTIONS

=over 5

=item -input

The string you want to url-encode

=item -help

Prints help text

=item -documentaion

Prints out this whole friggin' document

=back

=head1 AUTHOR

David Weintraub L<mailto:dweintraub@travelclick.com>

=cut
