function Ix=asym_segment_geometry4sq(g,ybar,wo,t,g_tol)
% EXPECTS A SCALAR VALUE OF g AND ybar. Make sure they're positive numbers.

r_out=wo/2;
wi=wo-2*t;

% Tube geometry
A_tube=wo^2-wi^2;
Ix_tube=(wo^4-wi^4)/12;
a=wo-g;
b=wo-g-t;

if g >= wo-t && g<wo     % We're cutting down to or past the inner wall

    % Outer diameter segment about origin
    A_seg_out=wo*a;
    ybar_out=0.5*(wo-a);
    Ix_seg_out=(1/12)*wo*a^3;
    
    A_center=A_seg_out;
    Ix_origin=Ix_seg_out+A_seg_out*ybar_out^2;

elseif g> t && g<wo-t  % We're cutting between the inner walls   

    % Outer diameter segment about origin
    A_seg_out=wo*a;
    ybar_out=0.5*(wo-a);
    Ix_seg_out=(1/12)*wo*a^3+A_seg_out*ybar_out^2;  
    
    % Inner diameter segment about origin
    A_seg_in=wi*b; 
    ybar_in=0.5*(wi-b);
    Ix_seg_in=(1/12)*wi*b^3+A_seg_in*ybar_in^2;

    % Segment geometry about origin
    A_center=A_seg_out-A_seg_in;
    Ix_origin=Ix_seg_out-Ix_seg_in;

elseif g<=t && g>=g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance

    % Outer Tube segment being cut out
    ybar_out=0.5*(wo-g);
    A_seg_out=wo*g;
    Ix_seg_out=(1/12)*wo*g^3;
    
    % Segment geometry about origin
    A_seg=A_seg_out;
    Ix_seg=Ix_seg_out+A_seg_out*ybar_out^2;
    
    % Cut tube geometry about origin
    A_center=A_tube-A_seg;
    Ix_origin=Ix_tube-Ix_seg;
    
else   %If we're cutting through less than our tolerance, say we have no cut
    A_center=A_tube;
    Ix_origin=Ix_tube;
end

A=A_center;
Ix=Ix_origin-A*ybar^2;   % Use parallel axis theorem to get it about ybar. I_point=I_centroid+A*d^2, and I_origin = I_point
end