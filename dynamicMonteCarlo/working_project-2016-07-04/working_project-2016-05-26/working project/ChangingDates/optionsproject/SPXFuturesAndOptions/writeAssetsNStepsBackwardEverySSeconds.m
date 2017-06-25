function writeAssetsNStepsBackwardEverySSeconds(bloomberg,fromDateTime,s,n,maturity,directory)
%writeAssetsNStepsBackwardEverySSeconds(bloomberg,'8-April-2016 15:00:00',10,3,'17-June-2016','\\nms-tier2.nms.kcl.ac.uk\k1455186\Desktop\gettingDataFromBloomberg')
dates(1)=datenum(fromDateTime);
dateStr=datestr(dates(1));
optionData = writeAssetsAtGivenDateAndTime(bloomberg,dateStr,maturity);
writeOptionData(dateStr,optionData,directory);

 for i= 2:n
     try
        dates(i)=dates(i-1)-s/(24*60*60);
        dateStr=datestr(dates(i));
        optionData = writeAssetsAtGivenDateAndTime(bloomberg,dateStr,maturity);
        writeOptionData(dateStr,optionData,directory);
     catch
         continue
     end
 
 end

end