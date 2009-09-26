#!/usr/bin/perl -w
# Time-stamp: <2005/02/18, 09:48:22 (EST), maverick, build.pl>

use strict;

my $e = $ARGV[0] or die "Specify example input file";
my $ee = $e;
$ee =~ s/\\/\\\//g;
print "Using $e as sample input\n";

my $lang = $ARGV[1] or die "Specify a language";
my $suffix = $ARGV[2] or die "Specify a suffix";
my $numleft = $ARGV[3] || -1;
print "Processing $numleft themes\n" if($numleft > 0);

my $date = localtime;
my $htmldir = '../html/';
my $frontpage = 'http://code.google.com/p/vimcolorschemetest/';

open IDX, '>' . $htmldir . "index-$suffix.html"
  or die "Cannot open index-$suffix.html";

# html header
my $title = 'VIM Color Scheme Test';
print IDX <<HEADER
<html>
  <head>
    <title>$title - $lang - $date</title>
    <style>
      body { background: White; }
      a {
        border-top: thin none;
        border-left: thin none;
        border-bottom: thin dotted #FF9900;
        border-right: thin none;
        color: Black;
        text-decoration: none;
      }
      a:hover { color: White; background: #FF9900; }
      a.frames { border: thin dotted #FF9900; }
      a.frames:hover { color: White; background: #FF9900; }
      td { padding-top: 5px; }
    </style>
  </head>
  <body>
    <h1><a href="$frontpage">$title</a> - $lang</h1>
    <script language="javascript">
      function changeHeight(h) {
        var tds = document.getElementsByTagName("td");
        for(var i = 0; i < tds.length; i++) { tds[i].setAttribute("height", h + "px"); }
      }
    </script>
    <ul>
    <li>This page really requires a modern web browser. Click <a
      href="$frontpage">here</a> for more information.</li>
    <li>Do your friends a favor. Link to the <a href="$frontpage">front page</a>
      instead. Thanks!</li>
    <li>Useful tip: decrease the text size to see more in each <tt>iframe</tt>.
      (For example, in Firefox press ctrl-minus and you will see.)</li>
    <li>Select <tt>iframe</tt> height (in pixels):
    <input type="radio" name="height" value="100" onclick="changeHeight(100);">100</input>
    <input type="radio" name="height" value="200" onclick="changeHeight(200);">200</input>
    <input type="radio" name="height" value="300" onclick="changeHeight(300);" checked>300</input>
    <input type="radio" name="height" value="400" onclick="changeHeight(400);">400</input>
    <input type="radio" name="height" value="500" onclick="changeHeight(500);">500</input>
    <input type="radio" name="height" value="600" onclick="changeHeight(600);">600</input>
    </li>
    </ul>
    <hr>
HEADER
;

# setup the brightness hash
my %brightness;
open BH, "<brightness.txt";
while (<BH>) {
  chomp;
  my ($cname, $group) = $_ =~ /^(\S+)\s+ = (\d)$/;
  $brightness{$cname} = $group;
}
close BH;

# make the tables
my $counter = 0;
print IDX "    <h2>Dark Background</h2>\n";
gentable(1);
print IDX "    <h2>Light Background</h2>\n";
gentable(2);
print IDX "    <h2>New or Updated (can be empty)</h2>\n";
gentable(0);

# html footer
print IDX <<FOOTER
    <hr>
    <p>Total: $counter schemes
    <p>Generated on $date by Maverick Woo</p>

<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-9469900-3");
pageTracker._trackPageview();
} catch(err) {}</script>

  </body>
</html>
FOOTER
;

close IDX;
print "$counter schemes processed.\n";

exit 0;

sub gentable {
  my $group = shift;
  my $vimcolorsdir = '../colors';
  opendir D, $vimcolorsdir
    or die "Cannot open colors directory";

  print IDX '    <table width="100%" valign="top" cellpadding="0px" cellspacing="1px">';
  print IDX "\n";

  # setup column state machine
  my $colmax = 3;
  my $colstate = 0;
  my $colwidth = int(100 / $colmax);

  # enumerate colors
  foreach my $f (readdir(D)) {

    # quit if numleft is 0
    last if $numleft == 0;

    # extract name
    my ($cname) = $f =~ /(.+)\.vim$/i;
    next unless $cname;

    # skip color themes that I don't want to show
    # next if $cname eq "";

    # make sure it's the right group
    if ($group == 0) { #undefined brightness
      next if defined $brightness{$cname} && $brightness{$cname} != 0;
      print STDERR sprintf("%-40s= 0\n", $cname);
    } else {
      next unless defined $brightness{$cname};
      next unless $brightness{$cname} == $group;
    }

    print $cname;
    my $hname = "$cname-$suffix.html";

    # compute the timestamps
    my $colortime = (stat($vimcolorsdir . '/' . $f))[9] || 0;
    my $htmltime = (stat($htmldir . $hname))[9] || 0;

    # generate iframe source
    if ($htmltime < $colortime) { #colorscheme is newer
      system('gvim', '-f', '-n', '--noplugin', '-u', 'thisvimrc', $e,
             '-c', '"set background=' . #default to light
                   ($group == 1 ? 'dark' : 'light') . '"',
             '-c', '"colorscheme ' . $cname . '"',
             qw(-c "TOhtml" -c "w!" -c "qa"));
      system('mv', $e . '.html', $htmldir . $hname);
      #system('sed', '-i', 's/>' . $ee . '.html' . '</>' . $cname . '</i', $hname);
      utime $colortime, $colortime, $htmldir . $hname;
    } else {
      print ' [skipped]';
    }

    print "\n";

    # is this the beginning of a row?
    if($colstate == 0) {
      print IDX <<ROW1
        <tr valign="top">
ROW1
;
    }

    # actual html to include iframe
    print IDX <<COL
          <td width="$colwidth%" height="300px">
            <a class="frames" href="../colors/$cname.vim">$cname</a><br>
            <iframe src="$hname" frameborder="0" width="100%" height="100%" scrolling="no"></iframe>
          </td>
COL
;
    $counter++;

    # is this the end of a row?
    if($colstate + 1 == $colmax) {
      print IDX <<ROW2
        </tr>
ROW2
;
    }

    # update state machine
    $colstate = ($colstate + 1) % $colmax;

    # quit if we have tested enough colors
    $numleft--;
    last unless $numleft != 0; # we use -1 to mean unlimited

  }
  closedir D;

  # is the last row orphaned?
  if($colstate != 0) {
    print IDX <<ROW3
        </tr>
ROW3
;
  }

  print IDX "    </table>\n";
}

