function mpc = bs_2area2gen
mpc.version = '2';
mpc.baseMVA = 100.0;

%% area data
%	area	refbus
mpc.areas = [
	1	 2;
];

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 2	 1767.0	 100.0	 0.0	 275.0	 1	    1.03000	    0.00000	 230.0	 1	    1.10000	    0.90000;
	3	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 230.0	 1	    1.10000	    0.90000;
	2	 3	 967.0	 100.0	 0.0	 275.0	 1	    1.03000	    0.00000	 230.0	 1	    1.10000	    0.90000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
    1	1388.0	 404.0	 500.0	 -300.0	 1.03	 100.0	 1	1600.0	 100.0;
	2	1388.0	 404.0	 500.0	 -300.0	 1.03	 100.0	 1	1600.0	 100.0;
];

%% generator cost data -> Not used in the PF formulation (I am not working with OPF)
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 0.0	 0.0	 0;
	2	 0.0	 0.0	 0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 3	 0.00700	 0.0700	 0.19250	 1e6	 1e6	 1e6	 1.0	 0.0	 1	 -30.0	 30.0;
	2	 3	 0.01500	 0.1500	 0.19250	 1e6	 1e6	 1e6	 1.0	 0.0	 1	 -30.0	 30.0;
];
