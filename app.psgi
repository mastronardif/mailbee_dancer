use Dancer;
#########use Template;
#use Dancer::Template;
#use Dancer::Template::TemplateToolkit;
require "./t.pl";
require "./routes.pl";
set serializer => 'JSON';

  get '/' => sub { template 'hello' };

# declare routes/actions
any '/' => sub {
    "Hello Dancer World";
};

any '/myaction' => sub {
    # code
	"I take POST's and GET's";
};

get '/json/' => sub {
    { foo => 42,
      number => 100234,
      list => [qw(one two three)],
    }
};

post '/get' => sub {
	my $results = msg_get(param('message'));
	debug "/get \$results = $results";

    template 'hello' => { number => $results };
};  

get '/get/:message' => sub {
    template 'hello' => { number => 42 };
};  


get '/publish/:message' => sub {
    template 'hello' => { number => 142 };
}; 

any '/env' => sub {
	"RabbitMQ env = " . &env();
};
 
any '/publish' => sub {
   #session('msg') = "sss"; #(param('message') || "you did not write a msg!");
   msg_put(param('message'));
"Hello there " . (param('message') || "whoever you are!").	&reply(params)."<br/>". Data::Dump::dump(params);
#    template 'hello' => { number => 42 };
};  


get '/rabbit/:name' => sub {
    template 'rabbit' => { number => 42 };
}; 



get '/hello/:name?' => sub {
    "Hello there " . (param('name') || "whoever you are!");
};
 
get '/hello/:name' => sub {
#get '/' => sub { "hello world!" };
    template 'hello' => { number => 42 };
};
dance;