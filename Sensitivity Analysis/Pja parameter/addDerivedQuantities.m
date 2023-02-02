function Data = addDerivedQuantities(Data)
% calculate relative prey preference matrix
A = Data.communityMatrix;
ng = size(A,1);
nps = 1./sum(A,2);
nps(isinf(nps)) = 0;
w = repmat(nps,1,ng);
w = A.*w;
Data.omega = w;

