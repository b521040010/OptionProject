function writeOptionData( givenDateTime,data, directory )
%WRITEOPTIONDATA Write option data that has been read from Bloomberg to a
%file
%writeOptionData('8-April-2016 15:00:00',optionData,'\\nms-tier2.nms.kcl.ac.uk\k1455186\Desktop\gettingDat

%dates = unique(data.dates);
dateTimeWritable=datestr(givenDateTime,'yyyymmddTHHMMSS')
    %dateStr = datestr( date, 'yyyy-mm-dd');
    %fprintf('Recording data for %s',givenDateTime);
    fileName = sprintf('%s/%s.csv',directory,dateTimeWritable);
    file = fopen( fileName, 'w' );
    fprintf(file,'Ticker,Strike,Bid,Ask,isPut,isFuture,BidSize,AskSize\n');
    for j=1:size(data.strikes,1)
        
            fprintf(file,'%s,%d,%d,%d,%i,%i,%d,%d\n',data.tickers{j},data.strikes(j),data.bids(j),data.asks(j),data.isPut(j),data.isFuture(j),data.bidSizes(j),data.askSizes(j));
    end
    fclose( file );


end

