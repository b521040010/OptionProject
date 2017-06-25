classdef PowerUtility
    properties
        lambda;
    end
    methods
        function o=PowerUtility(lambda)
            o.lambda=lambda;
        end
        function expectedUtility=computeExpectedUtility(o,x)
            expectedUtility=mean((1/(1-o.lambda))*x.^(1-o.lambda));
        end
    end
end