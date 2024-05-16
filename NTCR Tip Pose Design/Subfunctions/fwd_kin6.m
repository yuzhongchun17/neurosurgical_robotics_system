function shape=fwd_kin6(tube_geo,params,E,the_options)
% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
% g_relation=the_options{2};
cross_sec=the_options{1};

%tube_geo=[do,to,di,ti];
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);

% params=[h;c;go;gi;phi_o;phi_i;q];
h=params(1,:); c=params(2,:); go=params(3,:); gi=params(4,:);
phi_o=params(5,:); phi_i=params(6,:);
q=params(7,1);
n=length(go);

sum_factors=0;
for j=1:n
    if strcmp(cross_sec,'sq')
        gamma_o(j)=ybar_calc4sq(go(j),do,to,g_tol)*cos(phi_o(j));
        gamma_i(j)=ybar_calc4sq(gi(j),di,ti,g_tol)*cos(phi_i(j));
        Io(j)=asym_segment_geometry4sq(go(j),abs(gamma_o(j)),do,to,g_tol);
        Ii(j)=asym_segment_geometry4sq(gi(j),abs(gamma_i(j)),di,ti,g_tol);
    elseif strcmp(cross_sec,'circ')
        gamma_o(j)=ybar_calc4(go(j),do,to,g_tol)*cos(phi_o(j));
        gamma_i(j)=ybar_calc4(gi(j),di,ti,g_tol)*cos(phi_i(j));
        Io(j)=asym_segment_geometry4(go(j),abs(gamma_o(j)),do,to,g_tol);
        Ii(j)=asym_segment_geometry4(gi(j),abs(gamma_i(j)),di,ti,g_tol);
    elseif strcmp(cross_sec,'hex') %still a work in progress
        gamma_o(j)=ybar_calc4hex(go(j),do,to,g_tol)*cos(phi_o(j));
        gamma_i(j)=ybar_calc4hex(gi(j),di,ti,g_tol)*cos(phi_i(j));
        Io(j)=asym_segment_geometry4hex(go(j),abs(gamma_o(j)),do,to,g_tol);
        Ii(j)=asym_segment_geometry4hex(gi(j),abs(gamma_i(j)),di,ti,g_tol);
    end
    
    d(j)=gamma_i(j)-gamma_o(j);
    alpha(j)=d(j)/(E*(Io(j)+Ii(j)));
    sum_factors=sum_factors+d(j)*alpha(j)*h(j);
end

% k=0;
T_total=eye(4);
x(1)=T_total(1,4);
y(1)=T_total(2,4);
z(1)=T_total(3,4);


% options=optimoptions('fsolve','Algorithm','levenberg-marquardt','FunctionTolerance',1e-15,'StepTolerance',1e-15);
% options=optimoptions('fsolve','Algorithm','levenberg-marquardt','MaxFunctionEvaluations',50*10^3,'MaxIterations',100000,'FunctionTolerance',1e-20,'StepTolerance',1e-25);%,'Display','iter');
options=optimoptions('fsolve','Algorithm','levenberg-marquardt','MaxFunctionEvaluations',90*10^4,'MaxIterations',100000,'FunctionTolerance',1e-20,'StepTolerance',1e-30);%,'Display','iter');

ko_guess(1,:)=q*alpha/sum_factors;
ki_guess=ko_guess(1)/(1-ko_guess(1)*d(1));
tau_guess=(E/d(1))*(Io(1)*ko_guess(1)+Ii(1)*ki_guess);

% Guess only kappa_o
%{
find_kappa_o=@(kappa_o)([(scale_q_err*(q-calc_q(h,d,kappa_o)))^2, tau_err(E,Io,Ii,d,kappa_o,scale_tau_err)]);
% find_kappa_o=@(kappa_o)([q-calc_q(h,d,kappa_o); tau_err(E,Io,Ii,d,kappa_o,scale_tau_err)].^2);
% find_kappa_o=@(kappa_o)((scale_q_err*(q-calc_q(h,d,kappa_o)))^2+tau_err(E,Io,Ii,d,kappa_o,scale_tau_err)); % sum of squared errors-- tau_err is squared inside the function
kappa_o=fsolve(find_kappa_o,ko_guess,options);
%}
% Guess kappa_o and tau
%%{

act_var_guess=[ko_guess, tau_guess];
find_act_var=@(act_var)([(q-calc_q(h,d,act_var(1:n)))^2, (act_var(end)*ones(1,n)-calc_tau(E,Io,Ii,d,act_var(1:n))).^2]);
try
	act_var=fsolve(find_act_var,act_var_guess,options);
catch
	disp('DANGER, WILL ROBINSON. Catastrophic error in your code!')
	danger=1;
end
kappa_o=act_var(1:n);
% tau=act_var(2,:);	% we don't actually care what tau is
%}

for j=1:n
	kappa(j)=kappa_o(j)/(1+gamma_o(j)*kappa_o(j));
	l(j)=h(j)/(1-gamma_o(j)*kappa(j));
    if q==0
        T(:,:,j)=[1 0   0   0;
                0   1   0   0;
                0	0	1	l(j);
                0   0   0   1];
	elseif q>0
        if kappa(j)==0
            T(:,:,j)=[1	0	0	0;
                    0   1   0   0;
                    0   0   1   l(j);
                    0	0	0   1];
        else
            T(:,:,j)=[cos(kappa(j)*l(j)) 0  sin(kappa(j)*l(j)) (1-cos(kappa(j)*l(j)))/kappa(j);
                    0   1   0   0;
                    -sin(kappa(j)*l(j)) 0   cos(kappa(j)*l(j)) sin(kappa(j)*l(j))/kappa(j);
                    0   0   0   1];
		end
	else
		if kappa(j)==0
            T(:,:,j)=[1	0	0	0;
                    0   1   0   0;
                    0   0   1   l(j);
                    0	0	0   1];
        else
            T(:,:,j)=[cos(kappa(j)*l(j)) 0  sin(kappa(j)*l(j)) (1-cos(kappa(j)*l(j)))/kappa(j);
                    0   1   0   0;
                    -sin(kappa(j)*l(j)) 0   cos(kappa(j)*l(j)) sin(kappa(j)*l(j))/kappa(j);
                    0   0   0   1];
		end
    end
    
    Tc=[1 0 0 0; 0 1 0 0; 0 0 1 c(1); 0 0 0 1];
	%{
    T_total=T_total*T(:,:,j);
    k=k+1;
    x(k+1)=T_total(1,4);
    y(k+1)=T_total(2,4);
    z(k+1)=T_total(3,4);
    k=k+1;
    T_total=T_total*Tc;
    x(k+1)=T_total(1,4);
    y(k+1)=T_total(2,4);
    z(k+1)=T_total(3,4);
	%}
% if you just want the base of the notches, not the fully descretized curve.
    T_total=T_total*T(:,:,j)*Tc;  
    x(j+1)=T_total(1,4);
    y(j+1)=T_total(2,4);
    z(j+1)=T_total(3,4);
end
shape=[x;z];
end