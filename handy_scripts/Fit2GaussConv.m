function [estimates,ConvRescaleFactor,SumSquares] = Fit2GaussConv(ydata, ref, SD1, SD2, SD3, SD4)
% Call fminsearch with a random starting point.
start_point = rand(1,4);
model = @ConvSumGauss;
options = optimset('MaxFunEvals',10000,'MaxIter',10000);
%estimates = fminsearchbnd(model, start_point, [0 0 0 0], [],options);
estimates = fminsearch(model, start_point, options);
estimates = estimates/sum(estimates);
% ConvSumGauss accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for conv(EPIDprofile,(w1*g1+...+w4g4),'same'),
% and the TPS dose profile. FMINSEARCH only needs sse, but we want
% to plot the FittedCurve at the end.

    function [sse, FittedCurve] = ConvSumGauss(params)
        w1 = params(1);
        w2 = params(2);
        w3 = params(3);
        w4 = params(4);       
        % MAKE GAUSSIANS
        x=1:1000;    m=(max(x)-min(x))/2+0.5; 
        s1=SD1/.523; g1=gauss_distribution(x,m,s1);   
        s2=SD2/.523; g2=gauss_distribution(x,m,s2);   
        s3=SD3/.523; g3=gauss_distribution(x,m,s3);  
        s4=SD4/.523; g4=gauss_distribution(x,m,s4);       
        gsum=(w1*g1+w2*g2+w3*g3+w4*g4)/trapz(w1*g1+w2*g2+w3*g3+w4*g4);
        temp=ref;
        FittedCurve = conv(ydata,gsum,'same');
% rescale FittedCurve so that is has approx the same value of TPS at the max of the TPS

        [values,indexes]=sort(ref(1:end/2));        firstmax=indexes(end);
        
        [values,indexes]=sort(ref(end/2+1:end));    secondmax=size(ref,2)/2+indexes(end);        

        ConvRescaleFactor=(ref(firstmax)/FittedCurve(firstmax)+ref(secondmax)/FittedCurve(secondmax))/2;
        FittedCurve=FittedCurve*ConvRescaleFactor;
        
        ErrorVector = FittedCurve - ref;
        
        % FIND EDGES using the tps ref map
        slope=diff(ref);
        [value,index1]=max(slope);
        %index2=index1+57; %76pixels=4cm or 57pixels=3cm 38pixels=2cm inside the field edge
        [value,index4]=min(slope);
        %index3=index4-57; %76pixels=4cm or 57pixels=3cm 38pixels=2cm inside the field edge
                
         %sse = sum(abs(ErrorVector([index1:index2,index3:index4])));
     %    sse = sum(abs(ErrorVector([(index1+10):firstmax,secondmax:(index4-10)])));
      %   sse = sum(abs(ErrorVector([firstmax-2:firstmax+2,secondmax-2:secondmax+2])));
    %sse = sum(abs(ErrorVector([140:190])));
         %sse = sum(abs(ErrorVector(:)));
         a=index1;
         b=firstmax;
         c=secondmax;
         d=index4;
         %sse= sum(abs(ErrorVector([([a:b,c:d])])));
         sse= sum((ErrorVector([([a:b,c:d])])).^2);
       %  sse= sum(ErrorVector([a:d]).^2);
         SumSquares=sse;

    end
 sprintf('You have minimized [Conv(EPID,SumGaussians)-TPS_Dose] between these two sets of pixel indeces:')
 display([a b c d])
end