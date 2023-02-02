   xStart = 0.001;
   dx = 1/10000;
   N = 1001;
   x = xStart + (0:N-1)*dx;
   x = x';
   NewR = x;
   
   save('NewR','NewR')

load NewR.mat
NewR = NewR(1:491,1);


