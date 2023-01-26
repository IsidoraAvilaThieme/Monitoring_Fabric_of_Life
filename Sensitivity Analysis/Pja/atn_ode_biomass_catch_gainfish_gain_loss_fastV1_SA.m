function dXdt = atn_ode_biomass_catch_gainfish_gain_loss_fastV1_SA(~,X,Data)
% ----------------------------------------------------------------------- %
% ----------------------------- PARAMETERS ------------------------------ %
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% FEEDING LINKS
% ----------------------------------------------------------------------- %

% Feeding links between feeders and food
communityMatrix = Data.communityMatrix;
% Functional response exponent parameters for each feeding link
q = Data.q;
% Feeding interference coefficients for each feeding link
d = Data.d;
% Relative food preferences of feeders for each feeding link
omega = Data.omega;
% Assimilation efficiencies for each feeding link
e = Data.e;
% Maximum consumption rates for each feeding link
y = Data.y;
% Half saturation constants to the power of q for each feeding link
B0_pow_q = Data.B0_pow_q;

% ----------------------------------------------------------------------- %
% PRODUCERS
% ----------------------------------------------------------------------- %

% Carrying capacity of autotrophs for current year
K = Data.K.values(Data.year);
% Intrinsic growth rate of producers
r = Data.r;
%r(18) = 0.028574404000000; %equal r to all priary producers
r(18) = 0.018; %algae ower r than lessonias

% Competition coefficients of producers
c = Data.c; 

% ----------------------------------------------------------------------- %
% Lessonia juvenile
% ----------------------------------------------------------------------- %

%Probability of transforming to adult stage
Pja = Data.Pja;

% ----------------------------------------------------------------------- %
% CONSUMERS AND FISHES
% ----------------------------------------------------------------------- %
% Metabolic rate of consumers and fishes
x = Data.x;
% Fractions of assimilated C used for biomass gains for feeders
ax = Data.ax;
% Fractions of assimilated C respired by maintenance for feeders
bx = Data.bx;

% ----------------------------------------------------------------------- %
% FILTER FEEDERS
% ----------------------------------------------------------------------- %
% Metabolic rate of filters
xf= Data.xf;
% Fractions of assimilated C used for biomass gains for fiters feeders
faf = Data.faf;
% Fractions of assimilated C respired by maintenance for filer feeders
fmf = Data.fmf;
%biomass from plankton subsidy
sf = Data.sf;

% ----------------------------------------------------------------------- %
% MISC
% ----------------------------------------------------------------------- %

% Precalculated index vectors etc.
GuildInfo = Data.GuildInfo; 
% New variables for speed up by avoiding repetitive computations or indexing
B = X(1:GuildInfo.nGuilds); 
%to manually run: 
% B = Binit(1:GuildInfo.nGuilds) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ----------------------------------------------------------------------- %
% extinction threshold
B(B< 1.00000000000000e-06) = 0;
% ----------------------------------------------------------------------- %

% Producer biomasses
bProducerGuilds = B(GuildInfo.iProducerGuilds);
% Consumer biomasses
bConsumerGuilds = B(GuildInfo.iConsumerGuilds);
% Feeder biomasses
bFeederGuilds = B(GuildInfo.iFeederGuilds);
% Food biomasses
bFoodGuilds = B(GuildInfo.iFoodGuilds);
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% OMEGA VARIABLE
% ----------------------------------------------------------------------- %

A = bFoodGuilds'.*Data.communityMatrix;
A(A > 0) = 1;
ng = size(A,2);
nps = 1./sum(A,2);
nps(isinf(nps)) = 0;
w = repmat(nps,1,ng);
omega = A.*w; 


% ----------------------------------------------------------------------- %
% Fisheries
% ----------------------------------------------------------------------- %
Catch = Data.Catch;
ProducerHarvest = Catch(GuildInfo.iProducerGuilds);
ConsumerHarvest = Catch(GuildInfo.iConsumerGuilds);

%defining the intensity of fishing
Fmaxproducers = Data.Fmaxproducers;
Fmaxconsumers = Data.Fmaxconsumers;

ProducerFisheries = Fmaxproducers*bProducerGuilds.*ProducerHarvest;   
ConsumerFisheries = Fmaxconsumers*bConsumerGuilds.*ConsumerHarvest;

% ----------------------------------------------------------------------- %
% -------------------------------- MODEL -------------------------------- %
% ----------------------------------------------------------------------- %

% Preallocate biomass derivative vector
dBdt = zeros(GuildInfo.nGuilds,1);

% ----------------------------------------------------------------------- %
% FUNCTIONAL RESPONSE MATRIX
% ----------------------------------------------------------------------- %

Bmx_pow_q = repmat(bFoodGuilds',GuildInfo.nFeederGuilds,1).^q;
Ftop = omega.*repmat(bFoodGuilds',GuildInfo.nFeederGuilds,1).^q;
Fbot1 = B0_pow_q;
Fbot2 = diag(sum(omega.*Bmx_pow_q,2))*communityMatrix; 
Fbot3 = diag(bFeederGuilds)*d.*B0_pow_q;
Fbot = Fbot1 + Fbot2 + Fbot3;
F = Ftop./Fbot;
F(isnan(F)) = 0;

% ----------------------------------------------------------------------- %
% GAINS AND LOSSES
% ----------------------------------------------------------------------- %

ytimesxtimesBtimesF = y.*repmat(x.*bFeederGuilds,1,GuildInfo.nFoodGuilds).*F;

% Gain from resources
gainMTX = diag(ax)*ytimesxtimesBtimesF;
gainVEC = sum(gainMTX,2);

% Loss to consumers
%lossMTX = (ytimesxtimesBtimesF./e)';
lossMTX = (ytimesxtimesBtimesF)';
lossMTX(isnan(lossMTX)) = 0;
lossVEC = sum(lossMTX,2);

% Loss to maintenance
lConsumerMaintenance = bx.*x.*bConsumerGuilds;

% ----------------------------------------------------------------------- %
% PRODUCER AND FILTER FEEDERS BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

% PRODUCER and FILTERS gain from logistic growth
bnonsessilefilters = bProducerGuilds([12:16]);

%removing the biomass of non-sessile filter-feeders from competition
G = 1 - ((c'*bProducerGuilds - c([12:16])'*bnonsessilefilters) + bProducerGuilds)/K;

gProducerGrowth = r.*bProducerGuilds.*G;

%%%% Correction of growth of all Filters-feeders 
bFilters = bProducerGuilds([1:4, 6:16], :);
gFilterGrowth = gProducerGrowth([1:4, 6:16], :);
Gfilter = G([1:4, 6:16], :);
gFilterGrowth = faf.*xf.*sf.*bFilters.*Gfilter;
gProducerGrowth([1:4,6:16], :) = gFilterGrowth;


%correcting of growth of all non-sessile filters 
gnonsessileGrowth = gProducerGrowth([12:16], :);
gnonsessileGrowth = gnonsessileGrowth./Gfilter([11:15], :);
gProducerGrowth([12:16], :) = gnonsessileGrowth;

%%%%%%

% PRODUCER and Filters loss to consumption
lProducerConsumption = lossVEC(GuildInfo.iProducerGuildsInFood_position_vector);

% PRODUCER and Filters loss to Fisheries
lproducerHarvested = ProducerFisheries;

%FILTERS LOSS TO METABOLIC RATE
lFilterMaintenance = fmf.*xf.*bFilters; 

%Producers and filters total loss
lProducerConsumptionFilterMaintenance = lProducerConsumption;
lProducerConsumptionFilterMaintenance([1:4,6:16], :) =  lProducerConsumption([1:4,6:16],:) + lFilterMaintenance;

%Equation
 dBdt(GuildInfo.iProducerGuilds) = + gProducerGrowth ...
                                  - lProducerConsumptionFilterMaintenance...
                                  - lproducerHarvested;

%correcting dB/dt of lessonia
dBdt([40,60], :) = 0;

% ----------------------------------------------------------------------- %
% LESSONIA JUVENILE BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

%Lessonia Juvenile gain from logistic growth
fec = 1; %0.01
%rj = r(17)* Data.rmodificator * (bProducerGuilds(17) + (fec * bProducerGuilds(5))); 
rj =  r(17)* Data.rmodificator * fec * bProducerGuilds(5); 

LAmax = (8805/2) ;
%LAmax = 176299*10;

%
Gjuvenil = 1 - (bProducerGuilds(17) + bProducerGuilds(5))/LAmax;%K %6.6038e+03
%

gProducerGrowthLj = rj.*bProducerGuilds(17).*Gjuvenil;

%Lessonia Juvenile loss to consumption
lProducerConsumptionLj = lProducerConsumption(17);

%Lessonia Juvenile loss to Fisheries
lproducerHarvestedLj = ProducerFisheries(17);

%Lessonia Juvenile loss to transformation to adult stage
%Pja = Pja/100;
%Pja = 0.1;
LA = bProducerGuilds(5);
%LAmax = 8805/2 ; % K %-(sum (bProducerGuilds))
%LAmax = 176299;
Lj = bProducerGuilds(17);

lproducerStageTransformation = Pja*(1 -(LA/LAmax))*Lj;   

%subsidy
%subsj = 0.001;

%Equation
dBdt([60], :) = + gProducerGrowthLj ...
                                  - lProducerConsumptionLj...
                                  - lproducerHarvestedLj...
                                  - lproducerStageTransformation;
                                  %+ subsj;

% ----------------------------------------------------------------------- %
% LESSONIA ADULTS BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %
%Lessonia adults gain to transformation from juvenile stage
gproducerStageTransformation = lproducerStageTransformation;           

%Lessonia adults loss to consumption
lProducerConsumptionLa = lProducerConsumption(5);

%Lessonia adult loss to Fisheries
lproducerHarvestedLa = ProducerFisheries(5);

%Equation
dBdt([40], :) = + gproducerStageTransformation ...
                                  - lProducerConsumptionLa ...
                                  - lproducerHarvestedLa;

% ----------------------------------------------------------------------- %
% CONSUMER BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

% CONSUMER maintenance loss
lConsumerMaintenance = lConsumerMaintenance;

% CONSUMER gain from consumption
gConsumerConsumption = gainVEC;

% CONSUMER loss to consumption
NewlConsumerConsumption = lossVEC(GuildInfo.iConsumerGuildsInFood_position_vector); 
xxA = 1:GuildInfo.nGuilds; 
xxB = NewlConsumerConsumption'; 
xxBi = GuildInfo.iConsumerGuildsInFood; 
xxAnew = zeros(1,length(xxA)); 
xxAnew(xxBi) = xxB; 
xxAnew1 = xxAnew'; 
lConsumerConsumption2 = xxAnew1(GuildInfo.iConsumerGuilds); 

%------------------------------------------------------------------------%
lconsumerHarvested = ConsumerFisheries;

%Equation
dBdt(GuildInfo.iConsumerGuilds) = - lConsumerMaintenance ...
                                  + gConsumerConsumption ...
                                  - lConsumerConsumption2 ...
                                  -lconsumerHarvested;

% ----------------------------------------------------------------------- %
% CONCATENATE DERIVATIVES OF BIOMASSES, CATCHES, GAIN FISH, GAIN AND LOSS
% ----------------------------------------------------------------------- %
%save('dBdt','dBdt');
dXdt = dBdt; %./1000



