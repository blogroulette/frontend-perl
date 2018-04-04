#!/usr/bin/env perl
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
 
my $server_endpoint = "http://localhost:8080/blogroulette-jee/";
my $endpoint = "GetMessage";
my $post_data = '';

if($ARGV[0] eq ""){
	
}elsif($ARGV[0] eq "write"){
	if(scalar @ARGV != 3){&error();}
	$endpoint ="AddMessage";
	$post_data = '{"title":"'.$ARGV[1].'","text":"'.$ARGV[2].'"}';
}elsif($ARGV[0] eq "comment"){
	if(scalar @ARGV != 3){&error();}
	$endpoint ="AddComment";
	$post_data = '{"messageid":"'.$ARGV[1].'","text":"'.$ARGV[2].'"}';
}
else {
	&error();
}

# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => ${server_endpoint}.${endpoint});
$req->header('content-type' => 'application/json');
$req->content($post_data);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    print "Received reply: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}

sub error {
	print "Available Commands: \n",
	"write [title] [text]\n",
	"comment [Message-Id] [text]\n";
	exit 0;
}
