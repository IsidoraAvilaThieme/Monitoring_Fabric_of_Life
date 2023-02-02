%Fmax = FmaxX/100

load Before2.mat
load AfterComplianceFmax01.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100

(((After(end, :))./(Before2(end, :)))-1)*100

FmaxS1 =  (((After(end, :))./(Before2(end, :)))-1)*100


load Before2.mat
load AfterComplianceFmax02.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS2 =  (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax03.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS3 =  (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax04.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS4 = (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax05.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS5 = (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax06.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS6 =  (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax07.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS7 = (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax08.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS8 = (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax09.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS9 = (((After(end, :))./(Before2(end, :)))-1)*100

load Before2.mat
load AfterComplianceFmax1.mat
(((After(end, 40))/(Before2(end, 40)))-1)*100
FmaxS10 =  (((After(end, :))./(Before2(end, :)))-1)*100

Results = vertcat(FmaxS1,FmaxS2,FmaxS3,FmaxS4,FmaxS5,FmaxS6,FmaxS7,FmaxS8,FmaxS9,FmaxS10)
Results1 = Results'
writematrix(Results1,'AfterCompliance.xlsx')

plot(Results(:,1:61),'DisplayName','Results(:,1:61)')
plot(Results(:,40),'DisplayName','Results(:,40)')
plot(Results(:,60),'DisplayName','Results(:,60)')