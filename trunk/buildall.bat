perl build.pl ../sms.c C c 2> err.log
perl build.pl ../tiny.html HTML html 2> err.log
perl build.pl ../GetEnv.java Java java 2> err.log
perl build.pl ../test.tex LaTeX tex 2> err.log
perl build.pl ../csvformat.pl Perl pl 2> err.log

dir html\*-c.html | tail -n 2 | head -n 1
dir html\*-html.html | tail -n 2 | head -n 1
dir html\*-java.html | tail -n 2 | head -n 1
dir html\*-tex.html | tail -n 2 | head -n 1
dir html\*-pl.html | tail -n 2 | head -n 1
