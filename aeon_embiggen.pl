use strict;

use File::Copy;

my $valid_extensions = "iso img dat bin cue vob dvb m2t mts evo mp4 avi asf asx wmv wma mov flv swf nut avs nsv ram ogg ogm ogv mkv viv pva mpg";

my $path = $ARGV[0];

if (!defined $path) {

        print STDERR "\nNo directory passed in.\nPlease supply a directory containing the MOVIES\nyou want to copy thumbnails for: ";

        $path = <STDIN>;

}

chomp $path;

chdir($path) or die "I wasn't unable to chdir to $path";

if ($^O eq "MSWin32") {

    $path =~ s/\\/\\\\/g;  # Windows: Add a double slash for every single slash

}

$path =~ s/^"|"$//g;   # Strip quotes. you dirty girl.

my @files = findThumbs($path, 0);

if ($#files < 0)

{

    print STDERR "\nI didn't find any files to copy. Sorry.";

    exit -1;

}

print STDOUT "\n\n\n-----------Starting Copy Process-----------";

foreach (@files)

{

        $_ =~ s/(^\s+)|(\s+$)//g;               # Remove whitespace

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


sub findThumbs

{

    my $path = shift or die "You didn't supply enough arguments!";

    my $numTabs = shift;

    my @temps;

    opendir(DIR, $path) or die "Cannot do! The path was $path";

    foreach my $name (sort readdir(DIR))

    {

        my $formatting = "";

        if ($name eq "." || $name eq "..")

        { next; }

        else {

            $formatting .= "\n";

            for (my $lcv = 0; $lcv <= $numTabs; $lcv++) {

                $formatting .= "\t";

            }

        }

        my $filename = $path . "\\" . $name;

        if (-d $filename) {

            print "$formatting" . "$name is a directory - Recursing.";           

            push @temps, findThumbs($filename, $numTabs+1);

        } elsif (-f $filename) {

            my $temp = $filename;               # Preserve the original

            $temp =~ s/(^\s+)|(\s+$)//g;                # Remove whitespace

            my $extension = $temp;              # The file extension

            if ($extension =~ m/\.(\w+$)/) {

                $extension = $1;

            } else {

                print "$formatting" . "Unable to parse an extension for $temp... That's interesting.";

                next;

            }

            if ($valid_extensions =~ m/$extension/) {   # If the extension was one of those in the big long list

                #We got us a movie file here, boss!

                my $tbn = $temp;

                $tbn =~ s/\.\w+$/\.tbn/;

                my $already_done = 0;

                foreach (@temps) {

                    if ($tbn eq $_)

                    {

                        $already_done = 1;

                        last;

                    }

                }

                if (-e $tbn && !$already_done) {

                        push @temps, $filename;

                    print "$formatting" . "To be copied: $tbn";

                } else {

                        print "$formatting" . "Unable to locate $tbn: Not copying.";

                }

            }

        } else {

            print "$formatting" . "I have no idea what $name is...";

        }

    }

    return @temps;

    closedir(DIR);

}