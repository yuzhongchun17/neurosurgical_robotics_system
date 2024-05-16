function Sec_mom_area=getIi(g,do,t,g_tol,cross_sec)
% This just finds the second moment of area (sorry for the confusing name)
    if strcmp(cross_sec,'sq')
        ybar=ybar_calc4sq(g,do,t,g_tol);
        Sec_mom_area=asym_segment_geometry4sq(g,ybar,do,t,g_tol);
    elseif strcmp(cross_sec,'circ')
        ybar=ybar_calc4(g,do,t,g_tol);
        Sec_mom_area=asym_segment_geometry4(g,ybar,do,t,g_tol);
    elseif strcmp(cross_sec,'hex')
        ybar=ybar_calc4hex(g,do,t,g_tol);
        Sec_mom_area=asym_segment_geometry4hex(g,ybar,do,t,g_tol);
    end
end