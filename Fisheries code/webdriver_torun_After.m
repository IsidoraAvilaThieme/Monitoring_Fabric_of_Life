%After fishing
load Data\ChileanIntertidal_ECIMBiomass.mat 

FishingScenario = "non-compliance scenario";

%AfterComplianceScenario1
if FishingScenario == "Compliance"
%fishing: compliance scenario 1 
Data.Catch(40) = 1;
Data.Catch(60) = 0;
Data.Fmaxproducers = 0.9/100; 
Data.rmodificator = 1;

elseif FishingScenario == "non-compliance scenario"
%fishing: non-compliance scenario 2 
Data.Catch(40) = 1;
Data.Catch(60) = 0;
Data.Fmaxproducers = 0.9/100;
Data.rmodificator = 0.001;
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
%load Resultsrmodification\Before.mat
load Before2.mat
Binit = Before2(end,:)';

sf = Data.sf;
sf = sf-99;
Data.sf = sf;

cycle = 1;
Data.year = cycle; 
        
    options = odeset('AbsTol',1.000000000000000e-10,'RelTol',1.000000000000000e-08);

    [~,BC] = ode15s(@(t,BC)atn_ode_biomass_catch_gainfish_gain_loss_fastV1(t,BC,Data), ...
        tspan,[Binit], options);
% ----------------------------------------------------------------------- %
% extinction threshold
BC(BC< 1e-06) = 0;
% ----------------------------------------------------------------------- %
    
    if ~isreal(BC) || any(any(isnan(BC)))
        error('Differential eqution solver returned non real biomasses. Check model parameters.');
    end

After = BC;
    

%Saving results
if FishingScenario == "Compliance"
After = After(end,:)';
save('SimulationResults/AfterCompliance','After');
writematrix(After,'SimulationResults/AfterCompliance.xlsx')

elseif FishingScenario == "non-compliance scenario"
After = After(end,:)';
save('SimulationResults/After-nonCompliance','After');
writematrix(After,'SimulationResults/After-nonCompliance.xlsx') 
end


