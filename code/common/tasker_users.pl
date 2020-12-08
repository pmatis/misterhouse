# Category = Tasker
#@Tasker voice commands
=begin
################################################################################################
# Getting Started, Overview
################################################################################################

INITIAL SETUP:

 1) Enable tasker_users.pl in common code activation
 2) Create MHT file for users, like tasker_users.mht. See below example. Reload code.
 3) Visit http://localhost:8080/tasker_link.pl with web browser to test.
    You should this error only:
    [TASKER_LINK] ERROR: No Tasker interface defined. Create TASKER_INTERFACE, TASKER_USER and TASKER_DEVICE entries in an MHT file.

 4) Install Tasker and Autoremote on your phone (or multiple phones, tablets).
 5) Optionally, install Autovoice if you want to be able to speak commands to your phone
 6) Import the MH Tasker Project to each phone (MH_X.X.X.prj.xml)
    Long press the HOME icon at the bottom of Tasker, choose "Import Project" and select the file.
    Look at the "vars" tab in Tasker. Notice the MHVar_apikey and MHVar_apiurl variables.
    The variables are blank at this point.

 7) Obtain the AutoRemote key for each device you are setting up.
    The URL you see in autoremote it NOT it. Open the like that looks like:
    https://autoremote.jaoapps.com/euslDrifkksiewDaQ
    in a web browser, THEN you'll see the real key in the URL:
    http://autoremotejoaomgcd.appspot.com/?key=REALLY_LONG_KEY_HERE
    Take this key value, WITHOUT THE domain, WITHOUT the ?key= part, etc... ONLY the key, and
    place it into the MHT file for this device. (place_your_unique_autoremote_key_for_this_device_here)
 8) Generate an API key that YOU DEFINE for each device that unique for each device and place
    it into the MHT file for this same device (place_a_key_here)
    This is my exact example (I'll be destroying these keys!)

TASKER_INTERFACE,    http://192.168.22.101:8080/tasker_link.pl
TASKER_USER,   1,  jdoe,    John,  john
TASKER_DEVICE, 1,  1,  yg.gGfd@f6gy.gfdsaf,    ca57qekUrxY:APA91bFtzrbEQ20XXRORVg5I72OHTkC7h6EdAj__CIej2H7xkOhl7Lq5BNCyRlmTVXrwN-mriQpCI3qNwiLtJkSy2pxdsAu3ni2KsFhFNocH7jv01-OOBQX_z-L9f7JJHurnxFCsHFT8

 9) Send URL and keys to each device with voice command 'send api keys'
    The MHVar_apikey and MHVar_apiurl variables should now be populated in each Tasker client.
    If not, you have to wait a couple more minutes or the Autoremote key is incorrect.

10) Add a widget to your phone. Choose Tasker, drag "Task" to your home screen, choose "MH Text Cmd"
11) If you want to use AutoVoice, do the same thing, but choose "Autovoice", then drag "Recognize"
    to your home screen. You'll then be asked questions. Exclude powre optionally. Set Prompt Text
    If you choose to. I used "MH Voice Command." I suggest you check "Use Headset" too.
    Press Checkmark.


TEST:

12) Press "MH Text",type "hi", press OK. You should see a popup response from MH chose at random.
13) Testing Autovoice: Press "Recognize," say, "Hi." You should hear a spoken response of the
    random phrase that MH chose to respond with.
    Try "hi", "what time is it", "what's 1 + 1", etc


SECURE IT:

           !!!!!!!! WARNING !!!!!!!!

    You can stop and leave this in place if you'll ONLY use Wi-Fi.
    tasker_link.pl may be called directly, but I STRONGLY recommend
    placing tasker.php on a webserver with SSL in a DMZ and having
    that proxy the connection from tasker so MH isn't exposed
    directly to the Internet.

    Let's be honest. There are many other web server choices that
    have been hardened for use on the Internet, and they STILL
    see constant security fixes for new vulnerabilities. MH is
    NOT on that list of hardened webservers. Don't expose it!

    BE CAUTIOUS! Continue below:


14) Place tasker.php (from code/examples) onto a web server with IP access to MH, like in a DMZ.
    SECURE THE LINK FROM THE WEBSERVER TO MH, minimizing open ports!
    This file calls tasker_link.pl, but you'll have to adjust the top 2 lines:
    $MHSERVERIP='192.168.1.15';
    $MHSERVERPORT=8080;
15) Browse to the tasker.php file on your web server and ensure that it displays the same information
    As is did when you tested tasker_link.pl above. Check your firewall settings, etc until it does.
16) Add an SSL certificate. This is HIGHLY RECOMMENDED so your API key can't be stolen and used to do
    annoying (or destructive) things in your home.

17) Create your own user code to handle more voice commands and/or hooks.


################################################################################################
# FILE: tasker_users.mht
# Create this with your own values
################################################################################################
# Format = TASKER
# -*- mode: perl-mode; -*-
#
# See read_table_TASKER.pl  for definition of Format=TASKER items
#
#Define the URL that clients use to access MH, through the tasker.php file. This URL is sent to
#each the remote instances when the "sent api keys" voice command is used.
#
#I STRONGLY RECOMMEND USING tasker.php on nginx or Apache with HTTPS and A REAL SSL CERTIFICATE
#TASKER_INTERFACE,    http://your.mh.server.ip:8080/tasker_link.pl  #<--Please don't use tasker_link.pl in production!
TASKER_INTERFACE,    https://your.mh.example.com/tasker.php

#TASKER_USER   ID, username,    FirstName,  nickname
TASKER_USER,   1,  jdoe,    Jimmy,  jim
TASKER_USER,   2,  sdoe,    Sammi,  sam
TASKER_USER,   3,  ldoe,    Little,  little

#The 4th entry is the "key". Set this to something unique for each device. You generate this yourself
#the 5th entry is the key we get from autoremote. NOT the short one. Visit the short URL from the app, then copy/paste the realy long from the URL to here.
#If you set a password in autoremote, you can specify it as the 6th option so this module knows about it.
#TASKER_DEVICE,    ID, UserID, Key,    AutoRemote API Key, AutoRemote Password
#Phone 1
TASKER_DEVICE, 1,  1,  place_a_key_here,    place_your_unique_autoremote_key_for_this_device_here,   The_optional_Passw@rd

#Tablet
TASKER_DEVICE, 1,  2,  place_a_key_here,    place_your_unique_autoremote_key_for_this_device_here

#Phone 2
TASKER_DEVICE, 1,  3,  place_a_key_here,    place_your_unique_autoremote_key_for_this_device_here

#sdoe Phone
TASKER_DEVICE, 2,  1, place_a_key_here, place_your_unique_autoremote_key_for_this_device_here

#ldoe phone 1
TASKER_DEVICE, 3,  1, place_a_key_here,  place_your_unique_autoremote_key_for_this_device_here
#ldoe phone 2
TASKER_DEVICE, 3,  2, place_a_key_here,  place_your_unique_autoremote_key_for_this_device_here

################################################################################################
=cut

################################################################################################
use strict;
use warnings;
use Tasker_Interface;
use vars qw($TaskerInt %tasker_voice_forward_list %tasker_cmd @tasker_responses);
use constant { true => 1, false => 0 };

################################################################################################
if($Startup || $Reload) {
  if( defined $TaskerInt ) {
    print_log("[TASKER] {tasker_users}: ".Dumper($TaskerInt->{tasker_users})) if $main::Debug{tasker};
  } else {
    print_log("[TASKER] ERROR: No Tasker interface defined. Create TASKER_INTERFACE, TASKER_USER and TASKER_DEVICE entries in an MHT file. See tasker_users.pl for details.");
  }
  foreach my $key (split(",",$Save{tasker_forward_speech})) {
    $tasker_voice_forward_list{$key}=1;
  }
  #Only here to make this appear on the web interface
  $config_parms{tasker_show_help}=$config_parms{tasker_show_help};
}

Speak_pre_add_hook(\&tasker_voice_send_speech) if $Reload;

################################################################################################
# Distribute API keys & URL to all Tasker clients
################################################################################################
$v_tasker_send_keys = new Voice_Cmd 'send {tasker, } api keys';
if(said $v_tasker_send_keys) {
  $TaskerInt->send_keys();
}

################################################################################################
# Allow for voice announcement forwarding
################################################################################################
if( new_minute || $Reload || said $v_tasker_send_speech) { #print list if there was a reload, or the command was recently used
  print_log "[TASKER] Voice forwarding is active to: ".join(',',(keys %tasker_voice_forward_list)) if keys %tasker_voice_forward_list;
}

$v_tasker_send_speech = new Voice_Cmd '[begin,start,end,stop] forwarding {voice, } {announcement,announcements}';
if($state = said $v_tasker_send_speech) {
  my ($set_by_key) = $v_tasker_send_speech->{target} =~ m|tasker[a-z]*\ api=(.*)|;

  print_log "[TASKER] $state forwarding voice announcements: $set_by_key";
  if(($state eq 'begin') || ($state eq 'start')) {
  respond "Forwarding is already active" if defined $tasker_voice_forward_list{$set_by_key};
  respond "Beginning announcement forwarding" unless defined $tasker_voice_forward_list{$set_by_key};
  $tasker_voice_forward_list{$set_by_key}=1;
  }
  if(($state eq 'end') || ($state eq 'stop')) {
  respond "Ending announcement forwarding" if defined $tasker_voice_forward_list{$set_by_key};
  respond "Announcement forwarding was not enabled" unless defined $tasker_voice_forward_list{$set_by_key};
  delete $tasker_voice_forward_list{$set_by_key};
  }
  $Save{tasker_forward_speech}=join(",", keys %tasker_voice_forward_list);
}

$v_tasker_send_speech_end_all = new Voice_Cmd '[end,stop] forwarding {voice, } {announcement,announcements} for {everyone,all}';
if($state = said $v_tasker_send_speech_end_all) {
  my ($set_by_key) = $v_tasker_send_speech->{target} =~ m|tasker[a-z]*\ api=(.*)|;
  my %vparms;
  foreach my $key (keys %tasker_voice_forward_list) {
    if ( $set_by_key ne $key ) {
      $vparms{api} = $key;
      $vparms{text} = 'Ending announcement forwarding by remote command';
      respond_tasker(%vparms);
    }
    delete $tasker_voice_forward_list{$key};
  }
  delete $Save{tasker_forward_speech};
  respond "Ending announcement forwarding for everyone";
}


################################################################################################
#Voice command response
################################################################################################
sub respond_tasker {
  my (%parms) = @_;
  print_log("[TASKER] respond_tasker: ".Dumper(%parms)) if $Debug{tasker};
  $TaskerInt->_respond(%parms);
}
################################################################################################
#Text response
################################################################################################
sub respond_taskercmd {
  my (%parms) = @_;
  $parms{resptype}='cmdresp';
  print_log("[TASKER] respond_taskercmd: ".Dumper(%parms)) if $Debug{tasker};
  $TaskerInt->_respond(%parms);
}

################################################################################################
# Sub Declarations
################################################################################################
sub tasker_http_response {
  my ($txt, $response, $contenttype) = @_;
  my $date = time2str(time);
  return $txt if $txt =~ /^HTTP\//;
  $response = '200 OK' unless defined $response;
  $contenttype = 'text/plain' unless defined $contenttype;
  return <<eof;
HTTP/1.0 $response
Server: MisterHouse
Date: $date
Content-type: $contenttype
Cache-Control: no-cache

$txt
eof
}

#Called from tasker_link.pl, which is called from tasker.php on your web server
sub tasker_call {
  my ($params) = @_;

  if(defined $params->{cmd} && $params->{cmd} =~ m/^tasker_interface_test$/i) {
    print_log "[TASKER] TEST,       User Count: ".keys %{$TaskerInt->{tasker_users}};
    print_log "[TASKER] TEST,     Device Count: ".keys %{$TaskerInt->{tasker_devices}};
    print_log "[TASKER] TEST,        Key Count: ".keys %{$TaskerInt->{tasker_apikeys}};
    print_log "[TASKER] TEST, Autoremote Count: ".keys %{$TaskerInt->{tasker_arkey}};

    my $returntxt='<br><h2>TEST RESPONSE</h2>OK: Test call to tasker_call with parameter cmd=tasker_interface_test was successful.';
    return $returntxt.'<br>See the MH log file for more detailed information. Enable debug to see it here.' unless $Debug{tasker};

    $returntxt.='<p>';
    $returntxt.=(keys %{ $TaskerInt->{tasker_users} }).' users defined<br>';
    $returntxt.=(keys %{ $TaskerInt->{tasker_devices} }).' devices defined<br>';
    $returntxt.=(keys %{ $TaskerInt->{tasker_apikeys} }).' API Keys defined<br>';
    $returntxt.=(keys %{ $TaskerInt->{tasker_arkey} }).' Autoremote Keys defined<br>';
    $returntxt.='</p>';

    return $returntxt;
  }

  if(!defined $TaskerInt->{tasker_apikeys}{$params->{header_api}}{userid}) {
    print_log "[TASKER] ERROR: no api key found!";
    return 'reply: key failure';
  }
  print_log "[TASKER] $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$params->{header_api}}{userid}}{fname}: Received Tasker call: ".Dumper($params) if $Debug{tasker};
  print_log "[TASKER] $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$params->{header_api}}{userid}}{fname}: Received Tasker call (voice): ".$params->{voice} if defined($params->{voice});
  print_log "[TASKER] $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$params->{header_api}}{userid}}{fname}: Received Tasker call (cmd): ".$params->{cmd} if defined($params->{cmd});

  if(defined($params->{header_commandloc})) {
    $params->{header_LOC} = decode_base64($params->{header_commandloc});
    my @fields = split(/\n/, $params->{header_LOC});
    foreach my $field (@fields) {
       my ($locfield, $locinfo) = split(':', $field, 2);
       if ($locfield eq 'latlong') {
           $locfield='LOC' ;
           $params->{header_LOC}=$locinfo;
       } else {
           $locfield='LOC'.$locfield;
       }
       tasker_property_set($params->{header_api},$locfield,$locinfo);
    }
  }
  if(defined($params->{notification})) {
    tasker_notify_receive($params->{notification},$params->{header_api});
  }

  if(defined($params->{voice})) {
    return tasker_call_voice($params->{voice},$params->{header_api});

  } elsif(defined($params->{cmd})) {
      return tasker_call_cmd($params->{cmd},$params->{header_api});
=begin
#Testing
  #TODO: This bypasses security altogether. Think about security, or eliminate this option.
  } elsif(defined($params->{setstate})) {
    my @states;
    foreach my $stateline (split(/,/, $params->{setstate})) {
      my ($object_name, $objstate) = split(/:/, $stateline);
      my $object = get_object_by_name($object_name);
      foreach my $key (keys %{$object}) {
        my %objvals=%{$object};
        print_log "$object_name: ".$key." : ".$objvals{$key};
      }
      set $object $objstate if $object;
    }
    return 'set';

  #Get state of objects.
  #TODO: Should this consider security?
  } elsif(defined($params->{getstate})) {
    my @states;
    foreach my $object_name (split(/,/, $params->{getstate})) {
      my $object = get_object_by_name($object_name);
      my $state='';
      $state=state $object if $object;
      push @states, $object_name.':'.$state;
    }
    return join(',',@states);
=cut
    }
}


#To receive state updates from phones, e.g. charging status
sub tasker_notify_receive {
  my ($cmd,$api) = @_;
  print_log "[TASKER] $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$api}{userid}}{fname}: Received Tasker notification: $cmd";
  if($cmd =~ /^charger:o[nf]/) {
    if($cmd =~ /^charger:on/) {
      tasker_property_set($api,'charging',1);
    }
    elsif($cmd =~ /^charger:off/) {
      tasker_property_set($api,'charging',0);
    }
    if($cmd =~ /\ wifi:on/) {
      tasker_property_set($api,'wifi',1);
    }
    elsif($cmd =~ /\ wifi:off/) {
      tasker_property_set($api,'wifi',0);
    }
    if(my ($battlev) = $cmd =~ m|\ batt:(\d+)|) {
      tasker_property_set($api,'battery',$battlev);
    }
  }
  $TaskerInt->run_hooks('tasker_notify_receive', $cmd, $api);
}

#Internal sub to store data that the phones send
sub tasker_property_set {
  my ($api,$key,$value) = @_;
  $Save{"Tasker_$TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$api}{userid}}{fname}_$TaskerInt->{tasker_apikeys}{$api}{deviceid}_$key"}=$value;
  print_log "[TASKER] Save{Tasker_$TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$api}{userid}}{fname}_$TaskerInt->{tasker_apikeys}{$api}{deviceid}_$key} = ".$value if $Debug{tasker};
}

#For a phone to send a voice commant to MH
sub tasker_call_cmd {
  my ($cmd,$api) = @_;
  %tasker_cmd=('api' => $api, 'cmd' => $cmd, 'responsetarget' => 'taskercmd');

  print_log "[TASKER] (tasker_call_cmd) Received Tasker command: $cmd" if $Debug{tasker};
  my $result=tasker_voice_command_single($cmd,$api,'taskercmd');
  $result='' unless defined $result;
  print_log "[TASKER] (tasker_call_cmd) Result: $result" if $Debug{tasker};
  return($result) if $result eq 'running' || $result =~ m/^reply:/ || $result =~ m/^cmdresp:/;

  return tasker_http_response("reply: ".$TaskerInt->get_random_response('unknown'));#, '404 Not Found');
}

sub tasker_call_voice {
  my ($cmds,$api) = @_;
  print_log "[TASKER] (tasker_call_voice) Received Tasker voice command list: $cmds" if $Debug{tasker};
  for my $cmd (split ',', $cmds) {
    $cmd =~ s/^pseudo\ /sudo /i;
    $cmd =~ s/^psuedo\ /sudo /i;
    $cmd =~ s/^sudoh\ /sudo /i;
    $cmd =~ s/^sue doe\ /sudo /i;

    #Newer google voice dictation adds punctuation
    $cmd =~ s/[\.?!] ?$//;

    #Allow words to be ordered differently
    $cmd =~ s/(turn)\ ([onf]{2,3})\ (.*)/$1 $3 $2/i;

    %tasker_cmd=('api' => $api, 'cmd' => $cmd);

    my $result=tasker_voice_command_single($cmd,$api);
    $result='' unless defined $result;
    print_log "[TASKER] (tasker_call_voice) Return: $result" if $Debug{tasker};
    return($result) if $result eq 'running' || $result =~ m/^reply:/ || $result =~ m/^cmdresp:/;
  }
  return tasker_http_response("reply: ".$TaskerInt->get_random_response('unknown'));#, '404 Not Found');
}

#Called by tasker_call_voice, for a phone to send a voice command to MH
sub tasker_voice_command_single {
  $tasker_cmd{cmdorig}=$tasker_cmd{cmd};

  $tasker_cmd{announceroom}='' unless defined $tasker_cmd{announceroom};
  $tasker_cmd{responsetarget}='tasker' unless defined $tasker_cmd{responsetarget};
  $tasker_cmd{responsetarget} = "$tasker_cmd{responsetarget} api=$tasker_cmd{api}";
  $tasker_cmd{cmduser} = $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$tasker_cmd{api}}{userid}}{username};
  print_log "[TASKER] (tasker_voice_command) Command from ".$tasker_cmd{cmduser} .": ".$tasker_cmd{cmd} if $Debug{tasker};

  @tasker_responses=();
  $tasker_cmd{cmd} =~ s/^computer\ //g;
  $tasker_cmd{cmd} =~ s/^mr\.?\ house\ //g;
  $tasker_cmd{cmd} =~ s/^mister\ house\ //g;
  $tasker_cmd{cmd} =~ s/_/ /g;
  print_log "[TASKER] Processing modified command: $tasker_cmd{cmd}" if $Debug{tasker};

  $TaskerInt->run_hooks('tasker_voice_command');

  if (!defined $tasker_cmd{responsetxt}) {

    #Look for exact command matches
    print_log "[TASKER] (tasker_voice_command_single) Considering command: $tasker_cmd{cmd}" if $Debug{tasker};
    my ($ref) = Voice_Cmd::voice_item_by_text( lc($tasker_cmd{cmd}) );

    if(!$ref && $tasker_cmd{cmd} =~ m/\ my\ /i) {
      #Look for a match with "my" replaced.
      $tasker_cmd{cmd} =~ s/\ my\ / $TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$tasker_cmd{api}}{userid}}{nickname} /ig;
      print_log "[TASKER] (tasker_voice_command_single) Rewritinging Tasker command: $tasker_cmd{cmd}" if $Debug{tasker};
      ($ref) = Voice_Cmd::voice_item_by_text( lc($tasker_cmd{cmd}) );
    }
    if($ref) {
    $tasker_cmd{cmdauthority} = $ref->get_authority if $ref;
    $tasker_cmd{cmdauthority} = $Password_Allow{$tasker_cmd{cmd}} unless $tasker_cmd{cmdauthority};

    if ( tasker_authorized($tasker_cmd{cmdauthority}, $tasker_cmd{cmduser}, $tasker_cmd{cmd}) ) {
      print_log "[TASKER] Running command...";
      if($tasker_cmd{announceroom} ne '') {
        print_log "[TASKER] (tasker_voice_command_single) Sending speech to room $tasker_cmd{announceroom}: $tasker_cmd{responsetxt}";
        $tasker_cmd{responsetarget}="$tasker_cmd{responsetarget} rooms=$tasker_cmd{announceroom}";
      }
      run_voice_cmd($tasker_cmd{cmd}, undef, 'tasker', 0, $tasker_cmd{responsetarget});
      return 'running';
    } else {
      $tasker_cmd{responsetxt} = "reply: ".$TaskerInt->get_random_response('denied');
      return $tasker_cmd{responsetxt};
    }

    } elsif($tasker_cmd{cmdorig} =~ m/^hi\ ?.*/i || $tasker_cmd{cmdorig} =~ m/^hello\ ?.*/i) {
      @tasker_responses=(
        'Hi {fname}.',
        'Hi {fname}. Good to hear from you.',
        'Hi!',
        'Oh hi!',
        'Hello there.',
        'Greetings {fname}!',
        'Good day.'
      );

    } elsif($tasker_cmd{cmdorig} =~ m/^hola\ ?.*/i) {
      @tasker_responses=(
        'Hola {fname}. ¿Hablas español?',
      );

    } else {
      $TaskerInt->run_hooks('tasker_voice_command_notfound');
      if (!defined $tasker_cmd{responsetxt}) {
        print_log "[TASKER] Command not recognized";
        return tasker_http_response("reply: ".$TaskerInt->get_random_response('unknown')); #Return here so the phone gets the error, even if "announce" was used to redirect
      } else {
        print_log "[TASKER] Hook tasker_voice_command_notfound returned a response";
      }
    }
  } else {
    print_log "[TASKER] Hook tasker_voice_command returned a response";
  }
  print_log("[TASKER] response_text: ".$tasker_cmd{responsetxt}) if defined $tasker_cmd{responsetxt} && $Debug{tasker};
  print_log("[TASKER] tasker_responses: ".Dumper(@tasker_responses)) if $Debug{tasker};
  if($#tasker_responses gt 0) {
    $tasker_cmd{responsetxt} = "reply: ".$tasker_responses[int rand($#tasker_responses)];
  }
  $tasker_cmd{responsetxt} = '' unless defined $tasker_cmd{responsetxt};
  $tasker_cmd{responsetxt} =~ s/{fname}/$TaskerInt->{tasker_users}{$TaskerInt->{tasker_apikeys}{$tasker_cmd{api}}{userid}}{fname}/;

  print_log("response_text: ".$tasker_cmd{responsetxt}) if $Debug{tasker};
  if(defined($tasker_cmd{responsetxt})) {
    $tasker_cmd{responsetxt} =~ s/^reply: //i;
    print_log("response_texts: ".$tasker_cmd{responsetxt}) if $Debug{tasker};
    print_log("responsetarget: ".$tasker_cmd{responsetarget}) if $Debug{tasker};

    #Send directy back to phone, but only if not redirected
    if($tasker_cmd{responsetarget} =~ m/^tasker[a-z]*\ api/i && !defined $tasker_cmd{announcetarget}) {
      print_log('[TASKER] Response: '.$tasker_cmd{responsetxt});
      if($tasker_cmd{responsetarget} =~ m/^taskercmd\ /i) {
        print_log("responsetarget: ".$tasker_cmd{responsetarget}) if $Debug{tasker};
        return 'cmdresp: '.$tasker_cmd{responsetxt};
      } else {
        return 'reply: '.$tasker_cmd{responsetxt};
      }
    }

    if($tasker_cmd{responsetarget} eq 'default') {
      $tasker_cmd{responsetxt} = "nolog=1 $tasker_cmd{responsetxt}";
      respond("target=$tasker_cmd{responsetarget} $tasker_cmd{responsetxt}");
      return 'running';
    } elsif($tasker_cmd{announceroom} ne '') {
      print_log "[TASKER] Sending speech to room $tasker_cmd{announceroom}: $tasker_cmd{responsetxt}";
      speak("rooms=$tasker_cmd{announceroom} $tasker_cmd{responsetxt}");
      return 'running';
    }
    return $tasker_cmd{responsetxt};
  }
  return 'running';

=begin
  #Might be used later...

  # Look for nearest fuzzy match
  my $cmd1 = tasker_phrase_match($tasker_cmd{cmd});

  process_external_command($cmd1, 1, 'tasker', "tasker api=tasker_cmd{api}");
  return 'done';
=cut

}

#Send a request to the phone to speak, usually in response to a voice command
sub tasker_voice_send_speech {
  print_log "[TASKER] Speech Pre hook called";
  my (%parms) = @_;
  return if ($mode_mh->{state} eq 'mute' or $mode_mh->{state} eq 'offline') and not $parms{mode} =~ m/unmute/;

  print_log("(tasker_voice_send_speech) tasker_voice_forward_list: ".Dumper(%tasker_voice_forward_list));
  foreach my $apikey (keys %tasker_voice_forward_list) {
      my $arkey=$TaskerInt->{tasker_apikeys}{$apikey}{arkey};
      $TaskerInt->send_with_key($arkey, "=:=say=".$parms{text});
  }
}

#Check to see if a user is authorized to run a voice command.
sub tasker_authorized {
  my ($cmdauthority,$cmduser,$cmd) = @_;
  $cmdauthority='' unless defined $cmdauthority;
  print_log "[TASKER] user:$cmduser a=$cmdauthority cmd=$cmd\n";
  my @cmdautharray = split(',', $cmdauthority);
  if ( $cmdauthority and (
      $cmdauthority eq 'anyone'
      or grep { $_ eq $cmduser} @cmdautharray
  ) ) {
      print_log "[TASKER] Command authorized for $cmduser: $cmd";
      return true;
  }
  print_log "[TASKER] Command not authorized for $cmduser: $cmd";
  return false;
}

################################################################################################
=begin
#Might be used later...

sub tasker_phrase_match {
  my ($phrase) = @_;
  my (%list1);
  my $d_min1 = 999;
  my $set1 = 'abcdefghijklmnopqrstuvwxyz0123456789';
  my @phrases = Voice_Cmd::voice_items('mh', 'no_category');
  for my $phrase2 (sort @phrases) {
    my $d = pdistance($phrase, $phrase2, $set1, \&distance, {-cost => [0.5,0,4], -mode => 'set'});
    push @{$list1{$d}}, $phrase2 if $d <= $d_min1;
    $d_min1 = $d if $d < $d_min1;
  }
  return ${$list1{$d_min1}}[0];
}
=cut
