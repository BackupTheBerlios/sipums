package OpenUMS::CallOut; 

use strict; 
use OpenUMS::DbQuery;
use OpenUMS::Config;
use OpenUMS::Log;

my $MAX_INTRO_PROMPT_PLAY = 5; 


#################################
## sub do_callout
#################################
sub do_callout {
  my ($ctport, $dbh, $phone_sys, $message_file, $ext ) = @_;  
  ## this is real simple and straight forward 
  
  ## part 1) query db about message...
  my $msg_hr = OpenUMS::DbQuery::get_message($dbh, $message_file);

  if (! $ext ) {
     $ext = $msg_hr->{extension_to}; 
  } 
  $ctport->set_paths(BASE_PATH);
#  $ctport->on_hook()  ;
#  $ctport->set_paths(BASE_PATH);
#  sleep 3;
                                                                                                                                               
  $log->debug("clearing events and  going off_hook...");
  $ctport->clearevents();
  $ctport->off_hook()  ;
  $ctport->dial(",,$ext");
  sleep 1;

  ## get any stray stuff out...
  $ctport->collect(10,1)  ;
  sleep 1; 
  my $played = 1 ;
  my $input = undef;
  ## keep looping till the press 1
  # while ( $played < $MAX_INTRO_PROMPT_PLAY  && $input ne '*' && $input ne '9') {
  #  $ctport->play(PROMPT_PATH .  'callout_menu_intro.wav');
  #  $input = $ctport->collect(1,3) ;
  #  $log->debug("input =  $input\n");
  #  $played++;
  #}
  ## they never pressed a key or it kept ringing and ringing
  #if ($played >= $MAX_INTRO_PROMPT_PLAY  ) { 
  #   return OpenUMS::CallOut::end_call($ctport);
  #} 

  OpenUMS::CallOut::play_message($ctport,$dbh,$phone_sys, $msg_hr,$ext ); 

  my $in =  $ctport->collect(3,5) ; 

  return OpenUMS::CallOut::end_call($ctport);
}

#################################
## sub end_call
#################################
sub end_call {
  my $ctport = shift ; 
  $ctport->play($main::CONF->get_var('VM_PATH') . PROMPT_PATH .  'goodbye.vox');
  $ctport->on_hook()  ;
  return 1;

}

#################################
## sub play_message
#################################
sub play_message {
  my ($ctport,$dbh, $phone_sys, $msg_hr, $ext)  = @_;
  my $flag =  ($msg_hr->{extension_to} ne $ext || $msg_hr->{message_status_id} ne 'D') ;
  ## $log->debug("Flag = $flag ");
  if (($msg_hr->{extension_to} eq $ext) && ($msg_hr->{message_status_id} =~ /^S|^N/) ) { 
    $log->debug("Message owner is different from extension than message $ext $msg_hr->{extension_to} $msg_hr->{messsage_wav_file} $msg_hr->{message_status_id}");
    OpenUMS::CallOut::logged_in_callout_menu($ctport, $dbh, $phone_sys, $msg_hr, $ext ); 
  } else {
    $log->debug("here, we'd log them in  as $ext message_status_id = $msg_hr->{message_status_id}");
    OpenUMS::CallOut::single_callout_menu($ctport, $dbh, $msg_hr, $ext) ; 
    return ;
  } 
}

#################################
## sub single_callout_menu
#################################
sub single_callout_menu {
  my ($ctport,$dbh,  $msg_hr, $ext)  = @_;

  $log->debug("file = " . USER_PATH .  $msg_hr->{message_wav_path} . $msg_hr->{message_wav_file} );
  my $i = 0;

  while ($i < 4 ) {
    my $sound ;
    if ($i ==0) {
      $sound = $msg_hr->{message_wav_path}. $msg_hr->{message_wav_file};
      $sound .= " " . PROMPT_PATH . "callout_message_menu.vox";
    } else {
      $sound = PROMPT_PATH . "callout_message_menu.vox";
    }
    $ctport->play($sound) ;
    $i++;
                                                                                                                                               
    my $input = $ctport->collect(1,3) ;
    if ($input =~ /^9/ ) {
       $i =100;
    }  elsif ($input =~ /^1/ )  {
       $i = 0;
    }
 }
 return ;
}
#################################
## sub single_callout_menu
#################################
sub logged_in_callout_menu {
  my ($ctport,$dbh,$phone_sys, $msg_hr, $ext)  = @_;
  my $menu = new OpenUMS::Menu::Menu($dbh,$ctport,$phone_sys,undef);
  $menu->create_menu();
  ## get the user object....
  my $user = $menu->get_user();
  ## do the little auto_login thingie..
  $user->auto_login($ext) ;

  ## do the set the last message file to the message they requested 
  $user->last_message_file($msg_hr->{message_wav_file});

  $user->set_message_jump_flag();  ## this tells the spool to jump to the message they wanna hear
  my $menu_function = $msg_hr->{message_status_id} . '_messages' ; 
  $log->debug("gonna find menu_function =  $menu_function"); 
  my $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, $msg_hr->{message_status_id} . '_messages'); 

  $log->debug("logged user in : " . $user->extension() . "menu_id to run will be $menu_id" ) ; 

  return $menu->run_menu( $menu_id ); 
}
1;
