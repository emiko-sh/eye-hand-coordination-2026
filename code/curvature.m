function [invr, v] = curvature(TheoryX, TheoryY)
    % 1. Unit conversion (pixels to mm)
    x = TheoryX * 0.316;
    y = TheoryY * 0.32;

    % 2. Calculate velocity (vx, vy)
    % Use central difference with vector operations for better performance
    span_v = 7;% Set span for central difference (adjust based on data noise)
    a = floor(span_v/2);
    
    vx = nan(size(x));
    vy = nan(size(y));
    
    % Define index range to avoid loops
    idx_v = (a + 1) : (length(x) - a);
    vx(idx_v) = (x(idx_v - a) - x(idx_v + a)) / span_v;
    vy(idx_v) = (y(idx_v - a) - y(idx_v + a)) / span_v;

    % 3. Calculate acceleration (ax, ay)
    span_a = 11;% Set span for acceleration (larger span helps smooth out noise)
    b = floor(span_a/2);
    
    ax = nan(size(vx));
    ay = nan(size(vy));
    
    % Calculate acceleration within the range where velocity data exists
    idx_a = (101) : (length(vx) - 100); 
    ax(idx_a) = (vx(idx_a - b) - vx(idx_a + b)) / span_a;
    ay(idx_a) = (vy(idx_a - b) - vy(idx_a + b)) / span_a;

    % 4. Calculate velocity magnitude, radius of curvature, and curvature
    v_mag = sqrt(vx.^2 + vy.^2); 
    
    % Formula for radius of curvature: R = v^3 / |vx*ay - ax*vy|
    denominator = vx .* ay - ax .* vy;
    r = abs((v_mag.^3) ./ denominator);
    
    % Curvature is the reciprocal of the radius of curvature
    invr = 1 ./ r;
    
    % Replace zero or infinite curvature with NaN for cleaner data
    invr(invr == 0 | isinf(invr)) = NaN;

    % 5. Scaling for visualization
    % Multiply by an arbitrary number to keep the values roughly the same.
    v = v_mag * 200; 
end
