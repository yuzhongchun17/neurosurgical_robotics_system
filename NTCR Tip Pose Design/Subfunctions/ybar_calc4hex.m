function ybar=ybar_calc4hex(g,w,t,g_tol)
% This gets the ybar of a single notched tube.
% EXPECTS A SCALAR VALUE OF g. Make sure it's getting a positive number.

a = w-(2/sqrt(3))*t; % width of inner side of hexagonal tube
r = w*sqrt(3)/2; % distance from center of hexagon to midpoint of outer wall
area_tube=3*sqrt(3)*(w^2-a^2)/2; % area of tube

if g >= 2*r-t && g<2*r;   % We're cutting down to or past the inner wall 
    % 1
    d = 2*r-g; % distance not cut
    c = w+d*2/sqrt(3); % length of bottom side of trapezoid remaining after cut
    ybar = (d/3)*(2*w+c)/(w+c)+g-r;
    

elseif g> r && g<=2*r-t; % We're cutting past radius but not past inner wall
    % 2
    d = 2*r-g; % distance not cut
    b = d-t; % distance from inner wall to end of cut
    c = w+2*tand(30)*d; % length of bottom side of outer trapezoid remaining after cut
    k = a+2*tand(30)*b; % length of bottom side of inner trapezoid remaining after cut
    area = (w+d*tand(30))*d-(a+b*tand(30))*b;
    % full trapezoid
    ybar_f = (d/3)*(2*w+c)/(w+c);
    area_f = (w+d*tand(30))*d;
    
    % removed trapezoid
    ybar_r = (b/3)*(2*a+k)/(a+k);
    area_r = (a+b*tand(30))*b;
    
    % total
    ybar = (ybar_f*area_f-ybar_r*area_r)/area+g-r;
 
elseif g>t && g<=r; % cutting through thickness, but not past radius
    % 3
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_2 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_2; % same as above elseif statement
    b = d-t; % same as above elseif statement
    c = w+2*tand(30)*d; % same as above elseif statement
    k = a+2*tand(30)*b; % same as above elseif statement
    area_2 = (w+d*tand(30))*d-(a+b*tand(30))*b;
    % full trapezoid
    ybar_f = (d/3)*(2*w+c)/(w+c);
    area_f = (w+d*tand(30))*d;
    
    % removed trapezoid
    ybar_r = (b/3)*(2*a+k)/(a+k);
    area_r = (a+b*tand(30))*b;
    
    % total
    ybar_2 = (ybar_f*area_f-ybar_r*area_r)/(area_f-area_r)+g_2-r;
    
    ybar = ybar_2*area_2/(area_tube-area_2);

    
elseif g<=t && g>g_tol;  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % Outer Tube Segment Being Removed
    % 4
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_1 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_1; % same as first elseif statement
    c = w+d*2/sqrt(3); % same as first elseif statement
    ybar_1 = (d/3)*(2*w+c)/(w+c)+g_1-r;
    area_1 = 0.5*(c+w)*d;
    
    ybar = ybar_1*area_1/(area_tube-area_1);
    
else   %If we're cutting through less than our tolerance, say we have no cut
    ybar=0;
end

end