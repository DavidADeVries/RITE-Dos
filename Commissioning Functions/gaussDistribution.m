function f = gaussDistribution(x, mu, s)

p1 = -.5 * ((x - mu)/s) .^ 2;
p2 = (s * sqrt(2*pi));
f = exp(p1) ./ p2; 

end