function go=calc_go(gi,tube_geo,the_options)
% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
g_relation=the_options{2};
cross_sec=the_options{1};

% in the other script, it's tubes=[do,to,di,ti];
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);

% These hold true for circles and squares
r_out_o=do/2;      % outer radius of outer tube
r_in_o=r_out_o-to;   % inner radius of outer tube

% These hold true for hexagons
ao=do-(2/sqrt(3))*to;	% inner wall side length of outer tube

% Now for the acutal calculation
if strcmp(g_relation,'Weq')
		w_nom=di-gi;
		go=do-w_nom;
		
	elseif strcmp(g_relation,'Gratio')
		go=gi*do/di;
		
	elseif strcmp(g_relation,'EIeq')
		if strcmp(cross_sec,'sq')
			Io_tube=(do^4-(do-2*to)^4)/12;
			ybar_i=ybar_calc4sq(gi,di,ti,g_tol);
			Ii=asym_segment_geometry4sq(gi,ybar_i,di,ti,g_tol);
		elseif strcmp(cross_sec,'circ')
			Io_tube=pi/4*(r_out_o^4-r_in_o^4);
			ybar_i=ybar_calc4(gi,di,ti,g_tol);
			Ii=asym_segment_geometry4(gi,ybar_i,di,ti,g_tol);
		elseif strcmp(cross_sec,'hex')
            Io_tube=(5*sqrt(3)/16)*(do^4-ao^4);
			ybar_i=ybar_calc4hex(gi,di,ti,g_tol);
			Ii=asym_segment_geometry4hex(gi,ybar_i,di,ti,g_tol);
		end
		
		if Ii<Io_tube
% 			find_go=@(go)((1000*(Ii-getIi(go,do,to,g_tol,cross_sec)))^2);
			find_go=@(go)((100000*(Ii-getIi(go,do,to,g_tol,cross_sec))));
			go=fsolve(find_go,gi*do/di,optimoptions('fsolve','algorithm','levenberg-marquardt','FunctionTolerance',1e-20,'StepTolerance',1e-20));
		else
			go=0;
		end
	end
end