//
// Non-Degree Granting Education License -- for use at non-degree
// granting, nonprofit, educational organizations only. Not for
// government, commercial, or other organizational use.
//
// reflectivity_calculation.h
//
// Code generation for function 'reflectivity_calculation'
//

#ifndef REFLECTIVITY_CALCULATION_H
#define REFLECTIVITY_CALCULATION_H

// Include files
#include "reflectivity_calculation_spec.h"
#include "reflectivity_calculation_types.h"
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
REFLECTIVITY_CALCULATION_DLL_EXPORT extern void reflectivity_calculation(
    const struct0_T *problemDef, const cell_6 *problemDef_cells,
    const struct1_T *problemDef_limits, const struct2_T *controls,
    struct4_T *problem, cell_9 *result);

#endif
// End of code generation (reflectivity_calculation.h)
