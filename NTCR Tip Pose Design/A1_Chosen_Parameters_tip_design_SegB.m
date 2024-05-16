%% ALL THE CHOSEN PARAMETERS ARE HERE.
% This file is nothing but a script to save the tube geometry, material
% properties, and chosen optimization parameters to the workspace. This
% ensures that all scripts use the same parameters and that there is no
% accidental mix-up of parameters between scripts.
%
% UNITS: mm and N

clear; close all; clc
design_num='SegB';           % this is the design number
machine_res=2;			% # of decimal points the machine resolution can do, which is used to round the final parameters
% Explanation of machine_res:
%{
CNC can handle 0.01 mm on all axes.
Pro-M can only do 0.2 mm in the z-direction well, but it can do 0.01 mm
in the x- and y-directions, so we'll let the slicer descretize the z-axis 
geometry instead of doing it here.
%}

%% Here are some options for your design:
cross_sec='circ';           % shape of the cross section? sq, circ, hex (hex isn't working yet)
g_relation='EIeq';        % which way do you want to relate gi to go? EIeq, Gratio, Weq (See below for explanation.)
g_tol=0;                    % minimum cut depth, if g(j)=<g_tol => g(j)=0
the_options=[{cross_sec},{g_relation},g_tol];
% Some explanation:
%{
g_relation:  EIeq (equal notch stiffnesses), Gratio (gi=go*di/do), Weq (equal backbone widths)
%}

%% Tube Info
% PEEK
E=4.6*10^9/(1000^2);            % N/mm^2=Pa*(m/mm)^2, for PEEK
e_max=0.05;                     % For true strain/true stress, plots show up to 7-8%. Engineering strain/stress shows something more like 5%
FS=2;                         % Factor of safety
sigma_y=E*e_max;				% Yield stress
matl='PEEK';

% Stock Geometry
do=25.4*0.125;                     % mm, outer diameter of outer tube
doi=25.4*0.115;
to=(do-doi)/2;            % mm
di=25.4*0.095;                     % mm
dii=25.4*0.085;
ti=(di-dii)/2;            % mm
tube_geo=[do,to,di,ti];

%% The Curve, Defined and Sampled
% axis_lims=[-5 35 -10 30];	% for plotting
axis_lims=[];	% for plotting
line_fac=0.08;	% for plotting
beta=0.5;               % Approximately the proportion total length that will NOT be cut out-- keep at 0.5 for h_constraint
n=12; x_des=30; z_des=0; tip_angle=pi; %This one works really well

T_base=eye(4);
T_tip=[cos(tip_angle) 0 sin(tip_angle) x_des; 0 1 0 0; -sin(tip_angle) 0 cos(tip_angle) z_des; 0 0 0 1];
le_points=pose2curve3(T_tip,axis_lims,line_fac);

j=0;
for t=0:0.01:1
	j=j+1;
	B=(1-t)^4*le_points(:,1)+4*(1-t)^3*t*le_points(:,2)+6*(1-t)^2*t^2*le_points(:,3)+(4*(1-t))*t^3*le_points(:,4)+t^4*le_points(:,5);
	x_curve(j)=B(1); z_curve(j)=B(3);
end
L_c_des=integral(@(t)diffBnorm(le_points,t),0,1);
arc_step=(L_c_des/n)*ones(1,n);	% evenly step through arc length

for j=1:n+1
	if j==1
		s(j)=0;
		t_arc(j)=0;
	elseif j==n+1
		s(j)=L_c_des;
		t_arc(j)=1;
	else
		s(j)=s(j-1)+arc_step(j-1);
		find_t=@(t_a)(arc_step(j-1)-integral(@(t)diffBnorm(le_points,t),t_arc(j-1),t_a));
		t_arc(j)=fsolve(find_t,(j-1)/n,optimoptions('fsolve','algorithm','levenberg-marquardt'));
	end
	t=t_arc(j);
	B=(1-t)^4*le_points(:,1)+4*(1-t)^3*t*le_points(:,2)+6*(1-t)^2*t^2*le_points(:,3)+(4*(1-t))*t^3*le_points(:,4)+t^4*le_points(:,5);
	x(j)=B(1); z(j)=B(3);
end

% figure
% plot(x_curve,z_curve,'k')
% hold on; daspect([1 1 1])
% plot(x,z,'bo')

bez_plots2(T_base,T_tip,le_points,axis_lims,line_fac)

save parameters.mat

%% Subfunction alley
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