use strict;
# Format = TASKER
my %tasker_authority;
#my $TaskerInt; #noloop

sub read_table_init_TASKER {
    #$TaskerInt = new Tasker_Interface();
    &::print_log("Initialized read_table_TASKER");

}

sub read_table_TASKER {
    #&::print_log("In read_table_TASKER!");
    my ($record) = @_;

    if($record =~ /^#/ or $record =~ /^\s*$/) {
        return;
    }
    $record =~ s/\s*#.*$//;

    my $code='';
    my(@item_info) = split(',\s*', $record);
    my $type = uc shift @item_info;

    #print_log("[TASKER] (read_table_TASKER) type: $type");

    if($type eq "TASKER_INTERFACE") {
        $code .= "use Tasker_Interface;\n";
        $code .= '$TaskerInt = new Tasker_Interface(\''.$item_info[0].'\'); #noloop'."\n";
        #$code .= "\$Run_Members{'android_users_table'} = 100;\n";

    } elsif($type eq "TASKER_USER") {
        #$TaskerInt->new_user(userid, username, firstname, nickname);
        $code .= '$TaskerInt -> new_user('.$item_info[0].", '".$item_info[1]."', '".$item_info[2]."', '".$item_info[3]."'); #noloop\n";

    } elsif($type eq "TASKER_DEVICE") {
        #$TaskerInt->new_device( userid, deviceid, apikey, autovoice_apikey);
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
