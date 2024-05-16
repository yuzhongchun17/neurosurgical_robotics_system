function tau=tau_from_go(kappa,go,phi,tube_geo,E,the_options)
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);
phi_o=phi(1); phi_i=phi(2);

% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
cross_sec=the_options{1};
kappa_abs=abs(kappa);
gi=calc_gi(go,tube_geo,the_options);

if strcmp(cross_sec,'sq')
	gamma_o=ybar_calc4sq(go,do,to,g_tol)*cos(phi_o);
	gamma_i=ybar_calc4sq(gi,di,ti,g_tol)*cos(phi_i);
	Io=asym_segment_geometry4sq(go,abs(gamma_o),do,to,g_tol);
	Ii=asym_segment_geometry4sq(gi,abs(gamma_i),di,ti,g_tol);
elseif strcmp(cross_sec,'circ')
	gamma_o=ybar_calc4(go,do,to,g_tol)*cos(phi_o);
	gamma_i=ybar_calc4(gi,di,ti,g_tol)*cos(phi_i);
	Io=asym_segment_geometry4(go,abs(gamma_o),do,to,g_tol);
	Ii=asym_segment_geometry4(gi,abs(gamma_i),di,ti,g_tol);
 elseif strcmp(cross_sec,'hex')
	gamma_o=ybar_calc4hex(go,do,to,g_tol)*cos(phi_o);
	gamma_i=ybar_calc4hex(gi,di,ti,g_tol)*cos(phi_i);
	Io=asym_segment_geometry4hex(go,abs(gamma_o),do,to,g_tol);
	Ii=asym_segment_geometry4hex(gi,abs(gamma_i),di,ti,g_tol);
end

d=gamma_i-gamma_o;
kappa_o=kappa/(1-gamma_o*kappa_abs);
kappa_i=kappa/(1-gamma_i*kappa_abs);
tau=(E/d)*(Io*kappa_o+Ii*kappa_i);	% I believe the norm is correct here, to use a length instead of a vector
end