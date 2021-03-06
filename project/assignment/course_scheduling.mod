/*********************************************
 * OPL 20.1.0.0 Model
 * Author: ineso
 * Creation Date: May 4, 2022 at 7:16:36 PM
 *********************************************/

{string} instructors =...;
{string} fullTime =...;
{string} courses =...;
 
int preferences[instructors][courses] =...;
int qualifications[instructors][courses] =...;
int courseLoad[instructors] =...;
int seniority[instructors] =...;
int nClasses[courses] =...;

dvar int+ n[instructors][courses];
dvar int+ penaltyCSO3;
dvar int+ penaltyLoad;

maximize sum(i in fullTime, j in courses) n[i][j] * (0.5*seniority[i] + preferences[i][j]) - (penaltyCSO3 + penaltyLoad)*5;

subject to {
	forall (i in fullTime) sum (j in courses) n[i][j] == courseLoad[i];
	forall (i in fullTime, j in courses) n[i][j] <= qualifications[i][j] * n[i][j];
	forall (j in courses) sum (i in instructors) n[i][j] == nClasses[j];
	penaltyCSO3 == sum (i in fullTime) (n[i]["CSO3"] >= 3);
	penaltyLoad == sum(i in fullTime) ((sum (j in courses) (n[i][j]>= 1)) >= 3);
}

execute
{
var f=new IloOplOutputFile("res.csv");
f.writeln(n);
f.close();
}