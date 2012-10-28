package KC::Data;

use 5.010001;
use strict;
use warnings;

use LWP::Simple qw($ua get);
use XML::Simple;
use DateTime;

require Exporter;

our @ISA = qw(Exporter);

# This allows declaration	use KC::Data ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(
          get_dates get_devs ohloh_activity
          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.01';

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

sub get_devs {
    open( my $FH, '<', 'data/devs.txt' );
    my @devs;
    while ( my $line = <$FH> ) {
        my $devrow = { 'dev' => $line };
        push @devs, $devrow;
    }
    close $FH;
    return \@devs;
}

sub ohloh_activity {
    my $url =
"http://www.ohloh.net/projects/koha/analyses/latest/activity_facts.xml?api_key=ad98f4080e21c596b62c9315f6c7a4c8b08af082";
    # get the url from the server
    my $response = get $url or return;

    # parse the XML response
    my $xml = eval { XMLin($response) } or return;

    # was the request a success?
    return
      unless $xml->{status} eq 'success';
    return $xml;
}
__END__
