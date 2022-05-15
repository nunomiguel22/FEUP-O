/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Nuno Miguel Marques
 * Creation Date: 14/05/2022 at 16:26:22
 *********************************************/
// For CSV Printing
range MWF_Range = 1..3;
string MWF_Days[MWF_Range] = ["Monday", "Wednesday", "Friday"]; 
string MWF_Slots[1..7] = ["9:10", "10:20", "11:30", "1:30", "2:40", "3:50", "5:25"]; 

range TuTh_Range = 1..2;
string TuTh_Days[TuTh_Range] = ["Tuesday", "Thursday"]; 
string TuTh_Slots[1..7] = ["8:15", "9:50", "11:25", "1:00", "2:35", "4:10", "6:00"];  


 // Data begins
int n_slots = ...;
range slots = 1..n_slots;
{string} courses =...;

{string} instructors_MWF =...;
{string} fullTime_MWF =...;
int n_MWF[fullTime_MWF][courses] = ...;
int preferences_MWF[instructors_MWF][slots] = ...;

{string} instructors_TuTh =...;
{string} fullTime_TuTh =...;
int n_TuTh[fullTime_TuTh][courses] = ...;
int preferences_TuTh[instructors_TuTh][slots] = ...;


{string} days = ...;
{string} instructors = ...;
int n_contingent[courses] = ...;

// Decision Variables

dvar boolean TS_MWF[1..3][slots][instructors_MWF][courses];
dvar boolean TS_TuTh[1..2][slots][instructors_TuTh][courses];
dvar int+ penalty_MWF;
dvar int+ penalty_TuTh;
dvar int+ penalty_Class_MWF;
dvar int+ penalty_Class_TuTh;

// Objective Function

maximize (sum (i in 1..3, j in slots, k in instructors_MWF, l in courses) TS_MWF[i][j][k][l] * preferences_MWF[k][j]) + // MWF Happiness
(sum (i in 1..2, j in slots, k in instructors_TuTh, l in courses) TS_TuTh[i][j][k][l] * preferences_TuTh[k][j]) 		// TuTh Happiness
- (penalty_MWF + penalty_TuTh + penalty_Class_MWF + penalty_Class_TuTh) * 10;											// Penalties

// Restrictions

subject to {
 	// Sheduled classes must match allocated classes for MWF, TuTh and Contingent
 	forall(k in fullTime_MWF, l in courses) (sum(i in 1..3, j in slots)TS_MWF[i][j][k][l] == n_MWF[k][l]);
  	forall(k in fullTime_TuTh, l in courses) (sum(i in 1..2, j in slots)TS_TuTh[i][j][k][l] == n_TuTh[k][l]);
  	forall(l in courses)(sum(i in 1..3, j in slots)TS_MWF[i][j]["contingent"][l] +
  						sum(i in 1..2, j in slots)TS_TuTh[i][j]["contingent"][l]) == n_contingent[l];
  	
  	// Instructor can not teach more than one class at the same time
  	forall(i in 1..3, j in slots) forall(k in fullTime_MWF) (sum(l in courses) (TS_MWF[i][j][k][l])) <= 1;  
  	forall(i in 1..2, j in slots) forall(k in fullTime_TuTh) (sum(l in courses) (TS_TuTh[i][j][k][l])) <= 1;
  	
  	// At most three classes per time slot
  	forall(i in 1..3, j in slots) (sum (k in fullTime_MWF, l in courses) TS_MWF[i][j][k][l]) <= 3;
  	forall(i in 1..2, j in slots) (sum (k in fullTime_TuTh, l in courses) TS_TuTh[i][j][k][l]) <= 3; 
  	
  	// Penalty for instructors teaching consecutive classes
  	penalty_MWF == sum(i in 1..3, j in 1..n_slots-1, k in fullTime_MWF) (sum(l in courses)(TS_MWF[i][j][k][l] + TS_MWF[i][j + 1][k][l]) >= 2);
  	penalty_TuTh == sum(i in 1..2, j in 1..n_slots-1, k in fullTime_TuTh) (sum(l in courses)(TS_TuTh[i][j][k][l] + TS_TuTh[i][j + 1][k][l]) >= 2);
  	
  	// Penalty for classes of same course in the same timeslot
	penalty_Class_MWF == sum (i in 1..3, j in 1..n_slots) sum (l in courses) (sum(k in instructors_MWF) (TS_MWF[i][j][k][l]) >= 2); 
	penalty_Class_TuTh == sum (i in 1..2, j in 1..n_slots) sum (l in courses) (sum(k in instructors_TuTh) (TS_TuTh[i][j][k][l]) >= 2); 
}  


// Print CSV
execute
{ 
	var f=new IloOplOutputFile("result.csv");
	f.writeln('Instructor, Class, Day, Hour');
	for (var i in MWF_Range){
	 for (var j in slots){
	   for (var instructor in instructors_MWF){
	     for (var course in courses){
	      if (TS_MWF[i][j][instructor][course] >= 1){
	        f.writeln(instructor + ", " + course + ", " + MWF_Days[i] + ", " + MWF_Slots[j]);
	      } 
	     } 
	   } 
	 }  
	}
	
	for (var i in TuTh_Range){
	 for (var j in slots){
	   for (var instructor in instructors_TuTh){
	     for (var course in courses){
	      if (TS_TuTh[i][j][instructor][course] >= 1){
	        f.writeln(instructor + ", " + course + ", " + TuTh_Days[i] + ", " + TuTh_Slots[j]);
	      } 
	     } 
	   } 
	 }  
	}
	f.close();
}