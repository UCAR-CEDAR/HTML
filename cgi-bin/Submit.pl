#!/opt/local/bin/perl
#This is the user portal for
#the Cedarweb interface
#Patrick Kellogg pkellogg@hao.ucar.edu x1544
#Version 1.0
#Oct 12, 1999

#&serviceUnavailable ;

#Essential lines for security
use CGI;
$ENV{PATH} = '/bin:/usr/bin';
$ENV{IFS} = "" if $ENV{IFS} ne "";

#Open error log
#PLK do I need this?
#select STDOUT; $| = 1;
#open (LOGFILE,">$log_file") || die ("could not create log file");
#open (STDERR,">&LOGFILE") || die ("could not redirect stderr");

#Global variables
#
#program_name: name of this program.
$program_name=$0;
#
#Log_file: name of the file for dumping error messages.
$log_file=$program_name.".log";
#
#mysql_home: home directory for MySQL binary files.
$mysql_home="/project/cedar/bin/mysql/";
#
#mysql_client: name of the MySQL client program.
$mysql_client=$mysql_home."bin/mysql";
#
#mysql_port: port mysql is listening on
$mysql_port="3306";
#
#user: Defines the user ID to connect to mysqld.
$user="madrigal";
#
# pass: The password for the user which is getting connected to mysqld.
$pass="c3d4r78gh5";
#
# host: Defines the host where mysqld is running.
$host="db.hao.ucar.edu";
#
# CEDARDB: the database to connect
$CEDARDB = "CEDARCATALOG";
# DODS: Gives the location of DODS
$DODS = "/opendap";

#Create a new query object (see CGI.pl)
$query = new CGI;

#Parse the fields
$date = $query->param('date');
$instrument = $query->param('instrument');
$record_type = $query->param('record_type');
@parameters = $query->param('Parameter');
$filter = $query->param('filter');

#Parse the date, too
($StartYear,$StartMonthDay,$StartHourMinute,$StartSecond,$EndYear,$EndMonthDay,$EndHourMinute,$EndSecond) = split /,/, $date;
#Use substr(EXPR, OFFSET, LENGTH)
$StartMonth = substr($StartMonthDay, 0, 2);
$StartDay = substr($StartMonthDay, 2, 2);
$EndMonth = substr($EndMonthDay, 0, 2);
$EndDay = substr($EndMonthDay, 2, 2);

#Create an error flag and clear it
@error = "";

#If there is an error, show the user a page
if ($error ne "") {

	#Create the page
	print "Content-type: text/html", "\n\n";
	print "<HTML>", "\n\n";
	print "<HEAD>", "\n";

	#Don't let the server cache this page
	#print "<META HTTP-EQUIV='Pragma' CONTENT='no-cache'>", "\n";
	#print "<META HTTP-EQUIV='Expires' CONTENT='Mon, 01 Jan 1990 00:00:01 GMT'>", "\n";

	#Give the title
	print "<TITLE>Error Using the CEDAR Database</TITLE>", "\n";
	print "</HEAD>", "\n\n";

	#Start the body section
	print "<BODY BGCOLOR='#C0C0C0'>", "\n";

        #Give the user a warning message
        print "<P ALIGN='center'>Error passing parameters to the CEDAR database</P>", "\n";
	
	#Do the footer
	print "<HR>", "\n";
	print "<P><A HREF='/index.html'><IMG SRC='/images/home03.gif' WIDTH=36 HEIGHT=24 BORDER=0></A><A HREF='/index.html'> <I>Return to the CEDAR homepage</I></A><BR>", "\n";
	print "<A HREF='http://www.ucar.edu/legal/terms_of_use.shtml#copyright'>Copyright 1999, NCAR. </A></P>", "\n";
	print "</BODY>", "\n\n";
	print "</HTML>", "\n";

} else {

        #Redirect the user to the correct page
        print "Content-type: text/html", "\n\n";
        print "<HTML>", "\n\n";
        print "<HEAD>", "\n";

        #Don't let the server cache this page
        #print "<META HTTP-EQUIV='Pragma' CONTENT='no-cache'>", "\n";
        #print "<META HTTP-EQUIV='Expires' CONTENT='Mon, 01 Jan 1990 00:00:01 GMT'>", "\n";

        #Give the title
        print "<TITLE>Results From the CEDAR Database</TITLE>", "\n";
        print "</HEAD>", "\n\n";

        #Start the body section
        print "<BODY BGCOLOR='#C0C0C0'>", "\n";

	#Give the user a message
	print "<P>Date: " . $date . "</P>", "\n";
	print "<P>Instrument: " . $instrument . "</P>", "\n";
	print "<P>Record type: " . $record_type . "</P>", "\n";
	print "<P>Parameters: ";
	$number_of_parameters_in_list=@parameters;
	if ($number_of_parameters_in_list > 0) 
	{
	    $index=1;
	    foreach $par(@parameters)
	    {
		print $par;
		if($index<$number_of_parameters_in_list)
		{
		    print ",";
		    $index=$index+1;
		}
	    }
	    print "</P>", "\n";
	}
	print "<P>Filter: " . $filter . "</P>", "\n";

	#Query the  mysql database to find the starting and ending date indicies
	$StartClause = $mysql_client . " -s -B -h $host -P $mysql_port -u$user -p$pass  -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $StartYear . ") AND (MONTH = " . $StartMonth . ") AND (DAY = " . $StartDay . ");' $CEDARDB";
	#print $StartClause, "<BR />";
	#Open the SQL
	open (STARTINDEX, "$StartClause|") || DoExit ("MySQL could not open MySQL for StartIndex");
	$StartIndex = 1;
	while (<STARTINDEX>) {
	        $StartIndex = $_;
	chop($StartIndex);
	}
	$EndClause = $mysql_client . " -s -B -h $host -P $mysql_port -u$user -p$pass  -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $EndYear . ") AND (MONTH = " . $EndMonth . ") AND (DAY = " . $EndDay . ");' $CEDARDB";
	#print $EndClause, "<BR />";
	#Open the SQL
	open (ENDINDEX, "$EndClause|") || DoExit ("MySQL could not open MySQL for EndIndex");
	$EndIndex = 1;
	while (<ENDINDEX>) {
	        $EndIndex = $_;
	        chop($EndIndex);
	}
	##Find the index of the very last record in the database
	#$LastClause = $mysql_client . " -s -B -P$mysql_port -u$user -p$pass  -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $final_year . ") AND (MONTH = 12) AND (DAY = 31);' $CEDARDB";
	##Open the SQL
	#open (LASTINDEX, "$LastClause|") || DoExit ("MySQL could not open MySQL for EndIndex");
	#$LastIndex = 1;
	#while (<LASTINDEX>) {
	#        $LastIndex = $_;
	#        chop($LastIndex);
	#}

	#PLK testing
	#print "<P>StartIndex = " . $StartIndex . "</P>", "\n";
	#print "<P>EndIndex = " . $EndIndex . "</P>", "\n";

        #Create the mysql statement
        $SqlClause = $mysql_client . " -s -B -h$host -P$mysql_port -u$user -p$pass  -e'SELECT DISTINCT tbl_cedar_file.FILE_NAME";
        $SqlClause = $SqlClause . " FROM tbl_date_in_file,tbl_cedar_file,tbl_file_info,tbl_record_type";
        $SqlClause = $SqlClause . " WHERE tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID and tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID";
	$SqlClause = $SqlClause . " AND (tbl_date_in_file.DATE_ID >= " . $StartIndex. ") AND (tbl_date_in_file.DATE_ID <= " . $EndIndex . ")";

	#Add the Instrument
	if ($instrument ne "") {
		$SqlClause = $SqlClause . " AND (tbl_record_type.KINST=" . $instrument . ")";
	}

	#Add the KINST/KINDATS
	if ($record_type ne "") {

        	@MyParse = split(/,/,$record_type);
                #Pop the first key
		@ToAdd = split /\//, pop(@MyParse);

                $ExpandIt = "((tbl_record_type.KINST=" . $ToAdd[0] . ") AND (tbl_record_type.KINDAT=" . $ToAdd[1] . "))";
                while (@MyParse) {
			@ToAdd = split /\//, pop(@MyParse);
                        $ExpandIt = $ExpandIt . " OR ((tbl_record_type.KINST=" . $ToAdd[0] . ") AND (tbl_record_type.KINDAT=" . $ToAdd[1] . "))";
                }
                $SqlClause = $SqlClause . " AND (" . $ExpandIt . ")";
        }

	#Finish the query
        $SqlClause = $SqlClause . ";' $CEDARDB";

	#PLK testing
	#print "<P>SQL: " . $SqlClause . "</P>". "\n";
	#print $SqlClause, "\n";

        #Open the SQL
        open (FINDFILES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for FindFiles");

	#Start listing the URLs
	print "<HR>", "\n";
        $TotalString = "";
        $AnyFound = 0;
        #Loop through until done
        while (<FINDFILES>) {

		#We found at least one URL
		$AnyFound = ($AnyFound + 1);

                #Get the current line ($_) and parse it
                $NextFile = $_;
		chop($NextFile);

		#Create the URLs
		$theCookie = $query->cookie('wikidbUserName');
		$URL = $DODS . "?username=" . $theCookie . "&request=" ;
		$URL = $URL . "define+silently+d+as+" . $NextFile ;
		$URL = $URL . "+with+" . $NextFile . ".constraint=\"" ;

		#Add the date
		$URL = $URL . "date(" . $date . ")";

		#See if there are any record_types
		if ($record_type ne "") {
                        $URL = $URL . ";record_type(" . $record_type . ")";
		}

		#See if there are any parameters
		$number_of_parameters_in_list=@parameters;
		if ($number_of_parameters_in_list > 0) {
		    $URL = $URL . ";parameters(";
		    $index=1;
		    foreach $par(@parameters)
		    {
			$URL = $URL. $par;
			if($index<$number_of_parameters_in_list)
			{
			    $URL = $URL. ",";
			    $index=$index+1;
			}
			
		    }
		    $URL = $URL . ")";
		}

		$URL = $URL . "\";get+" . (lc $filter) . "+for+d;";

		$TotalString = $TotalString . "<A HREF='" . $URL . "'>" .  "TAB Data for " . $NextFile . "</A><BR>", "\n";
	}

	#See if anything was found
	if ($AnyFound == 0) {

		#No files were found for that query
		print "<P>No data found for those query parameters</P>", "\n";

	} elsif ($AnyFound == 1 ) {

		#Print a message for 1 URL
        	print "<P>Please click on the 'TAB Data' link below to retrieve your data<BR>", "\n";

	} else {

		#Print a message for > 1 URL
                print "<P>Please click on each of the 'TAB Data' links below to retrieve your data<BR>", "\n";
	}

	#Print the URLs
	print "<ul>";
	print "<li>On some browsers, using the left mouse button while holding down the SHIFT key or using the right mouse button and then selecting the option \"Save link as\" ";
	print "will send the data to a user-specified file instead of to the browser window.", "\n";
	print "<li>If you use 'Back' on your browser, you will get a ";
	print "<b>'Data Missing'</b>";
	print " message from your browser since the access procedure disallows caching.";
	print " Click on the 'Reload' button in your browser to restore.";
	print " <li>Also, the URL itself can be changed in the 'Location' edit area in your browser."; 
	print "</ul>";
	print "<P>", "\n";

	print $TotalString;

	print "</P>", "\n";


	#Do the footer
	print "<HR>", "\n";
	print "<P><A HREF='/index.html'><IMG SRC='/images/home03.gif' WIDTH=36 HEIGHT=24 BORDER=0></A><A HREF='/index.html'> <I>Return to the CEDAR homepage</I></A><BR>", "\n";
	print "<A HREF='http://www.ucar.edu/legal/terms_of_use.shtml#copyright'>Copyright 1999, NCAR. </A></P>", "\n";
        print "</BODY>", "\n\n";
        print "</HTML>", "\n";
}

#Close the log files
#PLK do I need these?

sub serviceUnavailable
{
    print "Content-type: text/html", "\n\n";
    print( "This service is currently unavailable. Please try again later.\n" ) ;
    exit 1 ;
}

exit(0);

