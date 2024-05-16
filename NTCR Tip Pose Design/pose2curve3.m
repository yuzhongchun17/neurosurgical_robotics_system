%% GENERATE SHAPE BASED ON BASE AND TIP CONSTRAINTS
% Author: K. Oliver-Butler
% Date: 10.21.2019
% This is the same as pose2curve2 except it allows you to pass in axis
% limits for the plots and the arrow scale (to make figure-making easier).

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

function le_points=pose2curve3(T_tip,axis_lims,line_fac)

T_base=eye(4);	% assume we're starting out at zero zero zero, but this can change.

%% Let's work on these control points-- initialize the guess
P0=T_base(1:3,4); P4=T_tip(1:3,4);	% P0 should always be [0,0,0], but keeping here for completeness.
V0=T_base(1:3,3); V4=T_tip(1:3,3);	% tangent unit vectors
tip_angle=atan2(V4(1),V4(3));

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

%% Plot the initial guess
%{
% This is for plotting the desired tangents-- the arrow command is 2-D
line_scale=line_fac*L_PP;%0.08*L_PP; %0.06*Lpp;
tip_tan_start=[P4(1); P4(3)];
tip_tan_end=tip_tan_start+1.5*line_scale*[V4(1); V4(3)]; %0.15*L_PP*[V4(1); V4(3)]
base_tan_start=[P0(1); P0(3)];
base_tan_end=base_tan_start+1.5*line_scale*[V0(1); V0(3)]; %0.15*L_PP*[V0(1); V0(3)]
tip_normal=[T_tip(1,4)-line_scale*T_tip(1,1), T_tip(1,4), T_tip(1,4)+line_scale*T_tip(1,1); T_tip(3,4)-line_scale*T_tip(3,1), T_tip(3,4), T_tip(3,4)+line_scale*T_tip(3,1)];
base_normal=[T_base(1,4)-line_scale*T_base(1,1), T_base(1,4), T_base(1,4)+line_scale*T_base(1,1); T_base(3,4)-line_scale*T_base(3,1), T_base(3,4), T_base(3,4)+line_scale*T_base(3,1)];

% Just the poses
figure
plot(tip_normal(1,:),tip_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
hold on; grid on; daspect([1 1 1])
plot(base_normal(1,:),base_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
arrow(tip_tan_start,tip_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)	% base tangent
axis(axis_lims)
xlabel('X'); ylabel('Z');

% Poses + connecting vector
figure
plot(tip_normal(1,:),tip_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
hold on; grid on; daspect([1 1 1])
plot(base_normal(1,:),base_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
plot([P0(1),P4(1)],[P0(3),P4(3)],'b-.')	% Vector from P0 and P4
arrow(tip_tan_start,tip_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)	% base tangent
axis(axis_lims)
xlabel('X'); ylabel('Z');

% Lines for initial guess
figure
plot(le_points_guess(1,:),le_points_guess(3,:),'ko','MarkerSize',5)	% the original control polygon
hold on; grid on; daspect([1 1 1])
plot([P0(1),P4(1)],[P0(3),P4(3)],'b-.')	% Vector from P0 and P4
hold on; grid on; daspect([1 1 1])
plot([0.5*P4(1),P2g(1)],[0.5*P4(3),P2g(3)],'b')	% Bisection line
plot([P0(1),P1g(1)],[P0(3),P1g(3)],'b')				% Base tangent
plot([P4(1),P3g(1)],[P4(3),P3g(3)],'b')				% Tip tangent
plot(tip_normal(1,:),tip_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
plot(base_normal(1,:),base_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
arrow(tip_tan_start,tip_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)	% base tangent
xlabel('X'); ylabel('Z');
axis(axis_lims)

% Lines for initial guess + control polygon outline
figure
plot(le_points_guess(1,:),le_points_guess(3,:),'k--o','MarkerSize',5)	% the original control polygon
hold on; grid on; daspect([1 1 1])
% plot([P0(1),P4(1)],[P0(3),P4(3)],'b-.')	% Vector from P0 and P4
% hold on; grid on; daspect([1 1 1])
% plot([0.5*P4(1),P2g(1)],[0.5*P4(3),P2g(3)],'b')	% Bisection line
% plot([P0(1),P1g(1)],[P0(3),P1g(3)],'b')				% Base tangent
% plot([P4(1),P3g(1)],[P4(3),P3g(3)],'b')				% Tip tangent
plot(tip_normal(1,:),tip_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
plot(base_normal(1,:),base_normal(2,:),'r')	% the tip normal (to help it be clear on the plot)
arrow(tip_tan_start,tip_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)		% tip tangent
arrow(base_tan_start,base_tan_end,'Length',12,'Width',line_scale/10,'BaseAngle',90,'TipAngle',24)	% base tangent
xlabel('X'); ylabel('Z');
legend('Control Polygon','Location','southeast')
axis(axis_lims)

% Initial Bezier curve
bez_plots2(T_base,T_tip,le_points_guess,axis_lims,line_fac)
%}

%% Let's minimize curvature
p2_bound=2;
LB=[0.1*L_PP, 0.1*L_PP, P2g(1)-p2_bound*L_PP,P2g(3)-p2_bound*L_PP]; UB=[2*L_PP, 2*L_PP, P2g(1)+p2_bound*L_PP,P2g(3)+p2_bound*L_PP];
[otps,fvale]=fmincon(@(the_params)bez_curvature(T_base,T_tip,the_params(1),the_params(2),the_params(3),the_params(4),1),init_guess,[],[],[],[],LB,UB);

L1=otps(1); L3=otps(2); P2=[otps(3), 0, otps(4)].';
P1=P0+L1*V0; P3=P4-L3*V4;
le_points=[P0,P1,P2,P3,P4];
end
