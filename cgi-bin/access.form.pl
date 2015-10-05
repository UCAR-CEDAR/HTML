#!/usr/bin/perl
# This perl script used by ...access.form.html 

use CGI;
$ENV{PATH}='/bin:/usr/bin';
$ENV{IFS}="" if $ENV{IFS} ne "";

$query= new CGI;

# General information and stuff...
$name= $query->param('name');
$address= $query->param('address');
$voice= $query->param('voice');
$fax= $query->param('fax');
$email= $query->param('email');
$existing= $query->param('existing');
$existuname1= $query->param('existuname1');
$existuname2= $query->param('existuname2');
$web= $query->param('web');
$webuname1= $query->param('webuname1');
$webuname2= $query->param('webuname2');
$haveused= $query->param('haveused');
$likeuse= $query->param('likeuse');
$advisor=$query->param('advisor');
$agreetoread= $query->param('agreetoread');
$date= $query->param('date');

# Send the email to Barbara Emery (emery@ucar.edu) and cedar_db
$tmale= "| mail -s'Access form for ". $name. "' cedar_db\@hao.ucar.edu";

print STDOUT ("Content-Type: text/html\n\n");

# Make sure the user signs and dates the form
#if (($agreetoread EQ "") || ($date EQ "")) {
if ((length($agreetoread) == 0) || (length($date) == 0)) {
 print STDOUT ("<HTML>\n");
 print STDOUT ("<BODY>\n");
 print STDOUT ("<P><H2>You must read and agree to the Rules of the Road to submit this form.</H2><BR>", "\n");
 print STDOUT ("Please go back and sign and date your application.</P>", "\n");
 print STDOUT ("</BODY></HTML>");
 exit(0);
}

# Now for the html code for output to the browser.
print STDOUT ("<HTML>\n");
print STDOUT ("<BODY>\n\n");

print STDOUT ("<H2>You have submitted the following for consideration:</H2>\n");
print STDOUT ("<HR width= 60%>");
print STDOUT ("<UL>\n");
print STDOUT ("<LI>Name= ", $name, "\n");
print STDOUT ("<LI>Address= ", $address, "\n");
print STDOUT ("<LI>Voice= ", $voice, "\n");
print STDOUT ("<LI>FAX= ", $fax, "\n");
print STDOUT ("<LI>Email= ", $email, "\n");

if ($advisor){
  print STDOUT ("<LI>My supervisor/advisor is ", $advisor,"\n");
} else{
  print STDOUT ("<LI>I did not enter a supervisor name", "\n");
}

print STDOUT ("<LI>Do you already have an existing web username to access the CEDAR Database via the World Wide Web?", "\n");
if ($web == '0'){
  print STDOUT ("<LI>Yes, and I would like to keep it", "\n");
} elsif ($web == '1') {
  print STDOUT ("<LI>Yes, but I would like to release my existing username of ", $webuname1, "\n");
} elsif ($web == '2') {
  print STDOUT ("<LI>No, and I would like a web username of ", $webuname2, "\n");
} else {
  print STDOUT ("<LI>No, since I am not interested or would prefer to get any data via the CEDAR Data Request Form", "\n");
}

print STDOUT ("<LI>Do you already have a login on any NCAR computer to access the CEDAR Database via remote or local login to the CEDAR computer?", "\n");
if ($existing == '0'){
  print STDOUT ("<LI>Yes, and I would like to keep it", "\n");
} elsif ($existing == '1') {
  print STDOUT ("<LI>Yes, but I would like to release my existing username of ", $existuname1, "\n");
} elsif ($existing == '2') {
  print STDOUT ("<LI>No, and I would like a login username of ", $existuname2, "\n");
} else {
  print STDOUT ("<LI>No, since I am not interested or would prefer to get any data via the web or the CEDAR Data Request Form", "\n");
}

if ($haveused) {
  print STDOUT ("<LI>I have used:\n", $haveused, "\n");
} else {
  print STDOUT ("<LI>I have not used anything", "\n");
}

if ($likeuse) {
  print STDOUT ("<LI>I would like to use:", "\n", $likeuse, "\n");
} else {
  print STDOUT ("<LI>I would not like to use anything:", "\n");
}

if ($agreetoread) {
  print STDOUT ("<LI>I've read the 'Rules of the Road' ");
  print STDOUT ("signed ", $agreetoread, "\n");
} else {
  print STDOUT ("<LI>I have not read the 'Rules of the Road'", "\n");
}

if ($date){
  print STDOUT ("<LI>The date signed is  ", $date, "\n");
} else {
  print STDOUT ("<LI>I did not enter a date'", "\n");
}

print STDOUT ("<CENTER>");
print STDOUT ("<P><HR>");
print STDOUT ("</CENTER>", "\n");
print STDOUT ("<P>Thank you for your application. We will let you know within 2-4 days about ");
print STDOUT ("your login name and password.</P>", "\n");
print STDOUT ("Close this window when we are finished <BR>", "\n");

print STDOUT ("</BODY></HTML>");

open(TMALE, $tmale) || die "Failed and stuff";

print TMALE ("-----------------------------------------------------\n");

print TMALE ("Name= ", $name, "\n");
print TMALE ("Address= ", $address, "\n");
print TMALE ("Voice= ", $voice, "\n");
print TMALE ("FAX= ", $fax, "\n");
print TMALE ("Email= ", $email, "\n");
if ($advisor){
  print TMALE ("Advisor/Supervisor is ", $advisor, "\n");
} else{
  print TMALE ("I did not enter a supervisor name", "\n");
}

print TMALE ("Do you already have an existing web username to access the CEDAR Database via the World Wide Web?", "\n");
if ($web == '0'){
  print TMALE ("Yes, and I would like to keep it", "\n");
} elsif ($web == '1') {
  print TMALE ("Yes, but I would like to release my existing username of ", $webuname1, "\n");
} elsif ($web == '2') {
  print TMALE ("No, and I would like a web username of ", $webuname2, "\n");
} else {
  print TMALE ("No, since I am not interested or would prefer to get any data via the CEDAR Data Request Form", "\n");
}

print TMALE ("Do you already have a login on any NCAR computer to access the CEDAR Database via remote or local login to the CEDAR computer?", "\n");
if ($existing == '0'){
  print TMALE ("Yes, and I would like to keep it", "\n");
} elsif ($existing == '1') {
  print TMALE ("Yes, but I would like to release my existing username of ", $existuname1, "\n");
} elsif ($existing == '2') {
  print TMALE ("No, and I would like a login username of ", $existuname2, "\n");
} else {
  print TMALE ("No, since I am not interested or would prefer to get any data via the web or CEDAR Data Request Form", "\n");
}

print TMALE ("------------------------------------------\n");

if ($haveused) {
  print TMALE ("I have used:\n", $haveused, "\n");
} else{
  print TMALE ("I have not used anything", "\n");
}

print TMALE ("------------------------------------------\n");

if ($likeuse) {
  print TMALE ("I would like to use:\n", $likeuse, "\n");
} else{
  print TMALE ("I would not like to use anything:", "\n");
}

print TMALE ("------------------------------------------\n");

if ($agreetoread) {
  print TMALE ("I've read the 'Rules of the Road' ");
  print TMALE ("signed ", $agreetoread, "\n");
} else{
  print TMALE ("I have not read the 'Rules of the Road'", "\n");
}

if ($date){
  print TMALE ("The date signed is  ", $date, "\n");
} else {
  print TMALE ("I did not enter a date'", "\n");
}

print TMALE ("----------------------------------------------------\n");

close(TMALE);

