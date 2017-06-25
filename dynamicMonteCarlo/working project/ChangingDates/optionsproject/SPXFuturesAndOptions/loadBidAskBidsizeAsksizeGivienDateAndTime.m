function [bid ask bidSize askSize] = loadBidAskBidsizeAsksizeGivienDateAndTime(bloomberg,ticker,dateTime)
%[bid ask bidSize askSize]=loadBidAskBidsizeAsksizeGivienDateAndTime(bloomberg,'SPX US 3/17/17 C2340 Index','15-Febuary-2017 15:00:00')
%we want the prices 1 second before the given time unless we will not be able to
%trade



    oneScecondBeforeDateTime=datestr(datenum(dateTime)-1/(24*60*60));


    % %we look back timeLookBack mins before the given date
    timeLookBack=10;
    startdate=datestr(datenum(oneScecondBeforeDateTime)-timeLookBack*1/(24*60));

    data = timeseries(bloomberg,ticker,{startdate,oneScecondBeforeDateTime},[],{'BID','ASK'});
    temp=1;
    i=1;
    if cell2mat(data(size(data,1),1)) == 'BID'
        bid=cell2mat(data(size(data,1),3));
        bidSize=cell2mat(data(size(data,1),4));
        while temp==1
            if cell2mat(data(size(data,1)-i,1)) == 'ASK'
                ask=cell2mat(data(size(data,1)-i,3));
                askSize=cell2mat(data(size(data,1)-i,4));
                temp=0;
            else
                i=i+1;
            end
        end
     
    else if cell2mat(data(size(data,1),1)) == 'ASK'
        ask=cell2mat(data(size(data,1),3));
        askSize=cell2mat(data(size(data,1),4));
        while temp==1
            if cell2mat(data(size(data,1)-i,1)) == 'BID'
                bid=cell2mat(data(size(data,1)-i,3));
                bidSize=cell2mat(data(size(data,1)-i,4));
                temp=0;
            else
                i=i+1;
            end
        end
     
        end


 
 
     

end