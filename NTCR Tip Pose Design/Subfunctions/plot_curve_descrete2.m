function shape=plot_curve_descrete2(CURVE,s,n,c)
% delta_s=s(2)-s(1);  %assuming delta_s is constant
kappa=CURVE(1,:);
l_c=CURVE(2,:);

T_total=eye(4); x(1)=0; y(1)=0; z(1)=0;
k=0;
for j=1:n
%     if j>1
%     c(j)=(s(j)-s(j-1))*(1-percent_cut);
%     l(j)=(s(j)-s(j-1))*percent_cut;
%     else
%     c(j)=s(j)*(1-percent_cut);
%     l(j)=s(j)*percent_cut;
%     end
	if j==1
		delta_s=s(j);
	else
		delta_s=s(j)-s(j-1);
	end
    if kappa(j)==0
        T(:,:,j)=[1 0 0 0;
            0   1   0   0;
            0   0   1   delta_s;
            0	0	0   1];
    else
        T(:,:,j)=[cos(kappa(j)*l_c(j)) 0  sin(kappa(j)*l_c(j)) (1-cos(kappa(j)*l_c(j)))/kappa(j);
            0   1   0   0;
            -sin(kappa(j)*l_c(j)) 0   cos(kappa(j)*l_c(j)) sin(kappa(j)*l_c(j))/kappa(j);
            0   0   0   1];
    end
	Tc=[1 0 0 0; 0 1 0 0; 0 0 1 c(j); 0 0 0 1];
	%{
    T_total=T_total*T(:,:,j);
    k=k+1;
    x(k+1)=T_total(1,4);
    y(k+1)=T_total(2,4);
    z(k+1)=T_total(3,4);


    T_total=T_total*Tc;
    k=k+1;
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

% plot(x,z,'--*')
% daspect([1 1 1]);
end