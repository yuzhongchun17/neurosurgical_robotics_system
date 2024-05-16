function gi=calc_gi(go,tube_geo,the_options)
% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
g_relation=the_options{2};
cross_sec=the_options{1};

% in the other script, it's tubes=[do,to,di,ti];
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);

% These hold true for circles and squares
r_out_i=di/2;      % outer raduis of inner tube
r_in_i=r_out_i-ti;   % inner radius of inner tube

% These hold true for hexagons
ai=di-(2/sqrt(3))*ti;	% inner wall side length of inner tube

% Now for the acutal calculation
if strcmp(g_relation,'Weq')
	w_nom=do-go;
	gi=di-w_nom;
	
elseif strcmp(g_relation,'Gratio')
	gi=go*di/do;
	
elseif strcmp(g_relation,'EIeq')
	if strcmp(cross_sec,'sq')
		Ii_tube=(di^4-(di-2*ti)^4)/12;
		ybar_o=ybar_calc4sq(go,do,to,g_tol);
		Io=asym_segment_geometry4sq(go,ybar_o,do,to,g_tol);
	elseif strcmp(cross_sec,'circ')
		Ii_tube=pi/4*(r_out_i^4-r_in_i^4);
		ybar_o=ybar_calc4(go,do,to,g_tol);
		Io=asym_segment_geometry4(go,ybar_o,do,to,g_tol);
	elseif strcmp(cross_sec,'hex')
		Ii_tube=(5*sqrt(3)/16)*(di^4-ai^4);
		ybar_o=ybar_calc4hex(go,do,to,g_tol);
		Io=asym_segment_geometry4hex(go,ybar_o,do,to,g_tol);
	end
	
	if Io<Ii_tube
% 		find_gi=@(gi)((1000*(Io-getIi(gi,di,ti,g_tol,cross_sec)))^2);
% 		find_gi=@(gi)((100000*(Io-getIi(gi,di,ti,g_tol,cross_sec))));
		find_gi=@(gi)((100*(Io-getIi(gi,di,ti,g_tol,cross_sec))));
		gi=fsolve(find_gi,0.25*go*di/do,optimoptions('fsolve','algorithm','levenberg-marquardt','FunctionTolerance',1e-20,'StepTolerance',1e-20,'MaxFunctionEvaluations',90*10^4));
	else
		gi=0;
	end
end
end