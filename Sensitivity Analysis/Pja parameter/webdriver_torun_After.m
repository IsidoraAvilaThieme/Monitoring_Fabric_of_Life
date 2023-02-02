%After fishing

load Data\ChileanIntertidal_ECIMBiomass.mat
load RandomPja2.mat
AfterV2 = zeros(61,length(RandomPja2));

for random = 1:(length(RandomPja2))
load Data\ChileanIntertidal_ECIMBiomass.mat 

FishingScenario = "Compliance";

%AfterComplianceScenario1
if FishingScenario == "Compliance"
%fishing: compliance scenario 1 
Data.Catch(40) = 1;
Data.Catch(60) = 0;
%Data.Catch(61) = 1;
Data.Fmaxproducers = 0.9/100; %1.1/100
Data.rmodificator = 1;

elseif FishingScenario == "non-compliance scenario"
%fishing: non-compliance scenario 2 
Data.Catch(40) = 1;
Data.Catch(60) = 0;
Data.Fmaxproducers = 0.9/100;
Data.rmodificator = 0.001; %0.001 %with 0.002 there is persistence
end


t_init = 0;
tspan = t_init:15000; 
Data.K.type = 'Constant';
Data.K.mean = 176299; %From Avila-Thieme et al. 2021
Data.K.standard_deviation = [];
Data.K.autocorrelation = [];
Data = updateGuildInfo(Data);
Data = addDerivedQuantities(Data);
Data.nYearsFwd = length(tspan)- 1;
Data = compileOdeData(Data);
GuildInfo = Data.GuildInfo;
Binds = 1:GuildInfo.nGuilds;

%%%
load BeforeV2.mat
Binit = BeforeV2(:,random);
%%%

sf = Data.sf;
sf = sf-99;
Data.sf = sf;

cycle = 1;
Data.year = cycle; 

%%%
Data.Pja = RandomPja2(random,1) ;
%%%
        
    options = odeset('AbsTol',1.000000000000000e-10,'RelTol',1.000000000000000e-08);

    [~,BC] = ode15s(@(t,BC)atn_ode_biomass_catch_gainfish_gain_loss_fastV1_SA(t,BC,Data), ...
        tspan,[Binit], options);
% ----------------------------------------------------------------------- %
% extinction threshold
BC(BC< 1e-06) = 0;
% ----------------------------------------------------------------------- %
    
    if ~isreal(BC) || any(any(isnan(BC)))
        error('Differential eqution solver returned non real biomasses. Check model parameters.');
    end


AfterTemp = BC(end,:)';
AfterV2(:,random) = AfterTemp;

random
end

if FishingScenario == "Compliance"
save('AfterComplianceV2','AfterV2')

elseif FishingScenario == "non-compliance"
save('AfterNonCompliance','AfterV2')

end
