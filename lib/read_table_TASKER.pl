# Category = Tasker
#@Tasker voice commands
################################################################################################
use strict;
# Format = TASKER

sub read_table_init_TASKER {
    &::print_log("Initialized read_table_TASKER");
}

sub read_table_TASKER {
    my ($record) = @_;

    if($record =~ /^#/ or $record =~ /^\s*$/) {
        return;
    }
    $record =~ s/\s*#.*$//;

    my $code='';
    my(@item_info) = split(',\s*', $record);
    my $type = uc shift @item_info;

    if($type eq "TASKER_INTERFACE") {
        $code .= "use Tasker_Interface;\n";
        $code .= '$TaskerInt = new Tasker_Interface(\''.$item_info[0].'\'); #noloop'."\n";

    } elsif($type eq "TASKER_USER") {
        #$TaskerInt->new_user(userid, username, firstname, nickname);
        $code .= '$TaskerInt -> new_user('.$item_info[0].", '".$item_info[1]."', '".$item_info[2]."', '".$item_info[3]."'); #noloop\n";

    } elsif($type eq "TASKER_DEVICE") {
        #$TaskerInt->new_device( userid, deviceid, apikey, autovoice_apikey, ?password?);
        $item_info[3] =~ s/^http.*\?key=//;
        $code .= '$TaskerInt -> new_device('.$item_info[0].", '".$item_info[1]."', '".$item_info[2]."', '".$item_info[3]."'";
        $code .= ", '".$item_info[4]."'" if defined $item_info[4];
        $code .= "); #noloop\n";

    } else {
        print_log "\nUnrecognized .mht entry for $type: $record\n";
        return;

    }
    $record='';
    return $code;
}

sub read_table_finish_TASKER {
    my $code = '#TASKER here';
    return $code;

}

1;
