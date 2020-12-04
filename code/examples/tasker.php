<?php
###############################################################
$MHSERVERIP='192.168.1.15';
$MHSERVERPORT=8080;
$MHSERVERTIMEOUT=6;

###############################################################
$MHSCRIPTNAME='tasker_link.pl';

###############################################################
function getIP() {
  if (getenv('HTTP_X_FORWARDED_FOR')) {
    $IP = getenv('HTTP_X_FORWARDED_FOR');
  }
  elseif (getenv('HTTP_X_REAL_IP')) {
    $IP = getenv('HTTP_X_REAL_IP');
  }
  else {
    $IP = $_SERVER['REMOTE_ADDR'];
  }
  return $IP;
}

###############################################################
if ($_SERVER['HTTPS'] == "on") {
    $URL='http://'.$MHSERVERIP.':'.$MHSERVERPORT.'/'.$MHSCRIPTNAME.'?'.$_SERVER['QUERY_STRING'];
    error_log("Calling URL: $URL");
    $ch = curl_init($URL);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, $MHSERVERTIMEOUT);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
      'X-REAL-IP: '.getIP(),
    ));
    curl_setopt($ch, CURLOPT_USERAGENT, $_SERVER['HTTP_USER_AGENT']);
    $response = curl_exec($ch);
    $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    error_log("CURL response code: $httpcode");
    if (curl_error($ch)) {
        $error_msg = curl_error($ch);
        print 'ERROR: Curl '.$error_msg;

        if(strpos($error_msg, 'Operation timed out') !== false) {
            header("HTTP/1.1 504 Gateway Timeout");
            print 'ERROR: Timeout';
            error_log('Sending timeout');
            exit;
        }
        error_log('ERROR: Curl '.$error_msg);
        exit;
    }

    curl_close($ch);
    if(!in_array($httpcode, array(200))) {
        header("HTTP/1.1 $httpcode OK");
        print 'ERROR: Received HTTP code '.$httpcode;
        error_log('ERROR: Received HTTP code '.$httpcode);
        exit;
    }
    $response=rtrim($response);
    error_log("Responding with: $response");
    print $response;
} else {
    print "failed";
    error_log("Responding with: failed");
}

#error_log(print_r($_SERVER,true));
exit;
?>
