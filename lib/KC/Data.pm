package KC::Data;

use 5.010001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# This allows declaration	use KC::Data ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(
          get_dates get_devs
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
    while ( my $line = <$FH> ) {
        my ( $date, $desc ) = split( /\|/, $line );
        my $daterow = {
            'date' => $date,
            'desc' => $desc
        };
        push @dates, $daterow;
    }
    close $FH;
    return \@dates;

}

sub get_devs {
    open( my $FH, '<', 'data/devs.txt' );
    my @devs;
    while ( my $line = <$FH> ) {
        my $devrow = {
            'dev' => $line
        };
        push @devs, $devrow;
    }
    close $FH;
    return \@devs;
}

1;
__END__
