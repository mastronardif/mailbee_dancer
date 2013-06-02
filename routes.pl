#!/usr/bin/perl
use jm002ra;

get '/jm/:name' => sub {
    template 'jm' => { number => 42 };
};

any '/jm/publish22' => sub {
	debug Data::Dump::dump(params);
	debug "publish22 is a debug message from my app.";
	my $dbg = "File: ". __FILE__. " Line: ". __LINE__. "\n";
	#my $env = " wwwwww " . $dbg. Data::Dump::dump(params). jm002ra:reply(\params);
	#params hash reference to all defined parameters
	
	my %allparams = params;
	#my $env = " www " . Data::Dump::dump(%allparams) . jm002ra::reply(\%allparams);
	my $msg; # = jm002ra::reply(\%allparams);
	my $op = param('Operation');
	if ($op =~ m/ Net::RabbitFoot/i)
	{
		$msg = jm002ra::reply(\%allparams);
		$msg = jm002ra::RabbitFootPublish($msg);
	}

	if ($op =~ m/ my_gmail/i)
	{
		$msg = jm002ra::sendtogmail(\%allparams);
		$msg = jm002ra::RabbitFootPublish($msg);
	}
	
	if ($op =~ m/VCAP_SERVICES/i)
	{
		$msg = jm002ra::RabbitVCAP_SERVICES();
	}
	
	if ($op =~ m/flush/i)
	{
		$msg = jm002ra::RabbitVCAP_SERVICES();
	}
	if ($op =~ m/each/i)
	{
		$msg = Data::Dump::dump(params);
	}

	
	# something wrong w/ anyRabbitmq somekind of blocking thing. my $msg2 = jm002ra::myinitRabbitmqAndPublish($msg);
	my $env = " ww <br/>" . $msg;

    template 'jm' => { number => $env };
};