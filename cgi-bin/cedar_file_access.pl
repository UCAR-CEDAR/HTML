#!/opt/local/bin/perl

use lib "/project/cedar/lib/perl/lib/perl5/site_perl/5.8.8";
use File::MimeInfo ;

#&serviceUnavailable ;

################################################################################
$VERSION="cookietest.pl v1.1"; #Aug. 18, 1996 Dale Bewley <dlbewley@iupui.edu>
# v1.0 29 June 96, v0.9 14 May 96
#-------------------------------------------------------------------------------
# This script and others found at http://www.bewley.net/perl/
#
# Simple cookie demo.
# For more info see:
#	http://www.bewley.net/perl/cookie-test.html
#
# Distributed through Cookie Central. http://www.cookiecentral.com.
#
################################################################################

#------------------------------------------------------------------------------#
#- User configurable variables ------------------------------------------------#

#------------------------------------------------------------------------------#
#- Main Program ---------------------------------------------------------------#

$baseDir="/project/cedar/html/protected" ;
$logFile="/project/cedar/logs/cedar_file_access.log" ;

open( DEBUGFILE, '>', "/project/cedar/src/pwest/access.log" ) ;

################################################################################
# Get the cookie from the environment variable HTTP_COOKIE. Once retrieved,
# check to see if this user has a session currently in the sessions table.
# If so then continue, if not then return a screen that allows the user to
# login.
################################################################################
local(@rawCookies)=split(/; /,$ENV{'HTTP_COOKIE'});
local(%cookies);

foreach(@rawCookies){
    ($key, $val)=split(/=/,$_);
    $cookies{$key}=$val;
} 

$logu="undefined";
$cookieu=$cookies{"OpenDAP.remoteuser"};
print( DEBUGFILE "Cookie = $cookieu\n" ) ;
if( $cookieu eq "" )
{
    &notLoggedIn;
    exit 1 ;
}
else
{
    print( DEBUGFILE "checking access for $cookieu\n" ) ;
    #$ckacc="/project/cedar/src/pwest/opendap/DODS/src/access/check_access";
    $ckacc="/project/cedar/bin/tools/check_access";
    $logu=`$ckacc $cookieu`;
    print( DEBUGFILE "logu = $logu\n" ) ;
    chop $logu;
    if( $logu ne $cookieu )
    {
	&notLoggedIn;
	exit 1;
    }
}

################################################################################
# Get the contents of the URL. If a GET method is used then the environment
# variale QUERY_STRING will be set. If not, then we can read in the
# variables passed to this script. Either way, the string will look like
# var1=val1&var2=val2, so use split to take each var=val and store in pairs.
################################################################################
if( $ENV{ 'REQUEST_METHOD' } eq 'GET' )
{
    print( DEBUGFILE "GET method used\n" ) ;
    print( DEBUGFILE "    QUERY_STRING = $ENV{'QUERY_STRING'}\n" ) ;
    @pairs = split( /&/, $ENV{ 'QUERY_STRING' } ) ;
}
else
{
    read( STDIN, $buffer, $ENV{ 'CONTENT_LENGTH' } ) ;
    print( DEBUGFILE "Not the GET method, use STDIN\n" ) ;
    print( DEBUGFILE "    buffer = $buffer\n" ) ;
    @pairs = split( /&/, $buffer ) ;
}

################################################################################
# For each pair in pairs split these by the equal (=) operator and store the
# values into name and value. De-internet these things and store in the
# array FORM
################################################################################
foreach $pair (@pairs)
{
    ($name, $value) = split( /=/, $pair ) ;
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
    $value =~ s/<!--(.|\n)*-->//g;
    if( $FORM{$name} ne "" )
    {
	    $FORM{$name} .= "; $value";
    }
    else
    {
        $FORM{$name} = $value;
        print( DEBUGFILE "Adding $name with value $value to FORM\n" ) ;
    }
}

################################################################################
# Now, get the filename from the FORM variables. If the filename is not
# specified then this thing will return an error screen to the user stating
# that no filename was passed.
################################################################################
if( $FORM{'filename'} eq "" )
{
    &noFileSpecified ;
}
print( DEBUGFILE "filename = $FORM{'filename'}\n" ) ;

################################################################################
# Set the full path to this file using the baseDir variable defined above.
# If the file does not exist then return an error screen to the user stating
# this. If we are unable to read this file then return an error screen to
# the user stating this.
################################################################################
$requestedFile=$FORM{'filename'} ;
if( index( $requestedFile, "../" ) != -1 )
{
    &accessToFileDenied ;
}
$fullPath="$baseDir/$requestedFile" ;
if( !-e "$fullPath" )
{
    &unableToOpenFile ;
}
if( !-r "$fullPath" )
{
    &unableToOpenFile ;
}
print( DEBUGFILE "fullPath = $fullPath\n" ) ;
my $file_type = mimetype( $fullPath ) ;
print( DEBUGFILE "type = $file_type\n" ) ;

################################################################################
# Now, dump this file to STDOUT and return the header stating that this is
# an attachment. There are many different formats of files that we will be
# returning so instead of trying to figure out which application to use, we
# will just specify that this file is to be download and let the user open
# the file once it has been download. Some browsers will know that, for
# example, this file is a pdf file and will do the appropriate thing. Other
# browsers are not so sophisticated and will not know what to do, but they
# will be able to download the file.
################################################################################
print( DEBUGFILE "Open the file and attach it\n" ) ;
select( STDOUT ) ;
$| = 1 ;
open( FILE, "<$fullPath" ) ;
if( -B $fullPath )
{
    binmode( FILE ) ;
}
$size = (stat( FILE ))[7] ;
$blockSize = (stat( FILE ))[11] ;
$blockSize = 16384 unless( $blockSize ) ;
print( DEBUGFILE "blockSize = $blockSize\n" ) ;
print( DEBUGFILE "size = $size\n" ) ;

#print( "Content-Type: application\/x-download\n" ) ;
print( "Content-Type: $file_type\n" ) ;
print( "Content-Disposition: attachment\; filename=$FORM{'filename'}\n" ) ;
print( "Content-Length: $size\n\n" ) ;

while( $length = sysread( FILE, $buffer, $blockSize ) )
{
    unless( defined $length ) { next if $! =~ /^Interrupted/; }
    $written = 0 ;
    while( $length )
    {
        $written = syswrite( STDOUT, $buffer, $length ) ;
        $length -= $written ;
    }
}
close( FILE ) ;

#FIXME: Log information about access, what was accessed
print( DEBUGFILE "print information to log file\n" ) ;
open( LOGFILE, '>>', "$logFile" ) ;
use POSIX qw(strftime);
$now_string = strftime( "[%a %b %e, %Y %H:%M:%S]", gmtime() ) ;
print( LOGFILE "$now_string User $logu accessed file $fullPath\n" ) ;
close( LOGFILE ) ;

exit 0 ;

sub headerInfo
{
    #FIXME: load this from cedar_login.html in htdocs
    print("Content-type: text/html\n\n"); 
    print( "<HTML>\n" ) ;
    print( "<HEAD></HEAD>\n" ) ;
    print( "<BODY>") ;
    print( "<TABLE ALIGN='CENTER' BORDER='1' WIDTH='800' CELLPADDING='2' CELLSPACING='2'>\n" ) ;
    print( "<TR>\n" ) ;
    print( "<TD WIDTH='20%'>\n" ) ;
    print( "<P ALIGN='center'>\n" ) ;
    print( "<A HREF='http://www.ucar.edu' TARGET='_blank'><IMG SRC='http://cedarweb.hao.ucar.edu/images/CedarwebUCAR.gif' ALT='UCAR' BORDER='0'><BR><FONT SIZE='2'>UCAR</FONT></A>\n" ) ;
    print( "</P>\n" ) ;
    print( "</TD>\n" ) ;
    print( "<TD WIDTH='80%'>\n" ) ;
    print( "<P ALIGN='center'>\n" ) ;
    print( "<IMG BORDER='0' SRC='http://cedarweb.hao.ucar.edu/images/Cedarweb.jpg' ALT='CEDARweb'>\n" ) ;
    print( "</P>\n" ) ;
    print( "</TD>\n" ) ;
    print( "</TR>\n" ) ;
    print( "<TR>\n" ) ;
    print( "<TD ALIGN='CENTER' COLSPAN='2' WIDTH='100%'>\n" ) ;
}

sub endInfo
{
    print( "</TD>\n" ) ;
    print( "</TR>\n" ) ;
    print( "</TABLE>\n" ) ;
    print( "</BODY></HTML>\n" ) ;
}

sub notLoggedIn
{
    &headerInfo ;
    print( "We were unable to authenticate your session for user $cookieu\n" ) ;
    print( "<BR />\n" ) ;
    print( "<BR />\n" ) ;
    print( "Please follow <A HREF=\"https://cedarweb.hao.ucar.edu/login.php\" TARGET=\"NEW\">this link</A> to login.\n" ) ;
    print( "Then refresh this page to get your data once you have logged in\n" ) ;
    &endInfo ;
}

sub noFileSpecified
{
    &headerInfo ;
    print( "No filename was specified to access.\n" ) ;
    &endInfo ;
    exit 1 ;
}

sub accessToFileDenied
{
    &headerInfo ;
    print( "You do not have permission to access that file $requestedFile\n" ) ;
    &endInfo ;
    exit 1 ;
}

sub unableToOpenFile
{
    &headerInfo ;
    print( "File does not exist or not able to open the file $requestedFile\n" ) ;
    &endInfo ;
    exit 1 ;
}

sub serviceUnavailable
{
    print("Content-type: text/html\n\n"); 
    print( "This service is currently unavailable. Please try again later.\n" ) ;
    exit 1 ;
}

