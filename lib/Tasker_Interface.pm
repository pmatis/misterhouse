# Category = Voice
#@Android voice commands
################################################################################################
use strict;
use vars qw(@tasker_responses);

################################################################################################
package Tasker_Interface;
use URI::Escape;
use LWP::Simple;
use threads;
use Data::Dumper::Simple;

@Tasker_Interface::ISA = ('Generic_Item');

my @tasker_denied=('Denied.','Access denied.','This command is not for you.','Command not authorized.',"I can't let you do that.","Please ask to be given permission.","You have to ask my master for permission.");
my @tasker_unknown=('Unknown command.',"My master didn't teach me that command.",'I know not what you speak of.',"Maybe if you say it differently, I'll get it.",'Sorry, try again?');
my (%hook_pointers, %hook_locations);

################################################################################################
# Construction subs
################################################################################################
#new Tasker_Interface('https://your.mh.example.com/tasker.php');
sub new {
  my ( $class, $tasker_api_url ) = @_;
  my $self = {};
  bless $self, $class;
  main::print_log("[Tasker_Interface] creating object: ") if $main::Debug{tasker};
  $self->{tasker_api_url}=$tasker_api_url;

  %hook_locations = map { $_, 1 } qw( tasker_notify_receive tasker_voice_command tasker_voice_command_notfound );

  return $self;
}

#new_user(1, 'user_login', 'first_name', 'nick_name');
sub new_user {
  my ( $self, $userid, $username, $firstname, $nickname ) = @_;
  main::print_log("[Tasker_Interface] adding user: '$userid'") if $main::Debug{tasker};
  if(defined($self->{tasker_users}{$userid})) {
    main::print_log("[Tasker_Interface]\n\n\n\t\tERROR adding user, id $userid already exists!\n\n");
  }
  $self->{tasker_users}{$userid}={
    'username' => $username,
    'fname'    => $firstname,
    'nickname' => $nickname,
    'devices'  => {},
  };
  $self->{tasker_usernames}{$firstname} = $userid;
  $self->{tasker_usernames}{$username}  = $userid;
  $self->{tasker_usernames}{$nickname}  = $userid;
}

#new_device(1, '1', 'apikey', 'auto_remote_api_key', 'optional_password_sent_to_autoremote');
sub new_device {
  my ( $self, $userid, $deviceid, $apikey, $arkey, $arpasswd ) = @_;
  main::print_log("[Tasker_Interface] adding device: '$deviceid' for '$userid'") if $main::Debug{tasker};
  if(defined($self->{tasker_devices}{$userid.'-'.$deviceid})) {
    main::print_log("[Tasker_Interface]\n\n\n\t\tERROR adding device, id $deviceid already exists for user $userid!\n\n");
  }
  unless(defined($self->{tasker_users}{$userid})) {
    main::print_log("[Tasker_Interface]\n\n\n\t\tERROR adding device, userid $userid not found!\n\n");
  }
  $self->{tasker_devices}{$userid.'-'.$deviceid} = {
    'deviceid' => $deviceid,
    'userid'   => $userid,
    'apikey'   => $apikey,
    'arkey'    => $arkey,
  };
  $self->{tasker_users}{$userid}{devices}{$deviceid} = {
    'userid'   => $userid,
    'apikey'   => $apikey,
    'arkey'    => $arkey,
    'avpass'   => $arpasswd,
  };
  $self->{tasker_apikeys}{$apikey} = {
    'deviceid' => $deviceid,
    'userid'   => $userid,
    'arkey'    => $arkey,
  };
  $self->{tasker_arkey}{$arkey} = {
    'deviceid' => $deviceid,
    'userid'   => $userid,
    'apikey'   => $apikey,
  };
}

################################################################################################
# Utility subs
################################################################################################
#Send the URL to clients along with each API key for remote reontol
sub send_keys {
  my ($self, $nickname) = @_;
  my $key;
  main::print_log("[Tasker_Interface] nickname: '$nickname'") if $main::Debug{tasker};
  foreach my $devkey (keys %{$self->{tasker_devices}}) {
    if((!defined($nickname)) || $nickname eq 'reserved' || $nickname eq $self->{tasker_users}{$self->{tasker_devices}{$devkey}{userid}}{nickname}) {
      $key=$self->{tasker_devices}{$devkey}{apikey};
      main::print_log("[Tasker_Interface] devkey: $devkey") if $main::Debug{tasker};
      my $urlvars;
      $urlvars->{ttl}=300;
      $self->send($self->{tasker_devices}{$devkey}{userid}, $self->{tasker_devices}{$devkey}{deviceid}, "apikey::".$self->{tasker_devices}{$devkey}{apikey}." apiurl::".$self->{tasker_api_url}.'=:=',$urlvars);
    }
  }
}

#Standardize on a username, even if we only have an ID
sub get_userid {
  my ($self, $nickname) = @_;
  if (($nickname * 1) eq $nickname) { main::print_log("[Tasker_Interface] get_userid, is numeric: '$nickname'"); return $nickname; }
  if(!defined $self->{tasker_usernames}{$nickname} && $self->{tasker_usernames}{$nickname} != '') {
    main::print_log("[Tasker_Interface] ERROR: userid $nickname not found");
    return undef;
  }
  main::print_log("[Tasker_Interface] get_userid, not numeric: '$nickname' / Sending: $self->{tasker_usernames}{$nickname}");
  return $self->{tasker_usernames}{$nickname};
}

sub get_dev_api {
  my ($self, $nickname, $deviceid, $keyname) = @_;
  $keyname='apikey' unless defined $keyname;
  $nickname=$self->get_userid($nickname);
  return $self->{tasker_users}{$nickname}{devices}{$deviceid}{$keyname};
}

sub set_responses {
  my ($self, $resname, @responses) = @_;
  if($resname eq 'denied') {
    @tasker_denied=@responses;
    return 1;
  } elsif($resname eq 'unknown') {
    @tasker_unknown=@responses;
    return 1;
  } else {
    main::print_log("[Tasker_Interface] (set_responses) ERROR: Unknown response name: $resname");
  }
  return 0;
}

sub get_random_response {
  my ($self, $resname) = @_;
  my @responses=();
  if($resname eq 'denied') {
    @responses=@tasker_denied;
  } elsif($resname eq 'unknown') {
    @responses=@tasker_unknown;
  }
  return '' unless $#responses;
  return $responses[int rand($#responses)];
}

sub add_hook {
  my ( $self, $location, $hook, @parms ) = @_;
  unless ( defined( $hook_locations{$location} ) ) {
    print "[Tasker_Interface] add_hook: Invalid hook location, loc=$location hook=$hook\n";
    return 0;
  }

  unless ( ref $hook eq 'CODE' ) {
    print "[Tasker_Interface] add_hook: Hook must be a code reference, loc=$location hook=$hook\n";
    return 0;
  }

  $hook_pointers{$location} = [] unless defined( $hook_pointers{$location} );

  push( @{ $hook_pointers{$location} }, [ $hook, @parms ] );

  return 1;
}

sub get_hooks {
  my ($self, $location) = @_;
  return defined $hook_pointers{$location} ? @{ $hook_pointers{$location} } : ();
}

sub run_hooks {
  my ($self, $location, @hparms) = @_;
  my $i = 0;
  for my $ptr ( $self->get_hooks($location) ) {
    my ( $hook, @parms ) = @$ptr;
    &$hook( @_, @hparms, @parms );
  }
  if($#main::tasker_responses gt -1) {
    $main::tasker_cmd{responsetxt} = "reply: ".$main::tasker_responses[int rand($#main::tasker_responses)];
  }
}


################################################################################################
# Message sending to AutoRemote/Tasker
################################################################################################
sub send {
  my ($self, $userid, $deviceid, $message, $urlvars) = @_;
  $userid=$self->get_userid($userid);
  $urlvars->{'key'}=$self->{tasker_users}{$userid}{devices}{$deviceid}{arkey};
  $urlvars->{'password'}=$self->{tasker_users}{$userid}{devices}{$deviceid}{avpass} if defined $self->{tasker_users}{$userid}{devices}{$deviceid}{avpass};
  $urlvars->{'message'}=$message;
  $self->_send($urlvars);
}

sub send_with_key {
  my ($self, $autoremote_key, $message, $urlvars) = @_;
  my $userid = $self->{tasker_arkey}{$autoremote_key}{userid};
  my $deviceid = $self->{tasker_arkey}{$autoremote_key}{deviceid};
  $urlvars->{'key'}=$autoremote_key;
  $urlvars->{'password'}=$self->{tasker_users}{$userid}{devices}{$deviceid}{avpass} if defined $self->{tasker_users}{$userid}{devices}{$deviceid}{avpass};
  $urlvars->{'message'}=$message;
  main::print_log("[Tasker_Interface] $self->{tasker_users}{$userid}{fname}: Sending $message");
  $self->_send($urlvars);
}

sub _send {
  my ($self, $urlvars) = @_;
  $urlvars->{'ttl'}='30' unless defined($urlvars->{'ttl'});
  $urlvars->{'sender'}='Mister House';
  main::print_log("(_send) urlvars: ".&::Dumper($urlvars)) if $main::Debug{tasker};
  if(!defined $urlvars->{'key'}) {
    main::print_log("[Tasker_Interface] ERROR: key is blank, aborting.");
    return undef;
  }
  my $ARAPIURL="https://autoremotejoaomgcd.appspot.com/sendmessage?".qq[${\(join'&',map"$_=".uri_escape($urlvars->{$_}),keys%{$urlvars})}];

  main::print_log("[Tasker_Interface] URL: $ARAPIURL") if $main::Debug{tasker};
  my $browser = LWP::UserAgent->new(timeout => 10);
  my $response = $browser->get( $ARAPIURL );
  if(LWP::UserAgent->can('add_handler')) { #TODO: Maybe there's a better way to determine which version(s) work properly? The one that comes with MH is OLD and reports a 500 error even when this works.
    main::print_log("[Tasker_Interface] Can't get $ARAPIURL -- ", $response->status_line) unless $response->is_success;
    main::print_log("[Tasker_Interface] AR API RESPONSE: ".$response->content) if $main::Debug{tasker};
  } else {
    main::print_log("[Tasker_Interface] LWP::UserAgent is old. Unable to reliably determine success or failure.")
  }
}

sub _respond {
  my ($self, %parms) = @_;
  main::print_log("[Tasker_Interface] respond: ".&::Dumper(%parms)) if $main::Debug{tasker};
  main::print_log("[Tasker_Interface] respond: Sending response to tasker [$parms{api}]: $parms{text}");
  if(defined $self->{tasker_apikeys}{$parms{api}}) {
    my $userid=$self->{tasker_apikeys}{$parms{api}}{userid};
    my $deviceid=$self->{tasker_apikeys}{$parms{api}}{deviceid};
    my $autoremote_key = $self->{tasker_devices}{$userid.'-'.$deviceid}{arkey};
    my $usernickname = $self->{tasker_users}{$userid}{nickname};
    my $verb='say'; $verb='cmdresp' if $parms{resptype} eq 'cmdresp';
    $parms{text} =~ s/\ $usernickname\'s/ your/ig;
    $parms{text} =~ s/\ $usernickname/ your/ig;
    main::print_log("[Tasker_Interface] respond: usernickname: $usernickname") if $main::Debug{tasker};
    $self->send_with_key($autoremote_key, "=:=$verb=$parms{text}");
  } else {
    main::print_log("[Tasker_Interface] Response Error: no api key found!");
  }
}

################################################################################################
# UI notification management
################################################################################################
#To create notifications on Android phones for UI interraction
sub notify_send {
  my ($self, $userid, $deviceid, $title, $text, $actions, $urlvars) = @_;
  main::print_log("(notify_send) actions: ".&::Dumper(%{$actions})) if $main::Debug{tasker};
  $userid=$self->get_userid($userid);
  return unless defined $userid;
  my $message="=:=notify=$title:_:$text";
  while (my ($key, $value) = each (%{$actions})) {
    $message.=':-:'.$key.':_:'.$value;
  }
  #Allow for prefixing the message with arparms for things like silent=1
  $message.=':-:Dismiss:_:';
  if(defined $urlvars->{arparams}) {
    $message=$urlvars->{arparams}.$message;
    undef $urlvars->{arparams};
  }
  main::print_log("[Tasker_Interface] notify_send / Sending \"$title\" to $self->{tasker_users}{$userid}{fname}");
  main::print_log("(notify_send) urlvars: ".&::Dumper(%{$urlvars})) if $main::Debug{tasker};
  $self->send($userid, $deviceid, $message, $urlvars);
}

#To cancel a notification on Android phones for UI interraction
sub notify_cancel {
  my ($self, $userid, $deviceid, $title, $urlvars) = @_;
  $userid=$self->get_userid($userid);
  return unless defined $userid;
  main::print_log("[Tasker_Interface] notify_cancel / Dismissing \"$title\" for $self->{tasker_users}{$userid}{fname}");
  $self->send($userid, $deviceid, "=:=notify=$title", $urlvars);
}

1;
