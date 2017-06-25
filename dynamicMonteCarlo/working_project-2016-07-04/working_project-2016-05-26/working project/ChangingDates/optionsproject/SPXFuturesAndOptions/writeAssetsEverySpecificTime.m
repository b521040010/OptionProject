function writeAssetsNStepsBackwardEverySSeconds(fromDateTime,s,n)
datenum(fromDateTime)
dates(1)=fromDateTime
for i= 2:n
dates(i)=dates(i-1)-1/(24*60*60);
dateStr=datestr(dates(i))
end

end