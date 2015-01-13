function [ d ] = distance_vector_to_rect( pt, theta, rect )

    b = pt(2) - pt(1)*tan(theta);
    a = tan(theta);
    
    xmin = rect(1); xmax = rect(1) + rect(3);
    ymin = rect(2); ymax = rect(2) + rect(4);
    intersections = [ xmin, (a * xmin + b) ; ...
                      xmax, (a * xmax + b) ; ...
                      (ymin - b)/a, ymin ; ...
                      (ymax - b)/a, ymax
                    ];
     distances = [];            
     for i = 1:4
         int = intersections(i,:);
         if int(1) >= xmin && int(1) <= xmax && int(2) >= ymin && int(2) <= ymax
             distances = [distances ; norm(int - pt)];
         else
             distances = [distances ; NaN];
         end
     end
     
     d = min(distances);

                
end

