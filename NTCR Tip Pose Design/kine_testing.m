%% Kinematics Testing
el_T=fwd_kin7_Tip(tube_geo,params_final,E,the_options);
for j=1:length(el_T(1,1,:))
	edge_shape(:,j)=[el_T(1,4,j); el_T(3,4,j)];
end

% edge_shape=fwd_kin6(tube_geo,params_final,E,the_options);


%% Figure graveyard
%%{
figure
plot(shape_desired(1,:),shape_desired(2,:),'k')
hold on; grid on; daspect([1 1 1])
plot(shape_descrete(1,:),shape_descrete(2,:),'r--x')
plot(edge_shape(1,:),edge_shape(2,:),'b-o')
legend('Desired Curve','Descritized Desired Curve','Kinematics of Opt. Design','Location','southeast')
title(['Design ',num2str(design_num),' Results (',g_relation,', ',cross_sec,')']);