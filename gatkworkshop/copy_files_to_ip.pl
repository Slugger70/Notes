#!/usr/bin/env perl
use warnings;
use strict;
use Net::OpenSSH;

my $user = "ubuntu";
my $password = "GATK2016";
my @ip = qw(115.146.88.236
130.56.255.53
115.146.88.235
130.56.255.52
130.56.255.51
130.56.255.50
115.146.88.233
115.146.88.232
115.146.88.231
130.56.251.224
130.56.255.49
130.56.255.48
115.146.88.137
130.56.255.47
130.56.255.44
130.56.255.43
130.56.255.42
130.56.255.41
130.56.255.4
130.56.255.38
130.56.255.37
115.146.88.230
115.146.88.227
115.146.88.226
115.146.88.225
115.146.88.222
115.146.88.176
115.146.88.220
115.146.88.219
115.146.88.218
115.146.88.217
130.56.255.34
115.146.88.210
115.146.88.209
115.146.88.208
115.146.88.207
115.146.88.206
115.146.88.181
130.56.252.195
115.146.87.9);
my @pw = qw(Reish9ei
ohShei3F
ooseth7A
Teim6aic
Ipoh8eok
auk0Zahl
xaNgeit7
Reghei5g
eSheij3h
zahS8Iev
EiV7hahN
Eiqu9ahk
AiCh2oa3
Meevai0a
Ug2ailae
Ohngiw5y
Du5zooX8
teiNiet0
iosi7ieK
Iec6AJ6a
to0Jeeh3
Thee9aid
AhM7euph
ou9OoPah
erie9Me3
eeh0ahYa
gohNg0ai
JohJ7tah
Tah7taep
eYiegai8
eikee1eP
deev9Aed
OuX9seey
eW9oeSh7
jai1Keey
Toh9kaeD
ioNg9Xu0
ahDohj7f
Ea7theW1
ooQu8Hio);
my $localpath = "cloudman_key_pair_RC.pub";
my $remotepath = "~";

for( my $i = 0; $i < @ip; $i ++){
  print "Working on $ip[$i] with password $pw[$i]\n";
  my $ssh = Net::OpenSSH->new($ip[$i], user => $user, password => $pw[$i]);
  $ssh->scp_put('./cloudman_key_pair_RC.pub', '/home/ubuntu/');
  $ssh->system("cat cloudman_key_pair_RC.pub >> .ssh/authorized_keys") or warn "cat failed: " . $ssh->error;
}
