**************** This is a standard model to import demographic data from NHANES 1999-2020 *********************;
%macro CreatDS(cyclein, DS); *Macro to import NHANES database from files;
	%let cycle = %substr(&cyclein,2,%eval(%length(&cyclein)-2));		%let path = D:/nhanes/data/;		filename xptIn "&path.&DS..xpt";			libname xptIn xport;
	data SASdata.&DS;	set xptIn.&DS;	run;
%mend creatds;
libname SASdata "D:\CF\data\";
%CreatDS("2011_2012",DEMO_G);		%CreatDS("2013_2014",DEMO_H);		%CreatDS("2015_2016",DEMO_I);		
%CreatDS("2017_2020",P_DEMO);

Data demo_merge;
	merge 	SASdata.demo_G SASdata.demo_H SASdata.demo_I SASdata.P_demo;
	keep 	SEQN SDDSRVYR RIDSTATR RIAGENDR RIDAGEYR RIDRETH1 MILITARY BORN DMDEDUC2 DMDEDUC3 HREDU EDUC3 INDFMPIR FMPIR MARITAL RIDEXPRG SDMVPSU SDMVSTRA HRMARITAL DMDHRGND DMDHHSIZ WTMEC2YR;
	by		SEQN;
	if SDDSRVYR in (1:4) then do;
		if DMDBORN = 1 then BORN = 1;		*Born in US;
		if DMDBORN in (2,3) then BORN = 2;	*Born elsewhere;
		if (DMDBORN = .) or (DMDBORN in (7,9)) then BORN = .;
	end;
	if SDDSRVYR in (5,6) then do;
		if DMDBORN2 = 1 then BORN = 1;
		if DMDBORN2 in (2:5) then BORN = 2;
		if (DMDBORN2 = .) or (DMDBORN2 in (7,9)) then BORN = .;
	end;
	if SDDSRVYR in (7:10) then do;
		if DMDBORN4 = 1 then BORN = 1;
		if DMDBORN4 = 2 then BORN = 2;
		if (DMDBORN4 = .) or (DMDBORN4 in (77,99)) then BORN = .;
	end;

	if SDDSRVYR in (1:6) then do;
		if DMQMILIT = 1 then MILITARY = 1;
		if DMQMILIT = 2 then MILITARY = 2;
		if (DMQMILIT in (7,9)) or (DMQMILIT = .) then MILITARY = .;
	end;
	if SDDSRVYR in (7:10) then do;
		if DMQMILIZ = 1 then MILITARY = 1;
		if DMQMILIZ = 2 then MILITARY = 2;
		if (DMQMILIZ in (7,9)) or (DMQMILIZ = .) then MILITARY = .;
	end;

	if SDDSRVYR in (1:9) then do;
		if DMDHRMAR in (1,6) then HRMARITAL = 1;
		if DMDHRMAR in (2,3,4) then HRMARITAL = 2;
		if DMDHRMAR in (77,99) then HRMARITAL = .;
		if DMDHRMAR = . then HRMARITAL = .;

		if DMDHREDU in (1,2) then HREDU = 1;
		if DMDHREDU in (3,4) then HREDU = 2;
		if DMDHREDU = 5 then HREDU = 3;
		if DMDHREDU = . then HREDU = .;
		if DMDHREDU in (7,9) then HREDU = .;
	end;
	if SDDSRVYR = 10 then do;
		HRMARITAL = DMDHRMAZ;
		if DMDHRMAZ in (77,99) then HRMARITAL = .;

		if DMDHREDZ in (7,9) then HREDU = .;
		if DMDHREDZ = . then HREDU = .;
		if DMDHREDZ in (1:3) then HREDU = DMDHREDZ;
	end;

	if RIDAGEYR < 20 then do;
		MARITAL = .;
	end;
	else do;
		if (DMDMARTL = 1) or (DMDMARTL = 6) 					then MARITAL = 1;	*Married or Living with Partner;
		if (DMDMARTL = 2)  or (DMDMARTL = 3)  or (DMDMARTL = 4)	then MARITAL = 2;	*Widowed, divorced, separated;
		if  DMDMARTL = 5										then MARITAL = 3;	*Never married;
		if (DMDMARTL = 77) or (DMDMARTL = 99) or (DMDMARTL =.)	then MARITAL = .;
	end;

	if DMDEDUC2 in (7,9) then DMDEDUC2 = .;
	if DMDEDUC2 in (1,2) 	then EDUC3 = 1;
	if DMDEDUC2 in (3,4)	then EDUC3 = 2;
	if DMDEDUC2 = 5			then EDUC3 = 3;
	if DMDEDUC2 = .			then EDUC3 = .;
	if (INDFMPIR = ".") or  (INDFMPIR = "") 	then FMPIR =.;		if (INDFMPIR >= 0) and (INDFMPIR < 1.3) then FMPIR = 1;		if (INDFMPIR >= 1.3) and (INDFMPIR < 1.85) then FMPIR = 2;		
	if (INDFMPIR >= 1.85) and (INDFMPIR < 3)	then FMPIR = 3;		if INDFMPIR >= 3 then FMPIR = 4;	
Run;

Data Demo_Merge;
	set Demo_Merge;
	Label Born = "Country of Birth"; *1 = Born in US, 2 = Born Elsewhere;
	Label Military = "Veteran/Military Status";	*1 = Served in armed forces in US, 2 = Not served in armed forces in US;
	Label HRMarital = "Household Reference Person Marital Status";	*1 = Married or living with partner, 2 = Widowed, divorced, or separated, 3 = never married;
	Label HREDU = "Household Reference Person Education Level";		*1 = Less than high school degree, 2 = High school grad/GED or some college/AA degree, 3 = College graduate or above;
	Label Marital = "Marital Status";	*1 =  Married or living with partner, 2 = widowed, divorced, separated, 3 = never married;
	Label FMPIR = "Family PIR"; *1 = <1.3, 2 = [1.3-1.85), 3 = [1.85,3), 4 = >=3;
Run;

Proc sort data=demo_merge;	by SEQN;	Run;
