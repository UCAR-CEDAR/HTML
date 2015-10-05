#!/opt/local/bin/perl
#perl mailToLouise.pl last=Ederer first=Tim email=ederer@colorado.edu country=USA telephone=444-4444
#FAX=555-5555 zip=80005 citystate="boulder, CO" inst=NCAR dept=HAO st="3xxx Mitchell Ln" email2=ederer@poop.edu
 
use CGI;

$ENV{PATH}='/bin:/usr/bin';
$ENV{IFS}="" if $ENV{IFS} ne "";


$query= new CGI;

# Get name to put on e-mail message
$last = $query->param('last');
$first = $query->param('first');
$name = "$first $last";

$zemail = $query->param('email');
$zemail =~ /([-\@\w.]+)$/;

# Define email addresses for reporting. 
$male= "| mailx -s'CEDAR Community: Address correction from ". $name. "' emery\@ucar.edu, louise\@ucar.edu, $zemail";

#Message from Bill Roberts
$zemail = "ackpht";
 
# html code for the output to the browser.
print STDOUT "Content-Type: text/html\n\n";
print STDOUT "</body></html>";


$zemail = $1;
if ($zemail){
$female= "| mailx $zemail";

open(MALE, $male) || die "Failed and stuff";

print MALE "-----------------------------------------------------\n";
print MALE "   CEDAR Community updated address\n";
print MALE "-----------------------------------------------------\n";

# General registration information and stuff...
$inst = $query->param('inst');
#if (length($inst) == 0) {$inst= " "};
$dept = $query->param('dept');
if (length($dept) == 0) {$dept= " "};
$st = $query->param('st');
if (length($st) == 0) {$st= " "};
$citystate = $query->param('citystate');
if (length($citystate) == 0) {$citystate= " "};
$zip = $query->param('zip');
if (length($zip) == 0) {$zip= " "};
$country = $query->param('country');
if (length($country) == 0) {$zip= " "};
$tele = $query->param('telephone');
if (length($tele) == 0) {$tele= " "};
$fax = $query->param('FAX');
if (length($fax) == 0) {$fax= " "};

# Get current time
# $mon=0-11, $yday=0-365, $wday=0-6, $year=year-1900, $mday=1!!-31, $hour=0-23,$min=0-59
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
# Late fee imposed on STUDENT and OTHER if > May 28 (daynum=148, $yday=147)
#  Allow 2 days grace (to 24 UT on Sunday May 30, or 3 PM MST)
 if ($late_fee ne 'on' && $yday > 149) {$late_fee='on'}

print STDOUT "<ul>\n";

#Send info to page for review by applicant
print STDOUT "<li>Year Yrday Month Month Day UTHour Min = ",
  $year+1900," ",$yday+1," ",$mon+1," ", $mday," ",$hour," ",$min, "<p>\n";
print STDOUT "<li>Last= ",$last,"\n";
print STDOUT "<li>First= ",$first,"\n";
print STDOUT "<li>Institution= ", $inst, "\n";
#print STDOUT "<li>Institution Address=\n", $address, "\n";
print STDOUT "<li>Department= ", $dept, "\n";
print STDOUT "<li>Street Address or PO Box= ", $st, "\n";
print STDOUT "<li>City and State (or Province)= ", $citystate, "\n";
print STDOUT "<li>Zip or City/Country code= ", $zip, "\n";
print STDOUT "<li>Country= ", $country, "\n";
print STDOUT "<li>Telephone= ", $tele, "\n";
print STDOUT "<li>Fax= ", $fax, "\n";
print STDOUT "<li>E-mail= ", $zemail,"\n";

#Send the info to Louise.
print MALE "Year Yrday Month Month Day UTHour Min = ",
  $year+1900," ",$yday+1," ",$mon+1," ", $mday," ",$hour," ",$min, "\n";
print MALE "Last= ",$last,"\n";
print MALE "First= ",$first,"\n";
print MALE "Institution= ", $inst, "\n";
#print MALE "Institution Address=\n", $address, "\n";
print MALE "Department= ", $dept, "\n";
print MALE "Street Address or PO Box= ", $st, "\n";
print MALE "City and State (or Province)= ", $citystate, "\n";
print MALE "Zip or City/Country code= ", $zip, "\n";
print MALE "Country= ", $country, "\n";
print MALE "Telephone= ", $tele, "\n";
print MALE "Fax= ", $fax, "\n";
print MALE "E-mail= ", $zemail, "\n";
print MALE "--------------------------------------------------\n";


print STDOUT "<hr wid= 60%><p>\n";
print MALE "--------------------------------------------------\n";

print STDOUT "</body></html>\n";

close(MALE);


} else {
  print STDOUT "<center><p>";
  print STDOUT "<hr width= 70%><p>";
  print STDOUT "<font color= red><blink>";
  print STDOUT "<h1>STOP!!! You failed to give a valid e-mail address.</h1></blink>";
}
