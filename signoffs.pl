#!/usr/bin/perl

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
"select realname,bugs.bug_id,bug_when,short_desc                                            from bugs_activity,profiles,bugs where bugs_activity.who=profiles.userid    and bugs.bug_id=bugs_activity.bug_id and added='Signed Off' order by bug_when desc limit 10";
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'show_entries.tt', { 'entries' => $sth->fetchall_arrayref, };
};

start;

sub connect_db {
    my $db_name   = 'bugzilla3';
    my $db_host   = 'localhost';
    my $db_port   = '3306';
    my $dbh =
      DBI->connect( "DBI:mysql:dbname=$db_name;host=$db_host;port=$db_port",
        $db_user, $db_passwd )
      || die;
    return $dbh;
}

