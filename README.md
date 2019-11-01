# Clinical.SAS

## Proc mixed normality
If you know the distribution from which the data is generated, then PROC GLIMMIX will suit your needs.  Unusual links (transformations) can be handled programmatically.
If you are determined to use PROC MIXED, then the key is making the RESIDUALS normal. 
Example:
proc mixed data=example2 plots=residualpanel;
class person sex;
model y = sex age1(sex) / noint s ddfm=kr
outpm=resm vciry residual;
repeated / type=cs sub=person group=sex r=1,12;
estimate 'diff in ints' sex 1 -1;
estimate 'diff in slopes' age1(sex) 1 -1;
run;


## Example for using format picture:
Put numbers into percent format (e.g., 96.789 to 96.79%)
proc format;
  picture pctfmt low-high='00.99%' (mult=1000);
run;
