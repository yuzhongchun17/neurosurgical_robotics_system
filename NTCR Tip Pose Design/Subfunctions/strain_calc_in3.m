function strain_inside=strain_calc_in3(kappa,g,do,t,the_options)
% calculate the strain on the "inner" fiber formed by the cut
g_tol=the_options{3};
cross_sec=the_options{1};
kappa=abs(kappa);

if strcmp(cross_sec,'sq')
	gamma=ybar_calc4sq(g,do,t,g_tol);
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4sq(g,d,t,g_tol)+d/2);
	strain_inside=abs(kappa_backbone)*(gamma+do/2-g);
elseif strcmp(cross_sec,'circ')
	gamma=ybar_calc4(g,do,t,g_tol);
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4(g,d,t,g_tol)+d/2);
	strain_inside=abs(kappa_backbone)*(abs(gamma)+do/2-g);
elseif strcmp(cross_sec,'hex')
	gamma=ybar_calc4hex(g,do,t,g_tol);
	r=do*sqrt(3)/2;	% tube radius to the flat surface based on side length
	kappa_backbone=kappa/(1-gamma*kappa);
% 	strain_inside=abs(kappa_backbone)*(-g+ybar_calc4hex(g,d,t,g_tol)+r);
	strain_inside=abs(kappa_backbone)*(abs(gamma)+r-g);
end

end