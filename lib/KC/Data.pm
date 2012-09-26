package KC::Data;

use 5.010001;
use strict;
use warnings;

use LWP::Simple;
use XML::Simple;
use Dancer::Debug;

use DateTime;

use Data::Dumper;

require Exporter;

#use Dancer;
#set log => 'debug';

our @ISA = qw(Exporter);

# This allows declaration	use KC::Data ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(
          get_dates ohloh_activity ohloh_devs
          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(

);

our $VERSION = '0.02';

sub get_dates {

    # subroutine to parse a date file and put it into a form suitable for TT
    open( my $FH, '<', 'data/dates.txt' );
    my @dates;
    my $today = DateTime->now->ymd;
    while ( my $line = <$FH> ) {
        my ( $date, $desc ) = split( /\|/, $line );
        my $daterow = {
            'date' => $date,
            'desc' => $desc
        };
        if ( $date gt $today ) {
            push @dates, $daterow;
        }
    }
    close $FH;
    return \@dates;
}

sub ohloh_activity {
    my $url =
"http://www.ohloh.net/projects/koha/analyses/latest/activity_facts.xml?api_key=ad98f4080e21c596b62c9315f6c7a4c8b08af082";

    # get the url from the server
    my $response = get $url or return;

    # parse the XML response
    my $xml = eval { XMLin($response) } or return;

    # was the request a success?
    return unless $xml->{status} eq 'success';
    return $xml;
}

sub ohloh_devs {
    my $url =
"http://www.ohloh.net/p/koha/contributors.xml?api_key=ad98f4080e21c596b62c9315f6c7a4c8b08af082&sort=newest";

    # get the url from the server
    my $response = get $url or return;
    # parse the XML response
    my $xml = eval { XMLin($response) } or return;
    # was the request a success?
    return unless $xml->{status} eq 'success';

    my @a1;
    my $i = 0;
    while ( $i <= 10 ) {

        my $date =
          $xml->{'result'}->{'contributor_fact'}->[$i]->{'first_commit_time'};
        $date =~ s/T.*//;

        my $o2 = {
            'name' => $xml->{'result'}->{'contributor_fact'}->[$i]
              ->{'contributor_name'},
            'date' => $date,
            'id' =>
              $xml->{'result'}->{'contributor_fact'}->[$i]->{'contributor_id'},
        };
        push @a1, $o2;
        $i++;
    }

    #print   Dumper $xml;
    return \@a1;

}

__END__
