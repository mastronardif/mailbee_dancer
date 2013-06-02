#!/usr/bin/perl -w
package jm002ra;

use CGI qw(:standard escapeHTML);
use JSON; # imports encode_json, decode_json, to_json and from_json.
use AnyEvent::RabbitMQ;
use Net::RabbitFoot;
use Test::More;
use Test::Exception;
use JSON::Parse 'json_to_perl';
use strict;

#Last Modified: September 18, 2012

########use strict "vars";
use warnings;

sub RabbitVCAP_SERVICES
{

   my ($host, $port, $user, $pass, $vhost);
   my $retval;
   # Extract and convert the JSON string in the VCAP_SERVICES environment var$
   my $vcap_services = json_to_perl ($ENV{'VCAP_SERVICES'});

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

$retval = <<EOF;
host  = $host
port  = $port
user  = $user
pass  = $pass
vhost = $vhost
EOF

	return $retval;
}


sub RabbitFootPublish
{
	my $msg = shift;
	my $retval;

my ($host, $port, $user, $pass, $vhost);

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

my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
    host =>  $host,
    port =>  $port,
    user =>  $user,
    pass =>  $pass,
    vhost => $vhost,
);


my $chan = $conn->open_channel();

$chan->publish(
	queue       => 'test_q',
    exchange    => 'test_x',
    routing_key => 'test_r',
    body => $msg,
);

my $tag = "message $msg";
if ($tag =~ m/<tags>(.*?)<\/tags>/im)
{
   $tag = $1;
}


$retval = "Queued $tag\n";

$conn->close();

	return $retval;
}

sub myinitRabbitmqAndPublish
{
	my $qs = shift;
	my $retval;
my $cv = AnyEvent->condvar;
my $ar = AnyEvent::RabbitMQ->new();

my %server = (
    product => undef,
    version => undef,
);

my ($host, $port, $user, $pass, $vhost);

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


my %conf = (
    host  => $host,  #'192.168.1.202',
    port  => $port,  #10001,
    user  => $user,  #'uDgekqrjVnomr',
    pass  => $pass,  #'pWLmImc8vSe3V',
    vhost => $vhost, #'v53ff409b719144eeba276a6d5df4e6cb',
);

#print "\nport = $port<br/>\n"; exit;

lives_ok sub {
    $ar->load_xml_spec()
}, 'load xml spec';



my $query = new CGI;

my $debug = param "debug" || "";

my $myOutpath= '.'; ##'/usr/home/pl1321/JSAdmin/log';
my $mypath    ='perl .'; # 'perl /usr/www/users/pl1321/cgi-bin';
my $fn =  "$myOutpath/cloudmail.txt";
#my $fnMailGun =  "$myOutpath/mailgun.txt";
#my $fnMail="$mypath/mailgun.txt";



$debug=102;
my $DBG;
if ($debug)
{
     open($DBG, ">>$fn") || die print "can not open($fn)$!";
     print $DBG "\n***\nlocaltime: ". localtime() ."\n";
###	 exit;
}

#my $params = "wtf";
#$qs = &reply($params);

if ($debug)
{

#print $qs;
#print ("<br/>F(12)\n\$qs = $qs\n");
if ($DBG){ close($DBG); }
#exit;
}

#$ENV{'WTF'} = $qs;
my $done = AnyEvent->condvar;

#1
$ar->connect(
    (map {$_ => $conf{$_}} qw(host port user pass vhost)),
    timeout    => 1,
    on_success => sub {
        my $ar = shift;
        isa_ok($ar, 'AnyEvent::RabbitMQ');
        $server{product} = $ar->server_properties->{product};
        $server{version} = version->parse($ar->server_properties->{version});
        $done->send;
    },
    on_failure => failure_cb($done),
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    },
);

$done->recv;
#2
$done = AnyEvent->condvar;
my $ch;
$ar->open_channel(
    on_success => sub {
        $ch = shift;
        isa_ok($ch, 'AnyEvent::RabbitMQ::Channel');
        $done->send;
    },
    on_failure => failure_cb($done),
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    },
);
$done->recv;

$done = AnyEvent->condvar;
$ch->declare_exchange(
    exchange   => 'test_x',
    on_success => sub {
        pass('declare exchange');
        $done->send;
    },
    on_failure => failure_cb($done),
);
$done->recv;

$done = AnyEvent->condvar;
$ch->declare_queue(
    queue      => 'test_q',
    on_success => sub {
        pass('declare queue');
        $done->send;
    },
    on_failure => failure_cb($done),
);
$done->recv;
$done = AnyEvent->condvar;
$ch->bind_queue(
    queue       => 'test_q',
    exchange    => 'test_x',
    routing_key => 'test_r',
    on_success  => sub {
        pass('bound queue');
        $done->send;
    },
    on_failure => failure_cb($done),
);
$done->recv;


#$done = AnyEvent->condvar;
#publish($ch, 'I love RabbitMQ.', $done,);

# push to RabbitMQ
publish($ch, $qs, $done,);

#fm 9/13/12

$done = AnyEvent->condvar;
$ar->close(
    on_success => sub {
        pass('close');
        $done->send;
    },
    on_failure => failure_cb($done),
);
$done->recv;

#fm 9/13/12


if ($DBG)
{
   close($DBG);
}
	$retval = "Well...  Did it work?";
	return $retval;
}
 
sub publish {
    my ($ch, $message, $cv,) = @_;

    $ch->publish(
        exchange    => 'test_x',
        routing_key => 'test_r',
        body        => $message,
        on_return   => sub {
            my $response = shift;
            fail('on_return: ' . Dumper($response));
            $cv->send;
        },
    );

   $cv->recv;  # 9/12/12 
   return;
}

sub failure_cb {
    my ($cv,) = @_;
    return sub {
        fail(join(' ', 'on_failure:', @_));
        $cv->send;
    };
}



sub makeReplyFromMailGun
{
    my $query = shift;
	my $retval = "from Mailgun\n";
	#$retval = Data::Dump::dump($query);

  my $subject = $query->{'Subject'} || "";
  
#  my $Action = 'DECORATE'; #default Decorate or Joemailweb
#  if ($subject =~ m/joemailweb/i)
#  {
#     $Action = 'JOEMAILWEB';
#  }

     my $buf;
     $buf = "";
     #my $header = $query{'message-headers'};
	 my $header = $query->{'message-headers'};

	 my @decoded_json = @{decode_json($header)};

	 $retval .= "\n<MYMAIL>\n<HEADER>\n";

	 my $mailheader;
	foreach my $item(@decoded_json )
	{
    	my @FFF = ($item);
		   
		# Create the reply header. see testmymbox03.pl
		# From: become To:
		# Todo reomve whitelist from the Cc: field

		if ($FFF[0][0] =~ /^Message-Id$/i)
		{
			$retval .=  "$FFF[0][0]: fm $FFF[0][1]\n";
			next;
		}

		#Make the reply - To: is set to original sernder, From: is set to orignal joemail host.
		if ($FFF[0][0] =~ m/^From$/i)
		{
			my $recp = $query->{'recipient'}; # "joemail\@joeschedule.com"; #$query->param('recipient');
			$retval .=  "$FFF[0][0]:  $recp \n";
			next;
		}

		if ($FFF[0][0] =~ m/^To$/i)
		{
			my $sender =  $query->{'sender'};
			$retval .=  "$FFF[0][0]:  $sender\n";
			next;
		}
           $mailheader .= "$FFF[0][0]: $FFF[0][1]\n";
    };

   #my $Reply
   # I don't know for some reason mailgun does not set this filed.
   $mailheader .= 'Content-Type: text/html; charset="UTF-8"';

   $retval .=  "$mailheader\n";
   $retval .=  "\n</HEADER>\n";

   my $body = $query->{'body-html'};
   if (!$body){
      $body = $query->{'body-plain'};
   }

   $retval .=  $body;

   $retval .=  "\n</MYMAIL>\n";
  
  return $retval;
}

sub sendtogmail
{
	my $query = shift;
	my $tagValue = $query->{'message'};
	
my $retval = <<EOF;	
<MYMAIL>
<HEADER>
From: jimmy\@joeschedule.mailgun.org
To: Frank Mastronardi <mastronardif\@gmail.com>
Subject: dancer bee joemailweb
In-Reply-To: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsAmail.gmail.com>
References: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsAmail.gmail.com>
Message-Id: <FU uddy mailbox-19950-1311902078-753076ww3.pairlite.com>
Date: Thu, 13 Oct 2011 21:14:38 -0400
MIME-Version: 1.0
Content-Type: text/html; charset="UTF-8"

</HEADER>

<tags>
'$tagValue'
</tags>

</MYMAIL>	
EOF

	return $retval;
}

sub reply {
    my $query = shift;
	my $retval;
	#$retval = Data::Dump::dump($query);
	
	my $header = $query->{'message-headers'};
    if ($header)
    {
		return makeReplyFromMailGun($query);
	}

	#$retval .=  "<br/> - - -  - - - <br/>";

	#my @flds11 = qw(To From Subject Body);
	my %flds;
	my $fldnms = "To From Subject body-plain";
	foreach (qw(To From Subject body-plain)) {
		$flds{$_} = 1;
	};
	my $iMailFlds = 0;
   
	foreach (keys %{$query}) {
      $retval .=  "<STRONG>$_</STRONG> -> ";
      
	  
	  my $list = $query->{$_};
	  
	  if ( UNIVERSAL::isa($list,'ARRAY') )
	  {
	     my @values = $query->{$_};
	     $list = "";
	     foreach (@values) {
	     my $f =  $_;
			$list .= join ", ", @$f ;
	     }
	  }
	  
	  #if (m/To|From|Subject|Body/i)
	  if (exists $flds{$_})
	  {
		$iMailFlds++;
		$flds{$_} = $list;
	  }

      $retval .= $list ."\n";    
	}
  
   if (keys( %flds ) == $iMailFlds)
   {
		#$retval = "";
		#foreach ( split(' ',$fldnms))
		#{
		#	$retval .= $_ . ": " . $flds{$_} . "\n";
		#}
my $ret = <<EOF;

<MYMAIL> 
<HEADER>
From: $flds{'From'}
To: $flds{'To'}
Subject: $flds{'Subject'}

</HEADER>
$flds{'body-plain'}

</MYMAIL>
EOF

	return $ret;     
   }

  return $retval; 
}
1;