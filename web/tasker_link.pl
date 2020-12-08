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

my $tasker_project_file='MH_1.1.0.prj.xml';

###############################################################
# Check things out and dump an error if needed
###############################################################
my $date = time2str(time);
my $tlerror=0;
my $qrcount=1;
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

#TODO: Needed? Forgot why I needed the add_handler method. "HTTP::Headers" is a dependancy on LWP. Worked around these?
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
print_log("[TASKER_LINK] request: $Http{'request'}") if $Debug{tasker};

my ($path, $querystring) = $Http{request} =~ m/GET\ (\/[^?]*)\?(.*)\ /;
$querystring='' unless defined $querystring;

#If a Tasker client is making this call, and it's not a download, treat it normally
if( $Http{'User-Agent'} =~ /Tasker/i && $querystring !~ /^download=/ ) {
  return $error500 if $tlerror;

  if(scalar(@ARGV) == 0) {
    print_log("[TASKER_LINK] No data passed");
    return tasker_http_response('ERROR:No data passed');
    exit;
  }
  push @ARGV, 'header_client_ip_address='.$client_ip_address;
  push @ARGV, 'header_user-agent='.$Http{'User-Agent'} if defined $Http{'User-Agent'};
  push @ARGV, 'header_ver='.$Http{'ver'} if defined $Http{'ver'};
  push @ARGV, 'header_api='.$Http{'api'} if defined $Http{'api'};
  push @ARGV, 'header_commandloc='.$Http{'commandloc'} if defined $Http{'commandloc'};
  my $params;
  foreach my $part (@ARGV) {
    my ( $name, $value ) = split( /\=/, $part, 2 );
    $params->{$name} = $value;
  }
  #Backward compatibility
  $params->{header_ver}=$params->{ver} unless defined $params->{header_ver}; delete $params->{ver};
  $params->{header_api}=$params->{api} unless defined $params->{header_api}; delete $params->{api};
  $params->{header_commandloc}=$params->{commandloc} unless defined $params->{header_commandloc}; delete $params->{commandloc};

  #Check for an incomplete call
  if (ref $params ne ref {}) {
    print_log("[TASKER_LINK] Incomplete call: ".Dumper($params));
    return tasker_http_response('ERROR:Incomplete call');
  }

  print_log("[TASKER_LINK] Passing command to tasker_call ".$params->{header_api}) if $Debug{tasker};

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


#If this is not Tasker making the call, it must be Firefox, Chrome, etc. Show some information.
} else {
  #Allow for downloading the tasker project XML file
  if($querystring eq 'download=client') {
    my $date = time2str(time);

    open my $fh, '<', '../code/examples/'.$tasker_project_file;
    my $size_in_bytes = -s $fh;
    my $filedata = do { local $/; <$fh> };
    close $fh;

    return <<eof;
HTTP/1.0 200
Server: MisterHouse
Date: $date
Content-type: file/download\
Content-Length: $size_in_bytes\
Content-Disposition: attachment; filename=$tasker_project_file
Cache-Control: no-cache

$filedata
eof
  #Allow tasker to download the mhlogo.gif file for use in the scene
  } elsif ($querystring eq 'download=logo') {
    my $date = time2str(time);

    open my $fh, '<', '../web/ia5/images/mhlogo.gif';
    my $size_in_bytes = -s $fh;
    my $filedata = do { local $/; <$fh> };
    close $fh;
    print_log("Download of mhlogo.gif, size: $size_in_bytes");
    return <<eof;
HTTP/1.0 200
Server: MisterHouse
Date: $date
Content-type: image/gif\
Content-Length: $size_in_bytes\
Content-Disposition: attachment; filename=mhlogo.gif
Cache-Control: no-cache

$filedata
eof

    } else {
        return $error500 if $tlerror;
        my $params;
        $params->{'cmd'}='tasker_interface_test';

        my $htmldata='<img src=\'ia5/images/mhlogo.gif\'><h2>This URL should be called by the tasker project for MH.</h2>';
        $htmldata.='<br><font color="red">An error was detected and printed to error_log.</font>' if $tlerror;
        $htmldata.='<br>'.tasker_call($params) if $Debug{tasker};

        $htmldata.='<ul>';
        $htmldata.='<li>Enable $Debug{tasker} to run a test and display more information.</li>' unless $Debug{tasker};

        if ($config_parms{tasker_show_help} != 1) {
            $htmldata.='<li>Add tasker_show_help=1 to mh.private.ini to see download links and QR codes.</li>';
            return tasker_http_response($htmldata, undef, 'text/html');
        }

        $htmldata.='</ul>';

        #TODO: All of this could probably be much neater and/or more elegant, bit this works for now
        $htmldata.=<<EOF;
          <style>
          .wrapper {
            padding: 5px;
            max-width: 960px;
            width: 95%;
            margin: 20px auto;
          }
          header {
            padding: 0 15px;
          }
          .columns {
            display: flex;
            flex-flow: row wrap;
            justify-content: center;
            margin: 5px 0;
          }
          .column {
            flex: 1;
            border: 1px solid gray;
            margin: 2px;
            padding: 10px;
            &:first-child { margin-left: 0; }
            &:last-child { margin-right: 0; }
          }
          .column > p {
            height: 100px;
          }
          .qr {
            margin: auto;
            width: 256;
          }
          footer {
            padding: 0 15px;
          }
          </style>

          <div class="wrapper">

            <header>
              <h1>Steps 4 & 5: App Downloads</h1>
            </header>

            <section class="columns">
              <div class="column">
                <h2>Tasker</h2>
                <p>This app is required, as it's what runs the code on the Android client. It's responsible for sending messages to MH via the URL given to Tasker by MH.</p>
                <div class="qr" id="qrtasker"></div>
              </div>
              <div class="column">
                <h2>AutoRemote</h2>
                <p>This app receives messages from MH for processing by Tasker and the project. Prety much required to get messages to Tasker.</p>
                <div class="qr" id="qrautoremote"></div>
              </div>
              <div class="column">
                <h2>AutoVoice (Optional)</h2>
                <p>If you want to be able to speak to your phone/tablet, this app allows the Google API to interpret your voice as text, then the Tasker project processes it from there.</p>
                <div class="qr" id="qrautovoice"></div>
              </div>
            </section>

            <br><header>
              <h1>Step 6: Install the project file</h1>
            </header>
            <section class="columns">
              <div class="column">
                <h2>Tasker Project File</h2>
                This is the code that runs inside Tasker. It's downloaded to your phone as XML and is imported to Tasker.<br><br>
                <div id="taskerproj"></div>
              </div>
            </section>

            <footer>
              <h3></h3>
              <p>Once these are installed, continue on with step 7 in tasker_users.pl.</p>
            </footer>

          </div>

          <script src="https://cdn.rawgit.com/davidshimjs/qrcodejs/gh-pages/qrcode.min.js"></script>
          <script type="text/javascript">
          new QRCode(document.getElementById("qrtasker"), 'https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm');
          new QRCode(document.getElementById("qrautoremote"), 'https://play.google.com/store/apps/details?id=com.joaomgcd.autoremote');
          new QRCode(document.getElementById("qrautovoice"), 'https://play.google.com/store/apps/details?id=com.joaomgcd.autovoice');
          new QRCode(document.getElementById("taskerproj"), window.location.href.split(\"?\")[0] + '?download=client');
          </script>
EOF

        return tasker_http_response($htmldata, undef, 'text/html');
    }

}
