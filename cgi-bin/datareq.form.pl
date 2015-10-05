#!/opt/local/bin/perl
# This perl script used by ...datareq.form.html 

use CGI;
$ENV{PATH}='/bin:/usr/bin';
$ENV{IFS}="" if $ENV{IFS} ne "";

$query= new CGI;

# General information and stuff...
$name= $query->param('name');
$email= $query->param('email');
$used= $query->param('used');
$type= $query->param('type');
$media= $query->param('media');
$datadesired= $query->param('datadesired');
$signed= $query->param('signed');

# Send the email to Barbara Emery (emery@ucar.edu) and Roy Barnes
$male= "| mailx -s'Data request for ". $name. "' emery";
$tmale= "| mailx -s'Data request for ". $name. "' bozo";

print STDOUT ("Content-Type: text/html\n\n");

# Now for the html code for output to the browser.
print STDOUT ("<HTML>\n");
print STDOUT ("<BODY>\n\n");

print STDOUT ("<H2>You have submitted the following for consideration:</H2>\n");
print STDOUT ("<HR WIDTH= 60%>");	
print STDOUT ("<UL>\n");
print STDOUT ("<LI>Name= ", $name, "\n");
print STDOUT ("<LI>Email= ", $email, "\n");
print STDOUT ("<LI>Data/Inst/Modals used= ", $used, "\n");

print STDOUT ("<LI>Type of Data Desired= ", $type, "\n");
print STDOUT ("<LI>Media desired= ", $media, "\n");
if ($signed){
 print STDOUT ("<LI>I have filled out a ");
 print STDOUT ("CEDAR Database Access form\n");
}
if ($datadesired) {
  print STDOUT ("<LI>Data/Inst/Models/Docs Desired:\n", $datadesired, "\n");
}
print STDOUT ("<CENTER>");
print STDOUT ("<P><HR>\n");
print STDOUT ("</CENTER>");
print STDOUT ("<P>Thank you for your application. We will let you know within 2-4 days about \n");
print STDOUT ("the status of your data request.</P>", "\n");
print STDOUT ("<A HREF='/index.html'>Return to home page</A><BR>");
print STDOUT ("</BODY></HTML>");

open(MALE, $male) || die "Failed and stuff";
open(TMALE, $tmale) || die "Failed and stuff";

print MALE ("-----------------------------------------------------\n");
print MALE ("        CEDAR Database Data Request Form\n");
print MALE ("-----------------------------------------------------\n");

print MALE ("Name= ", $name, "\n");
print MALE ("Email= ", $email, "\n");
print MALE ("Data/Inst/Modals used= ", $used, "\n");

print MALE ("---------------------------------------\n");

print MALE ("Type of Data Desired= ", $type, "\n");
print MALE ("Media desired= ", $media, "\n");

print MALE ("---------------------------------------\n");

if ($signed) {
 print MALE ("I have filled out a ");
 print MALE ("CEDAR Database Access form\n");
} else {
 print MALE ("I have not filled out a ");
 print MALE ("CEDAR Database Access form\n");
}

print MALE ("---------------------------------------\n");

if ($datadesired) {
 print MALE ("Data/Inst/Models/Docs Desired:\n", $datadesired, "\n");
} else {
 print MALE ("No data desired\n");
}

print MALE ("---------------------------------------\n");

print TMALE ("-----------------------------------------------------\n");
print TMALE ("        CEDAR Database Data Request Form\n");
print TMALE ("-----------------------------------------------------\n");

print TMALE ("Name= ", $name, "\n");
print TMALE ("Email= ", $email, "\n");
print TMALE ("Data/Inst/Modals used= ", $used, "\n");

print TMALE ("---------------------------------------\n");

print TMALE ("Type of Data Desired= ", $type, "\n");
print TMALE ("Media desired= ", $media, "\n");

print TMALE ("---------------------------------------\n");

if ($signed) {
 print TMALE ("I have filled out a ");
 print TMALE ("CEDAR Database Access form\n");
} else {
 print TMALE ("I have not filled out a ");
 print TMALE ("CEDAR Database Access form\n");
}

print TMALE ("---------------------------------------\n");

if ($datadesired) {
 print TMALE ("Data/Inst/Models/Docs Desired:\n", $datadesired, "\n");
} else {
 print TMALE ("No data desired\n");
}

print TMALE ("---------------------------------------\n");

close(MALE);
close(TMALE);

