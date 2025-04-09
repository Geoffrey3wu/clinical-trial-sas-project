/**********************************************
 * Clinical Summary Project - SAS Script
 * Author: Geoffrey3wu
 * GitHub: https://github.com/Geoffrey3wu
 **********************************************/

%let path=/home/u62562597/UpWork;

/* Step 1: Import simulated clinical trial data */
proc import datafile="&path/clinical_trial_mock_data.csv"
	out=clinical_raw
    dbms=csv
    replace;
    getnames=yes;
run;

/* Exploratory data inspection */
proc contents data=clinical_raw; run;

/* Step 2: Data cleaning and processing */
data clinical_clean;
	length age_group $ 5;
	set clinical_raw;
	
    /* Normalize values */
    sex = propcase(sex);
    treatment_group = propcase(treatment_group);
    ae_type = propcase(ae_type);
    ae_severity = propcase(ae_severity);

    /* Handle patients without AE */
    if ae_type = "None" then do;
        ae_type = "";
        ae_severity = "";
    end;

    /* Create age group variables */
    if age < 30 then age_group = "<30";
    else if 30 <= age < 50 then age_group = "30-49";
    else if 50 <= age < 70 then age_group = "50-69";
    else age_group = "70+";
run;

proc freq data=clinical_clean;
    tables sex treatment_group age_group / missing;
run;

/* Step 3: Summary Statistics */
/* 3.1 Demographics Summary - Age summary by treatment group */
proc means data=clinical_clean n mean std min max;
    class treatment_group;
    var age;
    title "Demographic Summary by Treatment Group ";
run;

/* 3.2 Sex distribution by Treatment Group */
proc freq data=clinical_clean;
    tables treatment_group*sex / chisq;
    title "Sex Distribution by Treatment Group";
run;

/* 3.3 Age group Distribution */
proc freq data=clinical_clean;
    tables treatment_group*age_group / chisq;
    title "Age Group Distribution by Treatment Group";
run;

/* Step 4: Adverse Events Analysis  */
/* AE Type vs Treatment Group */
proc freq data=clinical_clean;
    tables ae_type*treatment_group / nocol norow nopercent;
    where ae_type ne "";
    title "Adverse Event Type by Treatment Group";
run;

/* AE Severity vs Treatment Group */
proc freq data=clinical_clean;
    tables ae_severity*treatment_group / nocol norow nopercent;
    where ae_severity ne "";
    title "Adverse Event Severity by Treatment Group";
run;

/* Step 5: Export and Display */

/* Export cleaned data */
proc export data=clinical_clean
    outfile="&path/clinical_cleaned.csv"
    dbms=csv
    replace;
run;

/* Display sample of cleaned dataset */
title "Clinical Trial Summary Report - Sample Data";
proc print data=clinical_clean (obs=10); 
run;



