/*** clear work library ***/
proc datasets lib=work memtype=data kill; quit;

/*** set datapath, outputpath and project***/
%let datapath=%str(G:\Scientific Computing\12 - Advanced Research\SMAD\Data\ACR_SMAD_18-12664_DB_lock_20190410);
%let outputpath=%str(G:\Scientific Computing\12 - Advanced Research\SMAD\Outputs);
%let project=SMAD;
libname &project "&datapath";

/*** import format if any ***/
proc format cntlin=&project..formats;
run;

proc format;
  value $trt "Group 1"="Placebo"
             "Group 2"="Neutrogena Regenerating Cream"
			 'Group 3'='0.15%SM 5253'
			 ;
run;

options fmtsearch=(work &project);
ods graphics / noborder;

data _null_;
  set &project..dbext_Rd end=eof;
  if rdstresc="Group 1" then n1+1;
  else if rdstresc="Group 2" then n2+1;
  else if rdstresc="Group 3" then n3+1;
  n4+1;
  if eof then do;
    call symput("n1", strip(put(n1, 3.)));
	call symput("n2", strip(put(n2, 3.)));
	call symput("n3", strip(put(n3, 3.)));
	call symput("n4", strip(put(n4, 3.)));
    end;
run;

proc sort data=&project..dbext_rd; by randoid; run;
proc sort data=&project..ae; by randoid; run;

data ae;
  merge &project..dbext_rd(in=intreat) &project..ae(in=inae);
  by randoid;
  if intreat and inae;
  if aeyn=1;
run;

data anyevent;
  set ae end=eof;
  by randoid;
  keep rowlabel count1 count2 count3 count4;
  if last.randoid;
  if rdstresc="Group 1" then count1+1;
  else if rdstresc="Group 2" then count2+1;
  else if rdstresc="Group 3" then count3+1;
  count4+1;
  if eof;
  length rowlabel $50;
  rowlabel="#S={font_weight=bold}Any Event";
run;


proc sort data=ae out=bysev;
  by randoid aesev;
run;

data bysev;
  set bysev;
  by randoid aesev;
  if last.randoid;
run;

proc sort data=bysev;
  by aesev;
run;

data bysev;
  set bysev end=eof;
  by aesev;
  keep rowlabel count1 count2 count3 count4;
  if first.aesev then do;
    count1=0;
	count2=0;
	count3=0;
	count4=0;
	end;
  if rdstresc="Group 1" then count1+1;
  else if rdstresc="Group 2" then count2+1;
  else if rdstresc="Group 3" then count3+1;
  count4+1;
  if last.aesev;
  length rowlabel $50;
  rowlabel="#{nbspace 6}"||put(aesev, sev.);
run;


proc sort data=ae out=bytype_sev;
  by randoid aetype aesev;
run;

data bytype_sev;
  set bytype_sev;
  by randoid aetype aesev;
  if last.aetype;
run;

proc sort data=bytype_sev;
  by aetype aesev;
run;

data bytype_sev;
  set bytype_Sev;
  by aetype aesev;
  keep aetype rowlabel count1 count2 count3 count4;
  if first.aesev then do;
    count1=0;
	count2=0;
	count3=0;
	count4=0;
	end;
  if rdstresc="Group 1" then count1+1;
  else if rdstresc="Group 2" then count2+1;
  else if rdstresc="Group 3" then count3+1;
  count4+1;
  if last.aesev;
  length rowlabel $50;
  rowlabel="#{nbspace 6}"||put(aesev, sev.);
run;


proc sort data=ae out=byterm_sev;
  by randoid aetype aeterm aesev;
run;

data byterm_sev;
  set byterm_sev;
  by randoid aetype aeterm aesev;
  if last.aeterm;
run;

proc sort data=byterm_sev;
  by aetype aeterm aesev;
run;

data byterm_sev;
  set byterm_sev;
  by aetype aeterm aesev;
  keep aetype aeterm rowlabel count1 count2 count3 count4;
  if first.aesev then do;
    count1=0;
	count2=0;
	count3=0;
	count4=0;
    end;
  if rdstresc="Group 1" then count1+1;
  else if rdstresc="Group 2" then count2+1;
  else if rdstresc="Group 3" then count3+1;
  count4+1;
  if last.aesev;
  length rowlabel $50;
  rowlabel="#{nbspace 6}"||put(aesev, sev.);
run;


data bytype;
  set bytype_sev(rename=(count1=_count1 count2=_count2 count3=_count3 count4=_count4));
  by aetype;
  keep aetype rowlabel count1 count2 count3 count4;
  if first.aetype then do;
    count1=0;
	count2=0;
	count3=0;
	count4=0;
	end;
  count1+_count1;
  count2+_count2;
  count3+_count3;
  count4+_count4;
  if last.aetype;
  length rowlabel $50;
  rowlabel="#S={font_weight=bold}"||put(aetype, type.);
run;

data bytype;
  set bytype bytype_sev;
  by aetype;
run;

data byterm;
  set byterm_sev(rename=(count1=_count1 count2=_count2 count3=_count3 count4=_count4));
  by aetype aeterm;
  keep aetype aeterm rowlabel count1 count2 count3 count4;
  if first.aeterm then do;
    count1=0;
	count2=0;
	count3=0;
	count4=0;
	end;
  count1+_count1;
  count2+_count2;
  count3+_count3;
  count4+_count4;
  if last.aeterm;
  length rowlabel $50;
  rowlabel="#{nbspace 3}"||aeterm;
run;

data byterm;
  set byterm byterm_sev;
  by aetype aeterm;
run;


data bytype_byterm;
  set bytype byterm;
  by aetype;
run;

data all;
  set anyevent bysev bytype_byterm;
  length col1 col2 col3 col4 $10;
  if rowlabel ne "" then do;
    pct1=(count1/&n1)*100;
	pct2=(count2/&n2)*100;
	pct3=(count3/&n3)*100;
	pct4=(count4/&n4)*100;
	col1=strip(put(count1, 3.))||" ("||strip(put(pct1, 3.))||"%)";
	col2=strip(put(count2, 3.))||" ("||strip(put(pct2, 3.))||"%)";
	col3=strip(put(count3, 3.))||" ("||strip(put(pct3, 3.))||"%)";
	col4=strip(put(count4, 3.))||" ("||strip(put(pct4, 3.))||"%)";
	end;
  length type_and_term $200;
  type_and_term=put(aetype, type.)||aeterm;
run;

ods escapechar="#";

ods rtf file="&outputpath\SMAD_AE_table_26Apr2019.rtf";
proc report data=all split="^" missing;
  column aetype rowlabel col1 col2 col3 col4;
  define aetype / group noprint;
  define rowlabel / display "AE Type^#{nbspace 3}AE Term^#{nbspace 6}Severity" style(header)=[just=left];
  define col1 / display "^Placebo^(N=&n1)" style(column)=[just=center];
  define col2 / display "^Neutrogena^(N=&n2)" style(column)=[just=center];
  define col3 / display '^0.15%SM 5253^(N=46)' style(column)=[just=center];
  define col4 / display "^All^(N=&n4)" style(column)=[just=center];
  compute after aetype;
    line "";
	endcomp;
title "Adverse Event by Type, Terms, and Greatest Severity";
run;
title;
ods rtf close;
