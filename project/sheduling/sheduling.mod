/*********************************************
 * OPL 20.1.0.0 Model
 * Author: ineso
 * Creation Date: May 5, 2022 at 5:14:54 PM
 *********************************************/

// For CSV Printing
string MWF_Slots[1..7] = ["9:10", "10:20", "11:30", "1:30", "2:40", "3:50", "5:25"]; 
string TuTh_Slots[1..7] = ["8:15", "9:50", "11:25", "1:00", "2:35", "4:10", "6:00"];  


 // Data begins
 
int n_slots = ...;
range slots = 1..n_slots;
{string} courses =...;

{string} instructors =...;
{string} fullTime = ...;

{string} instructors_MWF =...;
int preferences_MWF[instructors][slots] = ...;

{string} instructors_TuTh =...;
int preferences_TuTh[instructors][slots] = ...;

int n[instructors][courses] =...;
int seniority[instructors] =...;

{string} days = ...;
{string} mwf = ...;
{string} tuth = ...;

// Decision Variables

dvar boolean X[days][slots][instructors][courses];
dvar int+ penalty_instructors;
dvar int+ penalty_class1;
dvar int+ penalty_class2;
dvar int+ penalty_hours;

// Objective Function

maximize 
(sum (i in mwf, j in slots, k in instructors, l in courses) X[i][j][k][l] * (0.5*seniority[k] + preferences_MWF[k][j])) + // MWF Happiness
(sum (i in tuth, j in slots, k in instructors, l in courses) X[i][j][k][l] * (0.5*seniority[k] + preferences_TuTh[k][j])) 		// TuTh Happiness
- (penalty_instructors + penalty_class1 + penalty_hours) * 5 
- penalty_class2;											// Penalties

// Restrictions

subject to {
 	// Sheduled classes must match allocated classes for all faculty
 	forall(k in instructors, l in courses) (sum(i in days, j in slots) X[i][j][k][l] == n[k][l]);
  	
  	// Instructor can not teach more than one class at the same time
  	forall (i in days, j in slots, k in fullTime) (sum(l in courses) X[i][j][k][l]) <= 1;
  	
  	forall(i in mwf, j in slots, k in instructors_TuTh, l in courses) X[i][j][k][l] == 0;
  	forall(i in tuth, j in slots, k in instructors_MWF, l in courses) X[i][j][k][l] == 0;
  	
  	// At most three classes per time slot
  	forall(i in days, j in slots) (sum (k in instructors, l in courses) X[i][j][k][l]) <= 3;
  	
  	// Penalty for instructors teaching consecutive classes
  	penalty_instructors == sum(i in days, j in 1..n_slots-1, k in fullTime) (sum(l in courses)(X[i][j][k][l] + X[i][j + 1][k][l]) >= 2);
  	
  	// Penalty for classes of same course in the same timeslot
	penalty_class1 == sum (i in days, j in 1..n_slots, l in courses) (sum(k in instructors) (X[i][j][k][l]) >= 2); 
	
	penalty_class2 == sum (i in days, j in 1..n_slots) (sum(k in instructors, l in courses) (X[i][j][k][l]) >= 2); 
	
	//Penalty for classes starting before 9am or ending after 4pm
	penalty_hours == (sum (i in mwf, j in 6..7, k in instructors, l in courses) X[i][j][k][l]) + 
		(sum (i in tuth, j in 6..7, k in instructors, l in courses) X[i][j][k][l]) +
		(sum (i in tuth, k in instructors, l in courses) X[i][1][k][l]);
}  


// Print CSV
execute
{ 
	var f=new IloOplOutputFile("result.csv");
	f.writeln('Instructor, Class, Day, Hour');
	for (var i in mwf){
	 	for (var j in slots){
	   		for (var instructor in instructors_MWF){
	     		for (var course in courses){
	      			if (X[i][j][instructor][course] >= 1){
	        			f.writeln(instructor + ", " + course + ", " + i + ", " + MWF_Slots[j]);
	      			} 
	     		} 
	   		} 
	   		for (var course in courses){
	      		if (X[i][j]["contingent"][course] >= 1){
	        		f.writeln("contingent, " + course + ", " + i + ", " + MWF_Slots[j]);
	      		} 
   			}	    
	 	}  
	}
	
	for (var i in tuth){
	 	for (var j in slots){
	   		for (var instructor in instructors_TuTh){
	     		for (var course in courses){
	      			if (X[i][j][instructor][course] >= 1){
	        			f.writeln(instructor + ", " + course + ", " + i + ", " + TuTh_Slots[j]);
	      			} 
	     		} 
	   		} 
	   		for (var course in courses){
	      		if (X[i][j]["contingent"][course] >= 1){
	        		f.writeln("contingent, " + course + ", " + i + ", " + TuTh_Slots[j]);
	      		} 
	     	} 
	 	}  
	}
	f.close();
}