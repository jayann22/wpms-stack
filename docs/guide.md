<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<meta name=Generator content="Microsoft Word 12 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Helvetica;
	panose-1:2 11 6 4 2 2 2 2 2 4;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:10.0pt;
	margin-left:0cm;
	line-height:115%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
h2
	{mso-style-link:"Heading 2 Char";
	margin-right:0cm;
	margin-left:0cm;
	font-size:18.0pt;
	font-family:"Times New Roman","serif";
	font-weight:bold;}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
p
	{margin-right:0cm;
	margin-left:0cm;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-link:"Balloon Text Char";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:10.0pt;
	margin-left:36.0pt;
	line-height:115%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
p.MsoListParagraphCxSpFirst, li.MsoListParagraphCxSpFirst, div.MsoListParagraphCxSpFirst
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	line-height:115%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
p.MsoListParagraphCxSpMiddle, li.MsoListParagraphCxSpMiddle, div.MsoListParagraphCxSpMiddle
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	line-height:115%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
p.MsoListParagraphCxSpLast, li.MsoListParagraphCxSpLast, div.MsoListParagraphCxSpLast
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:10.0pt;
	margin-left:36.0pt;
	line-height:115%;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
span.Heading2Char
	{mso-style-name:"Heading 2 Char";
	mso-style-link:"Heading 2";
	font-family:"Times New Roman","serif";
	font-weight:bold;}
span.BalloonTextChar
	{mso-style-name:"Balloon Text Char";
	mso-style-link:"Balloon Text";
	font-family:"Tahoma","sans-serif";}
span.apple-converted-space
	{mso-style-name:apple-converted-space;}
.MsoPapDefault
	{margin-bottom:10.0pt;
	line-height:115%;}
@page Section1
	{size:612.0pt 792.0pt;
	margin:49.65pt 37.9pt 99.25pt 49.65pt;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
-->
</style>

</head>

<body lang=EN-US link=blue vlink=purple>

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><b><span
style='font-size:12.0pt;line-height:115%'>This is step by step installation
guide for wp multisite on Digital Ocean, with separate web and database
droplets which are connected to each other via private network.</span></b></p>

<p class=MsoNormal>Login to your Digital Ocean account and create 2 droplets,
named e.g. <b><i><span style='font-size:12.0pt;line-height:115%'>wp-web</span></i></b>
and <b><i><span style='font-size:12.0pt;line-height:115%'>wp-db</span></i></b>.
 In settings of each droplet mention following options.</p>

<p class=MsoListParagraphCxSpFirst style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;text-indent:-18.0pt;line-height:30.0pt;
background:white'><span style='font-size:12.0pt;font-family:"Arial","sans-serif";
color:#002060;letter-spacing:-.75pt'>1)<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-size:12.0pt;font-family:"Arial","sans-serif";
color:#002060;letter-spacing:-.75pt'>Select Region: New York 2</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'><img
width=515 height=279 id="Picture 2"
src="mysql%20installation%20guide_files/image005.jpg"></span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;text-indent:-18.0pt;line-height:30.0pt;
background:white'><span style='font-size:12.0pt;font-family:"Arial","sans-serif";
color:#333333;letter-spacing:-.75pt'>2)<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-size:12.0pt;font-family:"Arial","sans-serif";
color:#002060;letter-spacing:-.75pt'>Select Image: Linux Distributions =&gt;
CentOS =&gt; CentOS 6.5 x64</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:14.2pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'><img
width=550 height=308 id="Picture 3"
src="mysql%20installation%20guide_files/image006.jpg"></span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;text-indent:-18.0pt;line-height:30.0pt;
background:white'><span style='font-family:"Arial","sans-serif";color:#333333;
letter-spacing:-.75pt'>3)<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-size:12.0pt;font-family:"Arial","sans-serif";
color:#002060;letter-spacing:-.75pt'>Settings: Select you SSH key by which you
will connect to droplets and mention Private Networking</span><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'> </span><span
style='font-family:"Arial","sans-serif";color:#002060;letter-spacing:-.75pt'>option</span><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'>.</span></p>

<p class=MsoListParagraphCxSpMiddle><span style='font-family:"Arial","sans-serif";
color:#333333;letter-spacing:-.75pt'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'><img
width=458 height=197 id="Picture 4"
src="mysql%20installation%20guide_files/image007.jpg"></span></p>

<p class=MsoListParagraphCxSpMiddle><span style='font-family:"Arial","sans-serif";
color:#333333;letter-spacing:-.75pt'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpLast style='margin-top:15.0pt;margin-right:0cm;
margin-bottom:15.0pt;margin-left:36.0pt;line-height:30.0pt;background:white'><span
style='font-family:"Arial","sans-serif";color:#333333;letter-spacing:-.75pt'>&nbsp;</span></p>

<p class=MsoNormal style='margin-left:18.0pt'>Now you can create droplets and
after creation we will continue installation process by connecting to droplets
via ssh client.</p>

<p class=MsoNormal style='margin-left:18.0pt'>I assume that you have created
droplets with hostnames 1) <b><i>wp-web</i></b> and 2) <b><i>wp-db</i></b>, and
will continue guide using these names, but sure if you wish , you can set your
hostnames.</p>

<p class=MsoNormal>Choose your droplet on Digital Ocean interface and determine
the private ip addresses.</p>

<p class=MsoNormal><img width=478 height=324 id="Picture 1"
src="mysql%20installation%20guide_files/image008.jpg"></p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal>Write these ip addresses somewhere, because we will use them
during installation.</p>

<p class=MsoNormal> I will use 10.128.1.1 and 10.128.2.2 respectively for <b><i>wp-web</i></b>
and <b><i>wp-db</i></b>.</p>

<p class=MsoNormal>1) <b><i>wp-web</i></b>:  <span style='color:red'>10.128.1.1</span></p>

<p class=MsoNormal>2) <b><i>wp-db</i></b>:     <span style='color:red'>10.128.2.2</span></p>

<p class=MsoNormal>I will divide installation procedure into 2 main phases: </p>

<p class=MsoListParagraphCxSpFirst style='text-indent:-18.0pt'>1.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span>Database
installation</p>

<p class=MsoListParagraphCxSpLast style='text-indent:-18.0pt'>2.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span> web
installation</p>

<p class=MsoNormal align=center style='margin-left:18.0pt;text-align:center'>&nbsp;</p>

<p class=MsoNormal align=center style='margin-left:18.0pt;text-align:center'>&nbsp;</p>

<p class=MsoNormal align=center style='margin-left:18.0pt;text-align:center'><b><span
style='font-size:12.0pt;line-height:115%'>Phase 1. Database Installation</span></b></p>

<p class=MsoNormal>Connect to <b><i><span style='font-size:12.0pt;line-height:
115%'>wp-db</span></i></b> droplet via ssh , and install mysql-server </p>

<p class=MsoNormal><span style='color:#0070C0'>yum -y install mysql-server</span></p>

<p class=MsoNormal>After successful installation, start the service and set the
service to automatically start during boot.</p>

<p class=MsoNormal><span style='color:#0070C0'>service mysqld start</span></p>

<p class=MsoNormal><span style='color:#0070C0'>chkconfig --level 3 mysqld on</span></p>

<p class=MsoNormal>Now you can connect to mysql and set appropriate accounts by
which wordpress installation script and web service will connect to database. Please
note that Values in Red must be changed.</p>

<p class=MsoNormal><span style='color:#0070C0'>mysql -e &quot;create user '</span><span
style='color:red'>ADMIN</span><span style='color:#0070C0'>'@'10.128.%.%'
identified by '</span><span style='color:red'>ROOTPASSWORD</span><span
style='color:#0070C0'>'&quot;</span></p>

<p class=MsoNormal><span style='color:#0070C0'>mysql -e &quot;grant all
privileges on *.* to '</span><span style='color:red'>ADMIN</span><span
style='color:#0070C0'>'@'10.128.%.%'&quot;</span></p>

<p class=MsoNormal><span style='color:#0070C0'>mysql -e &quot;grant grant
option on *.* to '</span><span style='color:red'>ADMIN</span><span
style='color:#0070C0'>'@'10.128.%.%</span> <span style='color:#0070C0'>'&quot;             
</span></p>

<p class=MsoNormal>where    </p>

<p class=MsoListParagraphCxSpFirst style='text-indent:-18.0pt'>1)<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span
style='color:red'>ADMIN</span> is mysql user with root privileges</p>

<p class=MsoListParagraphCxSpMiddle style='text-indent:-18.0pt'>2)<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span
style='color:red'>ROOTPASSWORD</span> is password for admin user, which must be
specified during wordpress multisite stack  installation</p>

<p class=MsoListParagraphCxSpMiddle style='text-indent:-18.0pt'>3)<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span>installation</p>

<p class=MsoListParagraphCxSpLast style='text-indent:-18.0pt'>4)<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span
style='color:red'>10.128.%.%</span> is private network  of Digital Ocean in
NY2.</p>

<p class=MsoNormal style='margin-left:18.0pt'>&nbsp;</p>

<p class=MsoNormal align=center style='margin-left:18.0pt;text-align:center'><b><span
style='font-size:12.0pt;line-height:115%'>Phase 2. wp-multisite Installation</span></b></p>

<p class=MsoNormal>Connect to <b><i>wp-web</i></b> droplet via ssh with root
user, and execute following two commands.</p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:11.25pt;margin-left:
0cm;line-height:21.25pt'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#4F81BD'>curl<span class=apple-converted-space>&nbsp;</span>https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/install.sh<span
class=apple-converted-space>&nbsp;</span>&gt; install.sh</span></p>

<p style='margin-top:11.25pt;line-height:21.25pt'><span style='font-size:11.5pt;
font-family:"Helvetica","sans-serif";color:#4F81BD'>bash install.sh</span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
36.0pt;text-indent:-18.0pt;line-height:21.25pt'><span style='font-size:11.5pt;
font-family:"Helvetica","sans-serif"'>1)<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
</span></span><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'>Choose
Name for your Environment</span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
36.0pt;text-indent:-18.0pt;line-height:21.25pt'><span style='font-size:11.5pt;
font-family:"Helvetica","sans-serif"'>2)<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
</span></span><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'>Proceed
with setting values specific to your installation. </span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
36.0pt;line-height:21.25pt'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'>Following
are the values which must be set during installation. The values in <span
style='color:red'>red</span> must be changed during installation, in case if
wpms must be installed with separate database server. I will not cover below 
the other values, which will ask install.sh because they are environment
specific. </span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please answer Yes if the script shall create mysql database,
mysql user for wordpress and grant accesses for the created user to wordpress
database . </span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'> (The
default Value is &quot;Yes&quot;):<span style='color:red'>Yes (</span><span
style='color:#7030A0'>Set this to Yes , because we need to create wp user)</span></span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please answer Yes if the script shall install mysql-server . </span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'> (The
default Value is &quot;Yes&quot;):<span style='color:red'>No </span><span
style='color:#7030A0'>(Set this to NO, because we already have installed mysql)</span></span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please provide the username which has privileges to grant
accesses and create wp database on mysql server, e.g. root</span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'>(The
default Value is &quot;root&quot;):<span style='color:red'>ADMIN </span><span
style='color:#7030A0'>(The mysql super user, which we created on wp-db server)</span></span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please provide the password for mysql admin user . </span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:red'> </span><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'>(The
default Value is &quot;&quot;):<span style='color:red'>PASSWORD </span><span
style='color:#7030A0'>(The password for mysql super-user on wp-db server)</span></span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please provide the hostname or ip address of mysql to which
worpdress shall connect. </span></p>

<p style='margin-top:11.25pt;margin-right:0cm;margin-bottom:5.0pt;margin-left:
1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif"'> (The
default Value is &quot;localhost&quot;):<span style='color:red'>10.128.2.2 </span><span
style='color:#7030A0'>(The private ip address for wp-db server)</span></span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please provide database user for wordpress</span><span
style='font-size:11.5pt;font-family:"Helvetica","sans-serif";color:red'> . </span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:black'> (The default Value is &quot;wp_user&quot;): </span><span
style='font-size:11.5pt;font-family:"Helvetica","sans-serif";color:#7030A0'>(The
db user for wordpress, this can be leaved as default)</span></p>

<p style='margin-left:1.0cm'><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:#00B050'>Please provide the host from which will the user have access to
database</span><span style='font-size:11.5pt;font-family:"Helvetica","sans-serif";
color:red'> . </span></p>

<p style='margin-left:276.45pt;text-indent:-248.1pt'><span style='font-size:
11.5pt;font-family:"Helvetica","sans-serif"'> (The default Value is &quot;localhost&quot;):<span
style='color:red'>10.128.%.% </span><span style='color:#7030A0'>( Private
network, from which db user for wordpress will have access to mysql db   )</span></span></p>

<p class=MsoNormal><span style='font-size:11.5pt;line-height:115%;font-family:
"Helvetica","sans-serif"'>&nbsp;</span></p>

<p class=MsoNormal><span style='font-size:11.5pt;line-height:115%;font-family:
"Helvetica","sans-serif"'>After you check/confirm the new settings, you will
have installed wordpress multisite. </span></p>

<p class=MsoListParagraph>&nbsp;</p>

</div>

</body>

</html>
