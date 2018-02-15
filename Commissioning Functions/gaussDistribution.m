function fns = gaussDistribution(x, mu, stdevs)

numFns = length(stdevs);
lengthX = length(x);

fns = zeros(numFns, lengthX);

for i=1:numFns
    p1 = -.5 * ((x - mu)/stdevs(i)) .^ 2;
    p2 = (stdevs(i) * sqrt(2*pi));
    
    fns(i,:) = exp(p1) ./ p2; 
end

end