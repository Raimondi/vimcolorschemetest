perl build.pl samples/sms.c C c 2> err.log
perl build.pl samples/tiny.html HTML html 2> err.log
perl build.pl samples/GetEnv.java Java java 2> err.log
perl build.pl samples/test.tex LaTeX tex 2> err.log
perl build.pl samples/csvformat.pl Perl pl 2> err.log

svn add --force ..\colors
svn add --force ..\html
svn ps svn:mime-type text/html ..\html\*.html

dir ..\html\*-c.html | tail -n 2 | head -n 1
dir ..\html\*-html.html | tail -n 2 | head -n 1
dir ..\html\*-java.html | tail -n 2 | head -n 1
dir ..\html\*-tex.html | tail -n 2 | head -n 1
dir ..\html\*-pl.html | tail -n 2 | head -n 1
