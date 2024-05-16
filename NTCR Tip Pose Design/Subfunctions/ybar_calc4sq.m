function ybar=ybar_calc4sq(g,wo,t,g_tol)
% This gets the ybar of a single notched tube.
% EXPECTS A SCALAR VALUE OF g. Make sure it's getting a positive number.
wi=wo-2*t;
a=wo-g; % width of outer segment rectangle left after cut
b=wo-g-t;   % width of inner segment rectangle remaining after cut

if g >= wo-t && g<wo   % We're cutting down to or past the inner wall
    ybar=0.5*(wo-a);

elseif g> t && g<wo-t  % We're cutting between the inner walls
    % Outer Segment
    ybar_out=0.5*(wo-a);
    A_seg_out=wo*a;

    % Inner Segment
    ybar_in=0.5*(wi-b);
    A_seg_in=wi*b;

    A_seg=A_seg_out-A_seg_in;
    
    % ybar
    ybar=(ybar_out*A_seg_out-ybar_in*A_seg_in)/A_seg;
    
elseif g<=t && g>g_tol  % we aren't even cutting through the whole wall thickness but still above the tolerance
    % Outer Tube Segment Being Removed
    ybar_out=0.5*(wo-g);
    A_seg_out=wo*g;

    A_seg=A_seg_out;
    A_tube=wo^2-wi^2;
    
    ybar_seg=ybar_out;
    ybar=ybar_seg*A_seg/(A_tube-A_seg); %b/c ybar of the tube is zero-- centered about its origin
        
else   %If we're cutting through less than our tolerance, say we have no cut
    ybar=0;
end

end