#!/usr/bin/perl

use Tie::Cache::LRU::Array;
use Tie::Cache::LRU::LinkedList;
use Tie::Cache;
use Benchmark;
use vars qw($Size %tie_cache %count_cache %linked_cache);
use strict;

$Size = 20000;
$| = 1;

sub report {
    my($desc, $count, $sub) = @_;
#    return if $desc =~ /Tie::Cache([^:]|$)/;
    my $timed = timestr(timeit($count, $sub));
    $timed =~ /([\d\.]+\s+cpu)/i;
    printf("%-65.65s %s\n", "[ timing ] $desc", $1);
}


tie %count_cache, 'Tie::Cache::LRU::Array', $Size;
tie %tie_cache, 'Tie::Cache', $Size;
tie %linked_cache, 'Tie::Cache::LRU::LinkedList', $Size;

my %normal;

print "++++ Benchmarking operations on cache of size $Size\n\n";
my $i = 0;
report("insert of $Size elements into normal %hash", $Size,
       sub { $normal{++$i} = $i }
      );
$i = 0;
report("insert of $Size elements into Tie::Cache::LRU::Array", $Size,
       sub { $count_cache{++$i} = $i }
       );
$i = 0;
report("insert of $Size elements into Tie::Cache::LRU::LinkedList", $Size,
       sub { $linked_cache{++$i} = $i }
       );
$i = 0;
report("insert of $Size elements into Tie::Cache", $Size,
       sub { $tie_cache{++$i} = $i }
       );


my $rv;
$i = 0;
report("reading $Size elements from normal %hash", 
       $Size, sub { $rv = $normal{++$i} } );
$i = 0;
report("reading $Size elements from Tie::Cache::LRU::Array", 
       $Size, sub { $rv = $count_cache{++$i} } );
$i = 0;
report("reading $Size elements from Tie::Cache::LRU::LinkedList", 
       $Size, sub { $rv = $linked_cache{++$i} } );
$i = 0;
report("reading $Size elements from Tie::Cache", 
       $Size, sub { $rv = $tie_cache{++$i} } );


$i = 0;
report("deleting $Size elements from normal %hash",
       $Size, sub { $rv = delete $normal{++$i} } );
$i = 0;
report("deleting $Size elements from Tie::Cache::LRU::Array",
       $Size, sub { $rv = delete $count_cache{++$i} }
       );
$i = 0;
report("deleting $Size elements from Tie::Cache::LRU::LinkedList",
       $Size, sub { $rv = delete $linked_cache{++$i} }
       );
$i = 0;
report("deleting $Size elements from Tie::Cache",
       $Size, sub { $rv = delete $tie_cache{++$i} }
       );


my $over = $Size * 2;
$i = 0;
%count_cache = ();
%tie_cache = ();
%linked_cache = ();
report(
       "$over inserts overflowing Tie::Cache::LRU::Array", 
       $over,
       sub { $count_cache{++$i} = $i; }
      );
$i = 0;
report(
       "$over inserts overflowing Tie::Cache::LRU::LinkedList", 
       $over,
       sub { $linked_cache{++$i} = $i; }
      );
$i = 0;
report(
       "$over inserts overflowing MaxCount Tie::Cache", 
       $over,
       sub { $tie_cache{++$i} = $i; }
      );

$i = 0;
report(
       "$over reads from overflowed Tie::Cache::LRU::Array",
       $over,
       sub { $count_cache{++$i} }
      );
$i = 0;
report(
       "$over reads from overflowed Tie::Cache::LRU::LinkedList",
       $over,
       sub { $linked_cache{++$i} }
      );
$i = 0;
report(
       "$over reads from overflowed MaxCount Tie::Cache",
       $over,
       sub { $tie_cache{++$i} }
      );


report(
       "$over undef inserts, Tie::Cache::LRU::Array",
       $over,
       sub { $count_cache{rand()} = undef; }
      );

report(
       "$over undef inserts, Tie::Cache::LRU::LinkedList",
       $over,
       sub { $linked_cache{rand()} = undef; }
      );

report(
       "$over undef inserts, MaxCount Tie::Cache",
       $over,
       sub { $tie_cache{rand()} = undef; }
      );


report(
       "$over undef reads, Tie::Cache::LRU::Array",
       $over,
       sub { $count_cache{rand()}; }
      );

report(
       "$over undef reads, Tie::Cache::LRU::LinkedList",
       $over,
       sub { $linked_cache{rand()}; }
      );

report(
       "$over undef reads, MaxCount Tie::Cache",
       $over,
       sub { $tie_cache{rand()}; }
      );
