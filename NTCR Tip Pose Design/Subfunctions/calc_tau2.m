function tau=calc_tau2(E,Io,Ii,d,kappa_o)
n=length(Io);

for j=1:n
	kappa_i(j)=abs(kappa_o(j))/(1-abs(kappa_o(j))*norm(d(j)));
	tau(j)=(E/d(j))*(Io(j)*kappa_o(j)+Ii(j)*kappa_i(j));
end

end