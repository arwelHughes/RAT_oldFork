function [output,sub_rough] = volume_layer_bilayer_wph(params,bulk_in,bulk_out,contrast)
%CUSTOM_LAYER_THIOL_BILAYER  RASCAL Custom Layer Model File.
%
%
% This file accepts 3 vectors containing the values for
% Params, bulk in and bulk out
% The final parameter is an index of the contrast being calculated
% The m-file should output a matrix of layer values, in the form..
% Output = [thick 1, SLD 1, Rough 1, Percent Hydration 1, Hydrate how 1
%           ....
%           thick n, SLD n, Rough n, Percent Hydration n, Hydration how n]
% The "hydrate how" parameter decides if the layer is hydrated with
% Bulk out or Bulk in phases. Set to 1 for Bulk out, zero for Bulk in.
% Alternatively, leave out hydration and just return..
% Output = [thick 1, SLD 1, Rough 1,
%           ....
%           thick n, SLD n, Rough n] };
% The second output parameter should be the substrate roughness


Substrate_Roughness	= params(1);
Alloy_Thick	 = params(2); 
Alloy_SLD_up = params(3); 	
Alloy_Rough = params(4);	
Gold_Thick = params(5); 	
Gold_Rough = params(6);	
Gold_SLD = params(7); 	
Thiol_APM = params(8);
Thiol_wph = params(9);   %Number of hydrating water molecs in head group
Thiol_coverage = params(10);
Thiol_rough = params(11);
Alloy_SLD_down = params(12);

GOLD = [Gold_Thick Gold_SLD Gold_Rough];
ALLOY_UP = [Alloy_Thick Alloy_SLD_up Alloy_Rough];
ALLOY_DOWN = [Alloy_Thick Alloy_SLD_down Alloy_Rough];

%Neutron b's..
%define all the neutron b's.
bc = 0.6646e-4;     %Carbon
bo = 0.5843e-4;     %Oxygen
bh = -0.3739e-4;	%Hydrogen
bp = 0.513e-4;      %Phosphorus
bn = 0.936e-4;      %Nitrogen
bd = 0.6671e-4;     %Deuterium

%Work out the total scattering length in each fragment....
%Define scattering lengths..
%Hydrogenated version....
COO = (2*bo) + (bc);
GLYC = (3*bc) + (5*bh);
CH3 = (1*bc) + (1*bh);             
PO4 = (1*bp) + (4*bo);
CH2 = (1*bc) + (2*bh);
CH = (1*bc) + (1*bh);
CHOL = (5*bc) + (12*bh) + (1*bn);
H2O = (2*bh) + (1*bo);
D2O = (2*bd) + (1*bo);

%And also volumes....
vCH3 = (52.7/2);        %CH3 volume in the paper appears to be for 2* CH3's
vCH2 = 28.1;
vCOO = 39.0;
vGLYC = 68.8;
vPO4 = 53.7;
vCHOL = 120.4;
vWAT = 30.4;
vCH_CH = 42.14;

vHead = vCHOL + vPO4 + vGLYC + 2*vCOO;
vTail = (28*vCH2) + (1*vCH_CH) + vCH3;%Tail_volume;

%Calculate mole fraction of D2O from the bulk SLD..
Rho_d2o = 6.35e-6;
Rho_h2o = -0.56e-6;
Rho_this = bulk_out(contrast);
d2o_molfr = (Rho_this-Rho_h2o)/(Rho_d2o-Rho_h2o);

%..so use this to calculat 'average' sum_b per water molecule in bulk
sumb_Water = (d2o_molfr * D2O) + ((1-d2o_molfr)*H2O);

%Calculate sum_b's for other fragments
sumb_Head = CHOL + PO4 + GLYC + 2*COO;
sumb_Tail = (28*CH2) + (2*CH) + CH3;

%Need to include the number of hydrating water molecules in head sum_b
%and head volume.
total_sumb_water = sumb_Water * Thiol_wph;
total_vol_water = vWAT * Thiol_wph;

vHead = vHead + total_vol_water;
sumb_Head = sumb_Head + total_sumb_water;


%Calculate SLD's and Thickness'
sldHead = sumb_Head/vHead;
thickHead = vHead/Thiol_APM;

sldTail = sumb_Tail/vTail;
thickTail = vTail/Thiol_APM;

%Now correct both the SLD's for the coverage parameter
sldTail = (Thiol_coverage*sldTail) + ((1-Thiol_coverage) * bulk_out(contrast));
sldHead = (Thiol_coverage*sldHead) + ((1-Thiol_coverage) * bulk_out(contrast));


SAMTAILS = [thickTail sldTail Thiol_rough];
SAMHEAD = [thickHead sldHead Thiol_rough];



switch contrast
    case{1,3}
        output = [ALLOY_UP; GOLD; SAMTAILS; SAMHEAD] ;
    otherwise
        output = [ALLOY_DOWN; GOLD; SAMTAILS; SAMHEAD] ;
end

sub_rough = Substrate_Roughness;

    