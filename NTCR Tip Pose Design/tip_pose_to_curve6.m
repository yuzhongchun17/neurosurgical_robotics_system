%% GENERATE SHAPE BASED ON BASE AND TIP CONSTRAINTS
% Author: K. Oliver-Butler
% Date: 10.21.2019
% This script takes a desired tip pose and generates a quartic Bezier curve
% of five points (P0-P4) that achieves the desired end conditions in a 
% manner suitable for NTCR design. It does so by minimizing the maximum 
% squared curvature of the curve. The minimization is carried out by 
% changing the length of the tangent vectors (thus changing P1 and P3) as 
% well as changing the position of the midpoint Bezier control point (P2).
% The initial guess uses the vector between the two end positions to
% generate a reasonable curve that can then be optimized to reduce
% curvature, which relates directly to material strain. A constraint is
% used so that P2 isn't moved any more than twice the length of the
% connecting vector in any direction.

clear; clc; close;

% Maybe rework to constrain curvature and minimize L instead? That would
% tie into material properties better.

%% Desired Parameters
curve_option=1;
% x_des=20; z_des=0; tip_angle=5*pi/4; %note-- this is an angle off the vertical in the clockwise direction
x_des=30; z_des=20; tip_angle=2*pi/3; %note-- this is an angle off the vertical in the clockwise direction

%% Format them into Transformation matrices
% This isn't totally necessary, but it's the format I'm most comfortable working with.
T_base=eye(4);	% assume we're starting out at zero zero zero, but this can change.
T_tip=[cos(tip_angle) 0 sin(tip_angle) x_des; 0 1 0 0; -sin(tip_angle) 0 cos(tip_angle) z_des; 0 0 0 1];

%% Let's work on these control points-- initialize the guess
P0=T_base(1:3,4); P4=T_tip(1:3,4);	% P0 should always be [0,0,0], but keeping here for completeness.
V0=T_base(1:3,3); V4=T_tip(1:3,3);	% tangent unit vectors

% initialize guess
PP=P4-P0;	% vector from the points
L_PP=norm(PP);	% length of said vector
theta=atan2(PP(3),PP(1));	% angle from horizontal
N_PP=[-sin(theta), 0, cos(theta)].';
L_guess=0.5*L_PP;
% change this to some relationship between tip angle and angle of PP
% if theta<pi/6
	P2g=0.5*PP+L_PP*N_PP;
% else
% 	if tip_angle < 3*pi/2 && tip_angle>0
% 		P2g=0.5*PP+L_PP*N_PP;
% 	else
% 		P2g=0.5*PP-L_PP*N_PP;
% 	end
% end
init_guess=[L_guess,L_guess,P2g(1),P2g(3)];
P1g=P0+L_guess*V0; P3g=P4-L_guess*V4;
le_points_guess=[P0,P1g,P2g,P3g,P4];


%% Let's minimize curvature
% [otps,fvale]=fminsearch(@(the_params)bez_curvature(T_base,T_tip,the_params(1),the_params(2),the_params(3),the_params(4),curve_option),init_guess);
%%{
p2_bound=2;
LB=[0.1*L_PP, 0.1*L_PP, P2g(1)-p2_bound*L_PP,P2g(3)-p2_bound*L_PP]; UB=[2*L_PP, 2*L_PP, P2g(1)+p2_bound*L_PP,P2g(3)+p2_bound*L_PP];
[otps,fvale]=fmincon(@(the_params)bez_curvature(T_base,T_tip,the_params(1),the_params(2),the_params(3),the_params(4),curve_option),init_guess,[],[],[],[],LB,UB);
%}
L1=otps(1); L3=otps(2); P2=[otps(3), 0, otps(4)].';
P1=P0+L1*V0; P3=P4-L3*V4;
le_points=[P0,P1,P2,P3,P4];


%% Calculate the length of the curve
L0=integral(@(t)diffBnorm(le_points_guess,t),0,1);
L=integral(@(t)diffBnorm(le_points,t),0,1);
L_change=100*abs(L0-L)/L0;

%% Plotting stuff
%{
% Coordinates for the control polygon
for i=1:length(le_points)
	% Initial guess
	PLP0=le_points_guess(:,i);
	xLP0(i)=PLP0(1); zLP0(i)=PLP0(3);
	
	% Optimized Control Polygon
	PLP=le_points_guess(:,i);
	xLP(i)=PLP(1); zLP(i)=PLP(3);
end
%}

% Plotting the Bezier
j=0;
for t=0:0.01:1
	j=j+1;
	
	% This is the initial guess
	B0=(1-t)^4*P0+4*(1-t)^3*t*P1g+6*(1-t)^2*t^2*P2g+(4*(1-t))*t^3*P3g+t^4*P4;
	xB0(j)=B0(1); zB0(j)=B0(3);
	
	% This is the optimized version
	B=(1-t)^4*P0+4*(1-t)^3*t*P1+6*(1-t)^2*t^2*P2+(4*(1-t))*t^3*P3+t^4*P4;
	xB(j)=B(1); zB(j)=B(3);
	%{
	Bp=-4*(1-t)^3*P0-12*(1-t)^2*t*P1+4*(1-t)^3*P1-(12*(1-t))*t^2*P2+12*(1-t)^2*t*P2-4*t^3*P3+(12*(1-t))*t^2*P3+4*t^3*P4;
	Bpp=12*(1-t)^2*P0+(24*(1-t))*t*P1-24*(1-t)^2*P1+12*t^2*P2-(48*(1-t))*t*P2+12*(1-t)^2*P2-24*t^2*P3+(24*(1-t))*t*P3+12*t^2*P4;
	kappa(j)=norm(cross(Bp,Bpp))/norm(Bp)^3;
	kappa_mag(j)=abs(kappa(j));
	%}
end

% This is for plotting the desired poses-- the arrow command is 2-D
tip_tan_start=[P4(1); P4(3)];
tip_tan_end=tip_tan_start+0.1*L_PP*[V4(1); V4(3)];
base_tan_start=[P0(1); P0(3)];
base_tan_end=base_tan_start+0.1*L_PP*[V0(1); V0(3)];
tip_normal=[T_tip(1,4)-T_tip(1,1), T_tip(1,4), T_tip(1,4)+T_tip(1,1); T_tip(3,4)-T_tip(3,1), T_tip(3,4), T_tip(3,4)+T_tip(3,1)];
base_normal=[T_base(1,4)-T_base(1,1), T_base(1,4), T_base(1,4)+T_base(1,1); T_base(3,4)-T_base(3,1), T_base(3,4), T_base(3,4)+T_base(3,1)];

% For an image of the process--
% if we want to compare this case to a circle
p2sq_x=[P2g(1)-p2_bound*L_PP,P2g(1)-p2_bound*L_PP,P2g(1)+p2_bound*L_PP,P2g(1)+p2_bound*L_PP];
p2sq_z=[P2g(3)-p2_bound*L_PP,P2g(3)+p2_bound*L_PP,P2g(3)+p2_bound*L_PP,P2g(3)-p2_bound*L_PP];

%{
i=0;
for t=0:pi/32:2*pi
	i=i+1;
	p2circ_x(i)=P2g(1)+2*L_PP*cos(t); p2circ_z(i)=P2g(3)+2*L_PP*sin(t);
end
%}

%% The actual figure commands
figure
plot(xB,zB,'k')	% the curve
hold on; grid on; daspect([1 1 1])
plot(xB0,zB0,'r')	% the curve
plot(le_points(1,:),le_points(3,:),'k--x')	% the optimized control polygon
plot(le_points_guess(1,:),le_points_guess(3,:),'r--x')	% the original control polygon
% legend('Curve','Optimize/d Control Polygon','Initial Control Polygon')
plot(tip_normal(1,:),tip_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
plot(base_normal(1,:),base_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
arrow(tip_tan_start,tip_tan_end,'Length',10,'Width',1,'BaseAngle',90,'TipAngle',20)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',10,'Width',1,'BaseAngle',90,'TipAngle',20)	% base tangent
xlabel('X'); ylabel('Y'); title('Resultant Curve')
% 	patch(p2sq_x,p2sq_z,'blue','EdgeColor','blue','facealpha',0.1);

% if we want to compare this case to a circle
if tip_angle==pi %&& x_des==z_des
	i=0;
	for t=0:pi/32:pi
		i=i+1;
		circ_x(i)=0.5*x_des+0.5*x_des*cos(t); circ_y(i)=0.5*x_des*sin(t);
	end
	plot(circ_x, circ_y,'r-.')
end

%%
close all
xmin=-10; xmax=45; ymin=0; ymax=45; w_ar=1;
figure
% subplot(1,3,1)
	plot([P0(1),P4(1)],[P0(3),P4(3)],'b')
	hold on; grid on; daspect([1 1 1])
	plot([0.5*P4(1),P2g(1)],[0.5*P4(3),P2g(3)],'b')
	plot([P0(1),P1g(1)],[P0(3),P1g(3)],'b')
	plot([P4(1),P3g(1)],[P4(3),P3g(3)],'b')
% 	patch(p2sq_x,p2sq_z,'blue','EdgeColor','blue','facealpha',0.1);
	plot(le_points_guess(1,:),le_points_guess(3,:),'r--x')	% the original control polygon
	plot(tip_normal(1,:),tip_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	plot(base_normal(1,:),base_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	arrow(tip_tan_start,tip_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)		% tip tangent
	arrow(base_tan_start,base_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)	% base tangent
	axis([xmin xmax ymin ymax])
% subplot(1,3,2)
figure
	plot(xB0,zB0,'k')	% the curve
	hold on; grid on; daspect([1 1 1])
	plot(le_points_guess(1,:),le_points_guess(3,:),'r--x')	% the original control polygon
	% legend('Curve','Optimize/d Control Polygon','Initial Control Polygon')
	plot(tip_normal(1,:),tip_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	plot(base_normal(1,:),base_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	arrow(tip_tan_start,tip_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)		% tip tangent
	arrow(base_tan_start,base_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)	% base tangent
	axis([xmin xmax ymin ymax])
% subplot(1,3,3)
figure
	plot(xB,zB,'k')	% the curve
	hold on; grid on; daspect([1 1 1])
	plot(le_points(1,:),le_points(3,:),'k--x')	% the optimized control polygon
	% legend('Curve','Optimize/d Control Polygon','Initial Control Polygon')
	plot(tip_normal(1,:),tip_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	plot(base_normal(1,:),base_normal(2,:),'b')	% the tip normal (to help it be clear on the plot)
	arrow(tip_tan_start,tip_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)		% tip tangent
	arrow(base_tan_start,base_tan_end,'Length',11*w_ar,'Width',w_ar,'BaseAngle',90,'TipAngle',20)	% base tangent
	axis([xmin xmax ymin ymax])



%% Subfunctions
function dBdt_norm=diffBnorm(le_points,t_vect)
	P0=le_points(:,1); P1=le_points(:,2); P2=le_points(:,3);
	P3=le_points(:,4); P4=le_points(:,5);
	dBdt=ones(1,length(t_vect));
	for i=1:length(t_vect)
		t=t_vect(i);
		dBdt=-4*(1-t)^3*P0-12*(1-t)^2*t*P1+4*(1-t)^3*P1-(12*(1-t))*t^2*P2+12*(1-t)^2*t*P2-4*t^3*P3+(12*(1-t))*t^2*P3+4*t^3*P4;
		dBdt_norm(i)=norm(dBdt);
	end
end
