#!/usr/bin/perl
#use jm002ra;
use JSON;
#use JSON::Parse; # 'json_to_perl';
use JSON::Parse 'json_to_perl';
my $vcap_services = json_to_perl ("asdfasdfasdf");

my @flds = qw(To From Subject Body);

print @flds;
print scalar @flds;

my %elements;
  foreach (qw(To From Subject Body)) {
    $elements{$_} = 1;
  };
  
  my $element = "From";
   print "Found '$element'\n" if (exists $elements{$element});

my $a;
$a =<<END;
Some stuff
goes here.
END
