function []=bez_plots2(T_base,T_tip,control_pts,axis_lims,line_fac)
% This is the same as bez_plots, it just allows you to pass in the plot's
% axis limits and the arrow scale (to make figure-making easier).
% Given the control points and base/tip transformation matrices, plot the
% curve and tangents.
V0=T_base(1:3,3); V4=T_tip(1:3,3);	% tangent unit vectors
P0=control_pts(:,1); P1=control_pts(:,2); P2=control_pts(:,3);
P3=control_pts(:,4); P4=control_pts(:,5);
L_PP=norm(P4-P0);

% Plotting the Bezier
j=0;
for t=0:0.01:1
	j=j+1;
	B=(1-t)^4*P0+4*(1-t)^3*t*P1+6*(1-t)^2*t^2*P2+(4*(1-t))*t^3*P3+t^4*P4;
	xB(j)=B(1); zB(j)=B(3);
end

% This is for plotting the desired tangents-- the arrow command is 2-D
line_scale=line_fac*L_PP;%0.08*L_PP; %0.06*Lpp;
tip_tan_start=[P4(1); P4(3)];
tip_tan_end=tip_tan_start+1.5*line_scale*[V4(1); V4(3)]; %0.15*L_PP*[V4(1); V4(3)]
base_tan_start=[P0(1); P0(3)];
base_tan_end=base_tan_start+1.5*line_scale*[V0(1); V0(3)]; %0.15*L_PP*[V0(1); V0(3)]
tip_normal=[T_tip(1,4)-line_scale*T_tip(1,1), T_tip(1,4), T_tip(1,4)+line_scale*T_tip(1,1); T_tip(3,4)-line_scale*T_tip(3,1), T_tip(3,4), T_tip(3,4)+line_scale*T_tip(3,1)];
base_normal=[T_base(1,4)-line_scale*T_base(1,1), T_base(1,4), T_base(1,4)+line_scale*T_base(1,1); T_base(3,4)-line_scale*T_base(3,1), T_base(3,4), T_base(3,4)+line_scale*T_base(3,1)];

%% The actual figure commands
figure
Bez=plot(xB,zB,'k');	% the curve
hold on; grid on; daspect([1 1 1])
CP=plot(control_pts(1,:),control_pts(3,:),'k--o','MarkerSize',5);	% the optimized control polygon
plot(tip_normal(1,:),tip_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
plot(base_normal(1,:),base_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
arrow(tip_tan_start,tip_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)	% base tangent
xlabel('X'); ylabel('Z'); %title('Resultant Curve')
axis(axis_lims);
legend([Bez,CP],'Curve','Control Polygon','Location','southeast')

end
%% Subfunctions
% function dBdt_norm=diffBnorm(le_points,t_vect)
% 	P0=le_points(:,1); P1=le_points(:,2); P2=le_points(:,3);
% 	P3=le_points(:,4); P4=le_points(:,5);
% 	dBdt=ones(1,length(t_vect));
% 	for i=1:length(t_vect)
% 		t=t_vect(i);
% 		dBdt=-4*(1-t)^3*P0-12*(1-t)^2*t*P1+4*(1-t)^3*P1-(12*(1-t))*t^2*P2+12*(1-t)^2*t*P2-4*t^3*P3+(12*(1-t))*t^2*P3+4*t^3*P4;
% 		dBdt_norm(i)=norm(dBdt);
% 	end
% end
