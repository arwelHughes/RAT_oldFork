% Analysis of DSPC Bilayers Data

% First make an instance of the project class
problem = projectClass('DSPC bilayer');
problem.setGeometry('substrate/liquid');

% Define the parameters:
Parameters = {
    %       Name                min         val         max     fit? 
        {'Oxide thick',         10,         20,         25,     true    };
        {'Oxide SLD',           3e-6,       3.41e-6,    4e-6,   true    };
        {'Oxide Hydration'      0,          20,         30,     true   };
        {'Sam tails thick',     10,         30,         50,     true    };      
        {'Sam tails sld',       -0.5e-6,    -0.4e-6,    -0.1e-8,    true    };
        {'Sam tails hydr',      0.0,        10,         20,     true   };
        {'Sam rough',           1,          5,          9,      true   };
        {'Sam head thick',      5,          10,         15,     true    };
        {'Sam head SLD',        1e-6,       1.4e-6,     2e-6,   true    };
        {'Sam head hydration',  0,          30,         50,     true   };
        {'cw thick',            10,         22,         50,     true    };
        {'cw SLD',              0,          0,          0,      false   };
        {'cw hydration',        100,        100,        100,    false   };
        {'Bilayer head thick',  5,          10,         15,     true    };
        {'Bilayer head sld',    1e-6,       1.47e-6,    1.6e-6, true    };
        {'Bilayer heads hydr',  20,         30,         40,     true   };
        {'Bilayer rough'        5,          7,          15,     true    };
        {'Bilayer tails thick', 10,         15,         20,     true    };
        {'Bilayer tails SLD',   -5e07,      -4e-7,      -1e-7,   false   };
        {'Bilayer tails hydr',  0,          10,         20,     true   };

        };
    
    
 % Group these into layers:
Oxide =     {'Oxide Layer',...
                'Oxide thick',...
                'Oxide SLD',...
                'Substrate Roughness',...
                'Oxide Hydration',...
                'bulk out' };
            

Sam_tails = {'Sam Tails',...
                'Sam tails thick',...
                'Sam tails sld',...
                'Sam rough',...
                'Sam tails hydr',...
                'bulk out'};


Sam_heads = {'Sam heads',...
                'Sam head thick',...
                'Sam head SLD',...
                'Sam rough',...
                'Sam tails hydr',...
                'bulk out'};
            
Central_water = {'Central water',...
                    'cw thick',...
                    'cw SLD',...
                    'Bilayer rough',...
                    'cw hydration',...
                    'bulk out'};
                
Bilayer_heads = {'Bilayer heads',...
                    'Bilayer head thick',...
                    'Bilayer head sld',...
                    'Bilayer rough',...
                    'Bilayer heads hydr',...
                    'bulk out'};
                
Bilayer_tails = {'Bilayer tails',...
                    'Bilayer tails thick',...
                    'Bilayer tails SLD',...
                    'Bilayer rough',...
                    'Bilayer tails hydr',...
                    'bulk out'};
                

% Add the parameters and Layers to the project:
problem.addParamGroup(Parameters);
problem.addLayerGroup({Oxide ; Sam_tails; Sam_heads; Central_water; Bilayer_heads; Bilayer_tails});

% add an additional bulk out
problem.addBulkOut({'SLD SMW',1.9e-6,2.073e-6,3e-6});

% And reset the range of the other bulk out
problem.setBulkOut(1,'min',5.5e-6);

% Set the bulk in to Silicon
problem.setBulkIn(1,'name','Silicon','min',2e-6,'value',2.073e-6,'max',2.1e-6);

% Need two backgrounds - one for D2O and for SMW
% Change the name of the first and add a new one for the second
% Also need a new backsPar
problem.setBacksParName(1,'Backs value D2O');
problem.setBacksParValue(1,5.5e-6);
problem.addBacksPar('Backs Value SMW',1e-8,2.8e-6,1e-5);

problem.addBackground('Background D2O','constant','Backs Value D2O');
problem.setBackgroundValue(1,'name','Background ACMW');
problem.setBackgroundValue(1,3,'Backs Value ACMW');
                
% Add the data files
D2O_data = dlmread('bilayer_d2o.dat');
SMW_data = dlmread('bilayer_smw.dat');

problem.addData('Bilayer / D2O', D2O_data);
problem.addData('Bilayer / SMW', SMW_data);

% Set some other values
problem.setScalefactor(1,'value',0.1);


% Add the 2 contrasts
problem.addContrast('name','Bilayer / D2O',...
    'background','Background D2O',...
    'resolution','Resolution 1',...
    'scalefactor', 'Scalefactor 1',...
    'nbs', 'SLD D2O',...
    'nba', 'Silicon',...
    'data', 'Bilayer / D2O');

% Set the model
problem.setContrast(1,'model', {'Oxide Layer',...
              'Sam Tails',...
              'Sam heads',...
              'Central water',...
              'Bilayer heads',...
              'Bilayer tails',...
              'Bilayer tails',...
              'Bilayer heads'});

problem.addContrast('name','Bilayer / SMW',...
    'background','Background ACMW',...
    'resolution','Resolution 1',...
    'scalefactor', 'Scalefactor 1',...
    'nbs', 'SLD SMW',...
    'nba', 'Silicon',...
    'data', 'Bilayer / SMW');

problem.setContrast(2,'model', {'Oxide Layer',...
              'Sam Tails',...
              'Sam heads',...
              'Central water',...
              'Bilayer heads',...
              'Bilayer tails',...
              'Bilayer tails',...
              'Bilayer heads'});


problem.setScalefactor(1,'max',1.1);
problem.setScalefactor(1,'fit',true);
problem.setBacksPar(1,'fit',true);
problem.setBacksPar(2,'fit',true);
problem.setBulkOut(1,'fit',true);
problem.setBulkOut(2,'fit',true);

problem

controls = controlsDef;
controls.procedure = 'bayes';
controls.calcSldDuringFit = 'no';
controls.nsimu = 4000;
controls.repeats = 1;
controls.parallel = 'single';
%[outProb,results] = RAT(problem,controls);

% controls.procedure = 'simplex';
% [problem,results] = RAT(problem,controls);
% 
% 
% [problem,results] = RAT(problem,controls);
% [problem,results] = RAT(problem,controls);
% [problem,results] = RAT(problem,controls);
% figure(1); clf; hold on
% plotRefSLD(problem,results);

% controls.procedure = 'calculate';
% [outProb,results] = RAT_new(problem,controls);

% h = figure(1); clf
% sf = results.contrastParams.scalefactors;
% bayesShadedPlot(h,results.predlims,results.shifted_data,sf)
% 
% h1 = figure(2); clf
% mcmcplot(results.chain,[],results.fitNames,'hist');
% 
% h2 = figure(3); clf
% mcmcplot(results.chain,[],results.fitNames);

% h3 = figure(4); clf
% mcmcplot(results.chain,[],results.fitNames,'pairs');











