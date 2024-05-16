function ratio=ratio_calc8(go,phi,tube_geo,the_options)
% the_options=[{cross_sec},{g_relation},g_tol];
g_tol=the_options{3};
g_relation=the_options{2};
cross_sec=the_options{1};
% in the other script, it's tubes=[do,to,di,ti];
do=tube_geo(1); to=tube_geo(2); di=tube_geo(3); ti=tube_geo(4);

% % These hold true for circles and squares
% r_out_o=do/2;      % outer radius of outer tube
% r_in_o=r_out_o-to;   % inner radius of outer tube
% r_out_i=di/2;      % outer raduis of inner tube
% r_in_i=r_out_i-ti;   % inner radius of inner tube
% 
% % These hold true for hexagons
% ao=do-(2/sqrt(3))*to;	% inner wall side length of outer tube
% ai=di-(2/sqrt(3))*ti;	% inner wall side length of inner tube

% Angle of cuts
phi_o=phi(1); phi_i=phi(2);

%{
% Cross-section of Tube w/o cut
% if strcmp(cross_sec,'sq')
%     Io_tube=(do^4-(do-2*to)^4)/12;
%     Ii_tube=(di^4-(di-2*ti)^4)/12;
% elseif strcmp(cross_sec,'circ')
%     Io_tube=pi/4*(r_out_o^4-r_in_o^4);
%     Ii_tube=pi/4*(r_out_i^4-r_in_i^4);
% elseif strcmp(cross_sec,'hex')
% 	Io_tube=(5*sqrt(3)/16)*(do^4-ao^4);
% 	Ii_tube=(5*sqrt(3)/16)*(di^4-ai^4);
% end
%}

% Relate gi to go
gi=calc_gi(go,tube_geo,the_options);
%{
if strcmp(g_relation,'EIeq')   % make the EIs equal
    if strcmp(cross_sec,'sq')
        ybar_o=ybar_calc4sq(go,do,to,g_tol);
        Io=asym_segment_geometry4sq(go,ybar_o,do,to,g_tol);
    elseif strcmp(cross_sec,'circ')
        ybar_o=ybar_calc4(go,do,to,g_tol);
        Io=asym_segment_geometry4(go,ybar_o,do,to,g_tol);
    elseif strcmp(cross_sec,'hex') %this is a work in progress
        ybar_o=ybar_calc4hex(go,do,to,g_tol);
        Io=asym_segment_geometry4hex(go,ybar_o,do,to,g_tol);
    end
    
    if Io<Ii_tube
        find_gi=@(gi)((Io-getIi(gi,di,ti,g_tol,cross_sec)));
        gi=fsolve(find_gi,di/2,optimoptions('fsolve','FunctionTolerance',1e-10));
    else
        gi=0;
    end

elseif strcmp(g_relation,'Weq')    % make the backbone widths equal  
    w=do-go;
    if w<=di    % the diameter of the inner tube is the most we can do
        gi=di-w;
    else
        gi=0;
    end

elseif strcmp(g_relation,'Gratio') % make the inner cut a ratio of the outer cut  
    gi=go*di/do;   % This proportions the inner notch according to the diameters

end
%}

%% Get gammas and Is
if go<g_tol  % If we're below our cut tolerance, we have no cut
    gamma_o=0;
    gamma_i=0;
    I_o=Io_tube;
    I_i=Ii_tube;
else
    if strcmp(cross_sec,'sq')
        gamma_o=ybar_calc4sq(go,do,to,g_tol)*cos(phi_o);
        gamma_i=ybar_calc4sq(gi,di,ti,g_tol)*cos(phi_i);
        I_o=asym_segment_geometry4sq(go,abs(gamma_o),do,to,g_tol);
        I_i=asym_segment_geometry4sq(gi,abs(gamma_i),di,ti,g_tol);
    elseif strcmp(cross_sec,'circ')
        gamma_o=ybar_calc4(go,do,to,g_tol)*cos(phi_o);
        gamma_i=ybar_calc4(gi,di,ti,g_tol)*cos(phi_i);
        I_o=asym_segment_geometry4(go,abs(gamma_o),do,to,g_tol);
        I_i=asym_segment_geometry4(gi,abs(gamma_i),di,ti,g_tol);
     elseif strcmp(cross_sec,'hex')
        gamma_o=ybar_calc4hex(go,do,to,g_tol)*cos(phi_o);
        gamma_i=ybar_calc4hex(gi,di,ti,g_tol)*cos(phi_i);
        I_o=asym_segment_geometry4hex(go,abs(gamma_o),do,to,g_tol);
        I_i=asym_segment_geometry4hex(gi,abs(gamma_i),di,ti,g_tol);
    end
end

%% Finally, calculate the ratio
ratio=(gamma_i-gamma_o)/((I_o+I_i)); % removed E because it cancels out in the ratio, which is what we're really doing here. This is NOT alpha.
end