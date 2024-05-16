function j_max_strain=strain_check3(cut_params,kappa,kap_max,j_max,tube_geo,n,the_options)
% Evaluate the tensile strain to verify the assumption that strain_max
% happens at kap_max.
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);
go=cut_params(1,:);
gi=cut_params(2,:);
phi_o=cut_params(3,:);
phi_i=cut_params(4,:);

% Check the strain of benchmark notches
% max_strain=strain_calc_out2(kap_max,go(j_max),phi_o(j_max),do,to,the_options);
% strain_gi_kmax=strain_calc_in2(kap_max,gi(j_max),phi_i(j_max),di,ti,the_options);
% if strain_gi_kmax>max_strain
% 	max_strain=strain_gi_kmax;
% end

tens_strain_go=strain_calc_out2(kap_max,go(j_max),phi_o(j_max),do,to,the_options);
tens_strain_gi=strain_calc_in2(kap_max,gi(j_max),phi_i(j_max),di,ti,the_options);
comp_strain_go=strain_calc_in2(kap_max,go(j_max),phi_o(j_max),do,to,the_options);
comp_strain_gi=strain_calc_out2(kap_max,gi(j_max),phi_i(j_max),di,ti,the_options);
bench_strain=[tens_strain_go, tens_strain_gi, comp_strain_go, comp_strain_gi];
max_strain=max(bench_strain);	% max strain of that set
j_max_strain=j_max;

% Evaluate strain of all notches now
for j=1:n
	% These are all abs values that are output
	strain_out_o(j)=strain_calc_out2(kappa(j),go(j),phi_o(j),do,to,the_options);
	strain_in_o(j)=strain_calc_in2(kappa(j),go(j),phi_o(j),do,to,the_options);
	strain_out_i(j)=strain_calc_out2(kappa(j),gi(j),phi_i(j),di,ti,the_options);
	strain_in_i(j)=strain_calc_in2(kappa(j),gi(j),phi_i(j),di,ti,the_options);
	
	pair_strain(j,:)=[strain_out_o(j), strain_in_o(j), strain_out_i(j), strain_in_i(j)];
	max_new_strain=max(pair_strain(j,:));	% find the index of the max strain here

	% Compare strains to strain at max curvature 
	if max_new_strain>max_strain
		max_strain=max_new_strain;
		j_max_strain=j;
	end
end

end