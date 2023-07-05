# -*- coding: utf-8 -*-
'''
Adam Milsom, University of Birmingham 
Fitting kinetic runs NR data - Disk A 4000 rpm (4) dec RH
'''
#%%
# importing everything

#import matplotlib.pyplot as plt
import numpy as np
import os.path
import time as tm
import pandas as pd
import pickle
from os import listdir

start_time = tm.time()

import refnx, scipy

# the analysis module contains the curvefitting engine
from refnx.analysis import CurveFitter, Objective, Parameter, GlobalObjective, process_chain, Transform

# the reflect module contains functionality relevant to reflectometry
from refnx.reflect import SLD, MixedReflectModel, ReflectModel, Structure, LipidLeaflet, Stack

# the ReflectDataset object will contain the data
from refnx.dataset import ReflectDataset

#%%

# list of filenames to iterate through
directory = r'ENTER DIRECTORY HERE'

data_filenames = []
print('List of input filenames: ')
for filename in listdir(directory):
    if filename.endswith('.dat') and filename.find('corr') == -1:
        print(filename)
        data_filenames.append(filename)

# sort data filenames
data_filenames_sorted = []
print('Data processing order: ')
for i in np.arange(len(data_filenames)):
    for name in data_filenames:
        if name.startswith('{}'.format(i+1)):
            data_filenames_sorted.append(name)
            print(name)

file_no = 0
for file in data_filenames_sorted:
    file_no += 1
    print('Processing: ' + file) 
    # clean data (remove '0s'), error in curvefitting otherwise
    data = np.genfromtxt(file,skip_header=1)
    ints_to_delete = np.array([])
    for i, val in enumerate(data[:,1]):
        if val == 0:
            ints_to_delete = np.append(ints_to_delete,i)
    ints_to_delete = ints_to_delete.astype(int)
    corr_data = np.delete(data,ints_to_delete.astype(int),axis=0)
    np.savetxt(file[:-4]+'_corr.dat',corr_data)
    
    data_DiscA_1 = ReflectDataset(file[:-4]+'_corr.dat')
    data_DiscA_1.name = "1pc_2000RPM"

    ## create slabs
    si = SLD(2.07, name='Si')
    sio2 = SLD(3.47, name='SiO2')
    film = SLD(2.0, name='film')
    air = SLD(0.0, name='air')
    OA = SLD(1.7, name='OA')
    SO = SLD(1.2, name='SO')
    D2O = SLD(6.37, name='D2O') # add D2O for humidification
    
    # first number is thickness, second number is roughness
    # a native oxide layer
    sio2_layer = sio2(15.7, 6.4)
    
    # the film of interest
    film_layer = film(357, 26)
    OA_layer = OA(23,10)
    SO_layer = SO(23,8)
    
    #D2O
#    D2O_layer = D2O(5,2)
    
    
    #sio2_layer.thick.setp(bounds=(10, 100), vary=True)
    #sio2_layer.rough.setp(bounds=(1, 30), vary=True)
    
    film_layer.thick.setp(bounds=(180,235), vary=True)
    film_layer.sld.real.setp(bounds=(0.1, 4), vary=True)
    film_layer.rough.setp(bounds=(5, 80), vary=True)#
    
    OA_layer.thick.setp(bounds=(15, 25), vary=True)
    OA_layer.sld.real.setp(bounds=(0.2, 2.5), vary=True)
    OA_layer.rough.setp(bounds=(1, 10), vary=True)
    
    SO_layer.thick.setp(bounds=(15, 25), vary=True)
    SO_layer.sld.real.setp(bounds=(0.2, 2.5), vary=True)
    SO_layer.rough.setp(bounds=(1, 10), vary=True)
    
#    D2O_layer.thick.setp(bounds=(0,5),vary=True) #
#    D2O_layer.rough.setp(bounds=(1,5),vary=True)
    
    
    si_back = si(0,6.8)
    
    # define which model to use ***CHANGE THIS***
    model_no = 1
    MCMC = True
    if MCMC == True:
         print('DA 4000 rpm, kinetic run dec RH (4), MCMC sampling')
    else:
        print('DA 4000 rpm, kinetic run dec RH (4)')
    
    if model_no == 1:
        # Make a multilayer by using a Stack Component
        stack = Stack(components=OA_layer|SO_layer, repeats=6)
        #stack |= OA_layer
        #stack |= SO_layer
        #stack.repeats = 10.0
        stack.repeats.setp(bounds=(2,6),vary=True) # vary repeats
        # assemble the structure
        structure1 = air | film_layer | sio2_layer | si_back 
        structure2 = air | stack | sio2_layer | si_back
        
        
        
        model = MixedReflectModel((structure1,structure2), scales=(0.7,0.2), bkg=3e-7, dq=2.5)
        model.scales[0].setp(bounds=(0.0, 1.2), vary=True)
        model.scales[1].setp(bounds=(0.0, 1.2), vary=True)
        model.bkg.setp(bounds=(1e-9, 9e-6), vary=True)
        #model.threads=1

    #%%
    ## create 'objective'
    objective = Objective(model, data_DiscA_1, transform=Transform('logY'))

    #%%
    ## do the fit and plot result
    pars = (model.scales[0],model.scales[1])
    
    sf_lb, sf_ub = 0.88, 0.92 # lower and upper bounds for total scale factor
    
    # making a constraint for scale factors for differential evolution and 
    # MCMC sampling
        
    class DEC(object):
        def __init__(self, pars, objective):
            # we'll store the parameters and objective in this object
            # this will be necessary for pickling in the future
            self.pars = pars
            self.objective = objective
    
        def __call__(self, x):
            # we need to update the varying parameters in the
            # objective first
            self.objective.setp(x)
            return float(self.pars[0] + self.pars[1])
    
    from scipy.optimize import NonlinearConstraint
    dec = DEC(pars, objective)
    constraint = NonlinearConstraint(dec, sf_lb, sf_ub)
    
    class LogpExtra(object):
        def __init__(self,pars):
            self.pars = pars
            
        def __call__(self,model,data):
            if float(self.pars[0] + self.pars[1]) < sf_lb or float(self.pars[0] + self.pars[1]) > sf_ub:
                return -np.inf
            return 0
    lpe = LogpExtra(pars)
    objective.logp_extra = lpe
    
    fitter = CurveFitter(objective)
    fitter.fit('differential_evolution',{'constraints':constraint})

#%%
    #MCMC sampling
    if MCMC == True:
        fitter.initialise('jitter')
        fitter.sample(400)
        fitter.reset()
    
        res = fitter.sample(15,nthin=100)

#%%
    # check model
    objective.plot()
    
    #%%
    '''
    Getting fitted params with errors into a readable dictionary
    '''
    
    param_names = []
    param_vals = []
    param_err = []
    
    # capture fitted parameter name, output and std error
    params = objective.parameters.flattened()
    for i in np.arange(len(params)):
        param_names.append(params[i].name) # str
        param_vals.append(params[i].value) # int
        
        error = params[i].stderr
        if error == None:
            error = 0
        param_err.append(error) # int
    
    # stick vals and errors together
    val_err_array = np.column_stack((param_vals,param_err))
        
    # build results dictionary key --> param, value --> array(value,error)
    fitted_params = {}
    count = 0
    for ind, name in enumerate(param_names):   
        if name == 'scale' and count == 0:
            count = 1
            fitted_params[name] = val_err_array[ind,:]
        elif name == 'scale':
            fitted_params[name+'_2nd'] = val_err_array[ind,:]
        else:
            fitted_params[name] = val_err_array[ind,:]
    if model_no in [3,4]:        
        params_ofinterest = ['OA - thick','OA - sld','OA - rough','SO - thick','SO - sld','SO - rough','film - thick','film - sld','film - rough','D2O - thick','D2O - rough','repeats','scale']
    elif model_no in [5,6]:
        params_ofinterest = ['OA - thick','OA - sld','OA - rough','film - thick','film - sld','film - rough','D2O - thick','D2O - rough','repeats','scale']  
    elif model_no == 1:
        params_ofinterest = ['OA - thick','OA - sld','OA - rough','SO - thick','SO - sld','SO - rough','film - thick','film - sld','film - rough','repeats','scale','scale_2nd']
    elif model_no in [7,8]:
        params_ofinterest = ['OA - thick','OA - sld','OA - rough','SO - thick','SO - sld','SO - rough','film - thick','film - sld','film - rough','repeats','scale']
    else:
        params_ofinterest = ['OA - thick','OA - sld','OA - rough','SO - thick','SO - sld','SO - rough','film - thick','film - sld','film - rough','D2O - thick','D2O - rough','repeats','scale','scale_2nd']
    param_val_select = []
    for valname in params_ofinterest:
        param_val_select.append(fitted_params[valname])
    output = np.column_stack((params_ofinterest,param_val_select))
    output_df = pd.DataFrame(output)
    if MCMC == True:
        output_df.to_csv('DA4000rpm_incRH_kinetic_fitted_params_GenAlg_model{}_run{}_MCMC.csv'.format(model_no,file_no),index_label=False)    
    else:
        output_df.to_csv('DA4000rpm_incRH_kinetic_fitted_params_GenAlg_model{}_run{}.csv'.format(model_no,file_no),index_label=False)    
    
    # pickle model and objective
    filename = 'DA4000rpm_decRH_kinetic_model{}_run{}.pkl'.format(model_no,file_no)
    if MCMC == True:
        filename = 'DA4000rpm_decRH_kinetic_nlc_MCMC_model{}_run{}.pkl'.format(model_no,file_no)
    
    # pickle objective for future analysis
    with open(filename,'wb+') as f:
        pickle.dump(objective,f) 






