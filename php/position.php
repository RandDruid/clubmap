<?php

// ####################### SET PHP ENVIRONMENT ###########################
error_reporting(E_ALL & ~E_NOTICE);

// #################### DEFINE IMPORTANT CONSTANTS #######################
define('NO_REGISTER_GLOBALS', 1);
define('THIS_SCRIPT', 'position');
define('LOCATION_BYPASS', 1);
define('NOPMPOPUP', 1);

// ######################### REQUIRE BACK-END ############################
require_once('./global.php');

// #######################################################################
// ######################## START MAIN SCRIPT ############################
// #######################################################################

if ($_REQUEST['do'] == 'login')
{
    require_once('./includes/functions_login.php');
    
    $vbulletin->input->clean_array_gpc('g', array(
            'vb_login_username'        => TYPE_STR,
            'vb_login_password'        => TYPE_STR,
            'vb_login_md5password'     => TYPE_STR,
            'vb_login_md5password_utf' => TYPE_STR,
            'postvars'                 => TYPE_BINARY,
            'cookieuser'               => TYPE_BOOL,
            'logintype'                => TYPE_STR,
            'cssprefs'                 => TYPE_STR,
    ));

    // can the user login?
    $strikes = verify_strike_status($vbulletin->GPC['vb_login_username']);

    if ($vbulletin->GPC['vb_login_username'] == '')
    {
        exit;
    }

    // make sure our user info stays as whoever we were (for example, we might be logged in via cookies already)
    $original_userinfo = $vbulletin->userinfo;

    if (!verify_authentication($vbulletin->GPC['vb_login_username'], $vbulletin->GPC['vb_login_password'], $vbulletin->GPC['vb_login_md5password'], $vbulletin->GPC['vb_login_md5password_utf'], $vbulletin->GPC['cookieuser'], true))
    {
        // check password
        exec_strike_user($vbulletin->userinfo['username']);
        $vbulletin->userinfo = $original_userinfo;
        exit;        
    }

    exec_unstrike_user($vbulletin->GPC['vb_login_username']);

    // create new session
    process_new_login($vbulletin->GPC['logintype'], $vbulletin->GPC['cookieuser'], $vbulletin->GPC['cssprefs']);
}

echo "userid" . $vbulletin->userinfo['userid'] . ";";

if ($vbulletin->userinfo['userid']) {
    // Save position
    if (is_numeric($_REQUEST['x']) and is_numeric($_REQUEST['y']) and is_numeric($_REQUEST['s']) and is_numeric($_REQUEST['i']))
    {
        $db->query_write("
          REPLACE " . TABLE_PREFIX . "userpositions
          SET
            userid=" . $vbulletin->userinfo['userid'] ."
            ,dateline=" . time() . "
            ,lat=" . intval($_REQUEST['y']) . "
            ,lon=" . intval($_REQUEST['x']) . "
            ,status=" . intval($_REQUEST['s']) . "
            ,icon=" . intval($_REQUEST['i'])
        );
    }

    // Search users in the box
    if (is_numeric($_REQUEST['x0']) and is_numeric($_REQUEST['y0']) and is_numeric($_REQUEST['x1']) and is_numeric($_REQUEST['y1']))
    {
        $users = $db->query_read("
          SELECT A.userid, B.username, A.lat, A.lon, A.status, A.icon
          FROM " . TABLE_PREFIX . "userpositions AS A
          JOIN " . TABLE_PREFIX . "user AS B 
          ON A.userid = B.userid
          WHERE (A.lat BETWEEN " . intval($_REQUEST['y0']) . " AND " . intval($_REQUEST['y1']) . ")
            AND (A.lon BETWEEN " . intval($_REQUEST['x0']) . " AND " . intval($_REQUEST['x1']) . ")
            AND A.status = 1
            AND A.dateline > " . (time() - 86400)
        );

        while ($uinfo = $db->fetch_array($users)) {
            echo $uinfo['userid'] . "," . $uinfo['username'] . "," . $uinfo['lat'] . "," . $uinfo['lon'] . "," . $uinfo['status'] . "," . $uinfo['icon'] . ";";
        }

        $db->free_result($users);
    }
}

?>