# os/2 server built to run simple perl scripts from a des
# encrypted socket connection. Hacked from the 'Camel book'
# server and client scripts. Modifications are mostly to 
# deal with 'fork()'ed processes not inheriting socket handles
# (hence the use of a second socket address for the reply!)
# Use of des is just for an interesting example, and to test
# use of piped io.

#print "tell me a secret to decrypt the socket: \033[47m";
#$sec=(<>);
#print "\033[44m";

($port) = @ARGV;
$port = 12345678 unless $port;
$port2 = 12345679 ;

$AF_INET = 2;
$SOCK_STREAM = 1;

$sockaddr = 'S n a4 x8';

($name, $aliases, $proto) = getprotobyname('tcp');
if ($port !~ /^\d+$/) {
    ($name, $aliases, $port) = getservbyport($port, 'tcp');
}

print "Port = $port\n";

$this = pack($sockaddr, $AF_INET, $port, "\0\0\0\0");

select(NS); $| = 1; select (stdout);

socket(S, $AF_INET, $SOCK_STREAM, $proto) || die "socket: $!";
bind(S,$this) || die "bind: $!";
listen(S,5) || die "connect: $!";


select(S); $| = 1; select(stdout);

$con = 0;
print "Listening for connection 1....\n";
for(;;) {


    ($addr = accept(NS,S)) || die $!;

    $con++;
    if (($child[$con] = fork()) == 0) {
	print "accept ok\n";

	($af,$port,$inetaddr) = unpack($sockaddr,$addr);
	@inetaddr = unpack('C4',$inetaddr);
	print "$con: $af $port @inetaddr\n";

	@cyphert = <NS>;
	open (C_TEMP, ">$ENV{TMP}/tmp$$") || warn "cant open TEMP ";
	print C_TEMP @cyphert;
	close C_TEMP;
#	while (<NS>) {
#	    print SPIPE "$_";
#	}

	print STDERR "$port \n";
	open (SPIPE, "des -dk test $ENV{TMP}/tmp$$ |");
	@clear = <SPIPE>;
	close SPIPE;
	$des_return = $?;
	unlink "$ENV{TMP}/tmp$$" || warn "couldn't unlink cypher_temp $!";

#Call back the client and indicate result

chop($hostname = `hostname`);

($name,$aliases,$proto) = getprotobyname('tcp');
($name,$aliases,$port2) = getservbyname($port2,'tcp')
    unless $port2 =~ /^\d+$/;;
($name,$aliases,$type,$len,$thisaddr)=gethostbyname($hostname);
($name,$aliases,$type,$len,$thataddr) = gethostbyname($them);

$this2 = pack($sockaddr, $AF_INET, 0, $thisaddr2);
$that = pack($sockaddr, $AF_INET, $port2, $thataddr);

# Make the socket filehandle.

if (socket(S2, $AF_INET, $SOCK_STREAM, $proto)) { 
    print "socket ok\n";
}
else {
    warn $!;
}

# Give the socket an address.

if (bind(S2, $this2)) {
    print "bind ok\n";
}
else {
    warn $!;
}

# Call up the server.

sleep 2;
if (connect(S2,$that)) {
    print "connect ok\n";
}
else {
    warn $!;
}

# Set socket to be command buffered.

select(S2); $| = 1; select(STDOUT);


	if ($des_return==0){
		print S2 "succeeded !!\n";
	}
	else {
		printf S2 "failed \007 \007 %12.8lx !!\n", $des_return;
	}
	close(NS);
    $rslt=0;
	if ($des_return==0){
        foreach $line(@clear){
		      eval $line;
        }
   	}
	close(S2);
    exit;
    }
    close (NS);
    printf("Listening for connection %d\n",$con+1);

}

