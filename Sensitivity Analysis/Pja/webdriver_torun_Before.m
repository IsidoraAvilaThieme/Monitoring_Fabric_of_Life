%%Before harvesting
load Data\ChileanIntertidal_ECIMBiomass.mat
load RandomPja2.mat
BeforeV2 = zeros(61,length(RandomPja2));

for random = 1:(length(RandomPja2))

load Data\ChileanIntertidal_ECIMBiomass.mat 
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
Binit = vertcat(Data.Guilds.binit);
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


BeforeTemp = BC(end,:)';
BeforeV2(:,random) = BeforeTemp;  

end 
save('BeforeV2','BeforeV2');


