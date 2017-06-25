classdef StockGBM
    
    properties
        spot;
        mu;
        sigma;
    end
    
    methods
        function o=Stock(spot,mu,sigma)
            o.spot=spot;
            o.mu=mu;
            o.sigma=sigma;
        end
        
        function [S,times]=simulateBSPrices(o,nPaths,nSteps,T)
            dt=T/nSteps;
            rn=randn(nPaths,nSteps);
            logS0=log(o.spot);
            dlogS=(o.mu-0.5*o.sigma^2)*dt+o.sigma*sqrt(dt)*rn;
            logS=logS0+cumsum(dlogS,2);
            S=exp(logS);
            times=dt:dt:T;
        end
    end
   
    
end