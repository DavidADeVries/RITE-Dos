function weightEstimates = Fit2GaussConv(yData, ref, stDevs, epidDimsAtIsoInCm, settings)
% Call fminsearch with a random starting point.

numGaussians = length(stDevs);

numTrials = settings.numTrialsForGaussianCorrection;
estimates = zeros(numTrials, numGaussians);

startPoints = rand(numTrials, numGaussians);

for i=1:numTrials        
    model = @ConvSumGauss;
    optimizeFn = @(weights) model(weights, yData, ref, stDevs, epidDimsAtIsoInCm(1));
    
    options = optimset('MaxFunEvals', settings.numIterationsForOptimization, 'MaxIter', settings.numIterationsForOptimization);
    
    trialEstimates = fminsearchbnd(optimizeFn, startPoints(i,:), [0 0 0 0], [], options);
    trialEstimates = trialEstimates/sum(trialEstimates);
    
    estimates(i,:) = trialEstimates;
end

% average the trials
weightEstimates = mean(estimates,1);

end

% ** HELPER FUNCTIONS **

% ConvSumGauss accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for conv(EPIDprofile,(w1*g1+...+w4g4),'same'),
% and the TPS dose profile. FMINSEARCH only needs sse, but we want
% to plot the FittedCurve at the end.

function [sse, FittedCurve] = ConvSumGauss(weights, yData, ref, stDevs, epidDimAtIsoInCm)

% MAKE GAUSSIANS

x = 1:1000;
m = (max(x)-min(x))/2+0.5;

s = stDevs ./ epidDimAtIsoInCm;

gaussians = gaussDistribution(x, m, s);

gSum = (sum(weights.*gaussians))/trapz(sum(weights.*gaussians));

FittedCurve = conv(yData, gSum, 'same');
% rescale FittedCurve so that is has approx the same value of TPS at the max of the TPS

[~,indexes] = sort(ref(1:end/2));
firstMax = indexes(end);

[~,indexes] = sort(ref(end/2+1:end));
secondMax = size(ref,2)/2+indexes(end);

ConvRescaleFactor = (ref(firstMax) / FittedCurve(firstMax) + ref(secondMax) / FittedCurve(secondMax)) /2;
FittedCurve = FittedCurve*ConvRescaleFactor;

ErrorVector = FittedCurve - ref;

% FIND EDGES using the tps ref map
slope = diff(ref);
[~,index1] = max(slope);
%index2=index1+57; %76pixels=4cm or 57pixels=3cm 38pixels=2cm inside the field edge
[~,index4] = min(slope);
%index3=index4-57; %76pixels=4cm or 57pixels=3cm 38pixels=2cm inside the field edge

%sse = sum(abs(ErrorVector([index1:index2,index3:index4])));
%    sse = sum(abs(ErrorVector([(index1+10):firstmax,secondmax:(index4-10)])));
%   sse = sum(abs(ErrorVector([firstmax-2:firstmax+2,secondmax-2:secondmax+2])));
%sse = sum(abs(ErrorVector([140:190])));
%sse = sum(abs(ErrorVector(:)));
a = index1;
% b=firstMax;
% c=secondMax;
d = index4;
%sse= sum(abs(ErrorVector([([a:b,c:d])])));
%          sse= sum((ErrorVector([([a:b,c:d])])).^2);
sse = sum(ErrorVector(a:d).^2);


end