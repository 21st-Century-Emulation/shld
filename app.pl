#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use LWP::UserAgent ();

get '/status' => sub ($c) {
  $c->render(text => 'Healthy');
};

post '/api/v1/debug/writeMemory' => sub($c) {
  my $address = $c->param('address');
  my $value = $c->param('value');
  print "$address=$value";
  $c->render(text => '');
};

post '/api/v1/execute' => sub ($c) {
  my $writeMemoryApi = $ENV{'WRITE_MEMORY_API'};
  my $ua = LWP::UserAgent->new();
  my $highByte = int($c->param('operand2'));
  my $lowByte = int($c->param('operand1'));
  my $address = ($highByte << 8) | $lowByte;
  my $cpu = $c->req->json;
  $cpu->{'state'}->{'cycles'} += 16;
  my $l = $cpu->{state}->{l};
  my $h = $cpu->{state}->{h};
  my $hAddress = $address + 1;
  my $id = $cpu->{id};

  # Write L register to ADDR
  my $lRes = $ua->post("$writeMemoryApi?id=$id&address=$address&value=$l");
  if ($lRes->is_success) {
    print $lRes->decoded_content;
  }
  else {
    die $lRes->status_line;
  }
  # Write H register to ADDR + 1
  my $hRes = $ua->post("$writeMemoryApi?id=$id&address=$hAddress&value=$h");
  if ($hRes->is_success) {
    print $hRes->decoded_content;
  }
  else {
    die $hRes->status_line;
  }

  $c->render(json => $cpu);
};

app->start();