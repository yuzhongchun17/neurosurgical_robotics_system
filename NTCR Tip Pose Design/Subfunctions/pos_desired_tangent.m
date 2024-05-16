function curve_tan=pos_desired_tangent(pos_curve_desired,s,n)
x=pos_curve_desired(1,:);
z=pos_curve_desired(2,:);
delta_s=s(2)-s(1);	% assuming evenly spaced arclength samples
for j=1:n+1	% we have n+1 point since we're counting the base
	if j== 1
		tang(:,j)=[0; 1];
	else
% 		delta_s=s(j)-s(j-1);
		tang(1,j)=(x(j)-x(j-1))/delta_s;
		tang(2,j)=(z(j)-z(j-1))/delta_s;
	end	
	curve_tan(:,j)=tang(:,j)/norm(tang(:,j));
end
end