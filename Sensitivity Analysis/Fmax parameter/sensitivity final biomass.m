%Fmax = FmaxX/100

load AfterComplianceFmax01.mat
FmaxS1 = After(end, :)' 

load AfterComplianceFmax02.mat
FmaxS2 =  After(end, :)' 

load AfterComplianceFmax03.mat
FmaxS3 =  After(end, :)' 

load AfterComplianceFmax04.mat
FmaxS4 = After(end, :)' 

load AfterComplianceFmax05.mat
FmaxS5 = After(end, :)' 

load AfterComplianceFmax06.mat
FmaxS6 = After(end, :)' 

load AfterComplianceFmax07.mat
FmaxS7 = After(end, :)' 

load AfterComplianceFmax08.mat
FmaxS8 = After(end, :)' 

load AfterComplianceFmax09.mat
FmaxS9 = After(end, :)' 

load AfterComplianceFmax1.mat
FmaxS10 =  After(end, :)' 

Results = horzcat(FmaxS1,FmaxS2,FmaxS3,FmaxS4,FmaxS5,FmaxS6,FmaxS7,FmaxS8,FmaxS9,FmaxS10)
writematrix(Results,'AfterCompliance.xlsx')

load Before2.mat
Before=  Before2(end, :)'
writematrix(Before,'Before.xlsx')