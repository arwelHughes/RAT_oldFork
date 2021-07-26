//
// Non-Degree Granting Education License -- for use at non-degree
// granting, nonprofit, educational organizations only. Not for
// government, commercial, or other organizational use.
//
// makeSLDProfileXY.h
//
// Code generation for function 'makeSLDProfileXY'
//

#ifndef MAKESLDPROFILEXY_H
#define MAKESLDPROFILEXY_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
void makeSLDProfileXY(double nbair, double nbsub, double ssub,
                      const coder::array<double, 2U> &layers,
                      double numberOfLayers, double nrepeats,
                      coder::array<double, 2U> &out);

#endif
// End of code generation (makeSLDProfileXY.h)
