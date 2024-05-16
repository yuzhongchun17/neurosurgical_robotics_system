function q=calc_q(h,d,kappa_o)
n=length(h);
q=0;
for j=1:n
	q=q+d(j)*h(j)*kappa_o(j);
end
end