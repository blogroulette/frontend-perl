#!/usr/bin/env perl
use LWP::UserAgent;
use JSON::MaybeXS qw(encode_json decode_json);
use IO::Prompter;
use Term::ReadKey;

binmode(STDOUT, ":utf8");

my $ua = LWP::UserAgent->new;
 
my $server_endpoint = "http://localhost:8080/blogroulette-jee/";
my $endpoint = "GetMessage";
my $post_data = '';
my $token='';
if (open(my $fh, '<:encoding(UTF-8)', '.token')) {
  while (my $row = <$fh>) {
    chomp $row;
    $token=$row;
  }
}

if($ARGV[0] eq ""){
	
}elsif($ARGV[0] eq "doc"){
	$post_data='{"messageid":"0"}';
}elsif($ARGV[0] eq "write"){
	if(scalar @ARGV != 3){&error();}
	$endpoint ="AddMessage";
	$post_data = '{"title":"'.$ARGV[1].'","text":"'.$ARGV[2].'"}';
}elsif($ARGV[0] eq "comment"){
	if(scalar @ARGV != 3){&error();}
	$endpoint ="AddComment";
	$post_data = '{"messageid":"'.$ARGV[1].'","text":"'.$ARGV[2].'"}';
}elsif($ARGV[0] eq "vote"){
	if(scalar @ARGV != 3){&error();}
	$endpoint ="VoteMessage";
	$post_data = '{"messageid":"'.$ARGV[1].'","vote":"'.$ARGV[2].'"}';
}elsif($ARGV[0] eq "votecomment"){
	if(scalar @ARGV != 4){&error();}
	$endpoint ="VoteComment";
	$post_data = '{"commentid":"'.$ARGV[2].'","messageid":"'.$ARGV[1].'","vote":"'.$ARGV[3].'"}';
}elsif($ARGV[0] eq "login"){
	$endpoint="Login";
	my $name = $ARGV[1];
	undef @ARGV;
	my $password = prompt 'Password', -echo=>'*';
	$post_data = '{"username":"'.$name.'","password":"'.$password.'"}';
}elsif($ARGV[0] eq "logout"){
	$endpoint="Logout";
	unlink ".token";
}elsif($ARGV[0] eq "register"){
	$endpoint="Register";
	my $p1="p1";
	my $p2="p2";
	my $name = $ARGV[1];
	undef @ARGV;
	do{
		$p1 = prompt 'Password:', -echo => '*';
		$p2 = prompt 'Repeat Password:', -echo => '*';
	}while(!$p1 eq $p2);
	$post_data = '{"username":"'.$name.'","password":"'.$p1.'"}';
}else {
	&error();
}

# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => ${server_endpoint}.${endpoint});
$req->header('content-type' => 'application/json');
$req->header('Authorization' => $token);
$req->content($post_data);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
	my $message = $resp->decoded_content;
	&print_message( $message );
}
else {
	print "HTTP POST error code: ", $resp->code, "\n";
	print "HTTP POST error message: ", $resp->message, "\n";
}

sub print_message {
	my $message = decode_json $_[0];
	if(!$message->{token} eq ""){
		open(my $fh, '>', '.token');
		print $fh $message->{token};
		close $fh;
		print "ok\n";
		return;
	}
	if(!$message->{status} eq ""){
		print $message->{status},"\n";
		if(!$message->{error} eq ""){
	                print $message->{error},"\n";
        	}
		return;
	}
	print $message->{messageid},": ",
	$message->{title}, "\n",
	"\tVotes: ",$message->{votes},"\n",
	"--------------------------------------------------------------------------------\n",
	$message->{text},"\n",
	"--------------------------------------------------------------------------------\n";
	foreach $com (@{$message->{comments}}){
		print "\t",$com->{commentid},": ",$com->{text},
		"\n\t\tVotes: ",$com->{votes},"\n",
		"\t------------------------------------------------------------------------\n";
	}
}

sub error {
	print "Available Commands: \n",
	"write [title] [text] \n\tWrite a Message\n",
	"comment [Message-Id] [text]\n\tComment to a Message\n",
	"vote [Message-Id] up|down\n\tVote to a Message\n",
	"votecomment [Message-Id] [Comment-Id] up|down\n\tVote to a Comment\n",
	"login [username]\n\tLog in to Comment\n",
	"logout \n\tLogout\n",
	"register [username] \n\tRegister a new User\n",
	"doc\n\tGetDocumentation\n";
	exit 0;
}
