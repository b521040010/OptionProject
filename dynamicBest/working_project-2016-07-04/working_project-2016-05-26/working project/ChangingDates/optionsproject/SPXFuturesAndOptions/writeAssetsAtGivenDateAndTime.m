function optionData = writeAssetsAtGivenDateAndTime(bloomberg,givenDateTime,maturityDate)
%optionData = writeAssetsAtGivenDateAndTime(bloomberg,'8-April-2016 15:00:00','17-Jun-2016')

maturityDate=datevec(maturityDate);
%SPX Index
ticker = 'SPX Index';
[bid ask bidSize askSize]=loadBidAskBidsizeAsksizeGivienDateAndTime(bloomberg,ticker,givenDateTime);
optionData.tickers={ticker};
optionData.strikes=zeros(1,1);
optionData.isPut = zeros(1,1);
optionData.isFuture = zeros(1,1);
optionData.bids=bid;
optionData.asks=ask;
optionData.bidSizes=bidSize;
optionData.askSizes=askSize;
%-----------------------------------------------------

%EP
%we only have futures if the maturity is in March,June,September,December
if mod(maturityDate(2),3)==0
    switch maturityDate(2)
        case 3
            code = 'H';
        case 6
            code = 'M';
        case 9
            code = 'U';
        case 12
            code = 'Z';
        otherwise
            error('Invalid month %d',maturityDate(2));
    end
    ESYear=mod(maturityDate(1),10);
    ticker=strcat('ES',code,num2str(ESYear),' Index');
    strike=zeros(1,1);
    [bid ask bidSize askSize]=loadBidAskBidsizeAsksizeGivienDateAndTime(bloomberg,ticker,givenDateTime);
    optionData.tickers=vertcat(optionData.tickers,{ticker});
    optionData.strikes=vertcat(optionData.strikes,strike);
    optionData.bids=vertcat(optionData.bids,bid);
    optionData.asks=vertcat(optionData.asks,ask);
    optionData.bidSizes=vertcat(optionData.bidSizes,bidSize);
    optionData.askSizes=vertcat(optionData.askSizes,askSize);
    optionData.isPut=vertcat(optionData.isPut,zeros(1,1));
    optionData.isFuture=vertcat(optionData.isFuture,ones(1,1));
end
%-----------------------------------------------

%options
price=floor(optionData.bids(1,1)/5)*5;
%strikesTemp=(-30:5:30)+price;
strikesTemp=0:5:price+500;

trickerDate=sprintf(' %d/%d/%d',maturityDate(2),maturityDate(3),maturityDate(1));
for i = 1:length(strikesTemp)
    tickers{2*i-1}=strcat('SPX US',trickerDate,' C',num2str(strikesTemp(i)),' Index');
    tickers{2*i}=strcat('SPX US',trickerDate,' P',num2str(strikesTemp(i)),' Index'); 
end
%to make strike to be like [m m n n k k l l]'
for i=1:length(strikesTemp)
    strikes(2*i-1)=strikesTemp(i);
    strikes(2*i)=strikesTemp(i);
end
tickers
for i=1:length(tickers)
try
    ticker=tickers{i};
    strike=strikes(i);
    [bid ask bidSize askSize]=loadBidAskBidsizeAsksizeGivienDateAndTime(bloomberg,ticker,givenDateTime);
    optionData.strikes=vertcat(optionData.strikes,strike);
    optionData.tickers=vertcat(optionData.tickers,{ticker});   
    optionData.bids=vertcat(optionData.bids,bid);
    optionData.asks=vertcat(optionData.asks,ask);
    optionData.bidSizes=vertcat(optionData.bidSizes,bidSize);
    optionData.askSizes=vertcat(optionData.askSizes,askSize);
    optionData.isFuture=vertcat(optionData.isFuture,zeros(1,1));
    if mod(i,2)==1
        optionData.isPut=vertcat(optionData.isPut,zeros(1,1));
    else
        optionData.isPut=vertcat(optionData.isPut,ones(1,1));
    end
catch
    continue
end
end

end