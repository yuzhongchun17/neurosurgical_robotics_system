function cut_depths=notch_profile8(strain_limit,kappa,kap_max,j_kap_max,phi,tube_geo,n,E,the_options)
%% Find ybars, gs, and EIs of nominal notch thickness at highest curvature point
% This constraint simply finds the ybars for the notches with the highest
% curvature given our inital nominal backbone thickness (w).
% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
g_relation=the_options{2};
cross_sec=the_options{1};

options=optimoptions('fsolve','Algorithm','levenberg-marquardt','MaxFunctionEvaluations',90*10^3,'MaxIterations',100000,'FunctionTolerance',1e-20,'StepTolerance',1e-30);%,'Display','iter');

% in the other script, it's tubes=[do,to,di,ti];
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);
% Note: do is the outer tube outer raduis/width in circles/square and the
% outer side length for hexagons. di is the inner tube outer outer 
% raduis/width/side length.

% These hold true for circles and squares
r_out_o=do/2;      % outer radius of outer tube
r_in_o=r_out_o-to;   % inner radius of outer tube
r_out_i=di/2;      % outer raduis of inner tube
r_in_i=r_out_i-ti;   % inner radius of inner tube

% These hold true for hexagons
ao=do-(2/sqrt(3))*to;	% inner wall side length of outer tube
ai=di-(2/sqrt(3))*ti;	% inner wall side length of inner tube

% Angle of cuts
phi_o=phi(1,:);
phi_i=phi(2,:);

%% Find properties for benchmark notch pair

% Set the cut depths based on max strain (tensile or compressive)
tens_strain_max_o=@(go)((1e6*(strain_limit-strain_calc_out2(kap_max,go,phi_o(j_kap_max),do,to,the_options)))^2);
tens_strain_max_i=@(gi)((1e6*(strain_limit-strain_calc_in2(kap_max,gi,phi_i(j_kap_max),di,ti,the_options)))^2);
comp_strain_max_o=@(go)((1e6*(strain_limit-strain_calc_in2(kap_max,go,phi_o(j_kap_max),do,to,the_options)))^2);
comp_strain_max_i=@(gi)((1e6*(strain_limit-strain_calc_out2(kap_max,gi,phi_i(j_kap_max),di,ti,the_options)))^2);

% Begin by assuming the max strain will be tensile and happen on the outer tube
go(j_kap_max)=fsolve(tens_strain_max_o,0.75*do);

% Find gi(j_kap_max) based off of your G_relation eqn
gi(j_kap_max)=calc_gi(go(j_kap_max),tube_geo,the_options);
% max_bench_strain=strain_limit; new_max_strain=1.1*strain_limit;	%just to get started.

tens_strain_o=strain_calc_out2(kap_max,go(j_kap_max),phi_o(j_kap_max),do,to,the_options);
tens_strain_i=strain_calc_in2(kap_max,gi(j_kap_max),phi_i(j_kap_max),di,ti,the_options);
comp_strain_o=strain_calc_in2(kap_max,go(j_kap_max),phi_o(j_kap_max),do,to,the_options);
comp_strain_i=strain_calc_out2(kap_max,gi(j_kap_max),phi_i(j_kap_max),di,ti,the_options);
bench_strain=[tens_strain_o, tens_strain_i, comp_strain_o, comp_strain_i];
[max_bench_strain(1), max_flag(1)]=max(bench_strain);	% find the index of the max strain here
m=1;

% If the curve is so gentle that we're barely removing material,
% arbitrarily make the cuts deeper so that we don't end up with a pattern
% that results in no inner tube cuts.
% if go(j_kap_max)<do/2
% 	strain_limit=0.9*strain_limit;
% end

% Check the strain (absolute values)
while round(max_bench_strain(m),6)>round(strain_limit,6) && m<10   % while we're over our limit (up to 6 decimal points)
	m=m+1;	
	
	% See which part had highest strain on prev. design
	if max_flag(m-1)==1
		go(j_kap_max)=fsolve(tens_strain_max_o,0.75*do,options); % max strain is compressive on the outer tube
		gi(j_kap_max)=calc_gi(go(j_kap_max),tube_geo,the_options);
	elseif max_flag(m-1)==2
		gi(j_kap_max)=fsolve(tens_strain_max_i,0.75*di,options); % max strain is tensile on the inner tube
		go(j_kap_max)=calc_go(gi(j_kap_max),tube_geo,the_options);
	elseif max_flag(m-1)==3
		go(j_kap_max)=fsolve(comp_strain_max_o,0.75*do,options); % max strain is compressive on the outer tube
		gi(j_kap_max)=calc_gi(go(j_kap_max),tube_geo,the_options);
	elseif max_flag(m-1)==4	
		gi(j_kap_max)=fsolve(comp_strain_max_i,0.75*di,options); % max strain is compressive on the inner tube
		go(j_kap_max)=calc_go(gi(j_kap_max),tube_geo,the_options);
	end
	
	% Calculate strains of new design
	tens_strain_o=strain_calc_out2(kap_max,go(j_kap_max),phi_o(j_kap_max),do,to,the_options);
	tens_strain_i=strain_calc_in2(kap_max,gi(j_kap_max),phi_i(j_kap_max),di,ti,the_options);
	comp_strain_o=strain_calc_in2(kap_max,go(j_kap_max),phi_o(j_kap_max),do,to,the_options);
	comp_strain_i=strain_calc_out2(kap_max,gi(j_kap_max),phi_i(j_kap_max),di,ti,the_options);
	bench_strain(m,:)=[tens_strain_o, tens_strain_i, comp_strain_o, comp_strain_i];
	[max_bench_strain(m), max_flag(m)]=max(bench_strain(m,:));	% find the index of the max strain here
end
if m==10
	disp('Your curvature is too high.')
	cut_depths(:,:)=[0,0,0];
	return
end

% Get the ratio of the notches to apply to the others
alp_max=ratio_calc8(go(j_kap_max),phi(:,j_kap_max),tube_geo,the_options);
tau_max=tau_from_go(kap_max,go(j_kap_max),phi(:,j_kap_max),tube_geo,E,the_options);


%% Find the go values by applying the curvature ratio
for j=1:n
	if j==j_kap_max    % don't re-calculate the benchmark pair
		go(j)=go(j_kap_max);
		gi(j)=gi(j_kap_max);
	else
		kap_ratio(j)=alp_max*kappa(j)/kap_max;	
		find_go=@(go)((abs(kap_ratio(j))-abs(ratio_calc8(go,phi,tube_geo,the_options))));%^2);
% 		find_go=@(go)(tau_max-tau_from_go(kappa(j),go,phi(:,j),tube_geo,E,the_options));
		go_guess=go(j_kap_max)*abs(kappa(j)/kap_max);
		
		go(j)=fsolve(find_go,go_guess,options);%optimoptions('fsolve','FunctionTolerance',1e-10,'MaxFunctionEvaluations',90*10^4));
		gi(j)=calc_gi(go(j),tube_geo,the_options);	% Relate gi to go
	end
end

%% Save the cut parameters
    cut_depths=[go; gi];
end