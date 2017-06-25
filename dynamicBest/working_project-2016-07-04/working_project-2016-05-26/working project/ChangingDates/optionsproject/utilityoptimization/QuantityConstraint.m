classdef QuantityConstraint < UtilityMaximizationConstraint
    %QuantityConstraint Constraint that the quantity of a given
    %   instrument must be in a certain range
    
    properties
        instrumentIndex;
        min;
        max;
    end
    
    methods 
        
        function c = QuantityConstraint( instrumentIndex, min, max)
            c.instrumentIndex = instrumentIndex;
            c.min = min;
            c.max = max;
            assert(min<=0); % Currently only supporting min<=0<=max
            assert(max>=0);
        end
        
        function applyConstraint( c, utilityMaximizationSolver, separableProblem ) 
        % Apply the constraint to the separable problem
            s = utilityMaximizationSolver;
            
            indices = find(s.indexToInstrument==c.instrumentIndex);
            for i=indices
                short = s.indexToShort(i);
                if short
                    separableProblem.bux(i) = -c.min;
                else                    
                    separableProblem.bux(i) = c.max;
                end
            end
            
        end
        
        function c = rescale( c, scale)
            % Produce a rescaled constraint when all the associated prices
            % are multiplied by the given factor            
            factor = scale( c.instrumentIndex );
            c.min = c.min/factor;
            c.max = c.max/factor;
        end
        
    end
            
end



