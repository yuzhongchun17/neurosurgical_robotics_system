function opt_curve_param=bez_curvature3D(T_base,T_tip,L1,L3,x_mid,y_mid,z_mid,curve_option)
% We want to change the lengths of the tangent lines and the position of
% the midpoint in order to minimze some curvature-based metric, be it the
% energy of the curve or the variance of it.

P0=T_base(1:3,4); P4=T_tip(1:3,4);	% P0 should always be [0,0,0], but keeping here for completeness.
V0=T_base(1:3,3); V4=T_tip(1:3,3);	% tangent unit vectors

P1=P0+L1*V0;			% tangent line from base-- need the abs bc it's a length that we dont' want to be negative.
P2=[x_mid, y_mid, z_mid].';		% Just to keep numbering consistent
P3=P4-L3*V4;			% tangent line from tip

kappa_sqrd=find_curvature(P0,P1,P2,P3,P4,0:0.01:1);	

% This will minimize the magnitude of the highest curvature. It works
% pretty well, but we might be able to do better.
curve_magnitude=max(kappa_sqrd);

% This is the energy of the curve-- integral of curvature squared. This
% produced some strange results. Double-check it.
curve_energy=integral(@(t)find_curvature(P0,P1,P2,P3,P4,t),0,1);

% This will minimize the variation of the curvature-- the integral of the
% change in curvature over arc length. This tended to produce unrealistic
% curves.
curve_variation=integral(@(t)find_curve_variance(P0,P1,P2,P3,P4,t).^2,0,1);	% this is the variation of the curve

if curve_option==1
	opt_curve_param=curve_magnitude;
elseif curve_option==2
	opt_curve_param=curve_energy;
elseif curve_option==3
	opt_curve_param=curve_variation;
end


function realz_kappa=find_curvature(P0,P1,P2,P3,P4,t_vector)
	kmax=length(t_vector);
	realz_kappa=ones(1,kmax);
	for k=1:kmax
		t=t_vector(k);
		Bp=-4*(1-t)^3*P0-12*(1-t)^2*t*P1+4*(1-t)^3*P1-(12*(1-t))*t^2*P2+12*(1-t)^2*t*P2-4*t^3*P3+(12*(1-t))*t^2*P3+4*t^3*P4;
		Bpp=12*(1-t)^2*P0+(24*(1-t))*t*P1-24*(1-t)^2*P1+12*t^2*P2-(48*(1-t))*t*P2+12*(1-t)^2*P2-24*t^2*P3+(24*(1-t))*t*P3+12*t^2*P4;
		realz_kappa(k)=(norm(cross(Bp,Bpp))/norm(Bp)^3)^2;	% output the square of the curvature
	end
end

function dk_dt=find_curve_variance(P0,P1,P2,P3,P4,t_vector)
		kmax=length(t_vector);
		realz_kappa=ones(1,kmax);
		dk_dt=ones(1,kmax);
		for k=1:kmax
			t=t_vector(k);
			Bp=-4*(1-t)^3*P0-12*(1-t)^2*t*P1+4*(1-t)^3*P1-(12*(1-t))*t^2*P2+12*(1-t)^2*t*P2-4*t^3*P3+(12*(1-t))*t^2*P3+4*t^3*P4;
			Bpp=12*(1-t)^2*P0+(24*(1-t))*t*P1-24*(1-t)^2*P1+12*t^2*P2-(48*(1-t))*t*P2+12*(1-t)^2*P2-24*t^2*P3+(24*(1-t))*t*P3+12*t^2*P4;
			realz_kappa(k)=norm(cross(Bp,Bpp))/norm(Bp)^3;
			
			Bppp=-(24*(1-t))*P0-24*t*P1+(72*(1-t))*P1+72*t*P2-(72*(1-t))*P2-72*t*P3+(24*(1-t))*P3+24*t*P4;
			dk_dt(k)=norm(Bppp);	% this approximates the curvature variance
		end
	end
end