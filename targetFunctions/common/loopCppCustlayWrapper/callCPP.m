
function [allLayersArr,allRoughsArr] = callCPP(params,nba,nbs,numberOfContrasts,libraryName,functionName)

    coder.cinclude('<functional>');
    coder.cinclude('<string>');
    coder.cinclude('<iostream>');
    coder.cinclude('<map>');
    coder.cinclude('<vector>');
    coder.cinclude('libManager.h');
    coder.cinclude('<tuple>');
    coder.updateBuildInfo('addLinkFlags','-ldl');

    % Need to find a way to make this work with 100000,3
    output = zeros(8,3);
    subRough =0.0;
    
    %cfunctionName(isstrprop(cfunctionName,'digit')) = [];

    
    p = coder.opaque('Library','NULL','HeaderFile','libManager.h');
    % Make an instance 
    p = coder.ceval('Library');
    %coder.ceval('std::mem_fn(&Library::loadInfo)',p,[clibraryName,'0'],[cfunctionName,'0']);
    
    % call the class method in libManager.h
    coder.ceval('std::mem_fn(&Library::loadRunner)',p,coder.ref(params),coder.ref(nba),coder.ref(nbs)...
    ,numberOfContrasts,coder.wref(output),coder.wref(subRough),libraryName,functionName);
    
    allLayersArr = output;
    allRoughsArr = subRough;

end
