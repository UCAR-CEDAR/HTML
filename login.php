<?php
global $auth_result ;

$mydocumentroot=$_SERVER["DOCUMENT_ROOT"];
set_include_path( $mydocumentroot );
require_once( "rstfl/CedarAuth.php" ) ;

header( "HTTP1.1/200 OK" ) ;
header( "Content-type: text/html" ) ;

# make sure this is https and not http. Redirect if http
# if https then check the status and act accordingingly
# if no status, then display the login form
# if status then username and password sent. Look up the user_password
# in user table, encrypt the password sent, compare, and return
# appropriately
# should have a refresh value or something.
# use post
if( $_SERVER["HTTPS"] != "on" )
{
    header("Location: https://cedarweb.vsp.ucar.edu/login.php");
    exit( 0 ) ;
}

$username=$_REQUEST["username"] ;
$password=$_REQUEST["password"] ;
if( $username == "" || $password == "" )
{
    display_table_start() ;
    print( "Welcome to CEDARweb Login<BR><BR>\n" ) ;
    print( "Please enter your CEDAR database user name and password<BR>\n" ) ;
    print( "<FORM method=\"POST\" action=\"https://cedarweb.vsp.ucar.edu/login.php\" name=\"cedar_login\"><BR>\n" ) ;
    print( "<INPUT name=\"username\" type=\"TEXT\" size=\"30\"><BR>\n" ) ;
    print( "<INPUT name=\"password\" type=\"password\" size=\"30\"><BR>\n" ) ;
    print( "<INPUT name=\"reset\" type=\"reset\"><INPUT name=\"submit\" value=\"Login\" type=\"submit\"><BR>\n" ) ;
    print( "</FORM><BR>\n" ) ;
    print( "Don't have a CEDARweb login? <A HREF=\"http://cedarweb.vsp.ucar.edu/wiki/index.php/Special:Cedar_Create_Account\"><I>Apply for one now</I></A>\n" ) ;
    print( "<BR />\n" ) ;
    print( "<BR />\n" ) ;
    print( "Forgotten your password? Go to <A HREF=\"http://cedarweb.vsp.ucar.edu/wiki/index.php?title=Special:Userlogin\"><I>the CEDAR Wiki</I></A>, enter your username, and click E-mail passowrd.\n" ) ;
    print( "<BR />\n" ) ;
    print( "<BR />\n" ) ;
    print( "If you experience problems logging in, please contact <A HREF=\"mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username\"><I>the CEDARweb administrator</I></A>!\n" ) ;
    print( "<BR />\n" ) ;
    print( "<BR />\n" ) ;
    print( "<A HREF=\"/index.html\">Return to CEDARweb main page!</A>\n" ) ;
    display_table_end() ;
}
else
{
    display_table_start() ;
    $auth = new CedarAuth() ;
    if( !$auth )
    {
	$auth_result = "Failed to authenticate user $username. Problems accessing the CEDAR user database.<BR>\n" ;
    }
    else
    {
	$auth->execute( "cedar_login" ) ;
	$sid = session_id() ;
	if( $sid == "" ) session_start() ;
	$sid = session_id() ;
	$_REQUEST['token'] = $sid ;
	$auth->execute( "cedar_session" ) ;
    }
    if( $auth_result == "good" )
    {
	print_cookie_code( $username ) ;
    }
    else
    {
	echo "$auth_result<BR>\n" ;
    }
    display_table_end() ;
}

function display_table_start()
{
    print( "<TABLE ALIGN=\"CENTER\" BORDER='1' WIDTH='800' CELLPADDING='2' CELLSPACING='2'>\n" ) ;
    print( "    <TR>\n" ) ;
    print( "        <TD WIDTH='20%%'>\n" ) ;
    print( "            <P ALIGN='center'>\n" ) ;
    print( "                <A HREF='http://www.ucar.edu' TARGET='_blank'><IMG SRC='http://cedarweb.vsp.ucar.edu/images/CedarwebUCAR.gif' ALT='UCAR' BORDER='0'><BR><FONT SIZE='2'>UCAR</FONT></A>\n" ) ;
    print( "            </P>\n" ) ;
    print( "        </TD>\n" ) ;
    print( "        <TD WIDTH='80%%'>\n" ) ;
    print( "            <P ALIGN='center'>\n" ) ;
    print( "                <IMG BORDER='0' SRC='http://cedarweb.vsp.ucar.edu/images/Cedarweb.jpg' ALT='CEDARweb'>\n" ) ;
    print( "            </P>\n" ) ;
    print( "        </TD>\n" ) ;
    print( "    </TR>\n" ) ;
    print( "    <TR>\n" ) ;
    print( "        <TD COLSPAN=\"2\" ALIGN='CENTER' WIDTH=\"100%\">\n" ) ;
}

function display_table_end()
{
    print( "        </TD>\n" ) ;
    print( "    </TR>\n" ) ;
    print( "</TABLE>\n" ) ;
}

function print_cookie_code( $username )
{
    print( "<SCRIPT LANGUAGE=\"JavaScript\">\n" ) ;
    print( "<!--\n" ) ;
    print( "var cookieVal = \"$username\" ;\n" ) ;
    print( "var cookieDate = new Date() ;" ) ;
    print( "cookieDate.setTime( cookieDate.getTime() + 24*60*60*1000) ;\n" ) ;
    print( "var theCookie = \"OpenDAP.remoteuser=\" + escape(cookieVal) + \"; domain=cedarweb.vsp.ucar.edu; path=/; expires=\" + cookieDate.toGMTString() ;\n" ) ;
    print( "document.cookie = theCookie ;\n" ) ;
    print( "var theCookie = document.cookie ;\n" ) ;
    print( "if( theCookie == \"\" )\n" ) ;
    print( "{\n" ) ;
    print( "document.writeln( \"You must enable the creation of cookies in your browser in order to sign in to CedarWeb.\" ) ;\n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "document.writeln( \"Please enable cookies in your browser and refresh this page.\" ) ;\n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "document.writeln( \"If you continue to experience problems logging in, please contact <A HREF=\\\"mailto:cedar_db@hao.ucar.edu?Subject=CEDARweb%3A%20Problem%20logging%20in&Body=Please%20include%20any%20error%20messages%20you%20may%20see%20and%20your%20username\\\"><I>the CEDARweb Administrator</I></A>!\" ) \n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "}\n" ) ;
    print( "else\n" ) ;
    print( "{\n" ) ;
    print( "document.writeln( \"User <b>$username</b> connected to CEDARweb\" ) ;\n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "document.writeln( \"<BR />\" ) ;\n" ) ;
    print( "document.writeln( \"<A HREF=\\\"javascript:parent.self.close()\\\">Continue Browsing Data</A>\" ) ;\n" ) ;
    print( "}\n" ) ;
    print( "//-->\n" ) ;
    print( "</SCRIPT>\n" ) ;
    print( "<NOSCRIPT>\n" ) ;
    print( "CedarWeb sign in uses JavaScript. Please enable JavaScript and refresh this page.\n" ) ;
    print( "</NOSCRIPT>\n" ) ;
}
?>
