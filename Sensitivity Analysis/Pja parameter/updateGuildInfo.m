function Data = updateGuildInfo(Data)
gtypes = {Data.Guilds.type};

iProducerGuilds = find(strcmpi(gtypes,'producer'));
iConsumerGuilds = find(strcmpi(gtypes,'consumer'));
iFoodGuilds = find(any(Data.communityMatrix,1));
iFeederGuilds = find(any(Data.communityMatrix,2))';
nGuilds = length(Data.Guilds);
nFoodGuilds = length(iFoodGuilds); 
nFeederGuilds = length(iFeederGuilds); 
iProducerGuildsInFood = iProducerGuilds(ismember(iProducerGuilds,iFoodGuilds)); 
iConsumerGuildsInFood = iConsumerGuilds(ismember(iConsumerGuilds,iFoodGuilds)); 
iProducerGuildsInFood_position_vector = find(ismember(iFoodGuilds,iProducerGuilds)); 
iConsumerGuildsInFood_position_vector = find(ismember(iFoodGuilds,iConsumerGuilds)); 

Data.GuildInfo = struct( ...
    'iProducerGuilds', iProducerGuilds, ...
    'iConsumerGuilds', iConsumerGuilds, ...
    'iFoodGuilds', iFoodGuilds, ...
    'iFeederGuilds', iFeederGuilds, ...
    'nGuilds', nGuilds, ...
    'nFoodGuilds', nFoodGuilds, ...
    'nFeederGuilds', nFeederGuilds, ...
    'iProducerGuildsInFood', iProducerGuildsInFood, ...
    'iConsumerGuildsInFood', iConsumerGuildsInFood, ...
    'iProducerGuildsInFood_position_vector', iProducerGuildsInFood_position_vector, ...
    'iConsumerGuildsInFood_position_vector', iConsumerGuildsInFood_position_vector);