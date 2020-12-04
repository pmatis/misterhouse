###############################################################
# authority: anyone
#
# Calls tasker_call sub in tasker_users.pl
#
# See tasker_users.pl for instructions
#
#               !!!!!!!! WARNING !!!!!!!!
#
# This may be called directly, but I strongly recommend placing
# tasker.php on a webserver with SSL in a DMZ and having that
# proxy the connection from tasker so MH isn't exposed directly
# to the Internet.
#
# Let's be honest. There are many other web server choices that
# have been hardened for use on the Internet, and they STILL
# see constant security fixes for new vulnerabilities. MH is
# NOT on that list of hardened webservers. Don't expose it!
#
# BE CAUTIOUS!
#
###############################################################
use strict;
use warnings;
use Try::Tiny;

###############################################################
# Check things out and dump an error
###############################################################
my $date = time2str(time);
my $tlerror=0;
my $error500=<<eof;
HTTP/1.0 500 Internal Server Error
Server: MisterHouse
Date: $date
Content-type: text/plain
Cache-Control: no-cache

500 Internal Server Error
eof

if(!main->can("tasker_call")) {
  print_log('[TASKER_LINK] ERROR: tasker_users.pl is not enabled in common code.');
  $tlerror=1;
}
if(!defined($main::TaskerInt)) {
  print_log('[TASKER_LINK] ERROR: No Tasker interface defined. Create TASKER_INTERFACE, TASKER_USER and TASKER_DEVICE entries in an MHT file.');
  $tlerror=1;
}
if(!LWP::UserAgent->can('add_handler')) {
  print_log('[TASKER_LINK] WARNING: LWP::UserAgent is old.');
  #$tlerror=1;
}
if(!HTTP::Headers->can('redirects')) {
  print_log('[TASKER_LINK] WARNING: HTTP::Headers is old.');
  #$tlerror=1;
}


###############################################################
# Begin processing the request
###############################################################
my $client_ip_address=$Socket_Ports{http}{client_ip_address};
$client_ip_address=$Http{'X-REAL-IP'} if defined $Http{'X-REAL-IP'};

print_log("[TASKER_LINK] client_ip_address: $client_ip_address") if $Debug{tasker};
print_log("[TASKER_LINK] ARGV: ".Dumper(@ARGV)) if $Debug{tasker};
print_log("[TASKER_LINK] User-Agent: $Http{'User-Agent'}") if $Debug{tasker};
print_log(Dumper(%Http));
#If a Tasker client is making this call, treat it normally
if( $Http{'User-Agent'} =~ /Tasker/i ) {
  return $error500 if $tlerror;

  if(scalar(@ARGV) == 0) {
    print_log("[TASKER_LINK] No data passed");
    return tasker_http_response('ERROR:No data passed');
    exit;
  }
  push @ARGV, 'header_client_ip_address='.$client_ip_address;
  push @ARGV, 'header_user-agent='.$Http{'User-Agent'};
  push @ARGV, 'header_ver='.$Http{'ver'};
  push @ARGV, 'header_api='.$Http{'api'};
  push @ARGV, 'header_commandloc='.$Http{'commandloc'};
  my $params;
  foreach my $part (@ARGV) {
    my ( $name, $value ) = split( /\=/, $part, 2 );
    $params->{$name} = $value;
  }

  #Check for an incomplete call
  if (ref $params ne ref {}) {
    print_log("[TASKER_LINK] Incomplete call: ".Dumper($params));
    return tasker_http_response('ERROR:Incomplete call');
  }

  print_log("[TASKER_LINK] Passing command to tasker_call ".$params->{api}) if $Debug{tasker};

  #Wrap this in "try" so we don't expose too much info to the web
  try {
    my $cmd_result = tasker_call($params);

    #In cases of an unknown command, this is not set earlier. Bug or feature?
    if(defined($params->{cmd})) {
        $cmd_result =~ s/^reply:/cmdresp:/im;
    }
    print_log("[TASKER_LINK] cmd_result: ".$cmd_result) if $Debug{tasker};
    return tasker_http_response($cmd_result);

  } catch {
    print_log("[TASKER_LINK] Eval Error: ".$_);
    return tasker_http_response('ERROR:Tasker_link.pl eval error. Check the log.');
  };

} else {
  #If this is not Tasker making the call, it must be Firefox, Chrome, etc. Show some information.
  return $error500 if $tlerror;
  my $params;
  $params->{'cmd'}='tasker_interface_test';

  my $htmldata='This interface should be called by the tasker project for MH.';
  $htmldata.='<br><font color="red">An error was detected and printed to error_log.</font>' if $tlerror;
  $htmldata.='<br>'.tasker_call($params) if $Debug{tasker};
  $htmldata.='<br>Enable $Debug{tasker} for more information.' unless $Debug{tasker};

  return tasker_http_response($htmldata, undef, 'text/html');
}
