<?
function get_smarty_header($data, $auth, $perm ) {

  $smarty = get_smarty();
  $smarty->assign("uname",$auth->auth[uname]);
  if ($perm->have_perm('SUPER') ) {
    $smarty->assign("admin_reseller",1); 
    $smarty->assign("admin_clients",1); 
  } 

  if ($perm->have_perm('SUPER') || $perm->have_perm('RESELLER') ) {
    ## they are allowed to view more than one domain
    // change_domain();
    $smarty->assign("admin_domain",1);
    $opts = $data->get_domain_options(null,null);

    $udomain_values = $opts[0];
    $udomain_output = $opts[1];
                                                                                                                                               
    $smarty->assign("udomain_values", $udomain_values);
    $smarty->assign("udomain_output", $udomain_output);
    global $adomain;
                                                                                                                                               
    if ($adomain) {
      $smarty->assign("udomain_selected", $adomain);
    } else {
      $smarty->assign("udomain_selected", $auth->auth[udomain]);
    }
  } else {
    $smarty->assign("admin_domain",0);
    $smarty->assign("udomain",$auth->auth[udomain]);
  }

  if ($perm->have_perm('ADMIN') ) {
    $smarty->assign("admin_subscribers",1);
    $smarty->assign("admin_voicemail",1);
  } 

  return $smarty ;

}
function get_smarty() {
  $smarty = new Smarty;
  $smarty->left_delimiter = '<!--{';
  $smarty->right_delimiter = '}-->';
  $smarty->assign("thispage", basename($_SERVER['PHP_SELF']));
  return $smarty;
}

?>
