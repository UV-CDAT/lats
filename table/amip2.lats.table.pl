#!/usr/local/bin/perl

$cmd='
l.pl create_date > amip2.lats.table
cat pcmdi.lats.parms.table.head.txt  >> amip2.lats.table
l.pl pcmdi.lats.parms.table.1.txt amip2 >> amip2.lats.table

cat pcmdi.lats.vertdim.table.head.txt  >> amip2.lats.table
cat pcmdi.lats.vertdim.table.1.txt  >> amip2.lats.table

cat pcmdi.lats.center.table.head.txt  >> amip2.lats.table
cat pcmdi.lats.center.table.1.txt  >> amip2.lats.table

cat pcmdi.lats.qc.table.head.txt  >> amip2.lats.table
';

print "$cmd\n";
system($cmd);
exit;
