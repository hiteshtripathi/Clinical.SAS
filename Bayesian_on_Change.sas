proc format;
  value effect 1="Strong"
               2="Moderate"
			   3="Weak"
			   ;
run;


%macro BayesianChange(ds=, evtest=, site=, trt0=, trt1=);
proc sort data=adeff;
  by randoid test site side visitdy;
run;

data &ds;
  set adeff;
  by randoid test site side visitdy;
  if evtest="&evtest" and site=&site and visitdy ne -7;
  if first.randoid then base=.;
  retain base;
  if visitdy=0 then base=evstresn;
  chg=evstresn-base;
run; 


data mcmc_&ds;
	set &ds;
	rd=1*randoid;
	if visitdy=28 then timen=1 ;
	if visitdy=56 then timen=2 ;
	if visitdy=84 then timen=3 ;
	if visitdy=112 then timen=4;
	if visitdy=140 then timen=5;
	if visitdy=168 then timen=6;
	if treatment="&trt0" then trti=0; else if treatment="&trt1" then trti=1;
	if side=1 then sidei=0; else if side=2 then sidei=1;
run;

proc mcmc data=mcmc_&ds outpost=postout_&ds thin=100 nbi=10000 nmc=50000 PLOTS=(TRACE AUTOCORR DENSITY);
	parms s30 1 ;
	parms var_y 1 ;
	prior var_y ~ igamma(0.001, s=0.001);

	prior s30 ~ igamma(0.001, scale = 0.001);
	random rd_  ~ normal(0, var = s30) subject=rd initial=0.01 ;
	
	parms b0 0.01  b1 0.01 b2 0.01 b3 0.01 b4 0.01;
	prior b: ~ normal(0, var = 10000);
	mu = b0 + rd_  + b1*trti  + b2*timen + b3*trti*timen + b4*sidei ;
	model chg ~ normal(mu, var = var_y);
run;
quit;

data postout1_&ds;
  set postout_&ds;
  trteff=b1+b3*1; timec=28; output;
  trteff=b1+b3*2; timec=56; output;
  trteff=b1+b3*3; timec=84; output;
  trteff=b1+b3*4; timec=112; output;
  trteff=b1+b3*5; timec=140; output;
  trteff=b1+b3*6; timec=168; output; 
run;


data chg_&ds;
  set postout1_&ds;
  if trteff <= -0.25 then effect=1;
  else if trteff <= -0.1 then effect=2;
  else effect=3;
  format effect effect.;
run;

proc sort data=chg_&ds;
  by timec descending effect;
run;

proc freq data=chg_&ds noprint;
  by timec;
  tables effect / out=freq_&ds;
run;

data freq1_&ds;
  length V1 V2 V3 $200;
  set freq_&ds;
  label V1="Time" V2="Effect" V3="Probability";
  V1=put(timec, timenum.);
  V2=put(effect, effect.);
  percentc=round(percent/100, 0.0001);
  V3=put(percentc, 5.3);
run; 



proc means data=chg_&ds noprint;
  class timec;
  var trteff;
  output out=poststat_&ds mean=mu std=sd;
run;

data _null_;
  set poststat_&ds;
  if timec=28 then do;
    call symput("mu28_&ds", mu);
	call symput("sd28_&ds", sd);
	end;
	else if timec=56 then do;
	  call symput("mu56_&ds", mu);
	  call symput("sd56_&ds", sd);
	  end;
	  else if timec=84 then do;
	    call symput("mu84_&ds", mu);
		call symput("sd84_&ds", sd);
		end;
		else if timec=112 then do;
		  call symput("mu112_&ds", mu);
		  call symput("sd112_&ds", sd);
		  end;
		  else if timec=140 then do;
		    call symput("mu140_&ds", mu);
		    call symput("sd140_&ds", sd);
		    end;
		  else if timec=168 then do;
		    call symput("mu168_&ds", mu);
			call symput("sd168_&ds", sd);
			end;
run;


data pdf28_&ds;
  do x=-5*&&sd28_&ds + &&mu28_&ds to 5*&&sd28_&ds + &&mu28_&ds by 0.02*&&sd28_&ds;
    pdf=pdf("normal", x, &&mu28_&ds, &&sd28_&ds);
	lower=0;
	if x <= -0.25 then uStr=pdf("normal", x, &&mu28_&ds, &&sd28_&ds); else uStr=0;
	if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu28_&ds, &&sd28_&ds); else uMod=0;
	if x > -0.1 then uWeak=pdf("normal", x, &&mu28_&ds, &&sd28_&ds); else uWeak=0;
	time="Day 28"; timenum=28;
	output;
  end;
run;

data pdf56_&ds;
  do x=-5*&&sd56_&ds + &&mu56_&ds to 5*&&sd56_&ds + &&mu56_&ds by 0.02*&&sd56_&ds;
     pdf=pdf("normal", x, &&mu56_&ds, &&sd56_&ds);
	 lower=0;
     if x <= -0.25 then uStr=pdf("normal", x, &&mu56_&ds, &&sd56_&ds); else uStr=0;
	 if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu56_&ds, &&sd56_&ds); else uMod=0;
	 if x > -0.1 then uWeak=pdf("normal", x, &&mu56_&ds, &&sd56_&ds); else uWeak=0;
	 time="Day 56"; timenum=56;
	 output;
  end;
run;

data pdf84_&ds;
  do x=-5*&&sd84_&ds + &&mu84_&ds to 5*&&sd84_&ds + &&mu84_&ds by 0.02*&&sd84_&ds;
    pdf=pdf("normal", x, &&mu84_&ds, &&sd84_&ds);
	lower=0;
	if x <= -0.25 then uStr=pdf("normal", x, &&mu84_&ds, &&sd84_&ds); else uStr=0;
	if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu84_&ds, &&sd84_&ds); else uMod=0;
	if x > -0.1 then uWeak=pdf("normal", x, &&mu84_&ds, &&sd84_&ds); else uWeak=0;
	time="Day 84"; timenum=84;
	output;
  end;
run;

data pdf112_&ds;
  do x=-5*&&sd112_&ds + &&mu112_&ds to 5*&&sd112_&ds + &&mu112_&ds by 0.02*&&sd112_&ds;
    pdf=pdf("normal", x, &&mu112_&ds, &&sd112_&ds);
	lower=0;
	if x <= -0.25 then uStr=pdf("normal", x, &&mu112_&ds, &&sd112_&ds); else uStr=0;
	if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu112_&ds, &&sd112_&ds); else uMod=0;
	if x > -0.1 then uWeak=pdf("normal", x, &&mu112_&ds, &&sd112_&ds); else uWeak=0;
	time="Day 112"; timenum=112;
	output;
  end;
run;

data pdf140_&ds;
  do x=-5*&&sd140_&ds + &&mu140_&ds to 5*&&sd140_&ds + &&mu140_&ds by 0.02*&&sd140_&ds;
    pdf=pdf("normal", x, &&mu140_&ds, &&sd140_&ds);
	lower=0;
	if x <= -0.25 then uStr=pdf("normal", x, &&mu140_&ds, &&sd140_&ds); else uStr=0;
	if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu140_&ds, &&sd140_&ds); else uMod=0;
	if x > -0.1 then uWeak=pdf("normal", x, &&mu140_&ds, &&sd140_&ds); else uWeak=0;
	time="Day 140"; timenum=140;
	output;
  end;
run;

data pdf168_&ds;
  do x=-5*&&sd168_&ds + &&mu168_&ds to 5*&&sd168_&ds + &&mu168_&ds by 0.02*&&sd168_&ds;
    pdf=pdf("normal", x, &&mu168_&ds, &&sd168_&ds);
	lower=0;
	if x <= -0.25 then uStr=pdf("normal", x, &&mu168_&ds, &&sd168_&ds); else uStr=0;
	if -0.25 < x <= -0.1 then uMod=pdf("normal", x, &&mu168_&ds, &&sd168_&ds); else uMod=0;
	if x > -0.1 then uWeak=pdf("normal", x, &&mu168_&ds, &&sd168_&ds); else uWeak=0;
	time="Day 168"; timen=168;
	output;
  end;
run;

proc sql;
  create table pdf_&ds as
  select * from pdf28_&ds
  union
  select * from pdf56_&ds
  union 
  select * from pdf84_&ds
  union
  select * from pdf112_&ds
  union
  select * from pdf140_&ds
  union
  select * from pdf168_&ds
  ;
quit;

proc sort data=pdf_&ds;
  by timenum;
run;

data _null_;
  call symput("sitename", put(&site, site.));
  call symput("control", strip(put("&trt0", $trt.)));
  call symput("active", strip(put("&trt1", $trt.)));
run;


proc sgpanel data=pdf_&ds;
  format timenum timenum.;
  panelby timenum / onepanel columns=3 novarname headerattrs=(size=12) headerbackcolor=lightgray;
  band x=x lower=lower upper=uStr / fillattrs=(color=green) legendlabel="Strong" name="eff1";
  band x=x lower=lower upper=uMod / fillattrs=(color=yellow) legendlabel="Moderate" name="eff2";
  band x=x lower=lower upper=uWeak / fillattrs=(color=red) legendlabel="Weak" name="eff3";
  series x=x y=pdf / lineattrs=(color=black);
  series x=x y=lower / lineattrs=(color=black);
  refline -0.25 -0.1 / axis=x lineattrs=(pattern=2 color=black) label;
  rowaxis display=(nolabel noticks novalues);
  colaxis label="Difference between Change from Baseline";
  keylegend "eff1" "eff2" "eff3" / title="Effect";
  title1 "Wrinkles - &sitename";
  title2 "&active vs. &control";
  footnote1 j=c "Results are from Bayesian analysis using MCMC procedure with 50000 iterations (burn-in=10000)";
  footnote2 j=c "The change from baseline is modeled with normal distribution";
  footnote3 j=c "where mean = fixed intercept + random subject effect + side + treatment + time + treatment*time";
run; 
title;
footnote;

proc report data=freq1_&ds missing split="^";
  column V1 V2 V3;
  define V1 / group "Time" order=data style(column)=[just=left];
  define V2 / display "Effect" style(column)=[just=center];
  define V3 / display "Probability" style(column)=[just=center];
  compute after V1;
    line "";
	endcomp;
title1 "Wrinkles - &sitename";
title2 "&active vs. &control";
run;
title;
%mend;
