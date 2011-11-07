#!/usr/bin/env perl

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';
use English qw(-no_match_vars);
use Test::More;

use PerconaTest;
use Sandbox;
require "$trunk/bin/pt-table-checksum";

my $dp = new DSNParser(opts=>$dsn_opts);
my $sb = new Sandbox(basedir => '/tmp', DSNParser => $dp);
my $master_dbh = $sb->get_dbh_for('master');
my $slave1_dbh = $sb->get_dbh_for('slave1');

if ( !$master_dbh ) {
   plan skip_all => 'Cannot connect to sandbox master';
}
elsif ( !$slave1_dbh ) {
   plan skip_all => 'Cannot connect to sandbox slave';
}
else {
   plan tests => 17;
}

# The sandbox servers run with lock_wait_timeout=3 and it's not dynamic
# so we need to specify --lock-wait-timeout=3 else the tool will die.
# And --max-load "" prevents waiting for status variables.
my $master_dsn = 'h=127.1,P=12345,u=msandbox,p=msandbox';
my @args       = ($master_dsn, qw(--lock-wait-timeout 3), '--max-load', ''); 
my $row;
my $output;

sub load_data_infile {
   my ($file, $where) = @_;
   $master_dbh->do('truncate table percona.checksums');
   $master_dbh->do("LOAD DATA LOCAL INFILE '$trunk/t/pt-table-checksum/samples/checksum_results/$file' INTO TABLE percona.checksums");
   if ( $where ) {
      PerconaTest::wait_for_table($slave1_dbh, 'percona.checksums', $where);
   }
}

# Create an empty replicate table.
pt_table_checksum::main(@args, qw(-d foo --quiet));
PerconaTest::wait_for_table($slave1_dbh, 'percona.checksums');
$master_dbh->do('truncate table percona.checksums');

my $all_sakila_tables =  [
   [qw( sakila actor        )],
   [qw( sakila address      )],
   [qw( sakila category     )],
   [qw( sakila city         )],
   [qw( sakila country      )],
   [qw( sakila customer     )],
   [qw( sakila film         )],
   [qw( sakila film_actor   )],
   [qw( sakila film_category)],
   [qw( sakila film_text    )],
   [qw( sakila inventory    )],
   [qw( sakila language     )],
   [qw( sakila payment      )],
   [qw( sakila rental       )],
   [qw( sakila staff        )],
   [qw( sakila store        )],
];

# ############################################################################
# "Resume" from empty repl table.
# ############################################################################

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume)) },
);

$row = $master_dbh->selectall_arrayref('select db, tbl from percona.checksums order by db, tbl');
is_deeply(
   $row,
   $all_sakila_tables,
   "Resume from empty repl table"
);

# ############################################################################
# Resume when all tables already done.
# ############################################################################

# Timestamps shouldn't change because no rows should be updated.
$row = $master_dbh->selectall_arrayref('select ts from percona.checksums order by db, tbl');

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume)) },
);

is(
   $output,
   "",
   "Resume with nothing to do"
);

is_deeply(
   $master_dbh->selectall_arrayref('select ts from percona.checksums order by db, tbl'),
   $row,
   "Timestamps didn't change"
);

# ############################################################################
# Resume from a single chunk table.  So, resume should really start with
# next table.
# ############################################################################
load_data_infile("sakila-done-singles", "ts='2011-10-15 13:00:16'");
$master_dbh->do("delete from percona.checksums where ts > '2011-10-15 13:00:04'");

$row = $master_dbh->selectall_arrayref('select db, tbl from percona.checksums order by db, tbl');
is_deeply(
   $row,
   [
      [qw( sakila actor         )],
      [qw( sakila address       )],
      [qw( sakila category      )],
      [qw( sakila city          )],
   ],
   "Checksum results for 1/4 of sakila singles"
);

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume)) },
   trf => sub { return PerconaTest::normalize_checksum_results(@_) },
);

$row = $master_dbh->selectall_arrayref('select db, tbl from percona.checksums order by db, tbl');
is_deeply(
   $row,
   $all_sakila_tables,
   "Resume finished sakila"
);

# XXX This may not be a stable test if your machine isn't fast enough
# to do these remaining tables as single chunks.
is(
   $output,
"ERRORS DIFFS ROWS CHUNKS SKIPPED TABLE
0 0 109 1 0 sakila.country
0 0 599 1 0 sakila.customer
0 0 1000 1 0 sakila.film
0 0 5462 1 0 sakila.film_actor
0 0 1000 1 0 sakila.film_category
0 0 1000 1 0 sakila.film_text
0 0 4581 1 0 sakila.inventory
0 0 6 1 0 sakila.language
0 0 16049 1 0 sakila.payment
0 0 16044 1 0 sakila.rental
0 0 2 1 0 sakila.staff
0 0 2 1 0 sakila.store
",
   "Resumed from next table"
);

# ############################################################################
# Resume from the middle of a table that was being chunked.
# ############################################################################
load_data_infile("sakila-done-1k-chunks", "ts='2011-10-15 13:00:57'");
$master_dbh->do("delete from percona.checksums where ts > '2011-10-15 13:00:28'");

my $first_half = [
   [qw(sakila actor 1 200 )],
   [qw(sakila address 1 603 )],
   [qw(sakila category 1 16 )],
   [qw(sakila city 1 600 )],
   [qw(sakila country 1 109 )],
   [qw(sakila customer 1 599 )],
   [qw(sakila film 1 1000 )],
   [qw(sakila film_actor 1 1000 )],
   [qw(sakila film_actor 2 1000 )],
   [qw(sakila film_actor 3 1000 )],
   [qw(sakila film_actor 4 1000 )],
   [qw(sakila film_actor 5 1000 )],
   [qw(sakila film_actor 6 462 )],
   [qw(sakila film_category 1 1000 )],
   [qw(sakila film_text 1 1000 )],
   [qw(sakila inventory 1 1000 )],
   [qw(sakila inventory 2 1000 )],
   [qw(sakila inventory 3 1000 )],
   [qw(sakila inventory 4 1000 )],
   [qw(sakila inventory 5 581 )],
   [qw(sakila language 1 6 )],
   [qw(sakila payment 1 1000 )],
   [qw(sakila payment 2 1000 )],
   [qw(sakila payment 3 1000 )],
   [qw(sakila payment 4 1000 )],
   [qw(sakila payment 5 1000 )],
   [qw(sakila payment 6 1000 )],
   [qw(sakila payment 7 1000 )],
];

$row = $master_dbh->selectall_arrayref('select db, tbl, chunk, master_cnt from percona.checksums order by db, tbl');
is_deeply(
   $row,
   $first_half,
   "Checksum results through sakila.payment chunk 7"
);

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume),
      qw(--chunk-time 0)) },
   trf => sub { return PerconaTest::normalize_checksum_results(@_) },
);

$row = $master_dbh->selectall_arrayref('select db, tbl, chunk, master_cnt from percona.checksums order by db, tbl');
is_deeply(
   $row,
   [
      @$first_half,
      [qw(sakila payment 8 1000 )],
      [qw(sakila payment 9 1000 )],
      [qw(sakila payment 10 1000 )],
      [qw(sakila payment 11 1000 )],
      [qw(sakila payment 12 1000 )],
      [qw(sakila payment 13 1000 )],
      [qw(sakila payment 14 1000 )],
      [qw(sakila payment 15 1000 )],
      [qw(sakila payment 16 1000 )],
      [qw(sakila payment 17 49 )],
      [qw(sakila rental 1 1000 )],
      [qw(sakila rental 2 1000 )],
      [qw(sakila rental 3 1000 )],
      [qw(sakila rental 4 1000 )],
      [qw(sakila rental 5 1000 )],
      [qw(sakila rental 6 1000 )],
      [qw(sakila rental 7 1000 )],
      [qw(sakila rental 8 1000 )],
      [qw(sakila rental 9 1000 )],
      [qw(sakila rental 10 1000 )],
      [qw(sakila rental 11 1000 )],
      [qw(sakila rental 12 1000 )],
      [qw(sakila rental 13 1000 )],
      [qw(sakila rental 14 1000 )],
      [qw(sakila rental 15 1000 )],
      [qw(sakila rental 16 1000 )],
      [qw(sakila rental 17 44 )],
      [qw(sakila staff 1 2 )],
      [qw(sakila store 1 2 )],
   ],
   "Resume finished sakila"
);

is(
   $output,
"Resuming from sakila.payment chunk 7, timestamp 2011-10-15 13:00:28
ERRORS DIFFS ROWS CHUNKS SKIPPED TABLE
0 0 9049 10 0 sakila.payment
0 0 16044 17 0 sakila.rental
0 0 2 1 0 sakila.staff
0 0 2 1 0 sakila.store
",
   "Resumed from sakila.payment chunk 7"
);

# ############################################################################
# Resume from the end of a finished table that was being chunked.
# ############################################################################
load_data_infile("sakila-done-1k-chunks", "ts='2011-10-15 13:00:57'");
$master_dbh->do("delete from percona.checksums where ts > '2011-10-15 13:00:38'");

$row = $master_dbh->selectall_arrayref('select db, tbl, chunk, master_cnt from percona.checksums order by db, tbl');
is_deeply(
   $row,
   [
      @$first_half,
      [qw(sakila payment 8 1000 )],
      [qw(sakila payment 9 1000 )],
      [qw(sakila payment 10 1000 )],
      [qw(sakila payment 11 1000 )],
      [qw(sakila payment 12 1000 )],
      [qw(sakila payment 13 1000 )],
      [qw(sakila payment 14 1000 )],
      [qw(sakila payment 15 1000 )],
      [qw(sakila payment 16 1000 )],
      [qw(sakila payment 17 49 )],
   ],
   "Checksum results through sakila.payment"
);

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume),
      qw(--chunk-time 0)) },
   trf => sub { return PerconaTest::normalize_checksum_results(@_) },
);

$row = $master_dbh->selectall_arrayref('select db, tbl, chunk, master_cnt from percona.checksums order by db, tbl');
is_deeply(
   $row,
   [
      @$first_half,
      [qw(sakila payment 8 1000 )],
      [qw(sakila payment 9 1000 )],
      [qw(sakila payment 10 1000 )],
      [qw(sakila payment 11 1000 )],
      [qw(sakila payment 12 1000 )],
      [qw(sakila payment 13 1000 )],
      [qw(sakila payment 14 1000 )],
      [qw(sakila payment 15 1000 )],
      [qw(sakila payment 16 1000 )],
      [qw(sakila payment 17 49 )],
      [qw(sakila rental 1 1000 )],
      [qw(sakila rental 2 1000 )],
      [qw(sakila rental 3 1000 )],
      [qw(sakila rental 4 1000 )],
      [qw(sakila rental 5 1000 )],
      [qw(sakila rental 6 1000 )],
      [qw(sakila rental 7 1000 )],
      [qw(sakila rental 8 1000 )],
      [qw(sakila rental 9 1000 )],
      [qw(sakila rental 10 1000 )],
      [qw(sakila rental 11 1000 )],
      [qw(sakila rental 12 1000 )],
      [qw(sakila rental 13 1000 )],
      [qw(sakila rental 14 1000 )],
      [qw(sakila rental 15 1000 )],
      [qw(sakila rental 16 1000 )],
      [qw(sakila rental 17 44 )],
      [qw(sakila staff 1 2 )],
      [qw(sakila store 1 2 )],
   ],
   "Resume finished sakila"
);

is(
   $output,
"ERRORS DIFFS ROWS CHUNKS SKIPPED TABLE
0 0 16044 17 0 sakila.rental
0 0 2 1 0 sakila.staff
0 0 2 1 0 sakila.store
",
   "Resumed from end of sakila.payment"
);

# ############################################################################
# Resume when master_crc wasn't updated.
# ############################################################################
load_data_infile("sakila-done-1k-chunks", "ts='2011-10-15 13:00:57'");
$master_dbh->do("delete from percona.checksums where ts > '2011-10-15 13:00:50'");
$master_dbh->do("update percona.checksums set master_crc=NULL, master_cnt=NULL, ts='2011-11-11 11:11:11' where db='sakila' and tbl='rental' and chunk=12");

# Checksum table now ends with:
#    *************************** 49. row ***************************
#    db: sakila
#    tbl: rental
#    chunk: 11
#    chunk_time: 0.006462
#    chunk_index: PRIMARY
#    lower_boundary: 10005
#    upper_boundary: 11004
#    this_crc: d2ad38b8
#    this_cnt: 1000
#    master_crc: d2ad38b8
#    master_cnt: 1000
#    ts: 2011-10-15 13:00:49
#    *************************** 50. row ***************************
#    db: sakila
#    tbl: rental
#    chunk: 12
#    chunk_time: 0.00984
#    chunk_index: PRIMARY
#    lower_boundary: 11005
#    upper_boundary: 12004
#    this_crc: 3b07b7a1
#    this_cnt: 1000
#    master_crc: NULL
#    master_cnt: NULL
#    ts: 2011-11-07 10:45:20
# This ^ last row is bad because master_crc and master_cnt are NULL,
# which means the tool was killed before $update_sth was called.  So,
# it should resume from chunk 11 of this table and overwrite chunk 12.

my $chunk11 = $master_dbh->selectall_arrayref('select * from percona.checksums where db="sakila" and tbl="rental" and chunk=11');

my $chunk12 = $master_dbh->selectall_arrayref('select master_crc from percona.checksums where db="sakila" and tbl="rental" and chunk=12');
is(
   $chunk12->[0]->[0],
   undef,
   "Chunk 12 master_crc is null"
);

$output = output(
   sub { pt_table_checksum::main(@args, qw(-d sakila --resume),
      qw(--chunk-time 0)) },
   trf => sub { return PerconaTest::normalize_checksum_results(@_) },
);

$row = $master_dbh->selectall_arrayref('select db, tbl, chunk, master_cnt from percona.checksums order by db, tbl');
is_deeply(
   $row,
   [
      @$first_half,
      [qw(sakila payment 8 1000 )],
      [qw(sakila payment 9 1000 )],
      [qw(sakila payment 10 1000 )],
      [qw(sakila payment 11 1000 )],
      [qw(sakila payment 12 1000 )],
      [qw(sakila payment 13 1000 )],
      [qw(sakila payment 14 1000 )],
      [qw(sakila payment 15 1000 )],
      [qw(sakila payment 16 1000 )],
      [qw(sakila payment 17 49 )],
      [qw(sakila rental 1 1000 )],
      [qw(sakila rental 2 1000 )],
      [qw(sakila rental 3 1000 )],
      [qw(sakila rental 4 1000 )],
      [qw(sakila rental 5 1000 )],
      [qw(sakila rental 6 1000 )],
      [qw(sakila rental 7 1000 )],
      [qw(sakila rental 8 1000 )],
      [qw(sakila rental 9 1000 )],
      [qw(sakila rental 10 1000 )],
      [qw(sakila rental 11 1000 )],
      [qw(sakila rental 12 1000 )],
      [qw(sakila rental 13 1000 )],
      [qw(sakila rental 14 1000 )],
      [qw(sakila rental 15 1000 )],
      [qw(sakila rental 16 1000 )],
      [qw(sakila rental 17 44 )],
      [qw(sakila staff 1 2 )],
      [qw(sakila store 1 2 )],
   ],
   "Resume finished sakila"
);

is(
   $output,
"Resuming from sakila.rental chunk 11, timestamp 2011-10-15 13:00:49
ERRORS DIFFS ROWS CHUNKS SKIPPED TABLE
0 0 5044 6 0 sakila.rental
0 0 2 1 0 sakila.staff
0 0 2 1 0 sakila.store
",
   "Resumed from last updated chunk"
);

is_deeply(
   $master_dbh->selectall_arrayref('select * from percona.checksums where db="sakila" and tbl="rental" and chunk=11'),
   $chunk11,
   "Chunk 11 not updated"
);

$chunk12 = $master_dbh->selectall_arrayref('select master_crc, master_cnt from percona.checksums where db="sakila" and tbl="rental" and chunk=12');
ok(
   defined $chunk12->[0]->[0],
   "Chunk 12 master_crc updated"
);

# #############################################################################
# Done.
# #############################################################################
$sb->wipe_clean($master_dbh);
exit;
