function strain_outside=strain_calc_out3(kappa,g,do,t,the_options)
% calculate the strain on the outer edge of the tube (outer diameter) using
% the curvature of that tube's backbone (not the centerline)
g_tol=the_options{3};
cross_sec=the_options{1};
kappa=abs(kappa);

if strcmp(cross_sec,'sq')
	gamma=ybar_calc4sq(g,do,t,g_tol);
	kappa_backbone=kappa/(1-gamma*kappa);
%     strain_outside=abs(kappa_backbone)*(d/2-ybar_calc4sq(g,d,t,g_tol));
    strain_outside=abs(kappa_backbone)*(do/2-abs(gamma));
elseif strcmp(cross_sec,'circ')
	gamma=ybar_calc4(g,do,t,g_tol);
	kappa_backbone=kappa/(1-gamma*kappa);
%     strain_outside=abs(kappa_backbone)*(d/2-ybar_calc4(g,d,t,g_tol));
    strain_outside=abs(kappa_backbone)*(do/2-abs(gamma));
elseif strcmp(cross_sec,'hex')
	gamma=ybar_calc4hex(g,do,t,g_tol);
	r=do*sqrt(3)/2;	% tube radius to the flat surface based on side length
	kappa_backbone=kappa/(1-gamma*kappa);
%     strain_outside=abs(kappa_backbone)*(r-ybar_calc4hex(g,d,t,g_tol));
    strain_outside=abs(kappa_backbone)*(r-abs(gamma));
end

end