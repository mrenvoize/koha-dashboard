#!/usr/bin/perl

# Script to create dashboard.koha-community.org
# Copyright chris@bigballofwax.co.nz 2012

use Dancer;
use strict;
use warnings;
use DBI;
use Template;

my $username;
my $password;

set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;

get '/' => sub {
    my $db = connect_db( $username, $password );
    my $sql =
"SELECT realname,bugs.bug_id,bug_when,short_desc                                            
  FROM bugs_activity,profiles,bugs WHERE bugs_activity.who=profiles.userid
  AND bugs.bug_id=bugs_activity.bug_id AND added='Signed Off' 
  ORDER BY bug_when DESC LIMIT 5";
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    my $entries = $sth->fetchall_arrayref;
    $sql =
"select realname,count(*) from bugs_activity,profiles,bugs where bugs_activity.who=profiles.userid and bugs.bug_id=bugs_activity.bug_id and added='Signed Off' and bug_when >= '2012-07-01' and bug_when < '2012-08-01' group by realname,added order by count(*) desc;";
    $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    my $stats = $sth->fetchall_arrayref;

    template 'show_entries.tt',
      {
        'entries' => $entries,
        'stats'   => $stats
      };
};

get '/bug_status' => sub {
    my $db = connect_db( $username, $password );
    my $sql =
      "SELECT count(*) as count,bug_status FROM bugs GROUP BY bug_status";
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;

    template 'bug_status.tt',
      { 'status' => $sth->fetchall_hashref('bug_status') };
};

get '/randombug' => sub {
    my $db = connect_db( $username, $password );
    my $sql =
"SELECT * FROM (SELECT bug_id,short_desc FROM bugs WHERE bug_status NOT in ('CLOSED','RESOLVED','Pushed to Master','Pushed to Stable','VERIFIED') ) AS bugs2 ORDER BY rand() LIMIT 1";
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;

    template 'randombug.tt', { 'randombug' => $sth->fetchall_arrayref };
};

get '/needsignoff' => sub {
    my $db = connect_db( $username, $password );
    my $sql = "SELECT bugs.bug_id,short_desc FROM bugs
               WHERE bug_status ='Needs Signoff' ORDER by lastdiffed limit 5;";
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'needsignoff.tt', { 'needsignoff' => $sth->fetchall_arrayref };

};

start;

sub connect_db {
    my $db_name   = 'bugzilla3';
    my $db_host   = 'localhost';
    my $db_port   = '3306';
    my $db_user   = 'XXXXXXX';
    my $db_passwd = 'XXXXXXX';
    my $dbh =
      DBI->connect( "DBI:mysql:dbname=$db_name;host=$db_host;port=$db_port",
        $db_user, $db_passwd )
      || die;
    return $dbh;
}

