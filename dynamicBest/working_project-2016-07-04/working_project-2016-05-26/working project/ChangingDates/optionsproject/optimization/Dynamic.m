classdef Dynamic < matlab.mixin.Copyable
    
    properties
        startDate
        endDate
        rebalancingInterval
        initialWealth
        histDiffPort
        histPort
        histQuantities
        histUtility
        currentState
        dateString
        histSpot
        resedual
        sigma
    end
    
    methods
        
        function o=Dynamic(startDate,endDate,rebalancingInterval,initialWealth)
            o.startDate=startDate;
            o.endDate=endDate;
            o.rebalancingInterval=rebalancingInterval;
            o.initialWealth=initialWealth;
            initutilityoptimization();
                dayData = DayData( startDate );
                zcb = dayData.findInstrument(0, DayData.cashType );
                currentPort=Portfolio();
                currentPort.add([initialWealth],{zcb});
            o.histPort=struct('initialWealthhhh',currentPort);
            o.histDiffPort=struct('initialWealthhhh',currentPort);
            o.histUtility=struct('initialWealthhhh',0);
            o.histSpot=struct('initialWealthhhh',dayData.spot);
            o.resedual=struct('initialWealthhhh',0);
            o.sigma=struct('initialWealthhhh',0);
            o.currentState=2;
        end
        
        function o=run(o)
            o=o.prepareTheDates;
            tic
            i=2;
            while i<size(o.dateString,1)+1 
                %try
                i
                o=o.reoptimize;
                i=i+1;
                o.currentState=o.currentState+1;
                %catch
                %end
            end
                
%             for i=2 : size(o.dateString,1)
%                 try
%                 o=o.reoptimize;
%                 catch
%                     continue
%                 end
%                 o.currentState=o.currentState+1;
%                 toc
%                
%             end 
            
            
        end
        
        function o=prepareTheDates(o)
            %If the investment horizon is 20 days, and rebalancingInterval
            %is 6 days, we will invest only 3 times. The last investment
            %horizon is 8 days.

            onlyDateStartDate = strcat(o.startDate(2:5),'-',o.startDate(6:7),'-',o.startDate(8:9));
            onlyDateEndDate = strcat(o.endDate(2:5),'-',o.endDate(6:7),'-',o.endDate(8:9));
            numOnlyDateStartDate=datenum(onlyDateStartDate);
            numOnlyDateEndDate=datenum(onlyDateEndDate);
            numberOfRebalancing=floor((numOnlyDateEndDate -numOnlyDateStartDate )/o.rebalancingInterval);
            temp=o.rebalancingInterval*[0 ones(1,numberOfRebalancing-1)];
            tempDate=numOnlyDateStartDate+cumsum(temp);
            dateTimeZero=datestr(tempDate,'yyyymmddTHHMMSS');
%             o.dateString=strcat('D',dateTimeZero(:,1:8),o.startDate(10:ek.ud));
%             o.dateString=vertcat('initialWealthhhh',o.dateString);
            
            
            j=2;
            o.dateString='initialWealthhhh';
            dateWithHoliday=strcat('D',dateTimeZero(:,1:8),o.startDate(10:end));
            for i =1:size(dateWithHoliday,1)
                try 
                    xlsread(strcat( '../SPXFuturesAndOptions/',dateWithHoliday(i,:),'.csv'));
                    o.dateString=vertcat(o.dateString,dateWithHoliday(i,:));
                    j=j+1;
                catch
                end
            end
            
            
            
        end
        
        function o=reoptimize(o)
            guassianQuadrature = 0;
            riskAversion = 0.00002;
            utilityFunction = ExponentialUtilityFunction( riskAversion );
            date = o.dateString(o.currentState,:);
            previousDate=o.dateString(o.currentState-1,:);
            dayData = DayData( date );
            model = dayData.blackScholesModel();
            %model.mu = 0.5*model.sigma^2;
            model.mu=0;
            o.sigma=setfield(o.sigma,date,model.sigma);
%            model.sigma=0.05;
            model
%             arbitrage = ArbitrageFinder.findArbitrageForDate( date, false, true );
%             assert(~arbitrage);    
            ump = UtilityMaximizationProblem1D();
            ump.setModel( model );
            ump.setUtilityFunction(utilityFunction);
            %currentPort=(o.histPort.(previousDate));
            ump.setCurrentPosition(o.histPort.(previousDate));
%            ump.setCurrentPosition(currentPort);

            for i=1:length(dayData.instruments)
                ump.addInstrument( dayData.instruments{i} );
            end    
            for idx = 1:length(ump.instruments)
                instrument=ump.instruments{idx};
                ump.addConstraint(QuantityConstraint(idx,-instrument.bidSize,instrument.askSize));
            end    
            ump.addConstraint( BoundedLiabilityConstraint());
            [utility, quantities] = ump.optimize();
                
            totalInvestment=0;

            for i = 1:length(ump.instruments)
                if quantities(i)>=0
                    totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getAsk();
                else
                    totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getBid();
                end
            end
            totalInvestment
        %    assert(totalInvestment<=50)
          %  assert(totalInvestment>=-1800)
     %----------------------------------------------------------------------------------------------------------------------
            zcb = dayData.findInstrument(0, DayData.cashType );
            currentPort=(o.histPort.(previousDate));
            temp=values(currentPort.map);
            ii=cell(1,length(temp));
                for i =1:length(temp)
                    tempp=temp{i};
                    qq(i)=tempp.quantity;
                    ii{i}=tempp.instrument;
                end
            port=Portfolio();
            port.add(quantities,ump.instruments);
            port.add(qq',ii);
            port.add([-totalInvestment],{zcb});
            
            diffPort=Portfolio();
            diffPort.add(quantities,ump.instruments);
            
            o.resedual=setfield(o.resedual,date,totalInvestment);
            o.histPort=setfield(o.histPort,date,port);
            o.histDiffPort=setfield(o.histDiffPort,date,diffPort);
            o.histUtility=setfield(o.histUtility,date,utility);
            o.histSpot=setfield(o.histSpot,date,dayData.spot);

            
                %Test if buying and selling quantities are in [-bidSizes,askSizes]
    for idx=1:length(ump.instruments)
        instrument=ump.instruments{idx};
        assert(quantities(idx)<=instrument.askSize);
        assert(quantities(idx)>=-instrument.bidSize);
    end

            
            
            
            
        end
        
        function plotHistPortfolio(o,date)
            port=o.histPort.(date);
            temp=values(port.map);
            instruments=cell(length(temp),1);
            quantities=zeros(length(temp),1);
            for i=1:length(temp)
                instruments{i}=temp{i}.instrument;
                quantities(i)=temp{i}.quantity;
            end
            plotPortfolioWithoutFutures(date,instruments,quantities);
        end
        
        function plotHistDiffPortfolio(o,date)
            port=o.histDiffPort.(date);
            temp=values(port.map);
            instruments=cell(length(temp),1);
            quantities=zeros(length(temp),1);
            for i=1:length(temp)
                instruments{i}=temp{i}.instrument;
                quantities(i)=temp{i}.quantity;
            end
            plotPortfolioWithoutFutures(date,instruments,quantities);
        end
        
        function plotMarkToMarket(o)
            date=o.dateString
            mark=zeros(1,size(date,1));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:))
            
            for i=2:size(date,1)
                port=o.histPort.(date(i,:))
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            plot((1:1:length(mark)-1),mark(2:end));
            subplot(2,1,2);
            plot((1:1:length(mark)-1),spot(2:end));
            
        end
        
        function plotMarkToMarketPercent(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            plot((1:1:length(mark)-1),100*(mark(2:end)-o.initialWealth)/(o.initialWealth));
            subplot(2,1,2);
            plot((1:1:length(mark)-1),100*(spot(2:end)-spot(1))/spot(1));
            
        end
        
        function plotMarkToMarketDevelopePercent(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            bar((1:1:length(mark)-1),100*(mark(2:end)-mark(1:end-1))./(mark(1:end-1)));
            subplot(2,1,2);
            bar((1:1:length(mark)-1),100*(spot(2:end)-spot(1:end-1))./spot(1:end-1));
            
        end
    end
end