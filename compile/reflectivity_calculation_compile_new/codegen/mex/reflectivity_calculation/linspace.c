/*
 * Non-Degree Granting Education License -- for use at non-degree
 * granting, nonprofit, education, and research organizations only. Not
 * for commercial or industrial use.
 *
 * linspace.c
 *
 * Code generation for function 'linspace'
 *
 */

/* Include files */
#include "linspace.h"
#include "reflectivity_calculation_emxutil.h"
#include "reflectivity_calculation_types.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRTEInfo mb_emlrtRTEI = {
    33,         /* lineNo */
    37,         /* colNo */
    "linspace", /* fName */
    "/usr/local/MATLAB/R2021b/toolbox/eml/lib/matlab/elmat/linspace.m" /* pName
                                                                        */
};

static emlrtRTEInfo pj_emlrtRTEI = {
    49,         /* lineNo */
    20,         /* colNo */
    "linspace", /* fName */
    "/usr/local/MATLAB/R2021b/toolbox/eml/lib/matlab/elmat/linspace.m" /* pName
                                                                        */
};

/* Function Definitions */
void linspace(const emlrtStack *sp, real_T d1, real_T d2, real_T n,
              emxArray_real_T *y)
{
  real_T delta1;
  real_T delta2;
  real_T *y_data;
  int32_T k;
  int32_T y_tmp_tmp;
  if (!(n >= 0.0)) {
    if (muDoubleScalarIsNaN(n)) {
      emlrtErrorWithMessageIdR2018a(sp, &mb_emlrtRTEI,
                                    "Coder:toolbox:MustNotBeNaN",
                                    "Coder:toolbox:MustNotBeNaN", 3, 4, 1, "N");
    }
    y->size[0] = 1;
    y->size[1] = 0;
  } else {
    delta1 = muDoubleScalarFloor(n);
    y_tmp_tmp = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int32_T)delta1;
    emxEnsureCapacity_real_T(sp, y, y_tmp_tmp, &pj_emlrtRTEI);
    y_data = y->data;
    if ((int32_T)delta1 >= 1) {
      y_tmp_tmp = (int32_T)delta1 - 1;
      y_data[(int32_T)muDoubleScalarFloor(n) - 1] = d2;
      if (y->size[1] >= 2) {
        y_data[0] = d1;
        if (y->size[1] >= 3) {
          if ((d1 == -d2) && ((int32_T)delta1 > 2)) {
            delta2 = d2 / ((real_T)(int32_T)delta1 - 1.0);
            for (k = 2; k <= y_tmp_tmp; k++) {
              y_data[k - 1] =
                  (real_T)(((k << 1) - (int32_T)delta1) - 1) * delta2;
            }
            if (((int32_T)delta1 & 1) == 1) {
              y_data[(int32_T)delta1 >> 1] = 0.0;
            }
          } else if (((d1 < 0.0) != (d2 < 0.0)) &&
                     ((muDoubleScalarAbs(d1) > 8.9884656743115785E+307) ||
                      (muDoubleScalarAbs(d2) > 8.9884656743115785E+307))) {
            delta1 = d1 / ((real_T)y->size[1] - 1.0);
            delta2 = d2 / ((real_T)y->size[1] - 1.0);
            y_tmp_tmp = y->size[1];
            for (k = 0; k <= y_tmp_tmp - 3; k++) {
              y_data[k + 1] = (d1 + delta2 * ((real_T)k + 1.0)) -
                              delta1 * ((real_T)k + 1.0);
            }
          } else {
            delta1 = (d2 - d1) / ((real_T)y->size[1] - 1.0);
            y_tmp_tmp = y->size[1];
            for (k = 0; k <= y_tmp_tmp - 3; k++) {
              y_data[k + 1] = d1 + ((real_T)k + 1.0) * delta1;
            }
          }
        }
      }
    }
  }
}

/* End of code generation (linspace.c) */