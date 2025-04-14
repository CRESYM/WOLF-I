model RLC
  input Real u "Input Voltage"; 
  output Real y "Output Current"; 
  Modelica.Electrical.Analog.Basic.Resistor resistor(R = 0.01)  annotation(
    Placement(transformation(origin = {-8, 52}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(C = 0.01)  annotation(
    Placement(transformation(origin = {64, 52}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Inductor inductor(L = 0.1)  annotation(
    Placement(transformation(origin = {28, 52}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-52, 26}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground1 annotation(
    Placement(transformation(origin = {84, 26}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation(
    Placement(transformation(origin = {-38, 52}, extent = {{-10, -10}, {10, 10}})));
equation
  signalVoltage.v = u; 
  connect(resistor.n, inductor.p) annotation(
    Line(points = {{2, 52}, {18, 52}}, color = {0, 0, 255}));
  connect(inductor.n, capacitor.p) annotation(
    Line(points = {{38, 52}, {54, 52}}, color = {0, 0, 255}));
  connect(capacitor.n, ground1.p) annotation(
    Line(points = {{74, 52}, {84, 52}, {84, 36}}, color = {0, 0, 255}));
  connect(signalVoltage.n, resistor.p) annotation(
    Line(points = {{-28, 52}, {-18, 52}}, color = {0, 0, 255}));
  connect(signalVoltage.p, ground.p) annotation(
    Line(points = {{-48, 52}, {-52, 52}, {-52, 36}}, color = {0, 0, 255}));
  annotation(
    uses(Modelica(version = "4.0.0")));
  y = inductor.i; 
end RLC;
