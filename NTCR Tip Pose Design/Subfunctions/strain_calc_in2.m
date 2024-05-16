function strain_inside=strain_calc_in2(kappa,g,phi,d,t,the_options)
% calculate the strain on the "inner" fiber formed by the cut
g_tol=the_options{3};
cross_sec=the_options{1};

if strcmp(cross_sec,'sq')
	gamma=ybar_calc4sq(g,d,t,g_tol)*cos(phi);
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4sq(g,d,t,g_tol)+d/2);
	strain_inside=abs(kappa_backbone)*(abs(gamma)+d/2-g);
elseif strcmp(cross_sec,'circ')
	gamma=ybar_calc4(g,d,t,g_tol)*cos(phi);
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4(g,d,t,g_tol)+d/2);
	strain_inside=abs(kappa_backbone)*(abs(gamma)+d/2-g);
elseif strcmp(cross_sec,'hex')
	gamma=ybar_calc4hex(g,d,t,g_tol)*cos(phi);
	r=d*sqrt(3)/2;	% tube radius to the flat surface based on side length
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4hex(g,d,t,g_tol)+r);
	strain_inside=abs(kappa_backbone)*(abs(gamma)+r-g);
end

end