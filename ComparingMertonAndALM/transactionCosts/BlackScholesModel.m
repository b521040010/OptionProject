classdef BlackScholesModel < Model1D
    
    properties
        S0;
        mu;
        sigma;
        T;
    end
    
    methods
        function model = BlackScholesModel(spot,mu,sigma,T)            
            model.S0 = spot;
            model.mu = mu;
            model.sigma = sigma;
            model.T = T;
        end
       
        function [S, times] = simulatePricePaths( model, nPaths, nSteps )
            dt = model.T/nSteps;
            dW = randn( nPaths, nSteps );
            ds = (model.mu - 0.5*model.sigma^2)*dt + model.sigma*sqrt(dt)*dW;
            s = log( model.S0 ) + cumsum(ds,2);
            S = horzcat(model.S0*ones(nPaths,1),exp(s));
            times = linspace(0,model.T,nSteps+1);
        end
        
        function res = pdf(bsm,x)
        % Compute the pdf of the model
            [m,s] = logNormalParameters(bsm);      
            res = exp(-((-m + log(x)).^2/(2*s^2)))./(sqrt(2*pi)*s*x);            
        end         
        
        function res = logPdf(bsm,x)
        % Compute the log pdf of the model
            [m,s] = logNormalParameters(bsm);      
            res = -((-m + log(x)).^2/(2*s^2)) - log((sqrt(2*pi)*s*x));            
        end          
        
        function r = mean(bsm)
        % Mean of the model
            [m,s] = logNormalParameters(bsm);   
            r = exp(m + s^2*0.5);
        end
        
        function r = sd(bsm)
        % SD of the model
            [m,s] = logNormalParameters(bsm);
            r = sqrt((exp(s^2)-1)*exp(2*m + s^2 ));
        end
        
        function [m,s] = logNormalParameters(bsm)
        % Parameters definining assoicated log normal distribution
            m = (bsm.mu - 0.5*bsm.sigma.^2) * bsm.T + log(bsm.S0);
            s = bsm.sigma*sqrt(bsm.T);    
        end
        
        function model = fitLogNormalReturn(bsm, m, s)
            % Fit the black scholes model to a log normal distribution
            % with center parameter m and scale parameter s
            bsm.sigma = s/sqrt(bsm.T);
            bsm.mu = m/bsm.T + 0.5*bsm.sigma.^2;
            model = bsm;
        end
        
        function model = fit( bsm, S0, T, returns, weights)
            % Fit the model to historic return data            
            fittedDist = fitdist( returns + 1, 'LogNormal', 'frequency', weights);
            m = fittedDist.mu;
            s = fittedDist.sigma;
            bsm.S0 = S0;
            bsm.T = T;
            model = bsm.fitLogNormalReturn(m,s);
        end
        
        function wayPoints = getWayPoints(model)
        % Returns some standard way points for accurate numeric integration
            mean = model.mean();
            sd = model.sd();
            wayPoints = (-10:10)*sd + mean;
            wayPoints = wayPoints( wayPoints>0 );            
        end
        
        function [ prices, deltas ] = price(o, r, isPut, strike, spot)
            %BLACKSCHOLESPRICE Computes the black scholes price
            %  for an array of European options
            assert( islogical( isPut ));
            vol = o.sigma;
            if (nargin<5)
                spot = o.S0;
            end

            d1 = 1./(vol .* sqrt(o.T)) .* (log( spot./strike ) + (r+0.5*vol.^2).*o.T);
            d2 = 1./(vol .* sqrt(o.T)) .* (log( spot./strike ) + (r-0.5*vol.^2).*o.T);

            callPrice = spot .* normcdf(d1) - exp( -r .* o.T ) .* strike .* normcdf(d2);
            putPrice = -spot .* normcdf(-d1) + exp( -r .* o.T ) .* strike .* normcdf(-d2);
            prices = callPrice.*(1-isPut) + isPut.*putPrice;
            deltas = normcdf(d1) - 1 * isPut;
        end        
        
        function sigma = impliedVolatility( m, r, strike, isPut, optionPrice )
        % Compute the implied volatility of an option
        %optionPrice=optionPrice/100;
            function priceDiff = f( sigma )
                m.sigma = sigma;
                priceDiff = m.price( r, isPut, strike ) - optionPrice;
            end
            options = optimset('fsolve');
            options = optimset(options, 'Display', 'off');
            [sigma,~, ret] = fsolve( @f, 0.1, options );
            if ret<=0
                fprintf('Cannot find implied volatility\n');
                fprintf( 'r=%f, T=%f, S0=%f, strike=%f, isPut=%f, optionPrice%f\n', r, m.T, m.S0, strike, isPut, optionPrice );
                error('Failed');
            end
        end
        
    end
end