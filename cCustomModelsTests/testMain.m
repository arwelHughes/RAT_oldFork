
params = [3 20 0.2 55 0.2 0.1 4 3];
nba = 2.073e-6;
nbs  = [0 0 0];
numberOfContrasts = int32(3);

libraryName = 'customBilayer';
functionName = 'customBilayer';

[allLayersArr,allRoughsArr] = testDLL_mex(params,nba,nbs,numberOfContrasts,libraryName,functionName);
