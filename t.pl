#!/usr/bin/perl 
use Data::Dump ();
use Data::Dumper;
use JSON::Parse 'json_to_perl';
use strict;

sub msg_put {
   my($query) = @_;
   my(@values,$key);

   return "<H2>msg_put:</H2>" . $query;
}

sub msg_get {
   my($query) = @_;
   my(@values,$key);

   return "<H2>msg_get:</H2>" . $query;
}

sub env
{
	my ($host, $port, $user, $pass, $vhost);
	my $retval;
debug "env is a debug message from my env.";
	if ($ENV{'VCAP_SERVICES'})
	{
		# Extract and convert the JSON string in the VCAP_SERVICES environment var$
		my $vcap_services = json_to_perl ($ENV{'VCAP_SERVICES'});
		$host  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'host'};
		$port  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'port'};
		$user  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'user'};
		$pass  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'pass'};
		$vhost = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'vhost'};
	}
   
   $retval .= "<br />  host -> " . $host . "<br />";
   $retval .= "<br />  port -> " . $port . "<br />";
   $retval .= "<br />  user -> " . $user . "<br />";
   $retval .= "<br />  pass -> " . $pass . "<br />";
   $retval .= "<br />  vhost-> " . $vhost. "<br />";
   return $retval;
}

sub reply {
   my($query) = @_;
   my $retval;
   
   debug Data::Dump::dump(params);
   #my ($key, $value);
   while (my($key, $value) = each(params)){
     $retval .= "<br />" . $key . " -> " . $value . "<br />";
   }
   
   return $retval;
   #my(@values,$key);

   #return Data::Dump::dump(params);
   #return "<H2>What you wrote:</H2>";
=comment
   foreach $key ($query->param) {
      print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";
  }
=cut  
}
1;