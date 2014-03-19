#!/usr/bin/perl -w

use strict;

use Net::Telnet;
use Getopt::Long;
use Net::Ping;

my $ok;
my $telnet;
my $return_value;
my @chars;
my $i = 1;
my $ip = "192.168.20.216"; # Target IP Address
my $port = "50000"; # Target Port Number
my $output = "1"; # electric socket number
my $value = "off"; # value of electric socket number
my $help = undef; # help
my $status = undef; # electric socket status



GetOptions( "ip=s" => \$ip, "port=s" => \$port, "output=s" => \$output, "value=s" => \$value, "help" => \$help, "status" => \$status);
#print "help=$help\n";

if( $help)
{
   print "help - this options are allowed\n";
   print "ip     : IP-Address e.g. 192.168.1.1\n";
   print "port   : Telnet Port Numer of Target, e.g. 23\n";
   print "output : which number of electric socket (1, 2, 3 or 4) e.g. 1\n";
   print "value  : switch electric socket to on or off? e.g. on\n";
   print "h[elp] : this help\n";
   print "status : print the status of all electric sockets, \'output\' and \'value\' are not necessary\n";
   exit 0;
}

$telnet = new Net::Telnet (Timeout=>10, Errmode=>'die', Port=>$port);
$telnet->open($ip);

$telnet->waitfor('/KSHELL V1.3/i');

$ok = $telnet->print("login admin 0477nu8");
#print("$ok\n");
$return_value = $telnet->getline(Timeout=>1);
$return_value = $telnet->getline(Timeout=>1);
chop($return_value);
if( $return_value ne "250 OK")
{
   $telnet->close or die "close fail: $!";
   die "Login Error!";
}

if( $status)
{
   $ok = $telnet->print("port list");
   $return_value = $telnet->getline(Timeout=>1);
   chop($return_value);
   @chars = split(//, $return_value);
   shift @chars;
   shift @chars;
   shift @chars;
   shift @chars;
   foreach(@chars)
   {
     
      if($_ eq '1')
      {
         print"Port $i = on\n";
      }
      else
      {
         print"Port $i = off\n";
      }
      $i++;
   }
   $telnet->print("quit");
   $telnet->close or die "close fail: $!";
   exit 0;
}

$ok = $telnet->print("port $output");
# Sleep for 500 milliseconds 
select(undef, undef, undef, 0.5);
$return_value = $telnet->getline(Timeout=>1);
# Sleep for 500 milliseconds 
select(undef, undef, undef, 0.5);
chop($return_value);

if( $return_value eq "250 0" && $value eq "off")
{
   print "condition already reached\n";
}
elsif( $return_value eq "250 0" && $value eq "on")
{
   print "power on output $output\n";
   $ok = $telnet->print("port $output 1");
}
elsif( $return_value eq "250 1" && $value eq "off")
{
   print "power off output $output\n";
   $ok = $telnet->print("port $output 0");
}
elsif( $return_value eq "250 1" && $value eq "on")
{
   print "condition already reached\n";
}

$telnet->print("quit");
$telnet->close or die "close fail: $!";


