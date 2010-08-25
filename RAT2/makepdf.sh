#!/bin/csh

if ($#argv != 1) then
	echo "Usage: $0 $filename";
	goto done
endif

set pdftitle = "";
set pdfauthor = "";
set filename = $1

 
echo "\documentclass[8pt]{article}" > $filename;
echo "\usepackage[pdftex]{graphicx}" >> $filename;
echo "\usepackage{fullpage}" >> $filename;
echo "\usepackage[pdftex, pdftitle={$pdftitle}, " >> $filename;
echo " pdfauthor={$pdfauthor}, pdfpagemode={UseOutlines}, " >> $filename;
echo " bookmarks,bookmarksopen,pdfstartview={FitH}]" >> $filename;
echo "{hyperref}" >> $filename;
echo "\setlength{\topmargin}{0.0in}" >> $filename;
echo "\setlength{\headheight}{0.0in}" >> $filename;
echo "\setlength{\headsep}{0.0in}" >> $filename;
echo "\setlength{\textheight}{10.5in}" >> $filename;
echo "\setlength{\footskip}{0.1in}" >> $filename;
echo "\setlength{\textwidth}{6.5in}" >> $filename;
echo "\begin{document}" >> $filename;
echo "\begin{center}" >> $filename;
echo "\listoffigures" >> $filename;
echo "\pagebreak" >> $filename;
foreach file (`ls *.jpg`)
set file1 = `echo $file | awk '{sub("\\.jpg",""); print $0}'`
set file1 = `echo $file1 | awk '{gsub("\\.","-"); print $0}'`
#set file1 = `echo $file1 | awk '{gsub("-","x"); print $0}'`
set file1 = `echo $file1 | awk '{gsub("_","-"); print $0}'`
set file1 = `echo $file1.jpg`
mv $file $file1
echo "\section{$file1}" >> $filename;
echo "\begin{figure}[ht]" >> $filename;
echo "\begin{center}" >> $filename;
echo "\includegraphics[width=5.2in,keepaspectratio=true]{$file1}" >> $filename;
echo "\end{center}" >> $filename;
echo "\caption{$file1}" >> $filename;
echo "\end{figure}" >> $filename;
echo "\clearpage" >> $filename;
end;

echo "\end{center}" >> $filename;
echo "\end{document}" >> $filename;

/usr/bin/pdflatex $filename
/usr/bin/pdflatex $filename
done:
