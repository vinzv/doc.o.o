#!/usr/bin/perl

use warnings;
use strict;
use FileHandle;
use POSIX 'strftime';

# files to make
my $files = {
              'index.html'     => { title => 'Overview of guides | openSUSE Documentation' },
              'archive.html'  => { title => 'Documentation for previous openSUSE versions | openSUSE Documentation'},
              'release-notes/index.html'  => { title => 'Release notes for openSUSE | openSUSE Documentation'}
            };

my $template_file='main.html.template';
open(TFH, "<", $template_file) or die $@;
my $file;
my $myline;
my $myfh;
my $year = strftime "%Y", gmtime;

foreach $file (keys %{$files})
{
  $files->{$file}->{writeFH} = FileHandle->new($file, 'w') or die $@;
  $files->{$file}->{readFH} = FileHandle->new($file.'.content', 'r') or die $@;
}

foreach my $line (<TFH>)
{
  foreach $file (keys %{$files})
  {
    $myline = $line;
    if ($myline =~ /<%CONTENT%>/)
    {
      my $rfh = $files->{$file}->{readFH};
      $myline = eval { local $/; <$rfh> };
    }
    $myline =~ s/<%TITLE%>/$files->{$file}->{title}/;
    $myline =~ s/<%YEAR%>/$year/;
    $myfh = $files->{$file}->{writeFH};
    print $myfh $myline;
  }
}

# close all file handles
foreach $file (keys %{$files})
{
  close ($files->{$file}->{writeFH});
  close ($files->{$file}->{readFH});
}
close TFH;
