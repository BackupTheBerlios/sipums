#!/usr/bin/perl

  close (STDERR) ; 
  open  (STDERR, ">>/tmp/callout.err");
  print STDERR "called begin :) \n"  ;


## all the required
  use strict; 

  use lib '/usr/local/openums/lib';
  use OpenUMS::CallOut;
  use Telephony::CTPort;
  use Telephony::CTPortManager;
  use CGI; 

  my $cgi  = new CGI;
  my $cookie; 
  my $error; 
  print STDERR "remember is " . $cgi->param('remember') . "\n";
  
  my $global_callout_extension = $cgi->cookie('callout_extension') ; 
  my $form_extension = $cgi->param('extension') ; 

  if ($form_extension && $global_callout_extension  ne $form_extension) { 
     $global_callout_extension = $form_extension ; 
  } 
  
  print STDERR "callout_extension  $global_callout_extension\n";
  
  if ($cgi->param('remember') ) { 
     ## make them a cookie forever...
   print STDERR "remember is " . $cgi->param('remember') . "\n";
     $cookie = $cgi->cookie(-name=>'callout_extension',
                                    -value=>$global_callout_extension ,
                                    -expires=>'+10y'
                                    );
  } 
  if ($cookie) {   
    print $cgi->header(-cookie=>$cookie); 
  } else {
    print $cgi->header(); 
    
  } 
  my $html  ;
  if ($cgi->param('do_callout') && $cgi->param('message_file') && &validate_message_file( $cgi->param('message_file') )  )  { 
    $html = &get_response($cgi);
    my $ctport = new Telephony::CTPortManager();
    my $port = $ctport->find_idle();
    print STDERR "Found Idle port on $port, sending callout\n" ;
    $ctport->send_message($port,  "callout", $cgi->param('message_file'), $cgi->param('extension')  );
  } else {
#    if ($cgi->param('do_callout')) { 
       $html = &get_form($cgi); ## 'No Message File');
#    } 
  } 
  print $html; 

sub get_form {
  my $cgi = shift ; 

  my $message_file = $cgi->param('message_file');
  

  my $html = qq{
   <HTML><HEAD><Title> Callout Form</TITLE>
  <style type="text/css">\@import url("/style/style.css"); </style>
   </head>

   <body>
   <FORM action='callout.cgi' name='callout' method='get'>
    <input type='hidden' name='do_callout' value=1>
<table> 
<tr> <td colspan=2> 
  <!-- top menu/ log --> 
  <img height='79' src='/images/company_logo.jpg' border='0'> 
</td> </tr>
<tr> <td align='center' valign='top' width="300" > 

  <!-- left column--> 
  <table> 
}; 
  if ($error) { 
    $html .= qq{  <tr><td colspan=2 align=center>
     <B><FONT color='red'>$error</b>
     </td>
     </tr>
    } ; 

  } 
  my $extension_dd = &get_extension_dd(); 
  $html .= qq{ 
    <tr>
      <td> File Name:</td> 
      <td> <input name='message_file' value='$message_file' size=30 ></td> 
    </tr><tr>
      <td> Your Extension :</td> 
      <td> $extension_dd </td> 
    </tr><tr>
      <td colspan=2 ><input type='checkbox' name='remember' value=1 CHECKED>Remember my extension on this computer. </td>
    </tr><tr>
      <td colspan=2 align='center'> <input type='submit' value='Call Me' >  </td>
    </tr>
    <tr>
      <td colspan=2 align='center'>If extension is blank, callout will call extension that the message was left for. </td>
    </tr>
  </table>
</td> 

</table>
</form>
     
   </body> 
   

  };  
  return $html ;

}
sub get_response {
  my $cgi = shift ;
  my $extension = $cgi->param('extension');

  my $message_file = $cgi->param('message_file');

  my $html = qq{
   <HTML><HEAD><Title> Callout Form</TITLE>
  <style type="text/css">\@import url("/style/style.css"); </style>
   </head>

   <body>
<table> 
<tr> <td colspan=2> 
  <!-- top menu/ log --> 
  <img height='79' src='/images/company_logo.jpg' border='0'> 
</td> </tr>
<tr> <td align='center' valign='top' width="300" > 

  <!-- left column--> 
  <table> 
    <tr>
      <td colspan=2 align='center'>Please allow 15 to 30 seconds for callout. </td>
    </tr>
    <tr>
      <td> File Name:</td> 
      <td> <B>$message_file</b></td> 
    </tr><tr>
      <td> Extension :</td> 
      <td><B> $extension</b></td> 
    </tr>
    <tr>
      <td colspan=2 align='center'>If extension is blank, callout will call extension that the message was left for. </td>
    </tr>
  </table>
</td> 

</table>
</form>
     
   </body> 
   

  };  
  return $html ;
}
sub get_extension_dd {
  
  use OpenUMS::Common ; 
  my $dbh = OpenUMS::Common::get_dbh(); 
  my $statement = "SELECT  extension FROM VM_Users WHERE active = 1 and extension <> 0 ORDER BY extension " ; 
  my $ary_ref = $dbh->selectcol_arrayref($statement);
  my $opt = "<SELECT NAME='extension'>" ; 
  foreach my $ext (@{$ary_ref} ) {
     $opt .="<OPTION VALUE='$ext' " ; 
     if ($global_callout_extension eq $ext) { 
     $opt .='SELECTED' ; 
     } 
     $opt .=">$ext</option>";        
  } 
  $opt .= "</SELECT>" ; 
  $dbh->disconnect(); 
  return $opt; 
}
sub validate_message_file {
  my $message_wav_file = shift ; 
  use OpenUMS::Common; 
  my $dbh = OpenUMS::Common::get_dbh();
  my $statement = qq{ SELECT count(*)  FROM VM_Messages WHERE message_wav_file = ? AND message_status_id in ('N','S','D') } ; 
  my $sth = $dbh->prepare( $statement );
  $sth->execute($message_wav_file); 
  my $count = $sth->fetchrow(); 
  if ($count == 0 ) { 
     $error = "User Error: Invalid message file name. ";      
  } 
  print STDERR "validate_message_file returning $count \n"  ;
  return $count; 
 




}
