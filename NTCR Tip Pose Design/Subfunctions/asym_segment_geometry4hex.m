function Ix=asym_segment_geometry4hex(g,ybar,w,t,g_tol)
% EXPECTS A SCALAR VALUE OF g AND ybar. Make sure they're positive numbers.

a = w-(2/sqrt(3))*t; % width of inner side of hexagonal tube
r = w*sqrt(3)/2;

% Tube geometry
area_tube=3*sqrt(3)*(w^2-a^2)/2;
I_tube=5*sqrt(3)*(w^4-a^4)/16;

if g >= 2*r-t && g<=2*r     % We're cutting down to or past the inner wall
    % 1
    % Outer diameter segment about origin
    d = 2*r-g; % distance not cut
    c = w+d*2*tand(30); % length of bottom side of trapezoid remaining after cut
    area = 0.5*(c+w)*d;
    
    Ix_origin =d^3*(w^2+4*w*c+c^2)/(36*(w+c))+area*ybar^2;
   
  
elseif g> r && g<=2*r-t  % We're cutting between the inner walls   
    % 2
    % Outer diameter segment about origin
    d = 2*r-g; % distance not cut
    b = d-t; % distance from inner wall to end of cut
    c = w+2*tand(30)*d; % length of bottom side of outer trapezoid remaining after cut
    k = a+2*tand(30)*b; % length of bottom side of inner trapezoid remaining after cut
    area_f = 0.5*d*(w+c); % area of trapezoid if entirely full
    area_r = 0.5*b*(a+k); % area of hollow section of trapezoid
    area = area_f-area_r; % total area
    
    % full trapezoid
    ybar_f = (d/3)*(2*w+c)/(w+c)+g-r;
    I_fc = (d^3)*(w^2+4*w*c+c^2)/(36*(w+c));
    
    % removed trapezoid
    ybar_r = (b/3)*(2*a+k)/(a+k)+g-r;
    I_rc = (b^3)*(a^2+4*a*k+k^2)/(36*(a+k));
    
    % total thing
    Ix_origin = I_fc+area_f*(ybar_f)^2-(I_rc+area_r*(ybar_r)^2);
    
    
elseif g>t && g<=r  % We're cutting between the inner walls   
    % 3
    % Outer diameter segment about origin
    
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_2 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_2; % same as above elseif statement (as are the following commands)
    b = d-t;
    c = w+2*tand(30)*d;
    k = a+2*tand(30)*b;
    area_f = 0.5*d*(w+c);
    area_r = 0.5*b*(a+k);
    area_2 = area_f-area_r;
    
    % full trapezoid
    ybar_f = (d/3)*(2*w+c)/(w+c)+g_2-r;
    I_fc = (d^3)*(w^2+4*w*c+c^2)/(36*(w+c));
    
    % removed trapezoid
    ybar_r = (b/3)*(2*a+k)/(a+k)+g_2-r;
    I_rc = (b^3)*(a^2+4*a*k+k^2)/(36*(a+k));
    
    % Finding Ix_origin and ybar of removed section
    Ix_origin_2 = I_fc+area_f*(ybar_f)^2-(I_rc+area_r*(ybar_r)^2);
    ybar_2 = (ybar_f*area_f-ybar_r*area_r)/area_2;
    % END stuff from 2
    
    % Finding total area and total Ix_origin
    area = (area_tube-area_2);
    Ix_origin = I_tube-Ix_origin_2;

    
elseif g<=t && g>g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % 4
    
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_1 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_1; % same as above elseif statement (as are the following commands)
    c = w+d*2*tand(30);
    area_1 = 0.5*(c+w)*d;
    
    % Finding ybar and Ix_origin from removed section
    ybar_1 = (d/3)*(2*w+c)/(w+c)+g_1-r;
    Ix_origin_1 =d^3*(w^2+4*w*c+c^2)/(36*(w+c))+area_1*ybar_1^2;


    % Finding total area and total Ix_origin    
    area = (area_tube-area_1);
    Ix_origin = I_tube-Ix_origin_1;
    
    
else   %If we're cutting through less than our tolerance, say we have no cut
    area = area_tube;
    Ix_origin = I_tube;
end

Ix=Ix_origin-area*ybar^2;   % Use parallel axis theorem to get it about ybar. I_point=I_centroid+A*d^2, and I_origin = I_point
end