package KC::Dashboard;

# Script to create dashboard.koha-community.org
# Copyright chris@bigballofwax.co.nz 2012
# Copyright mtj@kohaaloha.com 2012

our $VERSION = '0.2';

use Dancer;
use Dancer::Plugin::Database;
use Dancer::Plugin::Redis;

use Dancer::Logger::File;
use KC::Data ':all';
use strict;
use warnings;
use DBI;
use Date::Manip;
use Dancer::Debug;

#use Template;
set template => 'template_toolkit';
set charset  => 'UTF-8';

set 'session' => 'Simple';
#set logger    => 'file';

set logger => 'console';
#set log => 'debug';

#set 'show_errors'  => 1;
#set 'startup_info' => 1;
#set 'warnings'     => 1;

use Data::Dumper;

set plugins => {
    Database => {
        driver   => 'mysql',
        database => "kc_bugs",
        host     => "miso",
        username => "kc_bugs",
        password => "kc_bugs", #woah, hardcoded passwd!
    }
};

# -----------------------------
get '/' => sub {

    my $sql = "SELECT realname,bugs.bug_id,short_desc, bug_when
  FROM bugs_activity,profiles,bugs WHERE bugs_activity.who=profiles.userid
  AND bugs.bug_id=bugs_activity.bug_id AND added='Signed Off'
  ORDER BY bug_when DESC LIMIT 5";
    my $sth = database->prepare($sql) or die database->errstr;

    $sth->execute or die $sth->errstr;
    my $new_signoff = $sth->fetchall_arrayref;

    # -----------------------------

    my $sql =

      "SELECT realname, bugs.bug_id,short_desc FROM bugs
join profiles on bugs.reporter=profiles.userid
  WHERE bug_status ='Needs Signoff' ORDER by lastdiffed limit 5";

    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;

    my $oldest_needs_signoff = $sth->fetchall_arrayref;

    #$oldest_needs_signoff->{widget_title} = 'moof';
    $sth->fetchall_arrayref;

    # -----------------------------

    $sql = "SELECT realname,count(*)  FROM bugs_activity,profiles,bugs
WHERE bugs_activity.who=profiles.userid AND bugs.bug_id=bugs_activity.bug_id
AND added='Signed Off' and bug_when >=


 DATE_SUB(CURDATE(), interval 5 month)


AND bug_when <  last_day( CURDATE() )  GROUP BY realname,added ORDER BY count(*) desc
limit 10";

    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;
    my $stats = $sth->fetchall_arrayref;

    #debug Dumper $stats ;

    $sql =
"SELECT count(*) as count ,subdate(current_date, 1) as day FROM bugs_activity WHERE date(bug_when) = subdate(current_date, 1);";
    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;
    my $yesterday = $sth->fetchrow_hashref();

    $sql =
"SELECT count(*) as count, current_date as day FROM bugs_activity WHERE date(bug_when) = current_date;";
    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;
    my $today = $sth->fetchrow_hashref();

    $sql =
"SELECT count(*) as count ,subdate(current_date, 2) as day FROM bugs_activity WHERE date(bug_when) = subdate(current_date, 2);";
    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;
    my $daybefore = $sth->fetchrow_hashref();

    $sql =
"SELECT bugs.bug_id,short_desc,bug_when FROM bugs,bugs_activity WHERE bugs.bug_id = bugs_activity.bug_id
AND added = 'Pushed to Master' AND bug_severity = 'enhancement' ORDER BY bug_when desc LIMIT 5";
    $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;
    my $enhancement = $sth->fetchall_arrayref;
    my $dates       = get_dates();

    # -----------------------------

    #my $ohloh       = redis->get('ohloh');
    my $ohloh = ohloh_activity();
    my $ohloh_devs = ohloh_devs();

    my $bug_activity = [

        [ $daybefore->{day}, $daybefore->{count} ],
        [ $yesterday->{day}, $yesterday->{count} ],
        [ $today->{day},     $today->{count} ],

    ];

    template 'index.tt', {
        'new_signoff' => $new_signoff,
        'stats'       => $stats,
        'yesterday'   => $yesterday,
        'today'       => $today,
        'daybefore'   => $daybefore,
        'enhancments' => $enhancement,
        'dates'       => $dates,
        'ohloh'                => $ohloh,
        'ohloh_devs'           => $ohloh_devs,
        'oldest_needs_signoff' => $oldest_needs_signoff,
        #'dummy'                => $dummy,
        'bug_activity'         => $bug_activity,

    };
};

get '/bug_status' => sub {
    my $sql =
      "SELECT count(*) as count,bug_status FROM bugs GROUP BY bug_status";
    my $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;

    template 'bug_status.tt',
      { 'status' => $sth->fetchall_hashref('bug_status') };
};

get '/randombug' => sub {
    my $sql =
      "SELECT * FROM (SELECT bug_id,short_desc FROM bugs WHERE bug_status NOT in
    ('CLOSED','RESOLVED','Pushed to Master','Pushed to Stable','VERIFIED', 'Signed Off', 'Passed QA') ) AS bugs2 ORDER BY rand() LIMIT 1";
    my $sth = database->prepare($sql) or die database->errstr;
    $sth->execute or die $sth->errstr;

    template 'randombug.tt', { 'randombug' => $sth->fetchall_arrayref };
};

#-------------------------------

true;

