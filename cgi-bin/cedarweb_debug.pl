#!/opt/local/bin/perl
#This is a perl script for
#the Cedarweb interface
#Patrick Kellogg pkellogg@hao.ucar.edu x1544
#Version 2.0
#Oct 19, 1999

#Essential lines for security
use CGI;
$ENV{PATH} = '/bin:/usr/bin:/project/cedar/bin/mysql/bin/';
$ENV{IFS} = "" if $ENV{IFS} ne "";

#Include the data routines
use Time::ParseDate;
use Time::CTime;

#Global variables
#
#main_site: cedarweb.hao.ucar.edu, the main html location
$main_site = "http://cedarweb.hao.ucar.edu";
#
#cgi_site: http://cedarweb.hao.ucar.edu/cgi-bin/ where all cgi-bin files are located
$cgi_site = "http://cedarweb.hao.ucar.edu/cgi-bin";
#
#hao_site: http://www.hao.ucar.edu the main HAO web site
$hao_site = "http://www.hao.ucar.edu";
#
#image_site: http://cedarweb.hao.ucar.edu/images where the images are
$image_site = "http://cedarweb.hao.ucar.edu/images";
#
#mysql_home: home directory for MySQL binary files.
$mysql_home="/project/cedar/bin/mysql/bin/";
#
#mysql_client: name of the MySQL client program.
$mysql_client=$mysql_home."mysql";
#
#user: Defines the user ID to connect to mysqld.
$user="madrigal";
#
# pass: The password for the user which is getting connected to mysqld.
$pass="c3d4r!er";
#
# host: Defines the host where mysqld is running.
$host="localhost";
#
# unix socket used to connect to the mysql server
$unix_sock="/project/cedar/bin/mysql/mysql.sock";
#
# CEDARDB: Defines the MySQL databases to get connected.
$CEDARDB = "CEDARCATALOG";
#
# beginning_year" Sets the beginning year of data in the CEDAR database
$beginning_year = 1950;
#
# final_year: Sets the final year of data in the CEDAR database
$final_year = 2005;

# Sey this variable to TRUE if you want to debug...
$DebugSQLClause = "TRUE";

#Find out who is logged in
$RemoteUser = $ENV{"REMOTE_USER"};

#Create a new query object (see CGI.pl)
$query = new CGI;

#See if the user clicked "Clear"
$Clear = $query->param('Clear');
if ($Clear eq "") {

	#Parse the fields
	$Stage = $query->param('Stage');
	$NewStage = $query->param('NewStage');
	$StartYear = $query->param('StartYear');
        $StartMonth = $query->param('StartMonth');
        $StartDay = $query->param('StartDay');
	$StartHour = $query->param('StartHour');
	$StartMinute = $query->param('StartMinute');
        $StartSecond = $query->param('StartSecond');
	$EndYear = $query->param('EndYear');
        $EndMonth = $query->param('EndMonth');
        $EndDay = $query->param('EndDay');
        $EndHour = $query->param('EndHour');
        $EndMinute = $query->param('EndMinute');
        $EndSecond = $query->param('EndSecond');
	$DateRange = $query->param('DateRange');
	$NewMonth = $query->param('NewMonth');
	$NewDay = $query->param('NewDay');
	$NewYear = $query->param('NewYear');
	$Kinst = $query->param('Kinst');
	$KinstSortBy = $query->param('KinstSortBy');
	$KinstAscDesc = $query->param('KinstAscDesc');
	$KinstShow = $query->param('KinstShow');
	$Kindat = $query->param('Kindat');
	$KindatSortBy = $query->param('KindatSortBy');
	$KindatAscDesc = $query->param('KindatAscDesc');
	$KindatShow = $query->param('KindatShow');
	@Parameter = $query->param('Parameter');
	$ParameterSortBy = $query->param('ParameterSortBy');
	$ParameterAscDesc = $query->param('ParameterAscDesc');
	$ParameterShow = $query->param('ParameterShow');
	$ParameterSearch = $query->param('ParameterSearch');
	$ClearInstruments = $query->param('ClearInstruments');
	$ClearKindats = $query->param('ClearKindats');
	$ClearParameters = $query->param('ClearParameters');
	$Filter = $query->param('filter');

} else {

	#Remember the filter anyway
	$Filter = $query->param('filter');

}

#Create a hash to translate the list of months
%MonthHash = (
	"" => "00",
	"January" => "01",
	"February" => "02",
	"March" => "03",
	"April" => "04",
	"May" => "05",
	"June" => "06",
	"July" => "07",
	"August" => "08",
	"September" => "09",
	"October" => "10",
	"November" => "11",
	"December" => "12",
);
%HashMonthPart = (
        "00" => "",
        "01" => "Jan",
        "02" => "Feb",
        "03" => "Mar",
        "04" => "Apr",
        "05" => "May",
        "06" => "Jun",
        "07" => "Jul",
        "08" => "Aug",
        "09" => "Sep",
        "10" => "Oct",
        "11" => "Nov",
        "12" => "Dec",
);
%HashMonthFull = (
        "00" => "",
        "01" => "January",
        "02" => "February",
        "03" => "March",
        "04" => "April",
        "05" => "May",
        "06" => "June",
        "07" => "July",
        "08" => "August",
        "09" => "September",
        "10" => "October",
        "11" => "November",
        "12" => "December",
);

#Create the page
print "Content-type: text/html", "\n\n";
print "<HTML>", "\n\n";
print "<HEAD>", "\n";

#Don't let the server cache this page
print "<META HTTP-EQUIV='Pragma' CONTENT='no-cache'>", "\n";
#print "<META HTTP-EQUIV='Expires' CONTENT='Mon, 01 Jan 1990 00:00:01 GMT'>", "\n";

#Give the title
print "<TITLE>CEDARweb Data Query Page for the CEDAR Database</TITLE>", "\n";
print "</HEAD>", "\n\n";

#Start the body section
print "<BODY BGCOLOR='#C0C0C0'>", "\n";

# Jose Garcia / Debug
# print "<P>@Parameter</P>\n";

#See if we have moved to another page
if ($NewStage ne "") {
        $Stage = $NewStage;
        $NewStage = "";
}

#See if we have just chosen a new day, month, or year
if ($NewDay ne "") {
        #Remove the brackets
        if ((substr($NewDay, 0, 2)) eq "> ") {
		#Chop off two characters from the front *and* the back
		$TempDay = substr($NewDay,2,99);
                $StartDay = substr($TempDay,0,-2);
        } else {
                $StartDay = $NewDay;
        }
}
if ($NewMonth ne "") {
        #Remove the brackets
        if ((substr($NewMonth, 0, 2)) eq "> ") {
		#Chop off two characters from the front *and* the back
                $TempMonth = substr($NewMonth,2,99);
		$StartMonth = substr($TempMonth,0,-2);
        } else {
                $StartMonth = $NewMonth;
        }
}
if ($NewYear ne "") {
	#Remove the brackets
	if ((substr($NewYear, 0, 2)) eq "> ") {
		$StartYear = substr($NewYear,2,4);
	} else {
        	$StartYear = $NewYear;
	}
}

#Check the starting year
if (!($StartYear =~ /^(\d*)$/)) {
	$StartYearError = "error";
	$Stage = "Date_Time";
} elsif ($StartYear ne "") {
	if ($StartYear < $beginning_year) {
		$StartYearError = "toolow";
		$Stage = "Date_Time";
	} elsif ($StartYear > $final_year) {
		$StartYearError = "toohigh";
		$Stage = "Date_Time";
	} else {
		#Set the effective starting year
		$EffectiveStartYear = $StartYear;
	}
} else {
	#Clear the effective starting year
	$EffectiveStartYear = $beginning_year;
}
if ($MonthHash{$StartMonth} ne "00") {
	#See if they haven't chosen a year
	if ($StartYear eq "") {
		$StartMonthError = "noyear";
		$Stage = "Date_Time";
	} else {
		#Set the effective starting month
		$EffectiveStartMonth = $MonthHash{$StartMonth};
	}
} else {
	#Clear the effective starting month
	$EffectiveStartMonth = "01";
}
if (!($StartDay =~ /^(\d*)$/)) {
        $StartDayError = "error";
        $Stage = "Date_Time";
} elsif ($StartDay ne "") {
	#See if they have entered a month or year
	if (($StartMonth eq "") || ($StartYear eq "")) {
		if ($StartYear eq "") {
			$StartDayError = "noyear";
			$Stage = "Date_Time";
		}
		if ($StartMont eq "") {
			$StartDatError = "nomonth";
			$Stage = "Date_Time";
		}
	} else {
		#Find the last day of the month
        	$LastStartDay = &FindLastDayOfMonth($EffectiveStartMonth, $EffectiveStartYear);
		#See if the day is later than the last day of the month
		if ($StartDay < 1) {
			$StartDayError = "tooearly";
			$Stage = "Date_Time";
		} elsif ($StartDay > $LastStartDay) {
			$StartDayError = "toolate";
			$Stage = "Date_Time";
		} else {
			#Set the effective starting day
			if ($StartDay < 10) {
				$EffectiveStartDay = "0" . (0 + $StartDay);
			} else {
				$EffectiveStartDay = "" . (0 + $StartDay);
			}
		}
	}
} else {
	#Clear the effective starting day
	$EffectiveStartDay = "01";
}
if (!($StartHour =~ /^(\d*)$/)) {
        $StartHourError = "error";
        $Stage = "Date_Time";
} elsif ($StartHour ne "") {
	if (($StartHour < 0) || ($StartHour > 23)) {
		$StartHourError = "invalid";
		$Stage = "Date_Time";
	} else {
                #Set the effective starting hour 
                if ($StartHour < 10) {
                        $EffectiveStartHour = "0" . (0 + $StartHour);
                } else {
                        $EffectiveStartHour = "" . (0 + $StartHour);
                }
        }
} else {
        #Clear the effective starting hour 
        $EffectiveStartHour = "00";
}
if (!($StartMinute =~ /^(\d*)$/)) {
        $StartMinuteError = "error";
        $Stage = "Date_Time";
} elsif ($StartMinute ne "") {
	if (($StartMinute < 0) || ($StartMinute > 59)) {
        	$StartMinuteError = "invalid";
		$Stage = "Date_Time";
        } else {
                #Set the effective starting minute 
                if ($StartMinute < 10) {
                        $EffectiveStartMinute = "0" . (0 + $StartMinute);
                } else {
                        $EffectiveStartMinute = "" . (0 + $StartMinute);
                }
        }
} else {
        #Clear the effective starting minute 
        $EffectiveStartMinute = "00";
}
if (!($StartSecond =~ /^(\d*)$/)) {
        $StartSecondError = "error";
        $Stage = "Date_Time";
} elsif ($StartSecond ne "") {
	if (($StartSecond < 0) || ($StartSecond > 5999)) {
        	$StartSecondError = "invalid";
		$Stage = "Date_Time";
        } else {
                #Set the effective starting second
                if ($StartSecond < 10) {
                        $EffectiveStartSecond = "000" . (0 + $StartSecond);
                } elsif ($StartSecond < 100) {
                        $EffectiveStartSecond = "00" . (0 + $StartSecond);
                } elsif ($StartSecond < 1000) {
                        $EffectiveStartSecond = "0" . (0 + $StartSecond);
                } else {
                        $EffectiveStartSecond = "" . (0 + $StartSecond);
                }
        }
} else {
        #Clear the effective starting second
        $EffectiveStartSecond = "0000";
}

#See if the user has picked a date range
if ($DateRange ne "") {

	#Make sure the date range is numeric
	$DateRange = 0 + $DateRange;

	#Figure out the starting date and the time to add
	$TempTime = parsedate($EffectiveStartMonth."/".$EffectiveStartDay."/".$EffectiveStartYear);
        $AddTime = 60 * 60 * 24 * $DateRange;
        $FinalTime = ($TempTime + $AddTime);
        #Now it's in an array (see Perl localtime docs for help)
        @MyTime = localtime($FinalTime);
	#Note: this is Y2K complient... it will @MyTime[5] will be 101 at 2001,
	#so 1900 + @MyTime[5] will still work
        $NewYear = 1900 + @MyTime[5];
        $NewMonth = 1 + @MyTime[4];
        if ($NewMonth < 10) {
                $NewMonth = "0".$NewMonth;
        }
        $NewDay = @MyTime[3];
        if ($NewDay < 10) {
                $NewDay = "0".$NewDay;
        }

	#Set the new values
	$EndYear = $NewYear;
	$EndMonth = $HashMonthFull{$NewMonth};
	$EndDay = $NewDay;
}

if (!($EndYear =~ /^(\d*)$/)) {
        $EndYearError = "error";
        $Stage = "Date_Time";
} elsif ($EndYear ne "") {
	if ($EndYear < $beginning_year) {
        	$EndYearError = "toolow";
        	$Stage = "Date_Time";
	} elsif ($EndYear > $final_year) {
        	$EndYearError = "toohigh";
        	$Stage = "Date_Time";
	} else {
		#Set the effective ending year
		$EffectiveEndYear = $EndYear;
	}
} else {
	#Clear the effective ending year
	$EffectiveEndYear = $final_year;
}
if ($MonthHash{$EndMonth} ne "00") {
        #See if they haven't chosen a year
        if ($EndYear eq "") {
                $EndMonthError = "noyear";
                $Stage = "Date_Time";
        } else {
                #Set the effective ending month
                $EffectiveEndMonth = $MonthHash{$EndMonth};
        }
} else {
        #Clear the effective ending month
        $EffectiveEndMonth = "12";
}
if (!($EndDay =~ /^(\d*)$/)) {
        $EndDayError = "error";
        $Stage = "Date_Time";
} elsif ($EndDay ne "") {
        #See if they have entered a month or year
        if (($EndMonth eq "") || ($EndYear eq "")) {
                if ($EndYear eq "") {
                        $EndDayError = "noyear";
                        $Stage = "Date_Time";
                }
                if ($EndMont eq "") {
                        $EndDatError = "nomonth";
                        $Stage = "Date_Time";
                }
        } else {
		#Find the last day of the month
                $LastEndDay = &FindLastDayOfMonth($EffectiveEndMonth, $EffectiveEndYear);
                #See if the day is later than the last day of the month
		if ($EndDay < 1) {
			$EndDayError = "tooearly";
			$Stage = "Date_Time";
                } elsif ($EndDay > $LastEndDay) {
                        $EndDayError = "toolate";
                        $Stage = "Date_Time";                                        
                } else {
        		#Set the effective ending day
        		if ($EndDay < 10) {
                		$EffectiveEndDay = "0" . (0 + $EndDay);
               		} else {
                       		$EffectiveEndDay = "" . (0 + $EndDay);
			}
                }
        }
} else {
        #Clear the effective ending day
        $EffectiveEndDay = &FindLastDayOfMonth($EffectiveEndMonth, $EffectiveEndYear);
}
if (!($EndHour =~ /^(\d*)$/)) {
        $EndHourError = "error";
        $Stage = "Date_Time";
} elsif ($EndHour ne "") {
	if (($EndHour < 0) || ($EndHour > 23)) {
        	$EndHourError = "invalid";
        	$Stage = "Date_Time";
        } else {
                #Set the effective ending hour 
                if ($EndHour < 10) {
                        $EffectiveEndHour = "0" . (0 + $EndHour);
                } else {
                        $EffectiveEndHour = "" . (0 + $EndHour);
                }
        }
} else {
        #Clear the effective ending hour 
        $EffectiveEndHour = "23";
}
if (!($EndMinute =~ /^(\d*)$/)) {
        $EndMinuteError = "error";
        $Stage = "Date_Time";
} elsif ($EndMinute ne "") {
	if (($EndMinute < 0) || ($EndMinute > 59)) {
        	$EndMinuteError = "invalid";
        	$Stage = "Date_Time";
	} else {
                #Set the effective ending minute 
                if ($EndMinute < 10) {
                        $EffectiveEndMinute = "0" . (0 + $EndMinute);
                } else {
                        $EffectiveEndMinute = "" . (0 + $EndMinute);
                }
        }
} else {
        #Clear the effective ending minute 
        $EffectiveEndMinute = "59";
}
if (!($EndSecond =~ /^(\d*)$/)) {
        $EndSecondError = "error";
        $Stage = "Date_Time";
} elsif ($EndSecond ne "") {
	if (($EndSecond < 0) || ($EndSecond > 5999)) {
        	$EndSecondError = "invalid";
        	$Stage = "Date_Time";
        } else {
                #Set the effective ending second
                if ($EndSecond < 10) {
                        $EffectiveEndSecond = "000" . (0 + $EndSecond);
                } elsif ($EndSecond < 100) {
                        $EffectiveEndSecond = "00" . (0 + $EndSecond);
                } elsif ($EndSecond < 1000) {
                        $EffectiveEndSecond = "0" . (0 + $EndSecond);
                } else {
                        $EffectiveEndSecond = "" . (0 + $EndSecond);
                }
        }
} else {
        #Clear the effective ending second
        $EffectiveEndSecond = "5999";
}

#See if the user is trying to go on without entering a KINST or KINDAT
if (($Stage eq "Go") && ($Kinst eq "") && ($Kindat eq "")) {
	#Don't let the user go on
	$KinstError = "cantgo";
	$Stage = "Instrument";
}

#Create the banner
&CreateBanner;

#See if MySQL is running
my $IsRunning="";
$IsRunning=`$mysql_client -u$user -p$pass -S$unix_sock -e"show tables;" $CEDARDB`;
if ($IsRunning eq "") {

        #Give the user a warning message
        print "<P ALIGN='center'>Sorry</P>", "\n";
        print "<P ALIGN='center'>The CEDAR database is currently unavailable. Please try back again later.</P>", "\n";
        print "<P ALIGN='center'>For news about maintenance schedules or planned down time, please read ", "\n";
        print "<A HREF='" . $main_site . "/Downtime.html'>" . $main_site . "/Downtime.html</A></P>", "\n";
        print "<P>&nbsp;</P>", "\n";
        print "<P>&nbsp;</P>", "\n";
        print "<P>&nbsp;</P>", "\n";
        print "<P>&nbsp;</P>", "\n";
        print "<P>&nbsp;</P>", "\n";
        print "<P>&nbsp;</P>", "\n";

} elsif ($Stage eq "Go") {

	#Show the final page
	&DoGo;

} else {

	#Query the  mysql database to find the starting and ending date indicies
	$StartClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $EffectiveStartYear . ") AND (MONTH = " . $EffectiveStartMonth . ") AND (DAY = " . $EffectiveStartDay . ");' $CEDARDB";
	#Open the SQL
	open (STARTINDEX, "$StartClause|") || DoExit ("MySQL could not open MySQL for StartIndex");
	$StartIndex = 1;
	while (<STARTINDEX>) {
        	$StartIndex = $_;
        	chop($StartIndex);
	}
	$EndClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $EffectiveEndYear . ") AND (MONTH = " . $EffectiveEndMonth . ") AND (DAY = " . $EffectiveEndDay . ");' $CEDARDB";
	#Open the SQL
	open (ENDINDEX, "$EndClause|") || DoExit ("MySQL could not open MySQL for EndIndex");
	$EndIndex = 1;
	while (<ENDINDEX>) {
        	$EndIndex = $_;
        	chop($EndIndex);
	}

	#Find the index of the very last record in the database
	$LastClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DATE_ID from tbl_date WHERE (YEAR = " . $final_year . ") AND (MONTH = 12) AND (DAY = 31);' $CEDARDB";
	#Open the SQL
	open (LASTINDEX, "$LastClause|") || DoExit ("MySQL could not open MySQL for EndIndex");
	$LastIndex = 1;
	while (<LASTINDEX>) {
        	$LastIndex = $_;
        	chop($LastIndex);
	}

	#Put everything into one form
        print "<FORM ACTION='" . $cgi_site . "/cedarweb_debug.pl' METHOD='POST'>", "\n";

	#Do the left and right sections
	print "<TABLE BORDER='0' CELLPADDING='1' CELLSPACING='1' WIDTH='100%'>", "\n";
	print "<TR>", "\n";

	#Add the left contents bar
	print "<TD WIDTH='20%' VALIGN='top' ALIGN='left'>", "\n";
	&CreateNav;
	print "</TD>", "\n";

	#Add the right main page
	print "<TD WIDTH='80%' VALIGN='top' ALIGN='left'>", "\n";
	&CreateMain;
	print "</TD>", "\n";

	#Close up the table
	print "</TABLE>", "\n";

        #Create hidden fields
        print "<INPUT TYPE=HIDDEN NAME='Stage' VALUE=", $Stage, ">", "\n";

	#Close the form
	print "</FORM>", "\n";
}

#Do the footer
print "<HR>", "\n";

#Create a table
print "<TABLE BORDER='0' CELLPADDING='1' CELLSPACING='1' WIDTH='100%'>", "\n";
print "<TR>", "\n";
print "<TD WIDTH='50%' VALIGN='top' ALIGN='left'>", "\n";

#Do the left side (return and copyright)
print "<P><A HREF='http://" . $hao_site . "'><IMG SRC='/icons/home03.gif' WIDTH=36 HEIGHT=24 ALT='CEDAR homepage'></A><A HREF='" . $main_site . "'> <I>Return to the CEDAR homepage</I></A><BR>", "\n";
print "<A HREF='" . $hao_site . "/public/home/copyright.html'>Copyright 2000, NCAR. </A></P>", "\n";
print "</TD>", "\n";

#Do the right side (approval and mailto)
print "<TD WIDTH='50%' VALIGN='top' ALIGN='right'>", "\n";
print "<P>-Approved by Peter Fox<BR>", "\n";
print "<I>-Version 2.1 by </I><A HREF='mailto:jgarcia\@hao.ucar.edu'><I>Patrick Kellogg</I></A></P>", "\n";
print "</TD>", "\n";
print "</TABLE>", "\n";

print "</BODY>", "\n\n";
print "</HTML>", "\n";

exit(0);

sub CreateBanner {
#	Create the banner at the top of the page
#
#	&CreateBanner;
#
#	INPUTS:
#	(none)
#	RETURNS:
#	(none)
#	EXTERNALS:
#	(none)(

	#Create the header in a three-column table
	print "<P>", "\n";
	print "<TABLE BORDER='2' WIDTH='100%' CELLPADDING='1' CELLSPACING='1'>", "\n";
	print "<TR>", "\n";
	print "<TD WIDTH='10%' BGCOLOR='#FFFFFF'><A HREF='http://www.ucar.edu'><P ALIGN='center'><IMG SRC='" . $image_site . "/CedarwebUCAR.gif' ALT='UCAR'><BR>UCAR</A></P></TD>", "\n";

	#Print the user name and the date
	print "<TD WIDTH='10%' BGCOLOR='#FFFFFF' VALIGN='bottom' ALIGN='center'><FONT SIZE='2'>";

	#Print the user name
	print $RemoteUser . "<BR>&nbsp;<BR>&nbsp;<BR>", "\n";

	#Tricky logic: it's using the localtime function to put array values into separate variables (see Programming Perl p. 185)
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime(time);

	#Print the day of the week. Note the 6th array element is the mday, just like a "tm" stucture
	$thisday = (Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday)[(localtime)[6]];
	print $thisday, "<BR>";

        #This function turns a number from 0-11 into a month name (for internationalization)
        $thismonth = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[(localtime)[4]];

        #localtime is Y2K complient. The "+1900" will work until UNIX dates have trouble
        $year = $year+1900;

	#Print the result, and close the cell
	print $thismonth, " ", $mday, ", ", $year, "\n";
	print "</FONT></TD>", "\n";

	#Print "CEDARweb"
	print "<TD WIDTH='60%' BGCOLOR='#FFFFFF'><P ALIGN='center'><IMG BORDER='1' SRC='" . $image_site . "/Cedarweb.jpg' ALT='CEDARweb'></P></TD>", "\n";

	#Print the time
	print "<TD WIDTH='10%' BGCOLOR='#FFFFFF' VALIGN='bottom' ALIGN='center'><FONT SIZE='2'>";

	#Turn 4:9 into 4:09
	if ($min<10) {
		$min = "0" . $min;
	}
	
	#Print the rest
	print $hour, ":", $min, "<BR>Mountain Standard Time", "\n";
	print "</TD>", "\n";

	#Finish the banner
	print "<TD WIDTH='10%' BGCOLOR='#FFFFFF'><P ALIGN='right'><A HREF='" . $main_site . "'><IMG SRC='" . $image_site . "/CedarwebCedar.gif' ALT='CEDAR'></A></P></TD>", "\n";
	print "</TR>", "\n";
	print "</TABLE>", "\n";
	print "</P>", "\n";
}

sub CreateNav {
#	Create the navigation buttons at the left of the page
#
#	&CreateNav;
#
#	INPUT:
#	(none)
#	RETURNS:
#	(none)
#	EXTERNALS:
#	(none)

	#Show the Instruments section
        print "<P>", "\n";
        #print "<IMG SRC='" . $image_site . "/NavInstrument.gif' ALT='Instrument'>", "\n";
	print "<BLOCKQUOTE>", "\n";
	#Show the Instruments button
        print "<INPUT NAME='NewStage' VALUE='Instrument' TYPE='submit'>", "\n";
        #See if the user has chosen an instrument
        if ($Kinst ne "") {
                print "<FONT SIZE='2'>", "\n";
                print "<BR>", "\n";
                print $Kinst, "\n";
                print "</FONT>", "\n";
        }
	print "</BLOCKQUOTE>", "\n";
        print "</P>", "\n";

	#Show the Kindats section
        print "<P>", "\n";
        #print "<IMG SRC='" . $image_site . "/NavRecordType.gif' ALT='Record Type'>", "\n";
        print "<BLOCKQUOTE>", "\n";
	#Show the Kindats button
        print "<INPUT NAME='NewStage' VALUE='Record_Type' TYPE='submit'>", "\n";
        #See if the user has chosen a Kindat
        if ($Kindat ne "") {
                print "<FONT SIZE='2'>", "\n";
                print "<BR>", "\n";
                print $Kindat . "\n";
                print "</FONT>", "\n";
        }
	print "</BLOCKQUOTE>", "\n";
        print "</P>", "\n";

	#Show the Parameters section
	print "<P>", "\n";
        #print "<IMG SRC='" . $image_site . "/NavParameters.gif' ALT='Parameters'>", "\n";
	print "<BLOCKQUOTE>", "\n";
	#Show the Parameters button
	print "<INPUT NAME='NewStage' VALUE='Parameters' TYPE='submit'>", "\n";
        #See if the user has chosen any parameters
	$number_of_parameters_in_list=@Parameter;
        if ($number_of_parameters_in_list>0) {
                print "<FONT SIZE='2'>", "\n";
                print "<BR>", "\n";
		foreach $par(@Parameter)
		{
		    print $par . "\n";
		}
                print "</FONT>", "\n";
        }
	print "</BLOCKQUOTE>", "\n";
        print "</P>", "\n";

        #Show the Date/ Time section
        print "<P>", "\n";
        #print "<IMG SRC='" . $image_site . "/NavDateTime.gif' ALT='Date_Time'>", "\n";
        print "<BLOCKQUOTE>", "\n";
        #Show the Date button
        print "<INPUT NAME='NewStage' VALUE='Date_Time' TYPE='submit'>", "\n";

        #See if the user has chosen a starting date
        if ($StartMonth ne "") {
                $FullStartDate = $HashMonthPart{$EffectiveStartMonth};
        }
        if ($StartDay ne "") {
                #Add a space
                if ($FullStartDate ne "") {
                        $FullStartDate = $FullStartDate . " ";
                }
                $FullStartDate = $FullStartDate . $EffectiveStartDay;
        }
        if ($StartYear ne "") {
                #Add a comma
                if ($FullStartDate ne "") {
                        $FullStartDate = $FullStartDate . ", ";
                }
                $FullStartDate = $FullStartDate . $EffectiveStartYear;
        }
        if ($FullStartDate ne "") {
                print "<FONT SIZE='2'>", "\n";
                print "<BR>", "\n";
                print "Start: " . $FullStartDate, "\n";
                print "</FONT>", "\n";
        }

        #See if the user has chosen an ending date
        if ($EndMonth ne "") {
                $FullEndDate = $HashMonthPart{$EffectiveEndMonth};
        }
        if ($EndDay ne "") {
                #Add a space
                if ($FullEndDate ne "") {
                        $FullEndDate = $FullEndDate . " ";
                }
                $FullEndDate = $FullEndDate . $EffectiveEndDay;
        }
        if ($EndYear ne "") {
                #Add a comma
                if ($FullEndDate ne "") {
                        $FullEndDate = $FullEndDate . ", ";
                }
                $FullEndDate = $FullEndDate . $EffectiveEndYear;
        }
        if ($FullEndDate ne "") {
                print "<FONT SIZE='2'>", "\n";
                print "<BR>", "\n";
                print "End: " . $FullEndDate, "\n";
                print "</FONT>", "\n";
        }
        print "</BLOCKQUOTE>", "\n";
        print "</P>", "\n";

        #Show the "Go" section
	print "<P>", "\n";
	#print "<IMG SRC='" . $image_site . "/NavGo.gif'> ALT='Go'>", "\n";
	print "<BLOCKQUOTE>", "\n";
	#Show the Go button
	print "<INPUT NAME='NewStage' VALUE='Go' TYPE='submit'>", "\n";
        print "</BLOCKQUOTE>", "\n";
        print "</P>", "\n";

        #Show the Clear All section
        print "<P>", "\n";
        #print "<IMG SRC='" . $image_site . "/NavClear.gif' ALT = 'Clear'>", "\n";
        print "<BLOCKQUOTE>", "\n";
        #Show the Clear All button
        print "<INPUT NAME='Clear' VALUE='Clear Query' TYPE='submit'>", "\n";
        print "</BLOCKQUOTE>", "\n";
	print "</P>", "\n";
}

sub CreateMain {
#       Create the information on the main page
#
#       &CreateMain;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

	#See which page we are supposed to be on
	if ($Stage eq "Date_Time") {

		#Create the Date query page
		&DoDateTime;

	} elsif ($Stage eq "Instrument") {

		#Create the Instruments page
		&DoInstruments;

        } elsif ($Stage eq "Record_Type") {

                #Create the Kindats page
                &DoKindats;

	} elsif ($Stage eq "Parameters") {

		#Create the Parameters page
		&DoParameters;

	} else {

		#Create a welcome page
		print "<P>&nbsp;</P>", "\n";
		print "<P ALIGN='center'><B>Welcome to the CEDAR database web interface</B></P>", "\n";
		print "<P ALIGN='center'><A HREF='http://www.unidata.ucar.edu/packages/dods/index.html'><IMG SRC='" . $image_site . "/dods-logo.gif' ALT='DODS' BORDER='0'></A>";
		print "<P ALIGN='center'>Powered by <A HREF='http://www.unidata.ucar.edu/packages/dods/index.html'>DODS</A></P>", "\n";
                print "<P>&nbsp;</P>", "\n";
		print "<P ALIGN='left'>Please click on an item to the left (Date_Time, Instrument, Record_Type, or Parameters) ", "\n";
		print "to start creating a query. Then, when the query is complete, click &quot;Go&quot;</P>", "\n";

                print "<P>&nbsp;</P>", "\n";
                print "<P>&nbsp;</P>", "\n";
                print "<P>&nbsp;</P>", "\n";
                print "<P>&nbsp;</P>", "\n";
                print "<P>&nbsp;</P>", "\n";

		#Save the hidden variables, just in case
	        print "<INPUT TYPE=HIDDEN NAME='StartYear' VALUE=",$StartYear,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='StartMonth' VALUE=",$StartMonth,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='StartDay' VALUE=",$StartDay,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='StartHour' VALUE=",$StartHour,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='StartMinute' VALUE=",$StartMinute,">", "\n";
                print "<INPUT TYPE=HIDDEN NAME='StartSecond' VALUE=",$StartSecond,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='EndYear' VALUE=",$EndYear,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='EndMonth' VALUE=",$EndMonth,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='EndDay' VALUE=",$EndDay,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='EndHour' VALUE=",$EndHour,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='EndMinute' VALUE=",$EndMinute,">", "\n";
                print "<INPUT TYPE=HIDDEN NAME='EndSecond' VALUE=",$EndSecond,">", "\n";
		print "<INPUT TYPE=HIDDEN NAME='Kinst' VALUE=",$Kinst,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KinstSortBy' VALUE=",$KinstSortBy,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KinstAscDesc' VALUE=",$KinstAscDesc,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KinstShow' VALUE=",$KinstShow,">", "\n";
                print "<INPUT TYPE=HIDDEN NAME='Kindat' VALUE=",$Kindat,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KindatSortBy' VALUE=",$KindatSortBy,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KindatAscDesc' VALUE=",$KindatAscDesc,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='KindatShow' VALUE=",$KindatShow,">", "\n";
		foreach $par(@Parameter)
		{
		    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
		    
		}
	        print "<INPUT TYPE=HIDDEN NAME='ParameterSortBy' VALUE=",$ParameterSortBy,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='ParameterAscDesc' VALUE=",$ParameterAscDesc,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='ParameterShow' VALUE=",$ParameterShow,">", "\n";
	        print "<INPUT TYPE=HIDDEN NAME='ParameterSearch' VALUE=",$ParameterSearch,">", "\n";
                print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";
	}
}

sub DoDateTime {
#       Create the page for the date and time selection
#
#       &DoDateTime;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

	#Tell the user if they have made an error
	print "<P>", "\n";
	if ($StartYearError eq "error") {
		print "<FONT COLOR=red>Starting year must be numeric</FONT><BR>";
	} elsif ($StartYearError eq "toolow") {
		print "<FONT COLOR=red>Starting year must be greater than or equal to ". $beginning_year . "</FONT><BR>";
	} elsif ($StartYearError eq "toohigh") {
                print "<FONT COLOR=red>Starting year must be less than or equal to " . $final_year . "</FONT><BR>";
 	}
	if ($StartMonthError eq "noyear") {
		print "<FONT COLOR=red>You have chosen a starting month, so you must enter a starting year</FONT><BR>";
	}
	if ($StartDayError eq "error") {
	        print "<FONT COLOR=red>Starting day must be numeric</FONT><BR>";   
        } elsif ($StartDayError eq "noyear") {
                print "<FONT COLOR=red>You have chosen a starting day, so you must enter a starting year</FONT><BR>";
	} elsif ($StartDayError eq "nomonth") {
                print "<FONT COLOR=red>You have chosen a starting day, so you must enter a starting month</FONT><BR>";
        } elsif ($StartDayError eq "tooearly") {
                print "<FONT COLOR=red>Starting day must be greater than 0</FONT><BR>";
        } elsif ($StartDayError eq "toolate") {
                print "<FONT COLOR=red>There are only " . $LastStartDay . " days in the chosen starting month</FONT><BR>";
        }
	if ($StartHourError eq "error") {
	        print "<FONT COLOR=red>Starting hour must be numeric</FONT><BR>";   
	} elsif ($StartHourError eq "invalid") {
                print "<FONT COLOR=red>Starting hour must be between 0 and 23</FONT><BR>";
        }
	if ($StartMinuteError eq "error") {
	        print "<FONT COLOR=red>Starting minute must be numeric</FONT><BR>";
	} elsif ($StartMinuteError eq "invalid") {
                print "<FONT COLOR=red>Starting minute must be between 00 and 59</FONT><BR>";
        }
	if ($StartSecondError eq "error") {
	        print "<FONT COLOR=red>Starting centisecond must be numeric</FONT><BR>";
	} elsif ($StartSecondError eq "invalid") {
                print "<FONT COLOR=red>Starting centisecond must be between 0000 and 5999</FONT><BR>";
        }
	if ($EndYearError eq "error") {
	        print "<FONT COLOR=red>Ending year must be numeric</FONT><BR>";
	} elsif ($EndYearError eq "toolow") {
                print "<FONT COLOR=red>Ending year must be greater than or equal to ". $beginning_year . "</FONT><BR>";
        } elsif ($EndYearError eq "toohigh") {
                print "<FONT COLOR=red>Ending year must be less than or equal to " . $final_year . "</FONT><BR>";
        }
        if ($EndMonthError eq "noyear") {
                print "<FONT COLOR=red>You have chosen an ending month, so you must enter a ending year</FONT><BR>";
        }
	if ($EndDayError eq "error") {
	        print "<FONT COLOR=red>Ending day must be numeric</FONT><BR>";
        } elsif ($EndDayError eq "noyear") {        
                print "<FONT COLOR=red>You have chosen an ending day, so you must enter a ending year</FONT><BR>";
        } elsif ($EndDayError eq "nomonth") {
                print "<FONT COLOR=red>You have chosen an ending day, so you must enter a ending month</FONT><BR>";
        } elsif ($EndDayError eq "tooearly") {
                print "<FONT COLOR=red>Ending day must be greater than 0</FONT><BR>";
        } elsif ($EndDayError eq "toolate") {
                print "<FONT COLOR=red>There are only " . $LastEndDay . " days in the chosen ending month</FONT><BR>";
        }
	if ($EndHourError eq "error") {
	        print "<FONT COLOR=red>Ending hour must be numeric</FONT><BR>";
	} elsif ($EndHourError eq "invalid") {
                print "<FONT COLOR=red>Ending hour must be between 0 and 23</FONT><BR>";
        }
	if ($EndMinuteError eq "error") {
	        print "<FONT COLOR=red>Ending minute must be numeric</FONT><BR>";
	} elsif ($EndMinuteError eq "invalid") {
                print "<FONT COLOR=red>Ending minute must be between 00 and 59</FONT><BR>";
        }
	if ($EndSecondError eq "error") {
	        print "<FONT COLOR=red>Ending second must be numeric</FONT><BR>";
	} elsif ($EndSecondError eq "invalid") {
                print "<FONT COLOR=red>Ending centisecond must be between 0000 and 5999</FONT><BR>";
        }

        #Create the table
        print "<TABLE BORDER='0' CELLPADDING='0' CELLSPACING='0' WIDTH='100%'>", "\n";

        #Print a neat "header row" with the days of the week
        print "<TR>", "\n";
	print "<TD WIDTH='14%'> </TD>", "\n";
        print "<TD WIDTH='14%'><U>Month</U></TD>", "\n";
        print "<TD WIDTH='14%'><U>Day</U> (DD)</TD>", "\n";
        print "<TD WIDTH='14%'><U>Year</U> (YYYY)</TD>", "\n";
        print "<TD WIDTH='14%'><U>Hour</U> (00-23)</TD>", "\n";
        print "<TD WIDTH='14%'><U>Minute</U> (00-59)</TD>", "\n";
        print "<TD WIDTH='14%'><U>Second</U> (0000-5999)</TD>", "\n";
        print "</TR>", "\n";

	#Print the Starting information
	print "<TR>", "\n";

	#Print a label
	print "<TD WIDTH='14%'>", "\n";
	print "Starting Date:", "\n";
        print "</TD>", "\n";

	#Create a Starting Month
	print "<TD WIDTH='14%'>", "\n";
        print "<SELECT NAME='StartMonth' SIZE='1'>", "\n";
	&CreateStartingMonthCombo;
	print "</SELECT>", "\n";
	print "</TD>", "\n";

	#Create a Starting Day
	print "<TD WIDTH='14%'>", "\n";
	print "<INPUT TYPE='text' NAME='StartDay' SIZE='3'";
	if ($StartDay ne "") {
		print " VALUE='" . $StartDay . "'";
	}
	print ">", "\n";
	print "</TD>", "\n";

	#Create a Starting Year
	print "<TD WIDTH='14%'>", "\n";
	print "<INPUT TYPE='text' NAME='StartYear' SIZE='5'";
        if ($StartYear ne "") {
                print " VALUE='" . $StartYear . "'";
        }
	print ">", "\n";
	print "</TD>", "\n";

	#Create a Starting Hour
        print "<TD WIDTH='14%'>", "\n";
	print "<INPUT TYPE='text' NAME='StartHour' SIZE='3'", "\n";
	if ($StartHour ne "") {
		print " VALUE='" . $StartHour . "'";
	}
	print ">", "\n";
        print "</TD>", "\n";
        
	#Create a Starting Minute
	print "<TD WIDTH='14%'>", "\n";
	print "<INPUT TYPE='text' NAME='StartMinute' SIZE='3'", "\n";
	if ($StartMinute ne "") {
		print " VALUE='" . $StartMinute . "'";
	}
        print ">", "\n";
        print "</TD>", "\n";

        #Create a Starting Second
        print "<TD WIDTH='14%'>", "\n";
        print "<INPUT TYPE='text' NAME='StartSecond' SIZE='5'", "\n";
        if ($StartSecond ne "") {
                print " VALUE='" . $StartSecond . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

	#Close the row and start a new one
	print "</TR>", "\n";
	print "<TR>", "\n";

        #Let the user select an ending date
        print "<TD WIDTH='14%'>", "\n";
        print "Ending Date: ", "\n";
        print "</TD>", "\n";

        #Do the Ending Month
        print "<TD WIDTH='14%'>", "\n";
        print "<SELECT NAME='EndMonth' SIZE='1'>", "\n";
        &CreateEndingMonthCombo;
        print "</SELECT>", "\n";
        print "</TD>", "\n";

        #Create a Ending Day
        print "<TD WIDTH='14%'>", "\n";
        print "<INPUT TYPE='text' NAME='EndDay' SIZE='3'";
        if ($EndDay ne "") {
                print " VALUE='" . $EndDay . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

        #Create a Ending Year
        print "<TD WIDTH='14%'>", "\n";
        print "<INPUT TYPE='text' NAME='EndYear' SIZE='5'";
        if ($EndYear ne "") {
                print " VALUE='" . $EndYear . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

        #Create a Ending Hour
        print "<TD WIDTH='14%'>", "\n";
        print "<INPUT TYPE='text' NAME='EndHour' SIZE='3'", "\n";
        if ($EndHour ne "") {
                print " VALUE='" . $EndHour . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

        #Create a Ending Minute
        print "<TD WIDTH='14%'>", "\n";
        print "<INPUT TYPE='text' NAME='EndMinute' SIZE='3'", "\n";
        if ($EndMinute ne "") {
                print " VALUE='" . $EndMinute . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

        #Create a Ending Second
        print "<TD WIDTH='14%'>", "\n";
	print "<INPUT TYPE='text' NAME='EndSecond' SIZE='5'", "\n";
        if ($EndSecond ne "") {
                print " VALUE='" . $EndSecond . "'";
        }
        print ">", "\n";
        print "</TD>", "\n";

	#Close the row and the table
	print "</TR>", "\n";
	print "</TABLE>", "\n";

	#See which calendar we should bring up
	if ((($StartYear ne "") && ($StartMonth ne "") && ($StartDay ne "") && ($StartHour eq "")) || ($NewDay ne "")) {

		#Either we've chosen a year, month, and day, or we just chose a day
		&CreateDateRange;

	} elsif ((($StartYear ne "") && ($StartMonth ne "") && ($StartDay eq "")) || ($NewMonth ne "")) {

		#Either we've chosen a year and month, or we just chose a month
		&CreateDayCalendar;

	} elsif ((($StartYear ne "") && ($StartMonth eq "")) || ($NewYear ne "")) {

		#Either we've chosen a year but no month, or we've just chosen a month
		&CreateMonthCalendar;

	} else {

		#Bring up the year calendar
		&CreateYearCalendar;
	}

        #Create some hidden variables
	print "<INPUT TYPE=HIDDEN NAME='Kinst' VALUE=",$Kinst,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstSortBy' VALUE=",$KinstSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstAscDesc' VALUE=",$KinstAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstShow' VALUE=",$KinstShow,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='Kindat' VALUE=",$Kindat,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatSortBy' VALUE=",$KindatSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatAscDesc' VALUE=",$KindatAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatShow' VALUE=",$KindatShow,">", "\n";
	foreach $par(@Parameter)
	{
	    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
	    
	}
        print "<INPUT TYPE=HIDDEN NAME='ParameterSortBy' VALUE=",$ParameterSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterAscDesc' VALUE=",$ParameterAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterShow' VALUE=",$ParameterShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterSearch' VALUE=",$ParameterSearch,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";
}

sub CreateStartingMonthCombo {
#       Create a combo box with starting month information
#
#       &CreateStartingMonthCombo
#
#       INPUT:
#	(none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Create a "month" combo box
        print "<OPTION VALUE=''";
        if ($StartMonth eq '') {
                print " SELECTED";
        }
        print ">None yet</OPTION>", "\n";
        print "<OPTION VALUE='January'";
        if ($StartMonth eq 'January') {
                print " SELECTED";
        }
        print ">January</OPTION>", "\n";
        print "<OPTION VALUE='February'";
        if ($StartMonth eq 'February') {
                print " SELECTED";
        }
        print ">February</OPTION>", "\n";
        print "<OPTION VALUE='March'";
        if ($StartMonth eq 'March') {
                print " SELECTED";
        }
        print ">March</OPTION>", "\n";
        print "<OPTION VALUE='April'";
        if ($StartMonth eq 'April') {
                print " SELECTED";
        }
        print ">April</OPTION>", "\n";
        print "<OPTION VALUE='May'";
        if ($StartMonth eq 'May') {
                print " SELECTED";
        }
        print ">May</OPTION>", "\n";
        print "<OPTION VALUE='June'";
        if ($StartMonth eq 'June') {
                print " SELECTED";
        }
        print ">June</OPTION>", "\n";
        print "<OPTION VALUE='July'";
        if ($StartMonth eq 'July') {
                print " SELECTED";
        }
        print ">July</OPTION>", "\n";
        print "<OPTION VALUE='August'";
        if ($StartMonth eq 'August') {
                print " SELECTED";
        }
        print ">August</OPTION>", "\n";
        print "<OPTION VALUE='September'";
        if ($StartMonth eq 'September') {
                print " SELECTED";
        }
        print ">September</OPTION>", "\n";
        print "<OPTION VALUE='October'";
        if ($StartMonth eq 'October') {
                print " SELECTED";
        }
        print ">October</OPTION>", "\n";
        print "<OPTION VALUE='November'";
        if ($StartMonth eq 'November') {
                print " SELECTED";
        }
        print ">November</OPTION>", "\n";
        print "<OPTION VALUE='December'";
        if ($StartMonth eq 'December') {
                print " SELECTED";
        }
        print ">December</OPTION>", "\n";
}

sub CreateEndingMonthCombo {
#       Create a combo box with ending month information
#
#       &CreateEndingMonthCombo
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Create a "month" combo box
        print "<OPTION VALUE=''";
        if ($EndMonth eq '') {
                print " SELECTED";
        }
        print ">None yet</OPTION>", "\n";
        print "<OPTION VALUE='January'";
        if ($EndMonth eq 'January') {
                print " SELECTED";
        }
        print ">January</OPTION>", "\n";
        print "<OPTION VALUE='February'";
        if ($EndMonth eq 'February') {
                print " SELECTED";
        }
        print ">February</OPTION>", "\n";
        print "<OPTION VALUE='March'";
        if ($EndMonth eq 'March') {
                print " SELECTED";
        }
        print ">March</OPTION>", "\n";
        print "<OPTION VALUE='April'";
        if ($EndMonth eq 'April') {
                print " SELECTED";
        }
        print ">April</OPTION>", "\n";
        print "<OPTION VALUE='May'";
        if ($EndMonth eq 'May') {
                print " SELECTED";
        }
        print ">May</OPTION>", "\n";
        print "<OPTION VALUE='June'";
        if ($EndMonth eq 'June') {
                print " SELECTED";
        }
        print ">June</OPTION>", "\n";
        print "<OPTION VALUE='July'";
	if ($EndMonth eq 'July') {
                print " SELECTED";
        }
	print ">July</OPTION>", "\n";
	print "<OPTION VALUE='August'";
        if ($EndMonth eq 'August') {
                print " SELECTED";
        }
        print ">August</OPTION>", "\n";
        print "<OPTION VALUE='September'";
        if ($EndMonth eq 'September') {
                print " SELECTED";
        }
        print ">September</OPTION>", "\n";
        print "<OPTION VALUE='October'";
        if ($EndMonth eq 'October') {
                print " SELECTED";
        }
        print ">October</OPTION>", "\n";
        print "<OPTION VALUE='November'";
        if ($EndMonth eq 'November') {
                print " SELECTED";
        }
        print ">November</OPTION>", "\n";
        print "<OPTION VALUE='December'";
        if ($EndMonth eq 'December') {
                print " SELECTED";
        }
        print ">December</OPTION>", "\n";
}

sub CreateDateRange {
#       Create a simple way to select a date range
#
#       &CreateDateRange;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Print a header
	print "<P>", "\n";
        print "Please choose a date range:<BR>", "\n";
	print "(the number of days for the query)</P>", "\n";

        #Create a simple text box
        print "<INPUT TYPE='text' NAME='DateRange' SIZE='6'>", "\n";

	#Create a "Calculate" button
        print "<INPUT TYPE='submit' NAME='Calculate' VALUE='Calculate'";
	print ">", "\n";
	print "</P>", "\n";

}

sub CreateDayCalendar {
#       Create the calendar that shows starting days
#
#       &CreateDayCalendar;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Print a header
	print "<P>", "\n";
        print "Please choose a starting day:<BR>", "\n";

	#Figure out what day of the month the 1st falls on (from 0 to 6)
	$FirstDayIndex = &FindDay($EffectiveStartMonth, $EffectiveStartYear);

	#Figure out the last day of the month
	$LastDayIndex = &FindLastDayOfMonth($EffectiveStartMonth, $EffectiveStartYear);

        #Create the mysql statement
        $MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT tbl_date.DAY";
        $FromClause = " FROM tbl_date,tbl_date_in_file";
        $WhereClause = " WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID";
        $JoinClause = " AND tbl_date.YEAR=" . $EffectiveStartYear . " AND tbl_date.MONTH =" . $EffectiveStartMonth;

	#See if the user has chosen anything yet
	$tt=@Parameter;
	if (($Kinst ne "") || ($Kindat ne "") || ($tt>0)) {
		#Add to the clauses
		$FromClause = $FromClause . ",tbl_cedar_file,tbl_file_info,tbl_record_type,tbl_record_info";
		$WhereClause = $WhereClause . " AND tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
	}
	#If the user has chosen a parameter, we need a little bit more information
	if ($NumParameterKeys > 0) {
		#Add to clauses
		$FromClause = $FromClause . ",tbl_record_info";
		$WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
	}

        #See if the user has specified any instruments
        if ($Kinst ne "") {
                $JoinClause = $JoinClause . " AND (tbl_record_type.KINST=" . $Kinst . ")";
        }

        #See if the user has specified any record_type
        if ($Kindat ne "") {
		#Do the split
		($KinstPart,$KindatPart) = split(/\//,$Kindat);
                $JoinClause = $JoinClause . " AND ((tbl_record_type.KINST=" . $KinstPart . ") AND (tbl_record_type.KINDAT=" . $KindatPart . "))";
        }

        #See if the user has specified any parameters
	$tt1=@Parameter;
        if ($tt1>0) {
	    $JoinClause = $JoinClause . " AND (";
	    $index=1;
	    foreach $par(@Parameter)
	    {
                $JoinClause = $JoinClause . "(tbl_record_info.PARAMETER_ID=" . $par  . ")";
		if($index<$tt1)
		{
		    $JoinClause = $JoinClause . " OR ";
		    $index=$index+1;
		}
	    }
	    $JoinClause = $JoinClause .") "
        }

        #Do the query to find the years that have data
        $SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . " ORDER BY tbl_date.DAY ASC;' $CEDARDB";
	
	# Jose Garcia / Debug
	# print "<p>$SqlClause</p>\n";

        open (FINDDATES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateDay");

	#Create a hash of the values
        %DateHash = ();
        while(<FINDDATES>) {
                $NextDate = $_;
                chop($NextDate);
                #Insert it into the hash
                $DateHash{$NextDate} = 'Chosen';
        }

	#PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<P>" . $SqlClause . "</P>", "\n";
	}


        #Create the table
        print "<TABLE BORDER='1' CELLPADDING='0' CELLSPACING='0' WIDTH='100%'>", "\n";

	#Print a neat "header row" with the days of the week
	print "<TR>", "\n";
	print "<TD WIDTH='14%'>Sunday</TD>", "\n";
        print "<TD WIDTH='14%'>Monday</TD>", "\n";
        print "<TD WIDTH='14%'>Tuesday</TD>", "\n";
        print "<TD WIDTH='14%'>Wednesday</TD>", "\n";
        print "<TD WIDTH='14%'>Thursday</TD>", "\n";
        print "<TD WIDTH='14%'>Friday</TD>", "\n";
        print "<TD WIDTH='14%'>Saturday</TD>", "\n";
	print "</TR>", "\n";

        #Loop for each week (six weeks maximum)
        for ($TempDay = 1; $TempDay < 42; ($TempDay = $TempDay + 7)) {

		#See if we need to print another row
		#i.e. the actual sunday is still less or equal than the  last day index
		if (($TempDay-$FirstDayIndex) <= $LastDayIndex ) {

                	#Print the row
                	print "<TR>", "\n";

                	#Loop seven times for each row
                	for ($TempLooper = 0; $TempLooper < 7; $TempLooper++) {

				#Find the actual day value
				$ActualDay = ($TempDay + $TempLooper - $FirstDayIndex);

                        	#Print the cell
                        	print "<TD WIDTH='14%'>";

				#Make sure the day is between 1 and the last day
				if (($ActualDay >= 1) && ($ActualDay <= $LastDayIndex )) {

                                	#Show the data
                                	print "<CENTER>";
                                	if ($DateHash{$ActualDay} ne "") {
                                        	#Show name in red with >brackets<
                                        	print "<FONT COLOR=RED>", "\n";
                                        	print "<INPUT TYPE='submit' VALUE='";
                                        	print "> " . $ActualDay . " <", "\n";
                                        	print "' NAME='NewDay'>";
                                        	print "</FONT>", "\n";
						#Load the next date
						$NextDate = $_;
						chop($NextDate);
                                	} else {
                                        	print "<INPUT TYPE='submit' VALUE='";
                                        	print $ActualDay;
                                        	print "' NAME='NewDay'>";
                                	}
                                	print "</CENTER>", "\n";
                        	} else {
                                	#Leave the cell blank
                                	print "&nbsp;";
                        	}
			print "</TD>", "\n";
                	}

			#Close the row
			print "</TR>", "\n";
		}
        }

        #Close the table
        print "</TABLE>", "\n";
	print "</P>", "\n";

	#Close the handle
	close(FINDDATES);
}

sub CreateMonthCalendar {
#       Create the calendar that shows starting months
#
#       &CreateMonthCalendar;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Print a header
	print "<P>", "\n";
        print "Please choose a starting month:<BR>", "\n";

        #Create the mysql statement
        $MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT tbl_date.MONTH";
	$FromClause = " FROM tbl_date,tbl_date_in_file";
        $WhereClause = " WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID";
        $JoinClause = " AND tbl_date.YEAR=" . $EffectiveStartYear;

        #See if the user has chosen anything yet
	$tt3=@Parameter;
        if (($Kinst ne "") || ($Kindat ne "") || ($tt3>0)) {
                #Add to the clauses
                $FromClause = $FromClause . ",tbl_cedar_file,tbl_file_info,tbl_record_type,tbl_record_info";
                $WhereClause = $WhereClause . " AND tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        }
        #If the user has chosen a parameter, we need a little bit more information
        if ($NumParameterKeys > 0) {
                #Add to clauses
                $FromClause = $FromClause . ",tbl_record_info";
                $WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        }

        #See if the user has specified any instruments
        if ($Kinst ne "") {
                $JoinClause = $JoinClause . " AND (tbl_record_type.KINST=" . $Kinst . ")";
        }

        #See if the user has specified any record_type
        if ($Kindat ne "") {
		#Do the split
		($KinstPart,$KindatPart) = split(/\//,$Kindat);
                $JoinClause = $JoinClause . " AND ((tbl_record_type.KINST=" . $KinstPart . ") AND (tbl_record_type.KINDAT=" . $KindatPart . "))";
        }

        #See if the user has specified any parameters
        $tt2=@Parameter;
	if ($tt2>0) {
	    $JoinClause = $JoinClause . " AND (";
	    $index=1;
	    foreach $par(@Parameter)
	    {
                $JoinClause = $JoinClause . "(tbl_record_info.PARAMETER_ID=" . $par  . ")";
		if($index<$tt2)
		{
		    $JoinClause = $JoinClause . " OR ";
		    $index=$index+1;
		}
	    }
	    $JoinClause = $JoinClause .") "
        }

        #Do the query to find the years that have data
        $SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . " ORDER BY tbl_date.MONTH ASC;' $CEDARDB";
        open (FINDDATES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateMonth");

        #Create a hash of the values
        %DateHash = ();
        while(<FINDDATES>) {
                $NextDate = $_;
                chop($NextDate);
                #Insert it into the hash
                $DateHash{$NextDate} = 'Chosen';
        }

	#PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<P>" . $SqlClause . "</P>", "\n";
	}

        #Create the table
        print "<TABLE BORDER='1' CELLPADDING='0' CELLSPACING='0' WIDTH='100%'>", "\n";

        #Print the row
        print "<TR>", "\n";

        #Print the cell
	print "<TD WIDTH='16%'>";
	print "<CENTER>";
	if ($DateHash{'1'} ne "") {
        	#Show name in red with >brackets<
        	print "<FONT COLOR=RED>", "\n";
        	print "<INPUT TYPE='submit' VALUE='> January <' NAME='NewMonth'>";
        	print "</FONT>", "\n";
		#Load the next date
	        $NextDate = $_;
		chop($NextDate);
	} else {
        	print "<INPUT TYPE='submit' VALUE='January' NAME='NewMonth'>";
	}
	print "</CENTER>", "\n";
	print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'2'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> February <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='February' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'3'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> March <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='March' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'4'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> April <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='April' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'5'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> May <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='May' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'6'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> June <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='June' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

	#Close the row
	print "</TR>", "\n";

	#Print the row
	print "<TR>", "\n";
        
        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'7'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> July <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='July' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'8'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> August <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='August' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'9'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> September <' NAME='NewMonth'>";
                print "</FONT>", "\n";
        } else {
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
                print "<INPUT TYPE='submit' VALUE='September' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'10'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> October <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='October' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'11'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> November <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='November' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Print the cell
        print "<TD WIDTH='16%'>";
        print "<CENTER>";
        if ($DateHash{'12'} ne "") {
                #Show name in red with >brackets<
                print "<FONT COLOR=RED>", "\n";
                print "<INPUT TYPE='submit' VALUE='> December <' NAME='NewMonth'>";
                print "</FONT>", "\n";
                #Load the next date
                $NextDate = $_;
                chop($NextDate);
        } else {
                print "<INPUT TYPE='submit' VALUE='December' NAME='NewMonth'>";
        }
        print "</CENTER>", "\n";
        print "</TD>", "\n";

        #Close the row
        print "</TR>", "\n";

        #Close the table
        print "</TABLE>", "\n";
	print "</P>", "\n";

}

sub CreateYearCalendar {
#       Create the calendar that shows starting years 
#
#       &CreateYearCalendar;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

	#Print a header
	print "<P>", "\n";
	print "Please choose a starting year:<BR>", "\n";

	#Create the mysql statement
	$MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT tbl_date.YEAR";
        $FromClause = " FROM tbl_date,tbl_date_in_file";
        $WhereClause = " WHERE tbl_date.DATE_ID=tbl_date_in_file.DATE_ID";
	$JoinClause = "";

        #See if the user has chosen anything yet
	@tt4=@Parameter;
        if (($Kinst ne "") || ($Kindat ne "") || ($tt4>0)) {
                #Add to the clauses
                $FromClause = $FromClause . ",tbl_cedar_file,tbl_file_info,tbl_record_type,tbl_record_info";
                $WhereClause = $WhereClause . " AND tbl_date_in_file.RECORD_IN_FILE_ID=tbl_file_info.RECORD_IN_FILE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_cedar_file.FILE_ID=tbl_file_info.FILE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID AND tbl_file_info.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        }
        #If the user has chosen a parameter, we need a little bit more information
        if ($NumParameterKeys > 0) {
                #Add to clauses
                $FromClause = $FromClause . ",tbl_record_info";
                $WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        }

	#See if the user has specified any instruments
	if ($Kinst ne "") {
		$JoinClause = $JoinClause . " AND (tbl_record_type.KINST=" . $Kinst . ")";
	}

	#See if the user has specified any record_type
	if ($Kindat ne "") {
		#Do the split
		($KinstPart,$KindatPart) = split(/\//,$Kindat);
		$JoinClause = $JoinClause . " AND ((tbl_record_type.KINST=" . $KinstPart . ") AND (tbl_record_type.KINDAT=" . $KindatPart . "))";
	}

	#See if the user has specified any parameters
	$tt5=@Parameter;
	if ($tt5>0) {
	    $JoinClause = $JoinClause . " AND (";
	    $index=1;
	    foreach $par(@Parameter)
	    {
                $JoinClause = $JoinClause . "(tbl_record_info.PARAMETER_ID=" . $par  . ")";
		if($index<$tt5)
		{
		    $JoinClause = $JoinClause . " OR ";
		    $index=$index+1;
		}
	    }
	    $JoinClause = $JoinClause .") "
        }

	#Do the query to find the years that have data
	$SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . " ORDER BY tbl_date.YEAR ASC;' $CEDARDB";
	open (FINDDATES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateYear");

	#Create a hash of the values
	%DateHash = ();
	while(<FINDDATES>) {
		$NextDate = $_;
		chop($NextDate);
		#Insert it into the hash
		$DateHash{$NextDate} = 'Chosen';
	}

	#PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<P>" . $SqlClause . "</P>", "\n";
	}
        #Create the table
        print "<TABLE BORDER='1' CELLPADDING='0' CELLSPACING='0' WIDTH='100%'>", "\n";

        #Loop as many times as needed, in groups of ten
        for ($TempYear = $beginning_year; $TempYear <= $final_year; ($TempYear = $TempYear + 10)) {

                #Print the row
                print "<TR>", "\n";

                #Loop nine times for each row
                for ($TempLooper = 0; $TempLooper < 10; $TempLooper++) {

                        #Find the actual value
                        $ActualYear = ($TempYear + $TempLooper);

                        #Print the cell
                        print "<TD WIDTH='10%'>";

                        #See if we've gone too far
                        if ($ActualYear <= $final_year) {

				#Show the data
				print "<CENTER>";
				if ($DateHash{$ActualYear} ne "") {

					#Show name in red with >brackets<
					print "<FONT COLOR=RED>", "\n";	
					print "<INPUT TYPE='submit' VALUE='";
					print "> " . $ActualYear . " <", "\n";
	                                print "' NAME='NewYear'>";
					print "</FONT>", "\n";

					#Load the next date
				        $NextDate = $_;
				        chop($NextDate);

				} else {
                                	print "<INPUT TYPE='submit' VALUE='";
					print $ActualYear;
                                        print "' NAME='NewYear'>";
				}
				print "</CENTER>", "\n";
			} else {
				#Leave the cell blank
				print "&nbsp;";
			}
			print "</TD>", "\n";
		}

		#Close the row
		print "</TR>", "\n";
	}	

	#Close the table
	print "</TABLE>", "\n";
	print "</P>", "\n";

        #Close the handle
        close(FINDDATES); 
}

sub DoInstruments {
#       Create the page for the instrument selection
#
#       &DoInstruments;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

	#Create a table
        print "<TABLE BORDER='0' WIDTH='100%' CELLPADDING='1' CELLSPACING='1'>", "\n";
	print "<TR>", "\n";

	#For the left cell, put a header, the instrument table, and a "more info" button
	print "<TD WIDTH='60%' VALIGN='top' ALIGN='left'>", "\n";

	#See if there is an error
	print "<P>", "\n";
        if ($KinstError eq "cantgo") {
                print "<FONT COLOR=red>Please choose at least one instrument or record type before proceeding</FONT></P><P>";
        }

	#Print the KinstList
        print "Select one instrument:</P>", "\n";

        print "<P>Note: you need to click a button on the left to process your selection</P>", "\n";

	print "<P>", "\n";
	&CreateKinstList;
	print "</P>", "\n";

        print "</TD>", "\n";

        #Add the right main page with "sort by", "Ascending/Descending", and "show" combo boxes,
	#buttons to re-sort and clear the list, and a button to go to the world map
        print "<TD WIDTH='40%' VALIGN='top' ALIGN='left'>", "\n";

	#Create a "sort by" combo box
        print "<P>", "\n";
	print "Sort by:<BR>", "\n";
	print "<SELECT NAME='KinstSortBy' SIZE='1'>", "\n";
	print "<OPTION VALUE='Code'";
	if ($KinstSortBy eq 'Code') {
		print " SELECTED";
	}
	print ">Instrument code</OPTION>", "\n";
        print "<OPTION VALUE='Prefix'";
        if ($KinstSortBy eq 'Prefix') {
                print " SELECTED";
        }
        print ">Prefix</OPTION>", "\n";
        print "<OPTION VALUE='Name'";
        if ($KinstSortBy eq 'Name') {
                print " SELECTED";
        }
        print ">Instrument name</OPTION>", "\n";
	print "</SELECT>", "\n";
	print "<BR>", "\n";

	#Create an "Ascending/Descending" combo box
        print "<SELECT NAME='KinstAscDesc' SIZE='1'>", "\n";
        print "<OPTION VALUE='Ascending'";
        if ($KinstAscDesc eq 'Ascending') {
                print " SELECTED";
        }
        print ">Ascending</OPTION>", "\n";
        print "<OPTION VALUE='Descending'";
        if ($KinstAscDesc eq 'Descending') {
                print " SELECTED";
        }
        print ">Descending</OPTION>", "\n";
	print "</SELECT>", "\n";
	print "<BR>", "\n";

        #Create a "show" combo box
        print "<SELECT NAME='KinstShow' SIZE='1'>", "\n";
        print "<OPTION VALUE='All'";
        if ($KinstShow eq 'All') {
                print " SELECTED";
        }
        print ">All Instruments</OPTION>", "\n";
        print "<OPTION VALUE='FabryPerot'";
        if ($KinstShow eq 'FabryPerot') {
                print " SELECTED";
        }
        print ">Fabry-Perot</OPTION>", "\n";
        print "<OPTION VALUE='ISRadar'";
        if ($KinstShow eq 'ISRadar') {
                print " SELECTED";
        }
        print ">I.S. Radar</OPTION>", "\n";
        print "<OPTION VALUE='Models'";
        if ($KinstShow eq 'Models') {
                print " SELECTED";
        }
        print ">Models</OPTION>", "\n";
        print "<OPTION VALUE='Miscellaneous'";
        if ($KinstShow eq 'Miscellaneous') {
                print " SELECTED";
        }
        print ">Miscellaneous</OPTION>", "\n";
        print "</SELECT>", "\n";
	print "</P>", "\n";

	#Give a hard break
	print "<HR>", "\n";

	#Let the user resort or clear the list
	print "<P>", "\n";
        print "<INPUT NAME='ResortInstruments' VALUE='Re-sort list' TYPE='submit'>", "\n";
	print "<BR>", "\n";
        print "<INPUT NAME='ClearInstruments' VALUE='Clear list' TYPE='submit'>", "\n";
        print "</P>", "\n";

	#Finish the right cell
        print "</TD>", "\n";

        #Close up the table
	print "</TR>", "\n";
        print "</TABLE>", "\n";

	#Create some hidden variables
        print "<INPUT TYPE=HIDDEN NAME='StartYear' VALUE=",$StartYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMonth' VALUE=",$StartMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartDay' VALUE=",$StartDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartHour' VALUE=",$StartHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMinute' VALUE=",$StartMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartSecond' VALUE=",$StartSecond,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndYear' VALUE=",$EndYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMonth' VALUE=",$EndMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndDay' VALUE=",$EndDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndHour' VALUE=",$EndHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMinute' VALUE=",$EndMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndSecond' VALUE=",$EndSecond,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='Kindat' VALUE=",$Kindat,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatSortBy' VALUE=",$KindatSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatAscDesc' VALUE=",$KindatAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatShow' VALUE=",$KindatShow,">", "\n";
	foreach $par(@Parameter)
	{
	    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
	    
	}
        print "<INPUT TYPE=HIDDEN NAME='ParameterSortBy' VALUE=",$ParameterSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterAscDesc' VALUE=",$ParameterAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterShow' VALUE=",$ParameterShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterSearch' VALUE=",$ParameterSearch,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";
}

sub CreateKinstList {
#       Uses the MySQL meta-database to create a list of instruments
#       at runtime.
#
#       &CreateKinstList;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       all page variables

        #Set up the Kinst list
        print "<SELECT NAME='Kinst' SIZE='";
        print "15";
        print "'>", "\n";

        #Create the mysql statement
        $MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT concat(tbl_instrument.INST_NAME,\"%\",tbl_instrument.PREFIX,\"%\",tbl_instrument.KINST)";
	$FromClause = " FROM tbl_instrument,tbl_record_info,tbl_record_type";
	$WhereClause = " WHERE tbl_instrument.KINST=tbl_record_type.KINST AND tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        $JoinClause = "";

	#See if the user has selected a date
	if (($StartIndex != 1) || ($EndIndex != $LastIndex)) {

		#Add to the FromClause
		$FromClause = $FromClause . ",tbl_file_info,tbl_cedar_file,tbl_date_in_file";

		#Add to the WhereClause
		$WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID";

		#Add to the JoinClause
		$JoinClause = " AND (tbl_date_in_file.DATE_ID >= " . $StartIndex. ") AND (tbl_date_in_file.DATE_ID <= " . $EndIndex .")";

	}

        #See if the user has specified any record_type
        if ($Kindat ne "") {
		#Do the split
		($KinstPart,$KindatPart) = split(/\//,$Kindat);
                $JoinClause = $JoinClause . " AND ((tbl_record_type.KINST=" . $KinstPart . ") AND (tbl_record_type.KINDAT=" . $KindatPart . "))";
        }

        #See if the user has specified any parameters
	$tt6=@Parameter;
	if ($tt6>0) {
	    $JoinClause = $JoinClause . " AND (";
	    $index=1;
	    foreach $par(@Parameter)
	    {
                $JoinClause = $JoinClause . "(tbl_record_info.PARAMETER_ID=" . $par  . ")";
		if($index<$tt6)
		{
		    $JoinClause = $JoinClause . " OR ";
		    $index=$index+1;
		}
	    }
	    $JoinClause = $JoinClause .") "
        }

	#Figure out sort by
	if ($KinstSortBy eq 'Name') {
		$JoinClause = $JoinClause . " ORDER BY tbl_instrument.INST_NAME";
	} elsif ($KinstSortBy eq 'Prefix') {
		$JoinClause = $JoinClause . " ORDER BY tbl_instrument.PREFIX";
	} else {
		$JoinClause = $JoinClause . " ORDER BY tbl_instrument.KINST";
	}
	#Figure out asc or desc
	if ($KinstAscDesc eq 'Descending') {
		$JoinClause = $JoinClause . " DESC";
	} else {
		$JoinClause = $JoinClause . " ASC";
	}
	#Finish the mysql statement
	$SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . ";' $CEDARDB";

	# Jose Garcia /Debug
	# $tt2=@Parameter;
	# print "<p>$tt2</p>\n";
	# print"<p>$SqlClause</p>\n";

	#Open the SQL
        open (FINDNAMES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateKinstList");

	#Loop through until done
        while (<FINDNAMES>) {

		#Get the current line ($_) and parse it
		($InstName,$Prefix,$KinstCode) = split /%/, $_;
		chop($KinstCode);

		#Create the list item
		print "<OPTION VALUE='" . $KinstCode . "'";
		#See if the item has been selected
		if ($ClearInstruments eq "") {
			if ($Kinst eq $KinstCode) {
				print " SELECTED";
			}
		}

		#Specify the order of display
		print ">" . $KinstCode . " - " . $Prefix . " - " . $InstName . "</OPTION>", "\n";

        }
        close (FINDNAMES);

	#Finish the HTML for the select
        print "</SELECT>", "\n";

	#PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<BR>\n" . $SqlClause . "\n";
	}
}

sub DoKindats {
#       Create the page for the Kindat selection
#
#       &DoKindats;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Create a table
        print "<TABLE BORDER='0' WIDTH='100%' CELLPADDING='1' CELLSPACING='1'>", "\n";
        print "<TR>", "\n";

        #For the left cell, put a header, the kindats table, and a "more info" button
        print "<TD WIDTH='60%' VALIGN='top' ALIGN='left'>", "\n";
        print "<P>", "\n";

        print "Select one record type,<BR>", "\n";
	print "or leave the box blank to select them all:</P>", "\n";

        print "<P>Note: you need to click a button on the left to process your selection</P>", "\n";

	print "<P>", "\n";
        &CreateKindatList;
        print "</P>", "\n";

        print "</TD>", "\n";

        #Add the right main page with "sort by", "Ascending/Descending", and "show" combo boxes,
        #buttons to re-sort and clear the list, and a button to go to the world map
        print "<TD WIDTH='40%' VALIGN='top' ALIGN='left'>", "\n";

        #Create a "sort by" combo box
        print "<P>", "\n";
        print "Sort by:<BR>", "\n";
        print "<SELECT NAME='KindatSortBy' SIZE='1'>", "\n";
        print "<OPTION VALUE='Code'";
        if ($KindatSortBy eq 'Code') {
                print " SELECTED";
        }
        print ">Instrument code</OPTION>", "\n";
        print "<OPTION VALUE='Kindat'";
        if ($KindatSortBy eq 'Kindat') {
                print " SELECTED";
        }
        print ">Record type code</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "<BR>", "\n";

        #Create an "Ascending/Descending" combo box
        print "<SELECT NAME='KindatAscDesc' SIZE='1'>", "\n";
        print "<OPTION VALUE='Ascending'";
        if ($KindatAscDesc eq 'Ascending') {
                print " SELECTED";
        }
        print ">Ascending</OPTION>", "\n";
        print "<OPTION VALUE='Descending'";
        if ($KindatAscDesc eq 'Descending') {
                print " SELECTED";
        }
        print ">Descending</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "<BR>", "\n";

        #Create a "show" combo box
        print "<SELECT NAME='KindatShow' SIZE='1'>", "\n";
        print "<OPTION VALUE='All'";
        if ($KindatShow eq 'All') {
                print " SELECTED";
        }
        print ">All record type codes</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "</P>", "\n";

        #Give a hard break
        print "<HR>", "\n";

        #Let the user resort or clear the list
        print "<P>", "\n";
        print "<INPUT NAME='ResortKindats' VALUE='Re-sort list' TYPE='submit'>", "\n";
        print "<BR>", "\n";
        print "<INPUT NAME='ClearKindats' VALUE='Clear list' TYPE='submit'>", "\n";
        print "</P>", "\n";

        #Finish the right cell
        print "</TD>", "\n";

        #Close up the table
        print "</TR>", "\n";
        print "</TABLE>", "\n";

        # Print the legend
	print "<b>Legend:</b>\n";
	print "<ul>\n";
	print "<li>Nu=uncorrected electron density (Ne) from fine ht resolution power profiles.</li>\n";
	print "<li>ACFs produce Ne, Te and Ti (Tr=Te/Ti) in long and short pulse lengths.</li>\n";
	print "<li>The longer pulse lengths cover more altitude, and are better in the F region.</li>\n";
	print "<li>Ni=ion density, which is either assumed or calculated from ACFs. </li>\n";
	print "<li>CF=ACFs in EISCAT records (huge); use kindat+1000 for records w/o ACFs < 1994.</li>\n";
	print "<li>Nn=any kind of neutral density except for Na (sodium) and Fe (iron). </li>\n";
	print "<li>Tn,Vn=neutral temperature and winds.</li>\n";
	print "<li>Vi=ion winds, related to electric fields (Ef), and electric potential (Ep), and electric current density (Je) and Joule heating (Qj).</li>\n";
	print "<li>Sg=sigma or conductances and particle heating (Qp) are related to Ne</li>\n";
	print "</ul>\n";

	#Create some hidden variables
        print "<INPUT TYPE=HIDDEN NAME='StartYear' VALUE=",$StartYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMonth' VALUE=",$StartMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartDay' VALUE=",$StartDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartHour' VALUE=",$StartHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMinute' VALUE=",$StartMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartSecond' VALUE=",$StartSecond,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndYear' VALUE=",$EndYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMonth' VALUE=",$EndMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndDay' VALUE=",$EndDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndHour' VALUE=",$EndHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMinute' VALUE=",$EndMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndSecond' VALUE=",$EndSecond,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='Kinst' VALUE=",$Kinst,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstSortBy' VALUE=",$KinstSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstAscDesc' VALUE=",$KinstAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstShow' VALUE=",$KinstShow,">", "\n";
	foreach $par(@Parameter)
	{
	    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
	    
	}
        print "<INPUT TYPE=HIDDEN NAME='ParameterSortBy' VALUE=",$ParameterSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterAscDesc' VALUE=",$ParameterAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterShow' VALUE=",$ParameterShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterSearch' VALUE=",$ParameterSearch,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";
}

sub CreateKindatList {
#       Uses the MySQL meta-database to create a list of KINDAT codes
#       at runtime.
#
#       &CreateKindatList;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       all page variables

        #Set up the Kinst list
        print "<SELECT NAME='Kindat' SIZE='";
        print "15";
        print "'>", "\n";

        #Create the mysql statement
        $MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT concat(tbl_record_type.KINST,\"%\",tbl_record_type.KINDAT,\"%\",tbl_record_type.DESCRIPTION)";
        $FromClause = " FROM tbl_record_info,tbl_record_type";
        $WhereClause = " WHERE tbl_record_type.RECORD_TYPE_ID=tbl_record_info.RECORD_TYPE_ID";
        $JoinClause = "";

        #See if the user has selected a date
        if (($StartIndex != 1) || ($EndIndex != $LastIndex)) {

                #Add to the FromClause
                $FromClause = $FromClause . ",tbl_file_info,tbl_cedar_file,tbl_date_in_file";

                #Add to the WhereClause
                $WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID";

                #Add to the JoinClause
                $JoinClause = " AND (tbl_date_in_file.DATE_ID >= " . $StartIndex. ") AND (tbl_date_in_file.DATE_ID <= " . $EndIndex .")";

        }

        #See if the user has specified any instruments
	if ($Kinst ne "") {
                $JoinClause = $JoinClause . " AND (tbl_record_type.KINST=" . $Kinst . ")";
        }

        #See if the user has specified any parameters
	$tt7=@Parameter;
	if ($tt7>0) {
	    $JoinClause = $JoinClause . " AND (";
	    $index=1;
	    foreach $par(@Parameter)
	    {
                $JoinClause = $JoinClause . "(tbl_record_info.PARAMETER_ID=" . $par  . ")";
		if($index<$tt7)
		{
		    $JoinClause = $JoinClause . " OR ";
		    $index=$index+1;
		}
	    }
	    $JoinClause = $JoinClause .") "
        }

        #Figure out sort by
        if ($KindatSortBy eq 'Kindat') {
                $JoinClause = $JoinClause . " ORDER BY tbl_record_type.KINDAT,tbl_record_type.KINST";
        } else {
                $JoinClause = $JoinClause . " ORDER BY tbl_record_type.KINST,tbl_record_type.KINDAT";
        }
        #Figure out asc or desc
        if ($KindatAscDesc eq 'Descending') {
                $JoinClause = $JoinClause . " DESC";
        } else {
                $JoinClause = $JoinClause . " ASC";
        }
        #Finish the mysql statement
        $SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . ";' $CEDARDB";
	
	#Jose Garcia / Debug
	#print "<p>$SqlClause</p>\n";

        #Open the SQL
        open (FINDNAMES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateKindatList");

        #Loop through until done
        while (<FINDNAMES>) {

                #Get the current line ($_) and parse it
                ($KinstCode,$KindatCode,$KindatDesc) = split /%/, $_;
                chop($KindatDesc);

                #Create the list item
                print "<OPTION VALUE='" . $KinstCode . "/" . $KindatCode . "'";
                #See if the item has been selected
		if ($ClearKindats eq "") {
                	if ($Kindat eq ($KinstCode . "/" . $KindatCode)) {
                        	print " SELECTED";
			}
                }

                #Specify the order of display
                print ">" . $KinstCode . " - " . $KindatCode . " " . $KindatDesc . "</OPTION>", "\n";

        }
        close (FINDNAMES);

        #Finish the HTML for the select
        print "</SELECT>", "\n";

        #PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<BR>\n" . $SqlClause . "\n";
	}
}

sub DoParameters {
#       Create the page for the parameter selection
#
#       &DoParameters;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        #Create a table
        print "<TABLE BORDER='0' WIDTH='100%' CELLPADDING='1' CELLSPACING='1'>", "\n";
        print "<TR>", "\n";

        #For the left cell, put a header, the parameter table, and a button for more info
        print "<TD WIDTH='60%' VALIGN='top' ALIGN='left'>", "\n";
        print "<P>", "\n";
        print "Select one or more parameters,<BR>", "\n";
        print "or leave the box blank to select them all:</P>", "\n";
	print "<P>Note: you need to click a button on the left to process your selection</P>", "\n";

        &CreateParameterList;
        print "</P>", "\n";

        print "</TD>", "\n";

        #Add the right main page, with a kindat combo box and and button for more info,
	#combo boxes for "sort by", "Ascending/Descending", and "show", a label for the
	#search text box, the text box and its "go" button, and buttons to resort or clear the list
        print "<TD WIDTH='40%' VALIGN='top' ALIGN='left'>", "\n";

        #Create a "sort by" combo box
        print "<P>", "\n";
        print "Sort by:<BR>", "\n";
        print "<SELECT NAME='ParameterSortBy' SIZE='1'>", "\n";
        print "<OPTION VALUE='Code'";
        if ($ParameterSortBy eq 'Code') {
                print " SELECTED";
        }
        print ">Parameter code</OPTION>", "\n";
        print "<OPTION VALUE='Madrigal'";
        if ($ParameterSortBy eq 'Madrigal') {
                print " SELECTED";
        }
        print ">Madrigal name</OPTION>", "\n";
        print "<OPTION VALUE='Description'";
        if ($ParameterSortBy eq 'Description') {
                print " SELECTED";
        }
        print ">Description</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "<BR>", "\n";
 
        #Create an "Ascending/Descending" combo box
        print "<SELECT NAME='ParameterAscDesc' SIZE='1'>", "\n";
        print "<OPTION VALUE='Ascending'";
        if ($ParameterAscDesc eq 'Ascending') {
                print " SELECTED";
        }
        print ">Ascending</OPTION>", "\n";
        print "<OPTION VALUE='Descending'";
        if ($ParameterAscDesc eq 'Descending') {
                print " SELECTED";
        }
        print ">Descending</OPTION>", "\n";
        print "</SELECT>", "\n";
	print "<BR>", "\n";

        #Create a "show" combo box
        print "<SELECT NAME='ParameterShow' SIZE='1'>", "\n";
        print "<OPTION VALUE='All'";
        if ($ParameterShow eq 'All') {
                print " SELECTED";
        }
        print ">All Parameters</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "</P>", "\n";

        #Create a searching text box
        #print "<P>", "\n";
        #print "Search (with wildcards):<BR>", "\n";
        #print "<INPUT TYPE='text' NAME='ParameterSearch' SIZE='10' VALUE='" . $ParameterSearch . "'>", "\n";
	#print "<INPUT NAME='ParameterReSearch' VALUE='Search' TYPE='submit'>", "\n";
	#print "</P>", "\n";

	#Give a hard break
	print "<HR>", "\n";

        #Let the user resort or clear the list
        print "<P>", "\n";
        print "<INPUT NAME='ResortParameters' VALUE='Re-sort list' TYPE='submit'>", "\n";
        print "<BR>", "\n";
        print "<INPUT NAME='ClearParameters' VALUE='Clear list' TYPE='submit'>", "\n";
        print "</P>", "\n";

        #Finish the right cell
        print "</TD>", "\n";

        #Close up the table
        print "</TR>", "\n";
        print "</TABLE>", "\n";

        #Create some hidden variables
        print "<INPUT TYPE=HIDDEN NAME='StartYear' VALUE=",$StartYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMonth' VALUE=",$StartMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartDay' VALUE=",$StartDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartHour' VALUE=",$StartHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMinute' VALUE=",$StartMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartSecond' VALUE=",$StartSecond,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndYear' VALUE=",$EndYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMonth' VALUE=",$EndMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndDay' VALUE=",$EndDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndHour' VALUE=",$EndHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMinute' VALUE=",$EndMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndSecond' VALUE=",$EndSecond,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='Kinst' VALUE=",$Kinst,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstSortBy' VALUE=",$KinstSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstAscDesc' VALUE=",$KinstAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstShow' VALUE=",$KinstShow,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='Kindat' VALUE=",$Kindat,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatSortBy' VALUE=",$KindatSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatAscDesc' VALUE=",$KindatAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatShow' VALUE=",$KindatShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";
}

sub CreateParameterList {
#       Uses the MySQL meta-database to create a list of parameters
#       at runtime.
#
#       &CreateParameterList;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       all page variables

        #Set up the parameter list
        print "<SELECT NAME='Parameter' SIZE='";
        print "15";
        print "' MULTIPLE>", "\n";

        #Create the mysql statement
        $MainClause = $mysql_client . " -s -B -u$user -p$pass -S$unix_sock -e'SELECT DISTINCT concat(tbl_parameter_code.PARAMETER_ID,\"%\",tbl_parameter_code.MADRIGAL_NAME,\"%\",tbl_parameter_code.LONG_NAME)";
	$FromClause = " FROM tbl_parameter_code";
	$WhereClause = " WHERE (1)";
        $JoinClause = "";

        #See if the user has chosen anything yet
        if (($Kinst ne "") || ($Kindat ne "") || ($StartIndex != 1) || ($EndIndex != $LastIndex)) {
                #Add to the clauses
                $FromClause = $FromClause . ",tbl_record_info,tbl_record_type";
                $WhereClause = $WhereClause . " AND tbl_parameter_code.PARAMETER_ID=tbl_record_info.PARAMETER_ID AND tbl_record_info.RECORD_TYPE_ID=tbl_record_type.RECORD_TYPE_ID";
        }

        #See if the user has selected a date
        if (($StartIndex != 1) || ($EndIndex != $LastIndex)) {

                #Add to the FromClause
                $FromClause = $FromClause . ",tbl_file_info,tbl_cedar_file,tbl_date_in_file";

                #Add to the WhereClause
                $WhereClause = $WhereClause . " AND tbl_record_type.RECORD_TYPE_ID=tbl_file_info.RECORD_TYPE_ID AND tbl_file_info.FILE_ID=tbl_cedar_file.FILE_ID AND tbl_file_info.RECORD_IN_FILE_ID=tbl_date_in_file.RECORD_IN_FILE_ID";

                #Add to the JoinClause
                $JoinClause = " AND (tbl_date_in_file.DATE_ID >= " . $StartIndex. ") AND (tbl_date_in_file.DATE_ID <= " . $EndIndex .")";

        }

        #See if the user has specified any instruments
	if ($Kinst ne "") {
                $JoinClause = $JoinClause . " AND (tbl_record_type.KINST=" . $Kinst . ")";
        }

        #See if the user has specified any record_type
	if ($Kindat ne "") {
		#Do the split
		($KinstPart,$KindatPart) = split(/\//,$Kindat);
                $JoinClause = $JoinClause . " AND ((tbl_record_type.KINST=" . $KinstPart . ") AND (tbl_record_type.KINDAT=" . $KindatPart . "))";
        }

        #Figure out sort by
        if ($ParameterSortBy eq 'Description') {
                $JoinClause = $JoinClause . " ORDER BY tbl_parameter_code.LONG_NAME";
        } elsif ($ParameterSortBy eq 'Madrigal') {
                $JoinClause = $JoinClause . " ORDER BY tbl_parameter_code.MADRIGAL_NAME";
	} else {
		$JoinClause = $JoinClause . " ORDER BY tbl_parameter_code.PARAMETER_ID";
        }
        #Figure out asc or desc
        if ($ParameterAscDesc eq 'Descending') {
                $JoinClause = $JoinClause . " DESC";
        } else {
                $JoinClause = $JoinClause . " ASC";
        }
        #Finish the mysql statement
        $SqlClause = $MainClause . $FromClause . $WhereClause . $JoinClause . ";' $CEDARDB";

        #Open the SQL
        open (FINDNAMES, "$SqlClause|") || DoExit ("MySQL could not open MySQL for CreateParameterList");

        #Loop through until done
        while (<FINDNAMES>) {

                #Get the current line ($_) and parse it
                ($Id,$MadrigalName,$LongName) = split /%/, $_;
                chop($LongName);

                #Create the list item
                print "<OPTION VALUE='" . $Id . "'";
                #See if the item has been selected
		if ($ClearParameters eq "") {
		    foreach $par(@Parameter)
		    {
                	if ($par == $Id) {
			    print " SELECTED";
                	}
		    }
		}

                #Specify the order of display
                print ">" . $Id . " - " . $MadrigalName . " - " . $LongName . "</OPTION>", "\n";

        }
        close (FINDNAMES);

        #Finish the HTML for the select
        print "</SELECT>", "\n";

        #PLK testing
	if ($DebugSQLClause eq "TRUE") {
	    print "<BR>\n" . $SqlClause . "\n";
	}
}

sub DoGo {
#       Create the page for the data to be returned 
#
#       &DoGo;
#
#       INPUT:
#       (none)
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

	#Create a table with two columns
        print "<TABLE BORDER='0' CELLPADDING='1' CELLSPACING='1' WIDTH='100%'>", "\n";
        print "<TR>", "\n";

        #Do the left column
        print "<TD WIDTH='50%' VALIGN='top' ALIGN='left'>", "\n";

	#Create a header
	print "<P>You have chosen the following selections:</P>", "\n";

	#Show the selections
	print "<P>", "\n";
	print "Starting Date_Time: " . $EffectiveStartYear . "," . $EffectiveStartMonth . "," . $EffectiveStartDay . "," . $EffectiveStartHour . "," . $EffectiveStartMinute . "," . $EffectiveStartSecond . "<BR>", "\n";
        print "Ending Date_Time: " . $EffectiveEndYear . "," . $EffectiveEndMonth . "," . $EffectiveEndDay . "," . $EffectiveEndHour . "," . $EffectiveEndMinute . "," . $EffectiveEndSecond, "<BR>\n";
	#PLK testing
        #print "Start index: " . $StartIndex . "<BR>", "\n";
        #print "End index: " . $EndIndex . "<BR>", "\n";
	#print "</P>", "\n";

	#Show the instruments
	print "<P>", "\n";
	print "Instrument(s):", "\n";
	print "<UL>", "\n";
	if ($Kinst ne "") {
        	print "<LI>" . $Kinst . "</LI>", "\n";
	} else {
		#Print "All instruments"
		print "<LI>All instruments</LI>", "\n";
	}
	print "</UL>", "\n";
	print "</P>", "\n";

	#Show the KINDATs
	print "<P>", "\n";
	print "Record Type(s):" ,"\n";
	print "<UL>", "\n";
        if ($Kindat ne "") {
        	print "<LI>" . $Kindat . "</LI>", "\n";
        } else {
                #Print "All record types"
                print "<LI>All record types</LI>", "\n"; 
        }
	print "</UL>", "\n";
	print "</P>", "\n";

	#Show the parameters
	print "<P>", "\n";
	print "Parameter(s):", "\n";
	print "<UL>", "\n";
	$tt8=@Parameter;
        if ($tt8>0) {
	    foreach $par(@Parameter)
	    {
        	print "<LI>" . $par . "</LI>", "\n";
	    }
        } else {        
                #Print "All parameters"
                print "<LI>All parameters</LI>", "\n";        
        }      

	print "</UL>", "\n";
	print "</P>", "\n";

        #Tell the user how big the data file will be
        #print "<P>", "\n";
	#print "This query will return:", "\n";
        #print "<UL>", "\n";
        #print "<LI>0 MB ASCII</LI>", "\n";
	#print "</UL>", "\n";
	#print "</P>", "\n";

	#Give the user a button to redo this query
        print "<FORM ACTION='" . $cgi_site . "/cedarweb_debug.pl' METHOD='POST'>", "\n";
        print "<INPUT NAME='Modify' VALUE='Modify Query' TYPE='submit'>", "\n";

	#Add the hidden variables
        print "<INPUT TYPE=HIDDEN NAME='StartYear' VALUE=",$StartYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMonth' VALUE=",$StartMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartDay' VALUE=",$StartDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartHour' VALUE=",$StartHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartMinute' VALUE=",$StartMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='StartSecond' VALUE=",$StartSecond,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndYear' VALUE=",$EndYear,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMonth' VALUE=",$EndMonth,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndDay' VALUE=",$EndDay,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndHour' VALUE=",$EndHour,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndMinute' VALUE=",$EndMinute,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='EndSecond' VALUE=",$EndSecond,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='Kinst' VALUE=",$Kinst,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstSortBy' VALUE=",$KinstSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstAscDesc' VALUE=",$KinstAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KinstShow' VALUE=",$KinstShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='Kindat' VALUE=",$Kindat,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatSortBy' VALUE=",$KindatSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatAscDesc' VALUE=",$KindatAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='KindatShow' VALUE=",$KindatShow,">", "\n";
	foreach $par(@Parameter)
	{
	    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
	    
	}
        print "<INPUT TYPE=HIDDEN NAME='ParameterSortBy' VALUE=",$ParameterSortBy,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterAscDesc' VALUE=",$ParameterAscDesc,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterShow' VALUE=",$ParameterShow,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='ParameterSearch' VALUE=",$ParameterSearch,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='filter' VALUE=",$Filter,">", "\n";

	#End the form
        print "</FORM>", "\n";

	#Give the user a button to clear the query
        print "<FORM ACTION='" . $cgi_site . "/cedarweb_debug.pl' METHOD='POST'>", "\n";
        print "<INPUT NAME='Clear' VALUE='Clear Query' TYPE='submit'>", "\n";
        print "</FORM>", "\n";
        print "</P>", "\n";

	#Finish the cell
	print "</TD>", "\n";

	#Do the right column
        print "<TD WIDTH='50%' VALIGN='top' ALIGN='left'>", "\n";

	#Put all of this into a form
        print "<FORM ACTION='" . $cgi_site . "/Submit_debug.pl' METHOD='GET'>", "\n";

	#Create a selection combo for the filter
	print "<P>", "\n";
        print "Return data as (INFO= header/catalog, TAB= ascii similar to DB ascii with labels):<BR>", "\n";
        print "<SELECT NAME='filter' SIZE='1'>", "\n";
        print "<OPTION VALUE='INFO'";
        if ($Filter eq "INFO") {
                print " SELECTED";
        }
        print ">INFO - Information about the data</OPTION>", "\n";
        print "<OPTION VALUE='DAS'";
        if ($Filter eq "DAS") {
                print " SELECTED";
        }
        print ">DAS - DODS Attribute Service</OPTION>", "\n";
        print "<OPTION VALUE='DDS'";
        if ($Filter eq "DDS") {
                print " SELECTED";
        }
        print ">DDS - DODS Descriptor Service</OPTION>", "\n";
        print "<OPTION VALUE='DODS'";
        if ($Filter eq "DODS") {
                print " SELECTED";
        }
        print ">DODS - DODS Data Service (binary)</OPTION>", "\n";
        print "<OPTION VALUE='ASC'";
        if ($Filter eq "ASC") {
                print " SELECTED";
        }
        print ">ASC - DODS Data Service (ascii)</OPTION>", "\n";
        print "<OPTION VALUE='TAB'";
        if (($Filter eq "") || ($Filter eq "TAB")) {
                print " SELECTED";
        }
        print ">TAB - DODS Data Service (tab delimited)</OPTION>", "\n";
        print "<OPTION VALUE='HELP'";
        if ($Filter eq "HELP") {
                print " SELECTED";
        }
        print ">HELP - DODS Help File</OPTION>", "\n";
        print "<OPTION VALUE='VER'";
        if ($Filter eq "VER") {
                print " SELECTED";
        }
        print ">VER - DODS Version file</OPTION>", "\n";
        print "</SELECT>", "\n";
        print "</P>", "\n";

	#Create a button to actually get the file
	print "<P>", "\n";
        print "<INPUT NAME='GetFile' VALUE='Get the data file(s) with these options' TYPE='submit'>", "\n";
        print "</P>", "\n";
	
	print "<P>", "\n";
	print "NOTE: If you use 'Back' on your browser, you will get a ";
	print "<b>'Data Missing'</b>";
	print " message from your browser since the access procedure disallows caching.";
	print " Click on the 'Reload' button in your browser to restore.";
	print " Also, the URL itself can be changed in the 'Location' edit area in your browser."; 
	print "</P>", "\n";

	#Create the hidden variables
	$FullStart = $EffectiveStartYear . "," . $EffectiveStartMonth . $EffectiveStartDay . "," . $EffectiveStartHour . $EffectiveStartMinute . "," . $EffectiveStartSecond;
        $FullEnd = $EffectiveEndYear . "," . $EffectiveEndMonth . $EffectiveEndDay . "," . $EffectiveEndHour . $EffectiveEndMinute . "," . $EffectiveEndSecond;
	#Send the date as 1990,0130,2015,0000,1991,0220,2359,5999
	$FullDate = $FullStart . "," . $FullEnd;
        print "<INPUT TYPE=HIDDEN NAME='date' VALUE=" . $FullDate,">", "\n";
	print "<INPUT TYPE=HIDDEN NAME='instrument' VALUE=",$Kinst,">", "\n";
        print "<INPUT TYPE=HIDDEN NAME='record_type' VALUE=",$Kindat,">", "\n";
	foreach $par(@Parameter)
	{
	    print "<INPUT TYPE=HIDDEN NAME='Parameter' VALUE=$par>\n",
	    
	}
        #End the form
        print "</FORM>", "\n";

        #Finish the cell
        print "</TD>", "\n";

        #Finish the table
        print "</TR>", "\n";
        print "</TABLE>", "\n";
	
}

sub FindLastDayOfMonth
{
#       Given a month and year, find the last day of that month
#
#       &FindLastDayOfMonth;
#
#       INPUT:
#	$month = the month we are checking (with two digits)
#       $year = the year we are checking (with all four digits)
#       RETURNS:
#       A number representing the last day of the month (28--31)
#       If the data is invalid, 0 will be returned
#       EXTERNALS:
#       (none)

	my $inmonth = shift;	
	$mymonth = 0 + $inmonth;
	my $inyear = shift;
	$myyear = 0 + $inyear;
	if (($mymonth == 1) || ($mymonth == 3) || ($mymonth == 5) || ($mymonth == 7) || ($mymonth == 8) || ($mymonth == 10) || ($mymonth == 12)) {
		#There are 31 days
		return (31);	
	} elsif (($mymonth == 4) || ($mymonth == 6) || ($mymonth == 9) || ($mymonth == 11)) {
		#There are 30 days
		return (30);
	} else {
		#See if that year is a leap year
		if (&IsLeapYear($myyear)) {
			#It is
			return (29);
		} else {
			# It is not a leap year
			return (28);
		}
	}

}

sub FindDay
{
#       Given a month and a year, find which day of the month it is (0-6)
#
#       &FindDay
#
#       INPUT:
#       $month = the month we are checking (with two digits)
#       $year = the year we are checking (with all four digits)
#       RETURNS:
#       A number representing the day of the week (0-6)
#       EXTERNALS:
#       (none)

        my $inmonth = shift;
        $mymonth = 0 + $inmonth;
        my $inyear = shift;
        $myyear = 0 + $inyear;

	#Use the localtime command to find the date
        $TempDate = parsedate($mymonth."/01/".$myyear);
        @MyDate = localtime($TempDate);
        $MyWeekDay = @MyDate[6];

	#This is the value (0 to 6)
	return ($MyWeekDay);
}

sub IsLeapYear
{
#       Cute little program to figure out is the passed-in year is a leap year
#
#       &IsLeapYear;
#
#       INPUT:
#       $year = the year we are checking (with all four digits)
#       RETURNS:
#       0 = the year is not a leap year
#       1 = the year *is* a leap year
#       EXTERNALS:
#       (none)

	my $inyear = shift;
	$myyear = 0 + $inyear;
	$leap = ($myyear%4 == 0 && $myyear%100 != 0 || $myyear%400 == 0) ;
	return $leap;
}

sub DoExit {
#	Cute little program to exit smoothly
#
#	&DoExit;
#
#	INPUT:
#       $ErrMessage = Message to print to error file
#       RETURNS:
#       (none)
#       EXTERNALS:
#       (none)

        my $ErrMessage = shift;

	print $ErrMessage . "\n";
	#Open up a file
	#if (open (ERRFILE,">error.log")) {
	#        print ERRFILE $ErrMessage;
	#}
	#close (ERRFILE);
        exit(1);
}

1;


