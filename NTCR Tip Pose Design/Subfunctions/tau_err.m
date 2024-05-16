function err=tau_err(E,Io,Ii,d,kappa_o,scale_err)
n=length(Io);
err=0;

for j=1:n
	kappa_i(j)=kappa_o(j)/(1-kappa_o(j)*d(j));
	tau(j)=(E/d(j))*(Io(j)*kappa_o(j)+Ii(j)*kappa_i(j));
	if j>1
		err=(scale_err*(tau(j)-tau(j-1)))^2+err;	% since tau is constant across all notches, this should be zero.
	end
end
end