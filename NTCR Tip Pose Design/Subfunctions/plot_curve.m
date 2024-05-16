function shape=plot_curve(kap,s_arc,s_pt,n)
delta_s=s_arc(2)-s_arc(1);  % assuming delta_s is constant.

k=1;
T_total=eye(4); x(1)=0; y(1)=0; z(1)=0;
for j=1:length(s_arc)
    if kap(j)==0
        T(:,:,j)=[1 0 0 0;
            0   1   0   0;
            0   0   1   delta_s;
            0	0	0   1];
    else
        T(:,:,j)=[cos(kap(j)*delta_s) 0  sin(kap(j)*delta_s) (1-cos(kap(j)*delta_s))/kap(j);
            0   1   0   0;
            -sin(kap(j)*delta_s) 0   cos(kap(j)*delta_s) sin(kap(j)*delta_s)/kap(j);
            0   0   0   1];       
    end
    
    T_total=T_total*T(:,:,j);
    x(j+1)=T_total(1,4);
    y(j+1)=T_total(2,4);
    z(j+1)=T_total(3,4);

    if k<=n && round(s_arc(j),1)== round(s_pt(k),1)
        sampled_pt(:,k)=[x(j);z(j)];
        k=k+1;
    end
    
end
shape=[x;z];

% figure
% plot(x,z,'m')
% hold on; daspect([1 1 1]);
% scatter(sampled_pt(1,:),sampled_pt(2,:),'b*')
end