/*********************************************
 * OPL 20.1.0.0 Model
 * Author: filip
 * Creation Date: 16/03/2022 at 16:33:32
 *********************************************/

{string} Factories = ...;
{string} Prod_Sizes = ...;

float Profit[Prod_Sizes] = ...;
float SalesForecast[Prod_Sizes] = ...;
float SpaceRequired[Prod_Sizes] = ...;
float SpaceAvailable[Factories] = ...;
float ProdCapacity[Factories] = ...;

dvar float+ x[Factories][Prod_Sizes];

maximize sum(j in Prod_Sizes) sum(i in Factories) Profit[j] * x[i][j];

subject to {
  forall(i in Factories) sum(j in Prod_Sizes) x[i][j] <= ProdCapacity[i];
  forall(i in Factories) sum(j in Prod_Sizes) x[i][j] * SpaceRequired[j] <= SpaceAvailable[i];
  forall(j in Prod_Sizes) sum(i in Factories) x[i][j] <= SalesForecast[j];
  forall(i in Factories) sum(j in Prod_Sizes) x[i][j]/ProdCapacity[i] == sum(k in Prod_Sizes) x["Factory1"][k]/ProdCapacity["Factory1"];
}
