function A=area_calc(g,do,t,g_tol)
% This gets the ybar of a single notched tube.
% EXPECTS A SCALAR VALUE OF g. Make sure it's getting a positive number.
% Moved away from the York et al equations to the one in the 'circular
% segment moment of inertia' PDF in the Literature folder. They're
% consistent with what we'll use for the I equations.

r_out=do/2;
r_in=r_out-t;

if g >= do-t && g<do   % We're cutting down to or past the inner wall
    % Outer Circular Segment
    alpha_out=acos((g-r_out)/r_out); 
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));

    % Area
    A=A_seg_out;

elseif g>= r_out && g<do-t  % We're cutting down to between the radius and inner wall  
    % Outer Circular Segment
    alpha_out=acos((g-r_out)/r_out); 
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));

    % Inner Circular Segment
    alpha_in=acos((g-r_out)/r_in);
    A_seg_in=(r_in^2)*(alpha_in-sin(alpha_in)*cos(alpha_in));

    A=A_seg_out-A_seg_in;
    
elseif g>t  && g<r_out  % we're cutting out less than the radius, so we need to subtract out the segment from the tube
    % Outer Circular Segment
    alpha_out=acos((r_out-g)/r_out); 
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));

    % Inner Circular Segment
    alpha_in=acos((r_out-g)/r_in); 
    A_seg_in=(r_in^2)*(alpha_in-sin(alpha_in)*cos(alpha_in));

    A_seg=A_seg_out-A_seg_in;
    A_tube=pi*(r_out^2-r_in^2);
    
    A=A_tube-A_seg;
    
elseif g<=t && g>g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % Outer Circular Segment
    alpha_out=acos((r_out-g)/r_out);
    A_seg_out=(r_out^2)*(alpha_out-sin(alpha_out)*cos(alpha_out));

    A_seg=A_seg_out;
    A_tube=pi*(r_out^2-r_in^2);
    
    A=A_tube-A_seg; %b/c ybar of the tube is zero-- centered about is origin
        
else   %If we're cutting through less than our tolerance, say we have no cut
    
    A=pi*(r_out^2-r_in^2);
end

end