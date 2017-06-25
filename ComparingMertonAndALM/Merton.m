classdef Merton
    
    properties
        T;
        mu;
        sigma;
        riskyAsset;
        risklessAsset;
        initialWealth;
        utility;
    end
    
    methods
        function o=Merton(initialWealth,T,mu,sigma)
            o.initialWealth=initialWealth;
            o.T=T;
            o.mu=mu;
            o.sigma=sigma;
            %o.riskyAsset=BlackScholesModel(1,o.mu,o.sigma,T);
            o.riskyAsset=BlackScholesModel(2056.32,o.mu,o.sigma,T);
            o.risklessAsset=Bond(0);
            %o.utility=PowerUtility(0.5);
            %o.utility=ExponentialUtility(1);
            o.utility=ExponentialUtility(0.00002);
        end
        
        function terminalUtility=simulateTradings(o,nPaths,nSteps,perturbation)
            isExpo=isa(o.utility,'ExponentialUtility');
%             pi=(o.riskyAsset.mu-o.risklessAsset.r)/(o.utility.lambda*o.riskyAsset.sigma^2)+perturbation;
%             if isExpo
%                 pi=o.riskyAsset.mu/(o.initialWealth*o.riskyAsset.sigma^2*o.utility.lambda)+perturbation;
%             end
            rng('default');
            pi=o.riskyAsset.mu/(o.initialWealth*o.riskyAsset.sigma^2*o.utility.lambda)+perturbation;
            riskyPrices=o.riskyAsset.simulatePricePaths(nPaths,nSteps);
            risklessPrices=o.risklessAsset.simulatePrices(nPaths,nSteps,o.T);
            riskyQuantities=zeros(nPaths,nSteps);
            risklessQuantities=zeros(nPaths,nSteps);
            totalWealth=zeros(nPaths,nSteps);
            riskyQuantities(:,1)=o.initialWealth*pi/o.riskyAsset.S0;
            risklessQuantities(:,1)=o.initialWealth*(1-pi)/o.risklessAsset.spot;
            for i=1:nSteps
                    totalWealth(:,i)=riskyQuantities(:,i).*riskyPrices(:,i+1)+risklessQuantities(:,i).*risklessPrices(:,i+1);
%                     if isExpo
%                         pi=o.riskyAsset.mu./(totalWealth(:,i)*o.riskyAsset.sigma^2*o.utility.lambda)+perturbation;
%                     end 
                    pi=o.riskyAsset.mu./(totalWealth(:,i)*o.riskyAsset.sigma^2*o.utility.lambda)+perturbation;
                    riskyQuantities(:,i+1)=totalWealth(:,i).*pi./riskyPrices(:,i+1);
                    risklessQuantities(:,i+1)=totalWealth(:,i).*(1-pi)./risklessPrices(:,i+1);
             end
             totalWealth;
             riskyQuantities;
             risklessQuantities;

             terminalUtility=o.utility.computeExpectedUtility(totalWealth(:,end));
        end
        
        function o=addRiskyAsset(o,riskyAsset)
            o.riskyAsset=riskyAsset;
        end
        function o=addRisklessAsset(o,risklessAsset)
            o.risklessAsset=risklessAsset;
        end
        function o=addUtitlity(o,utility)
            o.utility=utility;
        end
        
    end

end