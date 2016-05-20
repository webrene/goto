# goto
A script to speed up commandline SSH and SCP connects from MAC OSX
If a Machine is unreachable, an optional ping may be used

BE AWARE: This tool is by default configured for internal use only and will ignore changing SSH Hostkeys. 


Usage:

    goto [<MODE>] <Host> [<PORT>] [<USER>]
	    Hostname: IP or Name which may be looked up
		Port    : Port of the target machine ( default: 22 )
		User    : Username to login with
		Mode    : Mode may be scp or ping
		          scp  : open scp connection



Example 1:

    webrene$ goto myhost

    ******************************************
    Opening myhost : 22 as root
    ******************************************


    Connection to myhost port 22 [tcp/ssh] succeeded!
    Warning: Permanently added 'myhost' (ECDSA) to the list of known hosts.
    Password:
    
    
Example 2:

    webrene$ goto 172.100.50.51 test 21

    ******************************************
    Opening 172.100.50.51 : 21 as test
    ******************************************


    Port is not reachable! Keep trying? (y/n)y
    .....
    
    