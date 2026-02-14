%include "D:\gaolab\DGA2025-2030\SAS code\demo_merge.sas";				*Output: Demo_merge;
Data count;		set demo_merge;		if SDDSRVYR >= 5;	Run;	*45462 sample persons;
%include "D:\gaolab\DGA2025-2030\SAS code\diet_2d_2005_2018.sas";		*Output: Diet;
Data Diet_In;	set Diet;	Run;							*Create input dataset for fped;
%include "D:\gaolab\DGA2025-2030\SAS code\DataFIELD.sas";				*Output:FDCD_9918_GHGE;		*Ensured all food commodities mentioned in FCID dataset have GHGE info;
*¡üThis version included new FCID recipes used for substitution analysis;
%include "D:\gaolab\DGA2025-2030\SAS code\TOT_2D\FPED.sas";				*Need input: Diet_In, output: INDFOOD_OUT;
Data INDFOOD;	set INDFOOD_OUT;	Run;

*Merge GHGE information into INDFOOD;
Proc sort data=INDFOOD;		by DR1IFDCD DR1MC;	Run;
Proc sort data=FDCD_9918_GHGE;	by DR1IFDCD DR1MC;	Run;
Data INDFOOD;
	merge INDFOOD (in = a) FDCD_9918_GHGE;
	by DR1IFDCD DR1MC;
	if a;
Run;
Proc sort data=INDFOOD;	by SEQN DAYREC DR1ILINE;	Run;

*Merge DEMO information into INDFOOD;
Data demo_merge;
	set demo_merge;
	keep SEQN SDDSRVYR RIAGENDR RIDAGEYR SDMVPSU SDMVSTRA RIDRETH1 INDFMPIR WTMEC2YR;
Run;
Proc sort data=INDFOOD;		by SEQN;	Run;
Proc sort data=demo_merge;	by SEQN;	Run;
Data INDFOOD;
	merge demo_merge INDFOOD (in = a) ;
	by SEQN;
	if a;
Run;


Data INDFOOD;
	set INDFOOD;
	if (RIDAGEYR >= 20) and (DR1DRSTZ = 1) then do;
		LN_GHGE = DR1IGRMS * FDCD_GHGE / 100;
		LN_GHGE_DGA_1 = DR1IGRMS * FDCD_GHGE_DGA_1 / 100;		LN_GHGE_DGA_2 = DR1IGRMS * FDCD_GHGE_DGA_2 / 100;				LN_GHGE_DGA_3 = DR1IGRMS * FDCD_GHGE_DGA_3 / 100;
		LN_GHGE_DGA_4 = DR1IGRMS * FDCD_GHGE_DGA_4 / 100;		LN_GHGE_DGA_5 = DR1IGRMS * FDCD_GHGE_DGA_5 / 100;				LN_GHGE_DGA_6 = DR1IGRMS * FDCD_GHGE_DGA_6 / 100;
		LN_GHGE_DGA_7 = DR1IGRMS * FDCD_GHGE_DGA_7 / 100;		LN_GHGE_DGA_8 = DR1IGRMS * FDCD_GHGE_DGA_8 / 100;				LN_GHGE_DGA_9 = DR1IGRMS * FDCD_GHGE_DGA_9 / 100;
		LN_GHGE_DGA_10 = DR1IGRMS * FDCD_GHGE_DGA_10 / 100;		LN_GHGE_DGA_11 = DR1IGRMS * FDCD_GHGE_DGA_11 / 100;				LN_GHGE_DGA_12 = DR1IGRMS * FDCD_GHGE_DGA_12 / 100;
		LN_GHGE_DGA_13 = DR1IGRMS * FDCD_GHGE_DGA_13 / 100;		LN_GHGE_DGA_14 = DR1IGRMS * FDCD_GHGE_DGA_14 / 100;				LN_GHGE_DGA_15 = DR1IGRMS * FDCD_GHGE_DGA_15 / 100;
		LN_GHGE_DGA_16 = DR1IGRMS * FDCD_GHGE_DGA_16 / 100;		LN_GHGE_DGA_17 = DR1IGRMS * FDCD_GHGE_DGA_17 / 100;				LN_GHGE_DGA_18 = DR1IGRMS * FDCD_GHGE_DGA_18 / 100;
		LN_GRAM_DGA_1 = DR1IGRMS * FDCD_GRAM_DGA_1 / 100;		LN_GRAM_DGA_2 = DR1IGRMS * FDCD_GRAM_DGA_2 / 100;				LN_GRAM_DGA_3 = DR1IGRMS * FDCD_GRAM_DGA_3 / 100;
		LN_GRAM_DGA_4 = DR1IGRMS * FDCD_GRAM_DGA_4 / 100;		LN_GRAM_DGA_5 = DR1IGRMS * FDCD_GRAM_DGA_5 / 100;				LN_GRAM_DGA_6 = DR1IGRMS * FDCD_GRAM_DGA_6 / 100;
		LN_GRAM_DGA_7 = DR1IGRMS * FDCD_GRAM_DGA_7 / 100;		LN_GRAM_DGA_8 = DR1IGRMS * FDCD_GRAM_DGA_8 / 100;				LN_GRAM_DGA_9 = DR1IGRMS * FDCD_GRAM_DGA_9 / 100;
		LN_GRAM_DGA_10 = DR1IGRMS * FDCD_GRAM_DGA_10 / 100;		LN_GRAM_DGA_11 = DR1IGRMS * FDCD_GRAM_DGA_11 / 100;				LN_GRAM_DGA_12 = DR1IGRMS * FDCD_GRAM_DGA_12 / 100;
		LN_GRAM_DGA_13 = DR1IGRMS * FDCD_GRAM_DGA_13 / 100;		LN_GRAM_DGA_14 = DR1IGRMS * FDCD_GRAM_DGA_14 / 100;				LN_GRAM_DGA_15 = DR1IGRMS * FDCD_GRAM_DGA_15 / 100;
		LN_GRAM_DGA_16 = DR1IGRMS * FDCD_GRAM_DGA_16 / 100;		LN_GRAM_DGA_17 = DR1IGRMS * FDCD_GRAM_DGA_17 / 100;				LN_GRAM_DGA_18 = DR1IGRMS * FDCD_GRAM_DGA_18 / 100;
	end;
Run;


Proc datasets;	delete diet_in INDFOOD_out;		Run; Quit;
Data INDFOOD_IN;			set INDFOOD;				Run;

*Convert INDFOOD to INDPERS, need to calculate: dietary GHGE, GHGE of each DGA subgroups;
%include "D:\gaolab\DGA2025-2030\SAS code\INDPERS.sas";					*Need input: INDFOOD_IN, output: INDPERS_OUT; 
%include "D:\gaolab\DGA2025-2030\SAS code\TOT_merge.sas";	
Data TOT_merge;		set TOT_merge;
	keep 	SEQN	 DRQSDIET DR1TKCAL DR2TKCAL DRXTKCAL DRXTPROT DRXTCARB DRXTSUGR DRXTFIBE DRXTTFAT DRXTSFAT DRXTMFAT DRXTPFAT DRXTCHOL DRXTATOC DRXTATOA DRXTRET  DRXTVARA DRXTACAR DRXTBCAR DRXTCRYP DRXTLYCO DRXTLZ DRXTVB1 DRXTVB2 DRXTNIAC DRXTVB6 DRXTFOLA 
			DRXTFA 	 DRXTFF   DRXTFDFE DRXTCHL  DRXTVB12 DRXTB12A DRXTVC   DRXTVK	DRXTCALC DRXTPHOS DRXTMAGN DRXTIRON DRXTZINC DRXTCOPP DRXTSODI DRXTPOTA DRXTSELE DRXDRSTZ;
Run;
Proc sort data=INDPERS_OUT;	by SEQN;	Run;
Proc sort data=TOT_merge;		by SEQN;	Run;

Data INDPERS_IN;
	merge INDPERS_OUT (in = a) TOT_merge (in = b);
	by SEQN;
	if a;
Run;

Data INDPERS;	set INDPERS_IN;	Run;	


*****************************************************************************************************************************
*																															*
*								Count number of participants during exclusion process										*
*																															*
*****************************************************************************************************************************;
Data count;
	set demo_merge;
	if SDDSRVYR >= 5;
Run;																					
Data count;
	set demo_merge;
	if SDDSRVYR >= 5 and RIDAGEYR >= 20;
Run;																					* 26280 sample persons;
Data INDPERS;
	set INDPERS;
	INCLUDE = 1;		*INCLUDE = 1: included in this study, 0: excluded from this study;
	if  (Day1STZ = 1) and (Day2STZ = 1) then WTDRD12 = WTDR2D/4;
	if SDDSRVYR >= 5 and RIDAGEYR >= 20;
Run;
Data count;		set INDPERS;	if INCLUDE = 1;	Run; 									* 22572 sample persons;
Data INDPERS;	set INDPERS;
	if DRXDRSTZ = . then INCLUDE = 0;
Run;
Data count;		set INDPERS;	if INCLUDE = 1;	Run;									* 22572 sample persons;
Data INDPERS;	set INDPERS;
	if DRXDRSTZ GE 2 then INCLUDE = 0;
Run;
Data count;		set INDPERS;	if INCLUDE = 1;	Run;									* 19702 sample persons with total dietary data, 2870 eliminated;
Data INDPERS;	set INDPERS;
	if DRXDRSTZ GT 1 then INCLUDE = 0;
Run;
Data count;		set INDPERS;	if INCLUDE = 1;	Run;									* 19632 sample persons with reliable dietary recall, 70 eliminated;
Data INDPERS;	set INDPERS;
	if RIAGENDR = 1 then do;
		if (DRXTKCAL < 800) or (DRXTKCAL > 4200) then INCLUDE = 0;
	end;
	if RIAGENDR = 2 then do;
		if (DRXTKCAL < 500) or (DRXTKCAL > 3500) then INCLUDE = 0;
	end;
Run;
Data count;		set INDPERS;	if INCLUDE = 1;	Run;									*19026 sample persons without extreme energy intake, 606 eliminated;
Proc sort data=INDPERS;	by SEQN;	WHERE INCLUDE = 1; Run;
Data INDPERS;
	set INDPERS;
		CO_DGA_1 = PERS_AV_DGA1_GHGE / PERS_AV_DGA1_Gram;		CO_DGA_2 = PERS_AV_DGA2_GHGE / PERS_AV_DGA2_Gram;
		CO_DGA_3 = PERS_AV_DGA3_GHGE / PERS_AV_DGA3_Gram;		CO_DGA_4 = PERS_AV_DGA4_GHGE / PERS_AV_DGA4_Gram;				
		CO_DGA_5 = PERS_AV_DGA5_GHGE / PERS_AV_DGA5_Gram;		CO_DGA_6 = PERS_AV_DGA6_GHGE / PERS_AV_DGA6_Gram;				
		CO_DGA_7 = PERS_AV_DGA7_GHGE / PERS_AV_DGA7_Gram;		CO_DGA_8 = PERS_AV_DGA8_GHGE / PERS_AV_DGA8_Gram;				
		CO_DGA_9 = PERS_AV_DGA9_GHGE / PERS_AV_DGA9_Gram;		CO_DGA_10 = PERS_AV_DGA10_GHGE / PERS_AV_DGA10_Gram;				
		CO_DGA_11 = PERS_AV_DGA11_GHGE / PERS_AV_DGA11_Gram;		CO_DGA_12 = PERS_AV_DGA12_GHGE / PERS_AV_DGA12_Gram;				
		CO_DGA_13 = PERS_AV_DGA13_GHGE / PERS_AV_DGA13_Gram;		CO_DGA_14 = PERS_AV_DGA14_GHGE / PERS_AV_DGA14_Gram;			
		CO_DGA_15 = PERS_AV_DGA15_GHGE / PERS_AV_DGA15_Gram;		CO_DGA_16 = PERS_AV_DGA16_GHGE / PERS_AV_DGA16_Gram;				
		CO_DGA_17 = PERS_AV_DGA17_GHGE / PERS_AV_DGA17_Gram;		CO_DGA_18 = PERS_AV_DGA18_GHGE / PERS_AV_DGA18_Gram;				
Run;

Data INDPERS;
	set INDPERS;
	IF CO_DGA_1 = . THEN CO_DGA_1 = 0;		
	IF CO_DGA_2 = . THEN CO_DGA_2 = 0;
	IF CO_DGA_3 = . THEN CO_DGA_3 = 0;
	IF CO_DGA_4 = . THEN CO_DGA_4 = 0;
	IF CO_DGA_5 = . THEN CO_DGA_5 = 0;
	IF CO_DGA_6 = . THEN CO_DGA_6 = 0;
	IF CO_DGA_7 = . THEN CO_DGA_7 = 0;
	IF CO_DGA_8 = . THEN CO_DGA_8 = 0;
	IF CO_DGA_9 = . THEN CO_DGA_9 = 0;		
	IF CO_DGA_10 = . THEN CO_DGA_10 = 0;
	IF CO_DGA_11 = . THEN CO_DGA_11 = 0;
	IF CO_DGA_12 = . THEN CO_DGA_12 = 0;
	IF CO_DGA_13 = . THEN CO_DGA_13 = 0;
	IF CO_DGA_14 = . THEN CO_DGA_14 = 0;
	IF CO_DGA_15 = . THEN CO_DGA_15 = 0;
	IF CO_DGA_16 = . THEN CO_DGA_16 = 0;
	IF CO_DGA_17 = . THEN CO_DGA_17 = 0;
	IF CO_DGA_18 = . THEN CO_DGA_18 = 0;
Run;

Proc surveymeans data=INDPERS;
	Strata SDMVSTRA;	Cluster SDMVPSU;	Weight WTDRD12;	
	var CO_DGA_1;
Run;

Data INDPERS;
	set INDPERS;
	DENS_F_TOTAL 			= DRXT_F_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_F_CITMLB			= DRXT_F_CITMLB_CAL / DRXTKCAL * 1000;
	DENS_F_OTHER			= DRXT_F_OTHER_CAL / DRXTKCAL * 1000;
	DENS_F_JUICE			= DRXT_F_JUICE_CAL / DRXTKCAL * 1000;
	DENS_V_TOTAL			= DRXT_V_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_V_DRKGR			= DRXT_V_DRKGR_CAL / DRXTKCAL * 1000;
	DENS_V_REDOR_TOTAL 		= DRXT_V_REDOR_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_V_REDOR_TOMATO		= DRXT_V_REDOR_TOMATO_CAL / DRXTKCAL * 1000;
	DENS_V_REDOR_OTHER		= DRXT_V_REDOR_OTHER_CAL / DRXTKCAL * 1000;
	DENS_V_STARCHY_TOTAL	= DRXT_V_STARCHY_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_V_STARCHY_POTATO	= DRXT_V_STARCHY_POTATO_CAL / DRXTKCAL * 1000;
	DENS_V_STARCHY_OTHER	= DRXT_V_STARCHY_OTHER_CAL / DRXTKCAL * 1000;
	DENS_V_OTHER			= DRXT_V_OTHER_CAL / DRXTKCAL * 1000;
	DENS_V_LEGUMES			= DRXT_V_LEGUMES_CAL / DRXTKCAL * 1000;
	DENS_G_TOTAL			= DRXT_G_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_G_WHOLE			= DRXT_G_WHOLE_CAL / DRXTKCAL * 1000;
	DENS_G_REFINED			= DRXT_G_REFINED_CAL / DRXTKCAL * 1000;
	DENS_PF_TOTAL			= DRXT_PF_TOTAL_CAL / DRXTKCAL * 1000;									*Total meat, poultry, organ meat, cured meat, seafood, eggs, soy, and nuts and seeds, excludes legumes (oz. eq.);
	DENS_PF_MPS_TOTAL		= DRXT_PF_MPS_TOTAL_CAL / DRXTKCAL * 1000;								*Total of meat, poultry, seafood, organ meat, and cured meat (oz. eq.);
	DENS_PF_MEAT			= DRXT_PF_MEAT_CAL / DRXTKCAL * 1000;									*Beef, veal, pork, lamb, and game meat, excludes organ meat and cured meat (oz. eq.);
	DENS_PF_CUREDMEAT		= DRXT_PF_CUREDMEAT_CAL / DRXTKCAL * 1000;								*Frankfurters, sausages, corned beef, and luncheon meat that are made from beef, pork, or poultry (oz. eq.);
	DENS_PF_ORGAN			= DRXT_PF_ORGAN_CAL / DRXTKCAL * 1000;									*Organ meat from beef, veal, pork, lamb, game, and poultry (oz. eq.);
	DENS_PF_POULT			= DRXT_PF_POULT_CAL / DRXTKCAL * 1000;									*Chicken, turkey, Cornish hens, duck, goose, quail, and pheasant (game birds), excludes organ meat and cured meat (oz. eq.);
	DENS_PF_SEAFD_HI		= DRXT_PF_SEAFD_HI_CAL / DRXTKCAL * 1000;								*Seafood (finfish, shellfish, and other seafood) high in n-3 fatty acids (oz. eq.);
	DENS_PF_SEAFD_LOW		= DRXT_PF_SEAFD_LOW_CAL / DRXTKCAL * 1000;								*Seafood (finfish, shellfish, and other seafood) low in n-3 fatty acids (oz. eq.);
	DENS_PF_SEAFD			= (DRXT_PF_SEAFD_HI_CAL + DRXT_PF_SEAFD_LOW_CAL) / DRXTKCAL * 1000;		*Seafood (finfish, shellfish, and other seafood)(oz. eq.);
	DENS_PF_EGGS			= DRXT_PF_EGGS_CAL / DRXTKCAL * 1000;
	DENS_PF_SOY				= DRXT_PF_SOY_CAL / DRXTKCAL * 1000;
	DENS_PF_NUTSDS			= DRXT_PF_NUTSDS_CAL / DRXTKCAL * 1000;
	DENS_PF_LEGUMES			= DRXT_PF_LEGUMES_CAL / DRXTKCAL * 1000;								*Beans and Peas (legumes) computed as protein foods (oz. eq.);
	DENS_D_TOTAL			= DRXT_D_TOTAL_CAL / DRXTKCAL * 1000;
	DENS_D_MILK				= DRXT_D_MILK_CAL / DRXTKCAL * 1000;
	DENS_D_YOGURT			= DRXT_D_YOGURT_CAL / DRXTKCAL * 1000;
	DENS_D_CHEESE			= DRXT_D_CHEESE_CAL / DRXTKCAL * 1000;
	DENS_OILS				= DRXT_OILS_CAL / DRXTKCAL * 1000;
	DENS_SOLID_FATS			= DRXT_SOLID_FATS_CAL / DRXTKCAL * 1000;
	DENS_ADD_SUGARS			= DRXT_ADD_SUGARS_CAL / DRXTKCAL * 1000;
	DENS_A_DRINKS			= DRXT_A_DRINKS_CAL / DRXTKCAL * 1000;
	DENS_SUGR				= DRXTSUGR / DRXTKCAL * 1000;		*Total sugars, gm/1000 kcal;
	DENS_FIBE				= DRXTFIBE / DRXTKCAL * 1000;
	DENS_CHOL				= DRXTCHOL / DRXTKCAL * 1000;		*Cholesterol mg/1000 kcal;
	DENS_ATOC				= DRXTATOC / DRXTKCAL * 1000;		*Vitamin E as alpha-tocopherol, mg/1000 kcal;
	DENS_ATOA				= DRXTATOA / DRXTKCAL * 1000;		*Added alpha-tocopherol (Vitamin E) mg/1000 kcal;
	DENS_RET				= DRXTRET / DRXTKCAL * 1000;		*Retinol, ug/1000 kcal;
	DENS_VARA				= DRXTVARA / DRXTKCAL * 1000;		*Vitamin A, RAE ug/1000 kcal;
	DENS_ACAR				= DRXTACAR / DRXTKCAL * 1000;		*Alpha-carotene ug/1000 kcal;
	DENS_BCAR				= DRXTBCAR / DRXTKCAL * 1000;		*beta-carotene ug/1000 kcal;
	DENS_CRYP				= DRXTCRYP / DRXTKCAL * 1000;		*beta-cryptoxanthin, ug/1000 kcal;
	DENS_LYCO				= DRXTLYCO / DRXTKCAL * 1000;		*lycopene, ug/1000 kcal;
	DENS_LZ					= DRXTLZ / DRXTKCAL * 1000;			*lutein+zeaxanthin, ug/1000 kcal;
	DENS_VB1				= DRXTVB1 / DRXTKCAL * 1000;		*Vitamin B1, mg/1000 kcal;
	DENS_VB2				= DRXTVB2 / DRXTKCAL * 1000;		*Vitamin B2, mg/1000 kcal;
	DENS_NIAC				= DRXTNIAC / DRXTKCAL * 1000;		*Niacin, mg/1000 kcal;
	DENS_VB6				= DRXTVB6 / DRXTKCAL * 1000;		*Vitamin B6, mg/1000 kcal;
	DENS_FOLA				= DRXTFOLA / DRXTKCAL * 1000; 		*Total folate, ug/1000 kcal;
	DENS_FA					= DRXTFA / DRXTKCAL * 1000;			*Folic acid, ug/1000 kcal;
	DENS_FF					= DRXTFF / DRXTKCAL * 1000;			*Food folate, ug/1000 kcal;
	DENS_FDFE				= DRXTFDFE / DRXTKCAL * 1000;		*folate, DFE, ug/1000 kcal;
	DENS_CHL				= DRXTCHL / DRXTKCAL * 1000;		*Total choline, mg/1000 kcal;
	DENS_VB12				= DRXTVB12 / DRXTKCAL * 1000;		*Vitmain B12, ug/1000 kcal;
	DENS_B12A				= DRXTB12A / DRXTKCAL * 1000;		*Added vitamin B12, ug/1000 kcal;
	DENS_VC					= DRXTVC / DRXTKCAL * 1000;			*Vitamin C, mg/1000 kcal;
	DENS_VK					= DRXTVK / DRXTKCAL * 1000;			*Vitmain K, ug/1000 kcal;
	DENS_CALC				= DRXTCALC / DRXTKCAL * 1000;		*Calcium, mg/1000 kcal;
	DENS_PHOS				= DRXTPHOS / DRXTKCAL * 1000;		*Phosphorus, mg/1000 kcal;
	DENS_MAGN				= DRXTMAGN / DRXTKCAL * 1000;		*Magnesium, mg/1000 kcal;
	DENS_IRON				= DRXTIRON / DRXTKCAL * 1000;		*Iron, mg/1000 kcal;
	DENS_ZINC				= DRXTZINC / DRXTKCAL * 1000;		*Zinc, mg/1000 kcal;
	DENS_COPP				= DRXTCOPP / DRXTKCAL * 1000;		*Copper, mg/1000 kcal;
	DENS_POTA				= DRXTPOTA / DRXTKCAL * 1000;		*Potasium, mg/1000 kcal;
	DENS_SELE				= DRXTSELE / DRXTKCAL * 1000;		*Selenium, ug/1000 kcal;
	DENS_IntactFruit		= (DENS_F_CITMLB + DENS_F_OTHER);	*Intact fruits, cup equivalent/1000 kcal;
	DENS_PF_LEGUMESOY		= (DENS_PF_LEGUMES + DENS_PF_SOY);	*Legumes (beans, peas and soy), oz eq/1000 kcal;
	DENS_PF_SEAFD			= DENS_PF_SEAFD_HI + DENS_PF_SEAFD_LOW;	*Seafood (high or low in n-3 PUFA;
	DENS_POULTEGG			= DENS_PF_POULT + DENS_PF_EGGS;		*Poultry and eggs, oz eq/1000 kcal;
	DENS_PF_TOTALwithLegumes = DENS_PF_TOTAL + DENS_PF_LEGUMES;	*Total protein foods, including legumes;
	DENS_SEANUT				= DENS_PF_SEAFD + DENS_PF_NUTSDS;	*Seafood, nuts and seeds, oz eq/1000 kcal;
Run;
Proc sort data=INDPERS;	by SEQN;	WHERE INCLUDE = 1; Run;



%let varlist = 		DENS_F_CITMLB			DENS_F_OTHER			DENS_F_JUICE
					DENS_V_DRKGR			DENS_V_REDOR_TOTAL		DENS_V_STARCHY_TOTAL	DENS_V_OTHER
					DENS_G_WHOLE			DENS_G_REFINED			DENS_V_LEGUMES
					DENS_BEEF_GRAM			DENS_SHEEP_GRAM			DENS_PORK_GRAM			DENS_PF_POULT			DENS_PF_SEAFD_HI		DENS_PF_SEAFD_LOW	DENS_PF_EGGS		
					DENS_PF_SOY				DENS_PF_NUTSDS			DENS_PF_LEGUMES			DENS_PF_LEGUMESOY		
					DENS_D_MILK				DENS_D_YOGURT			DENS_D_CHEESE			
					DENS_OILS				DENS_SOLID_FATS			DENS_ADD_SUGARS			FA_RATIO				DENS_SODI						;		*27 input variables;
%let vardisplay = 	DRXTKCAL				
					DENS_F_TOTAL			DENS_IntactFruit		DENS_F_CITMLB			DENS_F_OTHER			DENS_F_JUICE		
					DENS_V_TOTAL			DENS_V_DRKGR			DENS_V_REDOR_TOTAL		DENS_V_REDOR_TOMATO		DENS_V_REDOR_OTHER		DENS_V_STARCHY_TOTAL
					DENS_V_STARCHY_POTATO	DENS_V_STARCHY_OTHER	DENS_V_OTHER			DENS_V_LEGUMES
					DENS_G_TOTAL			DENS_G_WHOLE			DENS_G_REFINED	
					DENS_PF_TOTAL			DENS_PF_TOTALwithLegumes						DENS_PF_MPS_TOTAL		DENS_PF_MEAT			DENS_PF_CUREDMEAT		DENS_PF_ORGAN		
					DENS_PF_POULT			DENS_PF_EGGS			DENS_POULTEGG			DENS_SEANUT				DENS_PF_SEAFD			DENS_PF_SEAFD_HI		DENS_PF_SEAFD_LOW		DENS_PF_NUTSDS		DENS_PF_LEGUMES		DENS_PF_SOY		DENS_PF_LEGUMESOY
					DENS_D_TOTAL			DENS_D_MILK				DENS_D_YOGURT			DENS_D_CHEESE		
					DENS_OILS				DENS_SOLID_FATS			DENS_ADD_SUGARS			DENS_SUGR				DENS_A_DRINKS		
					DENS_FIBE				DENS_CHOL				
					DENS_CALC				DENS_PHOS				DENS_MAGN				DENS_IRON				DENS_ZINC				DENS_COPP				DENS_POTA			DENS_SELE;

Data temp;
	set INDPERS;
	length VarNameFull $200;
	if VarName = "DENS_F_TOTAL" 			then VarNameFull = "Total intact fruits and fruit juices, cup eq. per 1000 kcal";
	if VarName = "DENS_F_CITMLB" 			then VarNameFull = "Intact fruits of citrus, melons, and berries, cup eq. per 1000 kcal";
	if VarName = "DENS_F_OTHER"				then VarNameFull = "Intact fruits excluding citrus, melons, and berries, cup eq. per 1000 kcal";
	if VarName = "DENS_F_JUICE"				then VarNameFull = "Fruit juices, cup eq. per 1000 kcal";
	if VarName = "DENS_V_TOTAL"				then VarNameFull = "Total vegetables, excluding legumes, cup eq. per 1000 kcal";
	if VarName = "DENS_V_DRKGR"				then VarNameFull = "Dark green vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_REDOR_TOTAL"		then VarNameFull = "Total red and orange vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_REDOR_TOMATO"		then VarNameFull = "Tomatoes and tomato products, cup eq. per 1000 kcal";
	if VarName = "DENS_V_REDOR_OTHER"		then VarNameFull = "Other red and orange vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_STARCHY_TOTAL"		then VarNameFull = "Total starchy vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_STARCHY_POTATO"	then VarNameFull = "White potatoes, cup eq. per 1000 kcal";
	if VarName = "DENS_V_STARCHY_OTHER"		then VarNameFull = "Other starchy vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_OTHER"				then VarNameFull = "Other vegetables, cup eq. per 1000 kcal";
	if VarName = "DENS_V_LEGUMES"			then VarNameFull = "Beans and Peas (legumes), cup eq. per 1000 kcal";
	if VarName = "DENS_G_TOTAL"				then VarNameFull = "Total grains, oz. eq. per 1000 kcal";
	if VarName = "DENS_G_WHOLE"				then VarNameFull = "Whole grains, oz. eq. per 1000 kcal";
	if VarName = "DENS_G_REFINED"			then VarNameFull = "Refined grains, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_TOTAL"			then VarNameFull = "Total protein foods, excluding legumes, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_MPS_TOTAL"		then VarNameFull = "Total meat, poultry, seafood, organ meat, and cured meat, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_MEAT"				then VarNameFull = "Beef, veal, pork, lamb and game meat, excluding organ meat and cured meat, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_CUREDMEAT"		then VarNameFull = "Cured meat, including frankfurters, sausages, corned beef, and luncheon meat, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_ORGAN"			then VarNameFull = "Organ meat from beef, veal, pork, lamb, game, and poultry, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_POULT"			then VarNameFull = "Poultry, excluding organ meat and cured meat, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_SEAFD_HI"			then VarNameFull = "Seafood high in n-3 fatty acids, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_SEAFD_LOW"		then VarNameFull = "Seafood low in n-3 fatty acids, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_EGGS"				then VarNameFull = "Eggs and egg substitutes, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_SOY"				then VarNameFull = "Soy products, excluding calcium fortified soy milk and mature soybeans, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_NUTSDS"			then VarNameFull = "Nuts and Seeds, excluding coconut, oz. eq. per 1000 kcal";
	if VarName = "DENS_PF_LEGUMES"			then VarNameFull = "Beans and Peas (legumes), oz. eq. per 1000 kcal";
	if VarName = "DENS_D_TOTAL"				then VarNameFull = "Total dairy, cup eq. per 1000 kcal";
	if VarName = "DENS_D_MILK"				then VarNameFull = "Milk and calcium fortified soy milk, cup eq. per 1000 kcal";
	if VarName = "DENS_D_YOGURT"			then VarNameFull = "Yogurt, cup eq. per 1000 kcal";
	if VarName = "DENS_D_CHEESE"			then VarNameFull = "Cheeses, cup eq. per 1000 kcal";
	if VarName = "DENS_OILS"				then VarNameFull = "Oils, fats naturally present in nuts, seeds, and seafood, grams per 1000 kcal";
	if VarName = "DENS_SOLID_FATS"			then VarNameFull = "Fats, naturally present in meat, poultry, eggs, and dairy, grams per 1000 kcal";
	if VarName = "DENS_ADD_SUGARS"			then VarNameFull = "Added sugars, tsp. eq. per 1000 kcal";
	if VarName = "DENS_A_DRINKS"			then VarNameFull = "Alcoholic beverages and alcohol added to foods after cooking, no. of drinks per 1000 kcal";
	if VarName = "DENS_SFAT"				then VarNameFull = "Saturated fat, grams per 1000 kcal";
	if VarName = "DENS_MFAT"				then VarNameFull = "Monounsaturated fat, grams per 1000 kcal";
	if VarName = "DENS_PFAT"				then VarNameFull = "Polyunsaturated fat, grams per 1000 kcal";
	if VarName = "FA_RATIO"					then VarNameFull = "(MUFA+PUFA)/SFA";
	if VarName = "DENS_SODI"				then VarNameFull = "Sodium, g per 1000 kcal";
	if VarName = "DENS_BEEF_GRAM"			then VarNameFull = "Beef meat/organ/cured meat, grams per 1000 kcal";
	if VarName = "DENS_SHEEP_GRAM"			then VarNameFull = "Sheep/Goat meat/organ/cured meat, grams per 1000 kcal";
	if VarName = "DENS_PORK_GRAM"			then VarNameFull = "Pork meat/organ/cured meat, grams per 1000 kcal";
	if VarName = "DENS_SUGR"				then VarNameFull = "Total sugars, grams per 1000 kcal";
	if VarName = "DENS_FIBE"				then VarNameFull = "Dietary fiber, grams per 1000 kcal";
	if VarName = "DENS_CHOL"				then VarNameFull = "Cholesterol, mg/1000 kcal";
	if VarName = "DENS_ATOC"				then VarNameFull = "Vitamin E as alpha-tocopherol, mg/1000 kcal";
	if VarName = "DENS_ATOA"				then VarNameFull = "Added alpha-tocopherol (Vitamin E), mg/1000 kcal";
	if VarName = "DENS_RET"					then VarNameFull = "Retinol, ug/1000 kcal";
	if VarName = "DENS_VARA"				then VarNameFull = "Vitamin A, RAE, ug/1000 kcal";
	if VarName = "DENS_ACAR"				then VarNameFull = "Alpha-carotene, ug/1000 kcal";
	if VarName = "DENS_BCAR"				then VarNameFull = "Beta-carotene, ug/1000 kcal";
	if VarName = "DENS_CRYP"				then VarNameFull = "Beta-cryptoxanthin, ug/1000 kcal";
	if VarName = "DENS_LYCO"				then VarNameFull = "Lycopene, ug/1000 kcal";
	if VarName = "DENS_LZ"					then VarNameFull = "Lutein + zeaxanthin, ug/1000 kcal";
	if VarName = "DENS_VB1"					then VarNameFull = "Vitamin B1";
	if VarName = "DENS_VB2"					then VarNameFull = "Vitamin B2";
	if VarName = "DENS_NIAC"				then VarNameFull = "Niacin";
	if VarName = "DENS_VB6"					then VarNameFull = "Vitamin B6";
	if VarName = "DENS_FOLA"				then VarNameFull = "Total folate, ug/1000 kcal";
	if VarName = "DENS_FA"					then VarNameFull = "Folic acid, ug/1000 kcal";
	if VarName = "DENS_FF"					then VarNameFull = "Food folate, ug/1000 kcal";
	if VarName = "DENS_FDFE"				then VarNameFull = "Folate, DFE, ug/1000 kcal";
	if VarName = "DENS_CHL"					then VarNameFull = "Total choline, mg/1000 kcal";
	if VarName = "DENS_VB12"				then VarNameFull = "Vitamin B12, ug/1000 kcal";
	if VarName = "DENS_B12A"				then VarNameFull = "Added vitamin B12, ug/1000 kcal";				
	if VarName = "DENS_VC"					then VarNameFull = "Vitamin C, mg/1000 kcal";
	if VarName = "DENS_VK"					then VarNameFull = "Vitamin K, ug/1000 kcal";
	if VarName = "DENS_CALC"				then VarNameFull = "Calcium, mg/1000 kcal";
	if VarName = "DENS_PHOS"				then VarNameFull = "Phosphorus, mg/1000 kcal";
	if VarName = "DENS_MAGN"				then VarNameFull = "Magnesium, mg/1000 kcal";
	if VarName = "DENS_IRON"				then VarNameFull = "Iron, mg/1000 kcal";
	if VarName = "DENS_ZINC"				then VarNameFull = "Zinc, mg/1000 kcal";
	if VarName = "DENS_COPP"				then VarNameFull = "Copper, mg/1000 kcal";
	if VarName = "DENS_POTA"				then VarNameFull = "Potassium, mg/1000 kcal";
	if VarName = "DENS_SELE"				then VarNameFull = "Selenium, ug/1000 kcal";
	if VarName = "DRXTKCAL"					then VarNameFull = "Daily energy intake, kcal";
	if VarName = "DENS_PROT"				then VarNameFull = "Energy contributed by protein, %";
	if VarName = "DENS_CARB"				then VarNameFull = "Energy contributed by carbohydrate, %";
	if VarName = "DENS_TFAT"				then VarNameFull = "Energy contributed by fat, %";
	if VarName = "PERS_AV_D_PRICE"			then VarNameFull = "Average food cost, $ per 1000 kcal";
	if VarName = "PERS_AV_D_GHGE"			then VarNameFull = "Average dietary greenhouse gas emission, kg CO2 per 1000 kcal";
	if VarName = "HEI2015_TOTAL_SCORE"		then VarNameFull = "HEI-2015 Score";
	if VarName = "LBDGLUSI"					then VarNameFull = "Fasting glucose, mmol/L";
	if VarName = "LBXGH"					then VarNameFull = "Glycohemoglobin, %";
	if VarName = "LBDGLTSI"					then VarNameFull = "Two hour glucose (OGTT), mmol/L";
	if VarName = "SBP"						then VarNameFull = "Systolic blood pressure, mmHg";
	if VarName = "DBP"						then VarNameFull = "Diastolic blood pressure, mmHg";
	if VarName = "LBXTR"					then VarNameFull = "Triglyceride, mg/dL";
	if VarName = "LBDLDL"					then VarNameFull = "LDL-cholesterol, mg/dL";
	if VarName = "HDL"						then VarNameFull = "HDL-cholesterol, mg/dL";
	if VarName = "LBXTC"					then VarNameFull = "Total cholesterol, mg/dL";
	if VarName = "LBXSUA"					then VarNameFull = "Uric acid, mg/dL";
	if VarName = "DRXTPROT"					then VarNameFull = "Protein, g/d";
	if VarName = "PROT_BW"					then VarNameFull = "Protein, g/kg";
	if VarName = "DENS_POULT_GRAM"			then VarNameFull = "Poultry meat/organ/cured meat, grams per 1000 kcal";
	if VarName = "DENS_IntactFruit"			then VarNameFull = "Intact fruits, cup equivalent per 1000 kcal";
	if VarName = "DENS_PF_LEGUMESOY"		then VarNameFull = "Legumes (beans, peas and soy), oz equivalent per 1000 kcal";
	if VarName = "DENS_PF_SEAFD"			then VarNameFull = "Seafood, oz. equivalent per 1000 kcal";
	if VarName = "DENS_POULTEGG"			then VarNameFull = "Poultry and eggs, oz. equivalent per 1000 kcal";
	if VarName = "DENS_PF_TOTALwithLegumes"	then VarNameFull = "Protein foods (including legumes), oz. equivalent per 1000 kcal";
	if VarName = "DENS_SEANUT"				then VarNameFull = "Seafood, nuts and seeds, oz. equivalent per 1000 kcal";
	
Run;

Proc surveymeans data=INDPERS;
	Strata SDMVSTRA;	Cluster SDMVPSU;	Weight WTDRD12;		ODS output Statistics = temp;
	var &vardisplay;
Run;
Proc export data=temp	outfile = "D:\gaolab\DGA2025-2030\foodgroup3.xlsx"	DBMS = xlsx	Replace;	Sheet = "Sheet1";					Run;

