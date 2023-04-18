clear


% Compare output of new abeles to previous
nbair = 0;
nbsub = 6.35e-6;
srough = 5;

layers = [ 0     nbair  3
          100    1.00e-6   3
          100    4e-6      3
          0      nbsub  srough ];

q = linspace(0.01,0.3,500);

% Run the new calculation:
N = 4;

thick = layers(:,1);
sld = layers(:,2);
sig = layers(:,3);

refNew = abeles_reflect_matlab(q,N,thick,sld,sig);


% Run the old calculation
slds = layers(2:3,:);

%   abelesSingle(x,sld,nbair,nbsub,nrepeats,rsub,layers,points)
refOld = abelesSingle(q,slds,nbair,nbsub,1,srough,size(slds,1),length(q));

figure(1); clf
semilogy(q,refNew);
hold on
semilogy(q,refOld)






