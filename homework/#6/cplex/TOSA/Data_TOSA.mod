/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Nuno Miguel Marques
 * Creation Date: 04/05/2022 at 14:43:06
 *********************************************/

int NStops = ...;
range Stops=1..NStops;

int CFS_idx = ...;
int FFS_idx = ...;
float Cost[0..1] = ...;
int Charge[0..1] = ...;

float Battery_Capacity = ...;

float Dwell_Time[Stops] = ...;
float Energy_Consumption[Stops] = ...;

dvar float+ Capacity[i in Stops];
dvar float+ Time_Charging[i in Stops];
dvar float+ CFS_Charge[i in Stops];
dvar float+ FFS_Charge[i in Stops];

dvar boolean x[i in Stops][0..1];


minimize sum(i in Stops) (x[i][CFS_idx] * Cost[CFS_idx] + x[i][FFS_idx] * Cost[FFS_idx]);

subject to {
  forall(i in Stops) x[i][0] + x[i][1] <= 1; // CFS or FFS
  
  // Battery Restrictions
  forall(i in Stops) Capacity[i] - Energy_Consumption[i] >= 18;
  forall(i in Stops) Capacity[i] <= 30;
  Capacity[1] == Battery_Capacity; // First Stop

  // FFS Charging
  forall(i in Stops) FFS_Charge[i] <= 15;
  //forall(i in 2..NStops) (x[i][FFS_idx] == 1) => (FFS_Charge[i] == 30 - (Capacity[i - 1] - Energy_Consumption[i - 1])); //Force full charge on FFS
  forall(i in 2..NStops) (x[i][FFS_idx] == 1) => (FFS_Charge[i] == 15); 
  forall(i in Stops) (x[i][FFS_idx] == 0) => (FFS_Charge[i] == 0);
  // CFS Charging
  forall(i in Stops) Time_Charging[i] <= Dwell_Time[i];
  forall(i in Stops) (x[i][CFS_idx]==0) => (Time_Charging[i] == 0);
  forall(i in Stops) CFS_Charge[i] == Charge[CFS_idx] * Time_Charging[i];

  
  forall(i in 2..NStops) Capacity[i] <= (Capacity[i - 1] - Energy_Consumption[i - 1] + FFS_Charge[i] + CFS_Charge[i]);
}