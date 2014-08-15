#!/usr/bin/perl
# os/2 client built to send simple perl scripts over a des
# encrypted socket connection. Hacked from the 'Camel book'
# server and client scripts. Modifications are mostly to
# deal with 'fork()'ed processes not inheriting socket handles
# (hence the use of a second socket address for the reply!)
# Use of des is just for an interesting example, and to test
# use of piped io.

($them,$port) = @ARGV;
$port = 12345678 unless $port;
$port2 = 12345679 ;
$them = 'localhost' unless $them;

$AF_INET = 2;
$SOCK_STREAM = 1;

$SIG{'INT'} = 'dokill';
sub dokill {
    kill 9,$child if $child;
}

$sockaddr = 'S n a4 x8';

chop($hostname = `hostname`);

($name,$aliases,$proto) = getprotobyname('tcp');
($name,$aliases,$port) = getservbyname($port,'tcp')
    unless $port =~ /^\d+$/;;
($name,$aliases,$type,$len,$thisaddr)=gethostbyname($hostname);
($name,$aliases,$type,$len,$thataddr) = gethostbyname($them);

$this = pack($sockaddr, $AF_INET, 0, $thisaddr);
$that = pack($sockaddr, $AF_INET, $port, $thataddr);

# Make the socket filehandle.

if (socket(S, $AF_INET, $SOCK_STREAM, $proto)) { 
    print "socket ok\n";
}
else {
    warn $!;
}

# Give the socket an address.

if (bind(S, $this)) {
    print "bind ok\n";
}
else {
    warn $!;
}

# Call up the server.

if (connect(S,$that)) {
    print "connect ok\n";
}
else {
    die $!;
}

# Set socket to be command buffered.

select(S); $| = 1; select(STDOUT);

# Avoid deadlock by forking.

#if($child != fork) {
    while (<STDIN>) {
	print S;
    }
    close(S);
    sleep 2;
    print "done sending\n";
#Accept call back to check reply

$this2 = pack($sockaddr, $AF_INET, $port2, "\0\0\0\0");

select(NS); $| = 1; select (stdout);

socket(S2, $AF_INET, $SOCK_STREAM, $proto) || die "socket: $!";
bind(S2,$this2) || die "bind: $!";
listen(S2,5) || die "connect: $!";

select(S2); $| = 1; select(stdout);

print "Listening for reply on $port2 ....\n";
#for(;;) {
    ($addr = accept(NS,S2)) || die $!;


    @list = <NS>;
	print "@list \n";
    
close (NS);

    sleep 2;
    do dokill();

