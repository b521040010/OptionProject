function testStock
spot=100;
mu=0.01;
sigma=0.02;
T=1;
stock=Stock(spot,mu,sigma);
[prices,times]=stock.simulateBSPrices(10000,100,T);
assert(times(end)==T)
endPrices=prices(:,end);
midPrices=prices(:,50);
assertApproxEqual(mean(log(endPrices)),(log(spot)+(mu-0.5*sigma^2)*T),10^-3);
assertApproxEqual(mean(log(midPrices)),(log(spot)+(mu-0.5*sigma^2)*T/2),10^-3);
assertApproxEqual(std(log(endPrices)),sigma*sqrt(T),10^-3);
assertApproxEqual(std(log(midPrices)),sigma*sqrt(T/2),10^-3);
end