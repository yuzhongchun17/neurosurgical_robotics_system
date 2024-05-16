function A=area_calcsq(g,wo,t,g_tol)
% This gets the ybar of a single notched tube.
% EXPECTS A SCALAR VALUE OF g. Make sure it's getting a positive number.
% Moved away from the York et al equations to the one in the 'circular
% segment moment of inertia' PDF in the Literature folder. They're
% consistent with what we'll use for the I equations.
wi=wo-2*t;
a=wo-g;
b=wo-g-t;
A_tube=wo^2-wi^2;

if g >= wo-t && g<wo   % We're cutting down to or past the inner wall
    % Outer Circular Segment
    A_seg_out=wo*a;
    % Area
    A=A_seg_out;

elseif g>t && g<wo-t  % We're cutting between the inner walls
    % Outer Circular Segment
    A_seg_out=wo*a;
    A_seg_in=wi*b;
    A=A_seg_out-A_seg_in;
    
elseif g<=t && g>g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % Outer Circular Segment being removed
    A_seg=wo*g;    
    A=A_tube-A_seg; %b/c ybar of the tube is zero-- centered about is origin
        
else   %If we're cutting through less than our tolerance, say we have no cut
    A=A_tube;
end

end