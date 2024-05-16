function tau=calc_tau(E,Io,Ii,d,kappa_o)
n=length(Io);

for j=1:n
	kappa_i(j)=kappa_o(j)/(1-kappa_o(j)*d(j));
	tau(j)=(E/d(j))*(Io(j)*kappa_o(j)+Ii(j)*kappa_i(j));
end

end