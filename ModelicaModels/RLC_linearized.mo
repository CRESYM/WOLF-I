model linearized_model "RLC"
  parameter Integer n = 2 "number of states";
  parameter Integer m = 1 "number of inputs";
  parameter Integer p = 1 "number of outputs";

  parameter Real x0[n] = {0, 0};
  parameter Real u0[m] = {0};

  parameter Real A[n, n] =
	[0, 100;
	-10, -0.09999999999999999];

  parameter Real B[n, m] =
	[0;
	-10];

  parameter Real C[p, n] =
	[0, 1];

  parameter Real D[p, m] =
	[0];


  Real x[n](start=x0);
  input Real u[m](start=u0);
  output Real y[p];

  Real 'x_capacitor.v' = x[1];
  Real 'x_inductor.i' = x[2];
  Real 'u_u' = u[1];
  Real 'y_y' = y[1];
equation
  der(x) = A * x + B * u;
  y = C * x + D * u;
end linearized_model;
