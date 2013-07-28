#! /usr/bin/env perl
# url-encode.pl
########################################################################

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

#########################################################################
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

#
# Separate out each character with a NUL character with URL encoded
# characters as a single character. Thus "foo%20bar":
# "f.o.o.%20.b.a.r" with the "." standing in for NUL.
#
$input =~ s/(%..|.)/$1\0/g;

#
# Now split that string on NULs. If it is a URL-encoded character,
# split off the "%", and print out the character representation.
# Otherwise, just print out that character
#
for my $char ( split /\0/, $input ) {
    if ( $char =~ s/^%// ) {
	print chr hex $char;
    }
    else {
	print $char;
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

    url-dencode.pl -input "my%20URL%20encoded%20string"
    my URL encoded string

    echo "my%20URL%20encoded%20string" | url-dencode.pl
    my URL encoded string

=head1 DESCRIPTION

This program takes a URL-encoded string and decodes it

It returns the decoded string onto STDOUT

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
