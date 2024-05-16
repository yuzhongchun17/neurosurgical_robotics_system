function A=area_calchex(g,wo,t,g_tol)
% This gets the ybar of a single notched tube.
% EXPECTS A SCALAR VALUE OF g. Make sure it's getting a positive number.
% Moved away from the York et al equations to the one in the 'circular
% segment moment of inertia' PDF in the Literature folder. They're
% consistent with what we'll use for the I equations.

a = wo-(2/sqrt(3))*t; % width of inner side of hexagonal tube
r = wo*sqrt(3)/2;

% Tube geometry
A_tube=3*sqrt(3)*(wo^2-a^2)/2;

if g >= 2*r-t && g<=2*r     % We're cutting down to or past the inner wall
    % 1
    % Outer diameter segment about origin
    d = 2*r-g; % distance not cut
    c = wo+d*2*tand(30); % length of bottom side of trapezoid remaining after cut
    A = 0.5*(c+wo)*d;
  
elseif g> r && g<=2*r-t  % We're cutting between the inner walls   
    % 2
    % Outer diameter segment about origin
    d = 2*r-g; % distance not cut
    b = d-t; % distance from inner wall to end of cut
    c = wo+2*tand(30)*d; % length of bottom side of outer trapezoid remaining after cut
    k = a+2*tand(30)*b; % length of bottom side of inner trapezoid remaining after cut
    area_f = 0.5*d*(wo+c); % area of trapezoid if entirely full
    area_r = 0.5*b*(a+k); % area of hollow section of trapezoid
    A = area_f-area_r; % total area

    
elseif g>t && g<=r  % We're cutting between the inner walls   
    % 3
    % Outer diameter segment about origin
    
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_2 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_2; % same as above elseif statement (as are the following commands)
    b = d-t;
    c = wo+2*tand(30)*d;
    k = a+2*tand(30)*b;
    area_f = 0.5*d*(wo+c);
    area_r = 0.5*b*(a+k);
    area_2 = area_f-area_r;

    % Finding total area
    A = (A_tube-area_2);


elseif g<=t && g>g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % 4
    
    % This calculation is performed by taking the section cut away and
    % calculating values of it, then subtracting them from the values
    % calculated from the total cross-section
    g_1 = 2*r-g; % complement of cut depth to analyze removed section
    d = 2*r-g_1; % same as above elseif statement (as are the following commands)
    c = wo+d*2*tand(30);
    area_1 = 0.5*(c+wo)*d;

    % Finding total area    
    A = (A_tube-area_1);

    
else   %If we're cutting through less than our tolerance, say we have no cut
    A=A_tube;

end