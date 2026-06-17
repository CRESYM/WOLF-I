function mpc = bs_3bus
mpc.version = '2';
mpc.baseMVA = 100.0;

%% area data
%	area	refbus
mpc.areas = [
	1	 4;
];

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 2	 0.0	 0.0	 0.0	 0.0	 1	    1.01000	    20.2000	 20.00	 1	    1.10000	    0.90000;
	2	 3	 0.0	 0.0	 0.0	 0.0	 1	    1.01000	    -20.200	 20.00	 1	    1.10000	    0.90000;
	3	 1	 1400	 400.0	 0.0	 0.0	 1	    1.00000	    -0.0000	 20.00	 1	    1.10000	    0.90000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
    1	 700.0	 200.0	 300.0	 -300.0	 1.01	 100.0	 1	 800.0	 100.0;
	2	 700.0	 200.0	 300.0	 -300.0	 1.01	 100.0	 1	 800.0	 100.0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 3	 0.00000	 0.0166	 0.00000	 1e6	 1e6	 1e6	 1.0	 0.0	 1	 -30.0	 30.0;
	2	 3	 0.00000	 0.0166	 0.00000	 1e6	 1e6	 1e6	 1.0	 0.0	 1	 -30.0	 30.0;
];
