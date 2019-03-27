#!/usr/bin/env perl
#
# Author: Vagner Rodrigues Fernandes <vagner.rodrigues@gmail.com>
# Description: stress script for Logstash messages on UDP plugin.
#
# Usage: ./udp-flood-elasticsearch.pl
#
# Settings:
# logstash_host = array logstash hosts
# logstash_port = logstash UDP port
# logstash_names = list names for make JSON template
# logstash_total = total messages send to UDP stream 
# interval_sleep = loop interval in milliseconds
#
# -----------------------------------------------------------------------------

use strict;
use POSIX();
use IO::Socket;
use Digest::SHA qw(sha256_hex);
use Time::HiRes qw(usleep nanosleep);

## Autoflush
$|=1;

## logstash host settings
my @logstash_host = ( "192.168.0.1", "192.168.0.2" );
my $logstash_port = 25000;

## logstash json names random
my @logstash_names = ( "vagner", "jose", "maria", "naruto", "lima", "jiraya", "pele" );

## Milliseconds interval
my $interval_sleep = 1600;

## Total messages
my $logstash_total = 30000;

my $count = 0;

while ($count <= $logstash_total) {

	foreach my $xname (@logstash_names) {

		foreach my $xhost (@logstash_host) {

			my @lt = localtime ;
			my $post_date  = POSIX::strftime( '%Y-%m-%dT%H:%M:%S', @lt );
			my $streamstring = sha256_hex(rand(1000));

			my $logstash_json = "{ \"name\" : \"" . $xname . "\", \"post_date\" : \"" . $post_date . "\", \"message\" : \"elasticsearch testing (" . $xhost .") - " . $streamstring ."\" }\n";

			my $sock = IO::Socket::INET->new(
			    Proto    => 'udp',
			    PeerPort => $logstash_port,
			    PeerAddr => $xhost,
			) or die "Could not create socket: $!\n";

			$sock->send('' . $logstash_json .'') or die "Send error: $!\n";
			# print $logstash_json; # debug output

			$sock->close();

			$count++;
			my $per=($count/$logstash_total)*100*1;
			print "\033[JCompleted ${count} registers - Status: ${per}%"."\033[G";
			usleep($interval_sleep);

		}

	}

}

# SYA!
