
mu=0.2;
sigma = [0.05:0.005:0.35];
%sigma=0.35
nPaths=1000000;
nSteps=1;
%T=[0.5:0.01:1.5];
for i=1:length(sigma)
    
o=Merton(100000,0.1918,mu,sigma(i));
%o=Merton(100000,1,mu,sigma(i));
%o=Merton(100000,T(i),0.1,0.35);
utility(i)=simulateTradings(o,nPaths,nSteps,0);
end
utility=(1+utility')/0.00002;