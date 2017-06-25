%This is for power utility
o=Merton(2,1)
% from explicit formula we know that v(T,XT)=2.9, In order to verify, run
simulateTradings(o,100000,2000,0)
% To plot #
e=[-1:0.5:1]
for i=1:length(e)
    terminal(i)=simulateTradings(o,100000,2000,e(i))
end
plot(e,terminal)

%for exponential utility
%first change the utility to exponential utility
%change interest rate to 0#
% then run
o=Merton(2,1)
simulateTradings(o,100000,2000,0)
%To plot
e=[-1:0.5:1]
for i=1:length(e)
    terminal(i)=simulateTradings(o,100000,2000,e(i))
end
plot(e,terminal)