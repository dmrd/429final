function [d] = dist(p1,p2)
  dx = p1(1) - p2(1);
  dy = p1(2) - p2(2);
  d = sqrt(dx*dx + dy*dy);
end

