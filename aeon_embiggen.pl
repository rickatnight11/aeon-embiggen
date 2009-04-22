use strict;
use File::Copy;

my $instruction_file = $ARGV[0];
if (!defined $instruction_file) {
	print STDERR "\nNo text file passed in.\nPlease supply a text file containing the MOVIES you want to copy thumbnails for: ";
	$instruction_file = <STDIN>;
}

open (INSTRUCT, $instruction_file) or die "I couldn't open the instruction file - pass it in as an argument.";
my @files = <INSTRUCT>;
foreach (@files)
{
	$_ =~ s/(^\s+)|(\s+$)//g;		# Remove whitespace
	my $tbn = $_;
	$tbn =~ s/\.\w+$/\.tbn/;
	my $big = $_;
	$big .= '-big.png';		
	
	if (-e $tbn) {
		print "\nCopying $tbn to $big...";
		copy($tbn, $big) or print STDERR "\nUnable to copy $tbn to $big";
	} else {
		print STDERR "\nUnable to locate $tbn: Not copying.";
	}	
}
print "\nThe magic that is perl has completed. Review the changes, and I hope this didn't destroy anything.\n";