*import DATAField;
Proc import datafile = "D:\nhanes\data\DATAFIELD\dataFIELDv1.0.xlsx"
	out = DATAfield
	dbms = xlsx replace;
	sheet = "FCID linkages";
Run;

Proc import datafile = "D:\nhanes\data\DATAFIELD\dataFIELDv1.0.xlsx"
	out = DATAfield2
	dbms = xlsx replace;
	sheet = "Additional FCID";
Run;

Data DATAfield;		set DATAfield;	if A >= 0;	Run;
Data DATAfield2;	set DATAfield2;	if A >= 0;	Run;

Proc sort data=DATAfield;	by A;	Run;
Proc sort data=DATAfield2;	by A;	Run;

Data DATAfield;
	merge DATAfield DATAfield2;
	by A;
Run;

Data DATAfield;
	set DATAfield;
	rename 	A = FCIDCODE						B = FCIDDESC						C = WGHTBASE						D = COMMENTS
			E = NUMCASES						UTILIZED_IMPACT_FACTORS = UIFCEDMJ	G = UIFGHGES						H = WTCVFACT
			I = CVFCTSRC						VAR10 = FMPRGATE					PROXY_DEFINITION = PRXYDEFN			ENERGY_USE_MJ_kg = EUMJPRXY
			M = EUMJNODP						N = EUMJNAVG						O = EUMJSTDV						VAR16 = GHGEPRXY
			Q = GHGENODP						R = GHGENAVG						S = GHGESTDV						additional_processing_inputs_for = ADPRCIN1
			U = ADPRCIN2;
	drop V;
	drop VARIANCE_CALCULATIONS X Y Z AA AB AC AD AE AF;
Run;

Data Datafield;
	set Datafield;
	Label FCIDCODE = "FCID Code";
	Label FCIDDESC = "FCID Description";
	Label WGHTBASE = "Weight Basis, as defined by FCID";
	Label COMMENTS = "Comments (from FCID)";
	Label NUMCASES = "Number of times specific commodity appears in FCID recipe files";
	Label UIFCEDMJ = "Utilized Impact Factors: CED (MJ/kg)";
	Label UIFGHGES = "Utilized Impact Factors: GHG (CO2eq/kg)";
	Label WTCVFACT = "Weight Conversion Factor";
	Label CVFCTSRC = "Weight Conversion Factor Source";
	Label FMPRGATE = "Farm or Processor Gate (farm gate = 1, processor gate = 2)";
	Label PRXYDEFN = "Proxy Definition";
	Label EUMJPRXY = "Energy Use MJ/kg, Proxy?";
	Label EUMJNODP = "Energy Use MJ/kg, Number of datapoints";
	Label EUMJNAVG = "Energy Use MJ/kg, N-average";
	Label EUMJSTDV = "Energy Use MJ/kg, Standard Deviation";
	Label GHGEPRXY = "GHG Emissions (kg CO2eq/kg), Proxy?";
	Label GHGENODP = "GHG Emissions (kg CO2eq/kg), Number of datapoints";
	Label GHGENAVG = "GHG Emissions (kg CO2eq/kg), N-average";
	Label GHGESTDV = "GHG Emissions (kg CO2eq/kg), Standard Deviation";
	Label ADPRCIN1 = "Additional Processing Inputs for Select Foods: Energy(MJ)";
	Label ADPRCIN2 = "Additional Processing INputs for Select Foods: GHG(kgCO2eq)";

	FCIDCODE_num = input(FCIDCODE,12.);
	rename FCIDCODE = FCIDCODE_char;
	rename FCIDCODE_num = FCIDCODE;
	if FCIDCODE >= 0;
Run;

Data DataFIELD;
	set DataFIELD;
	drop FCIDCODE_char;
Run;

Proc datasets;	delete Datafield2;	Run;	Quit;

Data DataFIELD_GHGE;		set DataFIELD;		keep FCIDCODE UIFGHGES;		Run;
Proc datasets;		delete DataFIELD;	Run; Quit;
*Calculate GHGE/100g Food Code;

*Obtain FCID database (original and manually added), merge;
Proc import datafile = "D:\nhanes\data\FCIDupdated\FCID9918v2.xlsx"	out = FCID9918newrecipe	DBMS = xlsx	replace;	sheet = "NewRecipe";			Run;
Proc import datafile = "D:\nhanes\data\FCIDupdated\FCID9918v2.xlsx"	out = FCID0510oldrecipe DBMS = xlsx replace;	sheet = "OldRecipe";			Run;
Proc import datafile = "D:\CF\AnalysisV3\Substitution_database.xlsx"			out = FCID_substitution	DBMS = xlsx replace;	sheet = "FCID";					Run;
Data FCID9918newrecipe;		set FCID9918newrecipe;	drop total_weight Proxy;		Run;
Data FCID0510oldrecipe;		set FCID0510oldrecipe;	drop total_weight;				Run;
Data FCID_Substitution;		set FCID_substitution;
	rename New_FDCD = food_code;					rename New_mod_code = mod_code;					rename New_desc = food_desc;
	rename new_ingredient_num = ingredient_num;		rename new_FCID_Code = FCID_Code;				rename new_commodity_weight = commodity_weight;
	rename new_commodity_CG_subgroup = CG_subgroup;	rename new_FCID_DESC = FCID_Desc;			
	drop proxy_FCID_desc proxy_food_code proxy_mod_code proxy_ingredient_num proxy_fcid_code proxy_commodity_weight proxy_food_desc proxy_CG_subgroup proxy_FCID_Desc_1 Proxy_sum_weight Note;
Run;
Proc sort data=FCID9918newrecipe;	by food_code mod_code ingredient_num;			Run;	*33096 observations;
Proc sort data=FCID0510oldrecipe;	by food_code mod_code ingredient_num;			Run;	*130023 observations;
Proc sort data=FCID_substitution;	by food_code mod_code ingredient_num;			Run;	*4377 observations;
Data FCID9918;	merge FCID0510oldrecipe FCID9918newrecipe FCID_substitution;	by food_code mod_code;	Run;	*167496 observations;
Proc sort data=FCID9918;	by food_code mod_code ingredient_num;	Run;
Data foodcode;
	set FCID9918;
	keep food_code mod_code food_desc;
Run;
Proc sort data=foodcode nodupkey;	by food_code mod_code;	Run;
Proc export data=foodcode	outfile = "D:\nhanes\FoodCode.xlsx"	DBMS = xlsx	Replace;	Sheet = "FDCD_from_FCID";	Run;
Data test;	set FCID9918;	if commodity_weight = .;	Run;	*Make sure there is no empty observations in the dataset;
Data FDCD_weight;
	set FCID9918;
	by food_code mod_code;
	retain sum_weight 0;
	if first.mod_code then sum_weight = 0;
	sum_weight = sum_weight + commodity_weight;
	if last.mod_code;
	keep Food_code mod_code sum_weight;
Run;
Proc sort data=FDCD_weight nodupkey;	by food_code mod_code;	Run;
Data FCID9918;
	merge FCID9918 FDCD_weight;
	by food_code mod_code;
	drop J K;
Run;

*For each food commodity, a DGA subgroup was manually assigned, animal-based or plant-based was also assigned. Obtain this information;
Proc import datafile = "D:\gaolab\DGA2025-2030\GHGEv2.xlsx"	out = FCID9918foodgroup	DBMS = xlsx replace;	sheet = "Sheet1";	Run;
Proc sort data=FCID9918foodgroup;	by fcid_code;	Run;
Data FCID9918foodgroup;	set FCID9918foodgroup;	keep fcid_code food_group_DGA;	Run;
Proc sort data=FCID9918;	by fcid_code;	Run;
Data FCID9918;	merge FCID9918 (in = a) FCID9918foodgroup; by fcid_code;	if a;	Run;
Data FCID9918;	set FCID9918;	rename fcid_code = FCIDCODE;	Run;

*Add GHGE information to FCID database;
Proc sort data=DataFIELD_GHGE;	by FCIDCODE;	Run;
Proc sort data=FCID9918;		by FCIDCODE;	Run;
Proc contents data=DataFIELD_GHGE;	Run;
Proc contents data=FCID9918;		Run;
Data FCID_9918_GHGE;
	merge FCID9918 (in = a) DataFIELD_GHGE;
	by FCIDCODE;
	if a;
Run;
*Make sure all food commodities have GHGE info;
Data test;
	merge FCID9918 (in = a) DataFIELD_GHGE (in = b);
	by FCIDCODE;
	if a;
	if b = 0;
Run;

*Calculate GHGE for each ingredient;
Proc sort data=FCID_9918_GHGE;
	by food_code mod_code ingredient_num;
Run;
Data FCID_9918_GHGE;
	set FCID_9918_GHGE;
	if commodity_weight = . then commodity_weight = 0;
	if (FCIDCODE ne .) and (UIFGHGES ne .) then INGREDIENT_GHGE = UIFGHGES / 1000 * commodity_weight;
		else INGREDIENT_GHGE = 0;
Run;	
Data FDCD_9918_GHGE;
	set FCID_9918_GHGE;
	by food_code mod_code;
	retain 	sum_weight 0 		sum_GHGE 0
			sum_GHGE_DGA_1 0		sum_GHGE_DGA_2 0		sum_GHGE_DGA_3 0		sum_GHGE_DGA_4 0		
			sum_GHGE_DGA_5 0		sum_GHGE_DGA_6 0		sum_GHGE_DGA_7 0		sum_GHGE_DGA_8 0		
			sum_GHGE_DGA_9 0		sum_GHGE_DGA_10 0		sum_GHGE_DGA_11 0		sum_GHGE_DGA_12 0	
			sum_GHGE_DGA_13 0		sum_GHGE_DGA_14 0		sum_GHGE_DGA_15 0		sum_GHGE_DGA_16 0	
			sum_GHGE_DGA_17 0		sum_GHGE_DGA_18 0
			sum_gram_DGA_1 0		sum_gram_DGA_2 0		sum_gram_DGA_3 0		sum_gram_DGA_4 0		
			sum_gram_DGA_5 0		sum_gram_DGA_6 0		sum_gram_DGA_7 0		sum_gram_DGA_8 0		
			sum_gram_DGA_9 0		sum_gram_DGA_10 0		sum_gram_DGA_11 0		sum_gram_DGA_12 0	
			sum_gram_DGA_13 0		sum_gram_DGA_14 0		sum_gram_DGA_15 0		sum_gram_DGA_16 0	
			sum_gram_DGA_17 0		sum_gram_DGA_18 0;
	if first.mod_code then do;
		sum_weight = 0;
		sum_GHGE = 0;
		sum_GHGE_DGA_1 = 0;		sum_GHGE_DGA_2 = 0;		sum_GHGE_DGA_3 = 0;		sum_GHGE_DGA_4 = 0;		
		sum_GHGE_DGA_5 = 0;		sum_GHGE_DGA_6 = 0;		sum_GHGE_DGA_7 = 0;		sum_GHGE_DGA_8 = 0;		
		sum_GHGE_DGA_9 = 0;		sum_GHGE_DGA_10 = 0;	sum_GHGE_DGA_11 = 0;	sum_GHGE_DGA_12 = 0;	
		sum_GHGE_DGA_13 = 0;	sum_GHGE_DGA_14 = 0;	sum_GHGE_DGA_15 = 0;	sum_GHGE_DGA_16 = 0;	
		sum_GHGE_DGA_17 = 0;	sum_GHGE_DGA_18 = 0;
		sum_gram_DGA_1 = 0;		sum_gram_DGA_2 = 0;		sum_gram_DGA_3 = 0;		sum_gram_DGA_4 = 0;		
		sum_gram_DGA_5 = 0;		sum_gram_DGA_6 = 0;		sum_gram_DGA_7 = 0;		sum_gram_DGA_8 = 0;		
		sum_gram_DGA_9 = 0;		sum_gram_DGA_10 = 0;	sum_gram_DGA_11 = 0;	sum_gram_DGA_12 = 0;	
		sum_gram_DGA_13 = 0;	sum_gram_DGA_14 = 0;	sum_gram_DGA_15 = 0;	sum_gram_DGA_16 = 0;	
		sum_gram_DGA_17 = 0;	sum_gram_DGA_18 = 0;
	end;
	
	sum_weight = sum_weight + commodity_weight;
	sum_GHGE = sum_GHGE + INGREDIENT_GHGE;
	
	*Accumulate GHG emissions and consumption by DGA group;
	if Food_Group_DGA = 1	then do; sum_GHGE_DGA_1 = sum_GHGE_DGA_1 + INGREDIENT_GHGE; sum_gram_DGA_1 = sum_gram_DGA_1 + commodity_weight; end;
	if Food_Group_DGA = 2	then do; sum_GHGE_DGA_2 = sum_GHGE_DGA_2 + INGREDIENT_GHGE; sum_gram_DGA_2 = sum_gram_DGA_2 + commodity_weight; end;
	if Food_Group_DGA = 3	then do; sum_GHGE_DGA_3 = sum_GHGE_DGA_3 + INGREDIENT_GHGE; sum_gram_DGA_3 = sum_gram_DGA_3 + commodity_weight; end;
	if Food_Group_DGA = 4	then do; sum_GHGE_DGA_4 = sum_GHGE_DGA_4 + INGREDIENT_GHGE; sum_gram_DGA_4 = sum_gram_DGA_4 + commodity_weight; end;
	if Food_Group_DGA = 5	then do; sum_GHGE_DGA_5 = sum_GHGE_DGA_5 + INGREDIENT_GHGE; sum_gram_DGA_5 = sum_gram_DGA_5 + commodity_weight; end;
	if Food_Group_DGA = 6	then do; sum_GHGE_DGA_6 = sum_GHGE_DGA_6 + INGREDIENT_GHGE; sum_gram_DGA_6 = sum_gram_DGA_6 + commodity_weight; end;
	if Food_Group_DGA = 7	then do; sum_GHGE_DGA_7 = sum_GHGE_DGA_7 + INGREDIENT_GHGE; sum_gram_DGA_7 = sum_gram_DGA_7 + commodity_weight; end;
	if Food_Group_DGA = 8	then do; sum_GHGE_DGA_8 = sum_GHGE_DGA_8 + INGREDIENT_GHGE; sum_gram_DGA_8 = sum_gram_DGA_8 + commodity_weight; end;
	if Food_Group_DGA = 9	then do; sum_GHGE_DGA_9 = sum_GHGE_DGA_9 + INGREDIENT_GHGE; sum_gram_DGA_9 = sum_gram_DGA_9 + commodity_weight; end;
	if Food_Group_DGA = 10	then do; sum_GHGE_DGA_10 = sum_GHGE_DGA_10 + INGREDIENT_GHGE; sum_gram_DGA_10 = sum_gram_DGA_10 + commodity_weight; end;
	if Food_Group_DGA = 11	then do; sum_GHGE_DGA_11 = sum_GHGE_DGA_11 + INGREDIENT_GHGE; sum_gram_DGA_11 = sum_gram_DGA_11 + commodity_weight; end;
	if Food_Group_DGA = 12	then do; sum_GHGE_DGA_12 = sum_GHGE_DGA_12 + INGREDIENT_GHGE; sum_gram_DGA_12 = sum_gram_DGA_12 + commodity_weight; end;
	if Food_Group_DGA = 13	then do; sum_GHGE_DGA_13 = sum_GHGE_DGA_13 + INGREDIENT_GHGE; sum_gram_DGA_13 = sum_gram_DGA_13 + commodity_weight; end;
	if Food_Group_DGA = 14	then do; sum_GHGE_DGA_14 = sum_GHGE_DGA_14 + INGREDIENT_GHGE; sum_gram_DGA_14 = sum_gram_DGA_14 + commodity_weight; end;
	if Food_Group_DGA = 15	then do; sum_GHGE_DGA_15 = sum_GHGE_DGA_15 + INGREDIENT_GHGE; sum_gram_DGA_15 = sum_gram_DGA_15 + commodity_weight; end;
	if Food_Group_DGA = 16	then do; sum_GHGE_DGA_16 = sum_GHGE_DGA_16 + INGREDIENT_GHGE; sum_gram_DGA_16 = sum_gram_DGA_16 + commodity_weight; end;
	if Food_Group_DGA = 17	then do; sum_GHGE_DGA_17 = sum_GHGE_DGA_17 + INGREDIENT_GHGE; sum_gram_DGA_17 = sum_gram_DGA_17 + commodity_weight; end;
	if Food_Group_DGA = 18	then do; sum_GHGE_DGA_18 = sum_GHGE_DGA_18 + INGREDIENT_GHGE; sum_gram_DGA_18 = sum_gram_DGA_18 + commodity_weight; end;
	
	if last.mod_code;
	Drop ingredient_num fcidcode commodity_weight food_desc cg_subgroup fcid_desc Food_Group_DGA uifghges ingredient_ghge;
Run;
*Calculate the GHG emissions per 100 grams of food and the contribution of each subgroup;
Data FDCD_9918_GHGE;
	set FDCD_9918_GHGE;
	
	*If the total weight is 0, all indicators are set to 0;
	if sum_weight = 0 then do;
		FDCD_GHGE = 0;
		FDCD_GHGE_DGA_1 = 0;	FDCD_GHGE_DGA_2 = 0;	FDCD_GHGE_DGA_3 = 0;	FDCD_GHGE_DGA_4 = 0;	
		FDCD_GHGE_DGA_5 = 0;	FDCD_GHGE_DGA_6 = 0;	FDCD_GHGE_DGA_7 = 0;	FDCD_GHGE_DGA_8 = 0;	
		FDCD_GHGE_DGA_9 = 0;	FDCD_GHGE_DGA_10 = 0;	FDCD_GHGE_DGA_11 = 0;	FDCD_GHGE_DGA_12 = 0;
		FDCD_GHGE_DGA_13 = 0;	FDCD_GHGE_DGA_14 = 0;	FDCD_GHGE_DGA_15 = 0;	FDCD_GHGE_DGA_16 = 0;
		FDCD_GHGE_DGA_17 = 0;	FDCD_GHGE_DGA_18 = 0;
		FDCD_GRAM_DGA_1 = 0;	FDCD_GRAM_DGA_2 = 0;	FDCD_GRAM_DGA_3 = 0;	FDCD_GRAM_DGA_4 = 0;	
		FDCD_GRAM_DGA_5 = 0;	FDCD_GRAM_DGA_6 = 0;	FDCD_GRAM_DGA_7 = 0;	FDCD_GRAM_DGA_8 = 0;	
		FDCD_GRAM_DGA_9 = 0;	FDCD_GRAM_DGA_10 = 0;	FDCD_GRAM_DGA_11 = 0;	FDCD_GRAM_DGA_12 = 0;
		FDCD_GRAM_DGA_13 = 0;	FDCD_GRAM_DGA_14 = 0;	FDCD_GRAM_DGA_15 = 0;	FDCD_GRAM_DGA_16 = 0;
		FDCD_GRAM_DGA_17 = 0;	FDCD_GRAM_DGA_18 = 0;
	end;
	else do;
		*total GHGE/100g;
		FDCD_GHGE = sum_GHGE / sum_weight * 100;
		
		*GHGE contribution per 100 grams for each DGA group;
		FDCD_GHGE_DGA_1 = sum_GHGE_DGA_1 / sum_weight * 100;
		FDCD_GHGE_DGA_2 = sum_GHGE_DGA_2 / sum_weight * 100;
		FDCD_GHGE_DGA_3 = sum_GHGE_DGA_3 / sum_weight * 100;
		FDCD_GHGE_DGA_4 = sum_GHGE_DGA_4 / sum_weight * 100;
		FDCD_GHGE_DGA_5 = sum_GHGE_DGA_5 / sum_weight * 100;
		FDCD_GHGE_DGA_6 = sum_GHGE_DGA_6 / sum_weight * 100;
		FDCD_GHGE_DGA_7 = sum_GHGE_DGA_7 / sum_weight * 100;
		FDCD_GHGE_DGA_8 = sum_GHGE_DGA_8 / sum_weight * 100;
		FDCD_GHGE_DGA_9 = sum_GHGE_DGA_9 / sum_weight * 100;
		FDCD_GHGE_DGA_10 = sum_GHGE_DGA_10 / sum_weight * 100;
		FDCD_GHGE_DGA_11 = sum_GHGE_DGA_11 / sum_weight * 100;
		FDCD_GHGE_DGA_12 = sum_GHGE_DGA_12 / sum_weight * 100;
		FDCD_GHGE_DGA_13 = sum_GHGE_DGA_13 / sum_weight * 100;
		FDCD_GHGE_DGA_14 = sum_GHGE_DGA_14 / sum_weight * 100;
		FDCD_GHGE_DGA_15 = sum_GHGE_DGA_15 / sum_weight * 100;
		FDCD_GHGE_DGA_16 = sum_GHGE_DGA_16 / sum_weight * 100;
		FDCD_GHGE_DGA_17 = sum_GHGE_DGA_17 / sum_weight * 100;
		FDCD_GHGE_DGA_18 = sum_GHGE_DGA_18 / sum_weight * 100;
		
		*consumption per 100 grams for each DGA group;
		FDCD_GRAM_DGA_1 = sum_gram_DGA_1 / sum_weight * 100;
		FDCD_GRAM_DGA_2 = sum_gram_DGA_2 / sum_weight * 100;
		FDCD_GRAM_DGA_3 = sum_gram_DGA_3 / sum_weight * 100;
		FDCD_GRAM_DGA_4 = sum_gram_DGA_4 / sum_weight * 100;
		FDCD_GRAM_DGA_5 = sum_gram_DGA_5 / sum_weight * 100;
		FDCD_GRAM_DGA_6 = sum_gram_DGA_6 / sum_weight * 100;
		FDCD_GRAM_DGA_7 = sum_gram_DGA_7 / sum_weight * 100;
		FDCD_GRAM_DGA_8 = sum_gram_DGA_8 / sum_weight * 100;
		FDCD_GRAM_DGA_9 = sum_gram_DGA_9 / sum_weight * 100;
		FDCD_GRAM_DGA_10 = sum_gram_DGA_10 / sum_weight * 100;
		FDCD_GRAM_DGA_11 = sum_gram_DGA_11 / sum_weight * 100;
		FDCD_GRAM_DGA_12 = sum_gram_DGA_12 / sum_weight * 100;
		FDCD_GRAM_DGA_13 = sum_gram_DGA_13 / sum_weight * 100;
		FDCD_GRAM_DGA_14 = sum_gram_DGA_14 / sum_weight * 100;
		FDCD_GRAM_DGA_15 = sum_gram_DGA_15 / sum_weight * 100;
		FDCD_GRAM_DGA_16 = sum_gram_DGA_16 / sum_weight * 100;
		FDCD_GRAM_DGA_17 = sum_gram_DGA_17 / sum_weight * 100;
		FDCD_GRAM_DGA_18 = sum_gram_DGA_18 / sum_weight * 100;
	end;
	
	*rename;
	Rename food_code = DR1IFDCD mod_code = DR1MC;
	
	*delete;
	Drop sum_:;
Run;

*add lable;
Data FDCD_9918_GHGE;
	set FDCD_9918_GHGE;
	Label FDCD_GHGE = "GHGE per 100g Food Code (kg CO2eq/100g)";
	Label FDCD_GHGE_DGA_1 = "GHGE from Fruit per 100g Food Code";
	Label FDCD_GHGE_DGA_2 = "GHGE from Dark green vegetables per 100g Food Code";
	Label FDCD_GHGE_DGA_3 = "GHGE from Red and orange vegetables per 100g Food Code";
	Label FDCD_GHGE_DGA_4 = "GHGE from Starchy vegetables per 100g Food Code";
	Label FDCD_GHGE_DGA_5 = "GHGE from Beans and peas per 100g Food Code";
	Label FDCD_GHGE_DGA_6 = "GHGE from Other vegetables per 100g Food Code";
	Label FDCD_GHGE_DGA_7 = "GHGE from Whole grains per 100g Food Code";
	Label FDCD_GHGE_DGA_8 = "GHGE from Refined grains per 100g Food Code";
	Label FDCD_GHGE_DGA_9 = "GHGE from Meat per 100g Food Code";
	Label FDCD_GHGE_DGA_10 = "GHGE from Poultry per 100g Food Code";
	Label FDCD_GHGE_DGA_11 = "GHGE from Seafood per 100g Food Code";
	Label FDCD_GHGE_DGA_12 = "GHGE from Eggs per 100g Food Code";
	Label FDCD_GHGE_DGA_13 = "GHGE from Soy products per 100g Food Code";
	Label FDCD_GHGE_DGA_14 = "GHGE from Nuts and seeds per 100g Food Code";
	Label FDCD_GHGE_DGA_15 = "GHGE from Dairy per 100g Food Code";
	Label FDCD_GHGE_DGA_16 = "GHGE from Oils per 100g Food Code";
	Label FDCD_GHGE_DGA_17 = "GHGE from Solid fats per 100g Food Code";
	Label FDCD_GHGE_DGA_18 = "GHGE from Other/Unclassified per 100g Food Code";
	
	Label FDCD_GRAM_DGA_1 = "Grams of Fruit per 100g Food Code";
	Label FDCD_GRAM_DGA_2 = "Grams of Dark green vegetables per 100g Food Code";
	Label FDCD_GRAM_DGA_3 = "Grams of Red and orange vegetables per 100g Food Code";
	Label FDCD_GRAM_DGA_4 = "Grams of Starchy vegetables per 100g Food Code";
	Label FDCD_GRAM_DGA_5 = "Grams of Beans and peas per 100g Food Code";
	Label FDCD_GRAM_DGA_6 = "Grams of Other vegetables per 100g Food Code";
	Label FDCD_GRAM_DGA_7 = "Grams of Whole grains per 100g Food Code";
	Label FDCD_GRAM_DGA_8 = "Grams of Refined grains per 100g Food Code";
	Label FDCD_GRAM_DGA_9 = "Grams of Meat per 100g Food Code";
	Label FDCD_GRAM_DGA_10 = "Grams of Poultry per 100g Food Code";
	Label FDCD_GRAM_DGA_11 = "Grams of Seafood per 100g Food Code";
	Label FDCD_GRAM_DGA_12 = "Grams of Eggs per 100g Food Code";
	Label FDCD_GRAM_DGA_13 = "Grams of Soy products per 100g Food Code";
	Label FDCD_GRAM_DGA_14 = "Grams of Nuts and seeds per 100g Food Code";
	Label FDCD_GRAM_DGA_15 = "Grams of Dairy per 100g Food Code";
	Label FDCD_GRAM_DGA_16 = "Grams of Oils per 100g Food Code";
	Label FDCD_GRAM_DGA_17 = "Grams of Solid fats per 100g Food Code";
	Label FDCD_GRAM_DGA_18 = "Grams of Other/Unclassified per 100g Food Code";
Run;
Proc datasets;		delete FCID0510oldrecipe FCID9918 FCID9918foodgroup FCID9918newrecipe FCID_9918_GHGE DataFIELD_GHGE FCID_substitution FDCD_weight foodcode test;	Run;	Quit;
