function Ix=asym_segment_geometry4(g,ybar,do,t,g_tol)
% EXPECTS A SCALAR VALUE OF g AND ybar. Make sure they're positive numbers.
% See PDF 'circular segment moment of inertia', page 3 in Literature folder.
% Still need parallel axis theorem because this calculates I with the axes
% at the center of the circle. In the coordinates in that formula, we need
% Ix.

r_out=do/2;
r_in=r_out-t;

% Tube geometry
A_tube=pi*(r_out^2-r_in^2);
Ix_tube=pi/4*(r_out^4-r_in^4);

if g >= do-t && g<do     % We're cutting down to or past the inner wall
    a=g-r_out;
    alpha_out=acos(a/r_out);

    % Outer diameter segment
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));
    Ix_seg_out=(r_out^4)/4*(alpha_out-sin(alpha_out)*cos(alpha_out)+2*sin(alpha_out)^3*cos(alpha_out));
%     Iy_seg_out=(r_out^4)/12*(3*alpha_out-3*sin(alpha_out)*cos(alpha_out)-2*sin(alpha_out)^3*cos(alpha_out));
    
    A_center=A_seg_out;
    Ix_center=Ix_seg_out;

elseif g>= r_out && g<do-t  % We're cutting down to between the radius and inner wall    
    a=g-r_out;
    alpha_out=acos(a/r_out);
    alpha_in=acos(a/r_in);
    
    % Outer diameter segment
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));
    Ix_seg_out=(r_out^4)/4*(alpha_out-sin(alpha_out)*cos(alpha_out)+2*sin(alpha_out)^3*cos(alpha_out));
    
    % Inner diameter segment
    A_seg_in=(r_in^2)*(alpha_in-sin(alpha_in)*cos(alpha_in));
    Ix_seg_in=(r_in^4)/4*(alpha_in-sin(alpha_in)*cos(alpha_in)+2*sin(alpha_in)^3*cos(alpha_in));

    % Segment geometry
    A_center=A_seg_out-A_seg_in;
    Ix_center=Ix_seg_out-Ix_seg_in;
    
elseif g>t  && g<r_out   % We're cutting less than the radius but at least past the thickness
    a=r_out-g;
    alpha_out=acos(a/r_out);
    alpha_in=acos(a/r_in);
    
    % Outer diameter segment
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));
    Ix_seg_out=(r_out^4)/4*(alpha_out-sin(alpha_out)*cos(alpha_out)+2*sin(alpha_out)^3*cos(alpha_out));
    
    % Inner diameter segment
    A_seg_in=(r_in^2)*(alpha_in-sin(alpha_in)*cos(alpha_in));
    Ix_seg_in=(r_in^4)/4*(alpha_in-sin(alpha_in)*cos(alpha_in)+2*sin(alpha_in)^3*cos(alpha_in));

    % Segment geometry
    A_seg=A_seg_out-A_seg_in;
    Ix_seg=Ix_seg_out-Ix_seg_in;
    
    % Cut tube geometry
    A_center=A_tube-A_seg;
    Ix_center=Ix_tube-Ix_seg;
    
elseif g<=t && g>=g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    a=r_out-g;
    alpha_out=acos(a/r_out);
    
    % Outer diameter segment
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));
    Ix_seg_out=(r_out^4)/4*(alpha_out-sin(alpha_out)*cos(alpha_out)+2*sin(alpha_out)^3*cos(alpha_out));
    
    % Segment geometry
    A_seg=A_seg_out;
    Ix_seg=Ix_seg_out;
    
    % Cut tube geometry
    A_center=A_tube-A_seg;
    Ix_center=Ix_tube-Ix_seg;
    
else   %If we're cutting through less than our tolerance, say we have no cut
    A_center=A_tube;
    Ix_center=Ix_tube;
    
end

A=A_center;
Ix=Ix_center-A*ybar^2;   % Use parallel axis theorem to get it about ybar. I_point=I_centroid+a*d^2, and I_center = I_point
end