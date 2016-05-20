#!/usr/bin/perl


##############################################################
## Author:  Rene Weber
## Purpose: Make SSH/sftp Connects faster
##
## How it works: See Help Function ( -h --help help ) 
## 
## This software comes with ABSOLUTELY NO WARRANTY and is 
## is licensed under the GNU GENERAL PPUBLIC LICENSE 3
## For details, see
## http://www.gnu.org/licenses/gpl.txt
##
##############################################################


# ##########################################################
# Default Values 
# ##########################################################


$conf_file 	= $ENV{"HOME"}.'/goto.ini';

############ DON'T CHANGE ANYTHING BELOW #############



############ Load Config #############

if( ! -f $conf_file ){

	print "\nNo Configuration Found. Adding new Config...\n\n";
	print "Default Username: ";
        my $username = <STDIN>;
        chomp( $username );
	my $svn_dir = '';
	while( !-d "$svn_dir" ){
		print "Path to Folder with multiple goto files: ";
        	$svn_dir = <STDIN>;
        	chomp( $svn_dir );
	}
	print "Path and Name to your private goto file ( will be created if not exists ): ";
        my $links = <STDIN>;
        chomp( $links );

	$config->{'global'}->{'svn_path'} = $svn_dir;
	$config->{'global'}->{'private_links'} = $links;
	$config->{'global'}->{'user'} = $username;
	$config->{'global'}->{'port'} = 22;
	&iniWrite($conf_file, $config );
}


$config = iniRead( $conf_file );

our $svn_link_dir = $config->{'global'}->{'svn_path'};
our $my_links	  = $config->{'global'}->{'private_links'};
our $user	  = $config->{'global'}->{'user'} || 'root';
our $port	  = $config->{'global'}->{'port'} || 22;

if( !-d $svn_link_dir ){
	print "No such directory '$svn_link_dir'. Please edit $conf_file";
	exit 1;
}
if( -d "$svn_link_dir/goto_files" ){
	$svn_link_dir = "$svn_link_dir/goto_files";
}

############ Starting Script itself #############

sub printHelp{

print <<EOF;

Possible calls are:

- goto [mode] <IP> [<USER>] [<PORT>]
- goto [mode] <NAME> [<USER>] [<PORT>] 

IP   : IP Adress. It will be used as is.

PORT : Port, defaults to $port

USER : Username, defaults to $user

NAME : 1. Check for alias Definitions in $my_links file to use
       2. If not found, try to resolve as hostname
       3. If not resolvable, offer possiblity to add new alias entry 

MODE: Possibilities are 'ping' or 'sftp'. 
      sftp  : Open SFTP Connection
       
EOF

}

my $ip   	= undef;
my $hostname 	= undef;
my $connecthost = undef;
my $othermode	= undef;

if ( $ARGV[0] =~ m/help/ || $ARGV[0] =~ m/'-h'/ || $ARGV[0] =~ m/--help/  ) {

	printHelp();
	exit 1;
}

if ( lc $ARGV[0] eq "sftp" ){

	$othermode = "sftp";
	shift( @ARGV );
}

if ( $#ARGV < 0 ){

	print "Usage:\n"; 
	print "\t\tgoto [<MODE>] <Host> [<PORT>] [<USER>]\n"; 
	print "\t\t\t Hostname: IP or Name which may be looked up\n";
	print "\t\t\t Port    : Port of the target machine ( default: 22 )\n";
	print "\t\t\t User    : Username to login with ( default as in Config or root )\n";
	print "\t\t\t Mode    : Mode may be sftp or ping\n";
	print "\t\t\t           sftp  : open sftp connection\n";
	
	print "\n\n\n";

	print "Please enter IP/Hostname:";
	$ARGV[0] = <STDIN>;
	chomp( $ARGV[0] );

	print "\nPlease enter Port/Username/Empty:";
	$ARGV[1] = <STDIN>;
	chomp( $ARGV[1] );

	if ( $ARGV[1] ){
		
		print "\nPlease enter Port/Username/Empty:";
		$ARGV[2] = <STDIN>;
		chomp( $ARGV[2] );
	}
		

}


if ( IsIP( $ARGV[1] ) ){

	$ip = $ARGV[0];
	
}else{

	$hostname = $ARGV[0];
	
}

if ( defined( $ARGV[1] ) && $ARGV[1]  ){

	if ( IsNumeric( $ARGV[1] ) ){
	
		$port = $ARGV[1];
	
	}else{
		
		$user = $ARGV[1];

	}


}


if( defined( $ARGV[2] ) && $ARGV[2] ){

	if( IsNumeric( $ARGV[2] ) ){
		
		$port = $ARGV[2];
	
	}else{

		$user = $ARGV[2];

	}


}


if ( defined( $hostname ) ){

	
	
	$values = ReadFile();
		
	if( !defined( $values->{$hostname} ) ){
	
	    if ( !LookupHostname( $hostname ) ) {
			
		print "\nUnknown Alias. Add to list (y/n)?";
		$answer = <STDIN>;
		chomp( $answer );

		if ( $answer eq 'y' ){
				
		    print "\nIP:";
		    $ip = <STDIN>;
		    chomp( $ip );
		
		    if ( !IsIP( $ip ) ){
				
		        print "\nNo valid IP Adress!!";
				exit 1;
				
		    }

			print "\nPort:";
		    $port = <STDIN>;
		    chomp( $port );

		    if ( !IsNumeric( $port ) ) {

				print "\nNumeric values only!";
				exit 1;
		    }

		    print "\nUser:";
		    $user = <STDIN>;
		    chomp( $user );

			if( IsNumeric( $user ) ){
				
				print "\nUsername should contain Letters!";
				exit 1;

			}

			WriteFile( $hostname, $ip, $port, $user );

			$hostname = undef;
			$connecthost = $ip;
			
			}else{
				exit 1;
			}

		}else{    
		
			$connecthost = $hostname;

		}	
	
	}else{

	    $ip    = $values->{$hostname}->{'ip'};
	    $port  = $values->{$hostname}->{'port'};
	    $user  = $values->{$hostname}->{'user'};

	    $hostname = undef;
		$connecthost = $ip;
	}

	

}else{

	$connecthost = $ip;

}




system("clear");
print "\n******************************************\n";
print "Opening $connecthost : $port as $user";
print "\n******************************************\n";
print "\n";

system("echo \"\033]0;$user\@$connecthost:$port\007\"");

if( $othermode eq "sftp" ){
	
	system("open sftp://$user\@$connecthost:$port");

}else{
	my $keep = 'undef';
	my $keep2 = 'undef';
	my $reachable = system("ping -c1 -t1 $connecthost >/dev/null 2>&1"); 
	if( $reachable != 0 ){
		print "Machine is not reachable! Keep pinging? (y/n)";
		$keep = <STDIN>;
                chomp( $keep );
		if( $keep ne 'y' ){
			print "Try ssh connect anyway? (y/n)";
			$anyway = <STDIN>;
                	chomp( $anyway );
			if( $anyway ne 'y' ){
				exit 1;
			}
			$reachable=0;
		}
	}
	while( $reachable != 0 ){
	    print ".";
	    sleep( 2 );
	    $reachable = system("ping -c1 -t1 $connecthost >/dev/null 2>&1"); 
	}
	
	my $portup = system("nc -w2 -z $connecthost $port");
	
	if( $portup != 0 && $keep eq 'undef' ){
		print "Port is not reachable! Keep trying? (y/n)";
		$keep2 = <STDIN>;
                chomp( $keep2 );
		if( $keep2 ne 'y' ){
			exit 1;
		}
	}	
	while( $portup != 0 ){
	    print ".";
	    sleep(1);
	    $portup = system("nc -z -w2 $connecthost $port >/dev/null 2>&1");
	}

	system("sed -i -e '/$connecthost/d' ~/.ssh/known_hosts");
	system("ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=yes  $connecthost -l $user -p $port");
	

}

exit 0;



## Check if this is a valid IPV4 address
sub IsIP {

    my $value = shift;

    return 0 unless defined( $value );

    my ( @octets ) = $value =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;

    return 0 unless ( @octets == 4 );

    foreach ( @octets ) {
        return 0 unless ( ($_ >= 0) && ($_ <= 255) );
    }

	return 1;
}


## Check if value is numeric
sub IsNumeric {

    my $value = shift;

    if ( $value =~m/^\d+$/ ){
		
        return 1;
	
    }

    return 0;	
	
}

sub LookupHostname {

    my $value = shift;

    $ip = gethostbyname( $value );

    if (defined ( $ip ) ){

        return 1;

    }

    return 0;
}

sub ReadFile { 


    my @lines;
    my @files;

    
    if( -d $svn_link_dir ){
    	opendir( LD, $svn_link_dir );
	foreach ( readdir(LD) ){
		push( @files, "$svn_link_dir/$_" );
	}
	closedir(LD);
    }else{
	print "No such directory $svn_link_dir";
    }
    push( @files, $my_links );

    foreach my $file ( @files ){
	if ( ! -f $file || $file =~ m/DS_Store/  ){
		next;
	}
    	if ( open( FP, "<$file" ) ){
		push( @lines, <FP>);
		close(FP);
   	}
    	else{
        	print "Failed to read file $file";
    	}
    }
    my %rethash;
    
    foreach( @lines ){
	
	if ( $_ =~ m/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/ ){
		
		$rethash{$1}{'ip'} = $2;
		$rethash{$1}{'port'} = $3;
		$rethash{$1}{'user'} = $4;
		
	}
	
	elsif ( $_ =~ m/(\S+)\s+(\S+)\s+(\d+)/ ){
		
		$rethash{$1}{'ip'} = $2;
		$rethash{$1}{'port'} = $3;
		$rethash{$1}{'user'} = $user;
	}
	elsif ( $_ =~ m/(\S+)\s+(\S+)\s+(\S+)/ ){
		
		$rethash{$1}{'ip'} = $2;
		$rethash{$1}{'port'} = $port;
		$rethash{$1}{'user'} = $3;
	}
	elsif ( $_ =~ m/(\S+)\s+(\S+)/ ){
		
		$rethash{$1}{'ip'} = $2;
		$rethash{$1}{'port'} = $port;
		$rethash{$1}{'user'} = $user;
	}
		
    }
    return \%rethash;

}


sub WriteFile {

	my ( $alias, $ip, $port, $user ) = @_;
	
	print "writing...";
	if ( open( FP, ">> $my_links" ) ) {

		print FP "$alias $ip $port $user\n";
	
		close( FP );
	}
	else{
		
		print "Failed to open File!";

	}

}	

sub iniRead
 { 
  my $ini = $_[0];
  my $conf;
  open (INI, "$ini") || die "Can't open $ini: $!\n";
    while (<INI>) {
        chomp;
        if (/^\s*\[\s*(.+?)\s*\]\s*$/) {
            $section = $1;
        }

        if ( /^\s*([^=]+?)\s*=\s*(.*?)\s*$/ ) {
          $conf->{$section}->{$1} = $2;         
        }
    }
  close (INI);
  return $conf;
}


sub iniWrite
{
  my $ini = $_[0];
  my $conf = $_[1];
  my $contents = '';
foreach my $section ( sort { (($b eq '_') <=> ($a eq '_')) || ($a cmp $b) } keys %$conf ) {
    my $block = $conf->{$section};
    $contents .= "\n" if length $contents;
    $contents .= "[$section]\n" unless $section eq '_';
    foreach my $property ( sort keys %$block ) {
      $contents .= "$property=$block->{$property}\n";
    }
  }
  open( CONF,"> $ini" ) or print("not open the file");
  print CONF $contents;
  close CONF;
}
