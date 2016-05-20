# goto
A script to speed up commandline SSH and SCP connects from MAC OSX
If a Machine is unreachable, an optional ping may be used

BE AWARE: This tool is by default configured for internal use only and will ignore changing SSH Hostkeys. 


Usage:
------

    goto [<MODE>] <Host> [<PORT>] [<USER>]
	    Hostname: IP or Name which may be looked up
		Port    : Port of the target machine ( default: 22 )
		User    : Username to login with
		Mode    : Mode may be scp or ping
		          scp  : open scp connection


Installation:
-------------

1. Place the Goto File to a folder that is included in your PATH variable. i.e. /usr/local/bin/
2. Make sure the script is executable
3. Run 'goto' from commandline
4. With the first start you will be asked for config file parameters
5. The config file will then be written to ~/goto.ini


Configuration:
--------------

~/goto.ini

    [global]
    port=               # DEFAULT PORT
    user=               # DEFAULT USER
    private_links=      # FIRST FILE TO STORE HOSTNAME->IP->USER->PORT
    svn_path=           # FOLDER WITH TEAMFILES TO READ FOR HOSTNAME->IP->USER->PORT

links file syntax

    HOSTNAME IP-ADRESS USERNAME PORT
    
    

Example 1:
----------

    webrene$ goto myhost

    ******************************************
    Opening myhost : 22 as root
    ******************************************


    Connection to myhost port 22 [tcp/ssh] succeeded!
    Warning: Permanently added 'myhost' (ECDSA) to the list of known hosts.
    Password:
    
    
Example 2:
----------

    webrene$ goto 172.100.50.51 test 21

    ******************************************
    Opening 172.100.50.51 : 21 as test
    ******************************************


    Port is not reachable! Keep trying? (y/n)y
    .....
   
   
Example 3:
----------

    webrene$ goto hostname_nodns

    Unknown Alias. Add to list (y/n)?y

    IP:192.168.0.1

    Port:22

    User:webrene 
    
    ******************************************
    Opening hostname_nodns : 22 as webrene
    ******************************************  
    
