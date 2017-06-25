classdef Bond
    
    properties
        r;
        spot;
    end
    
    methods
        function o=Bond(r)
            o.r=r;
            o.spot=1;
        end
        
        function [prices,times]=simulatePrices(o,nPaths,nSteps,T)
            dt=T/nSteps;
            times=dt:dt:T;
            prices=repmat(horzcat(1,exp(o.r*times)),nPaths,1);
        end
    end
   
    
end