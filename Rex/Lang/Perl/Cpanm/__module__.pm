#
# AUTHOR: jan gehring <jan.gehring@gmail.com>
# REQUIRES: 
# LICENSE: Apache License 2.0
# 
# Simple Module to install Cpanm on your Server.
#
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::Lang::Perl::Cpanm;
   
use strict;
use warnings;

use Rex -base;
use Rex::Logger;

require Exporter;
use base qw(Exporter);
use vars qw(@EXPORT);
    
@EXPORT = qw(cpanm);

sub cpanm {
   my ($action, @values) = @_;

   if($action eq "-install") {
      $action = "install";
   }

   if($action eq "install") {
      if(@values) {
         _install(@values);
      }
      else {
         run "curl -L http://cpanmin.us | perl - --self-upgrade";
         if($? != 0) {
            die("Installing cpanminus failed. Is curl installed?");
         }
         Rex::Logger::info("cpanminus installed.");
      }
   }

   if($action eq "-installdeps") {
      _install_deps(@values);
   }
}

sub _install {
   my ($modules, %option);

   if(ref($_[0]) eq "ARRAY") {
      ($modules, %option) = @_;
   }
   else {
      $modules = [ @_ ];
   }

   for my $mod (@{ $modules }) {
      Rex::Logger::info("Installing $mod");
      if(exists $option{to}) {
         run "cpanm -L " . $option{to} . " $mod";
      }
      else {
         run "cpanm $mod";
      }
   }
}

sub _install_deps {
   my ($path) = @_;

   $path ||= ".";

   Rex::Logger::info("Running installdeps for $path");
   run "cpanm --installdeps $path";
}

1;

=pod

=head1 NAME

Rex::Lang::Perl::Cpanm - Module to install and use Cpanm.

=head1 USAGE

Put it in your I<Rexfile>

 use Rex::Lang::Perl::Cpanm;
   
 task "prepare", sub {
    cpanm -install;   # install cpanminus
    cpanm -install => [ 'Test::More', 'Foo::Bar' ];
    cpanm -install => [ 'Test::More', 'Foo::Bar' ],
               to => "libs";
                  
    cpanm -installdeps => ".";
 };

=back

=cut

