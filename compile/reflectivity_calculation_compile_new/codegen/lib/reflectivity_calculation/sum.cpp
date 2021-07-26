//
// Non-Degree Granting Education License -- for use at non-degree
// granting, nonprofit, educational organizations only. Not for
// government, commercial, or other organizational use.
//
// sum.cpp
//
// Code generation for function 'sum'
//

// Include files
#include "sum.h"
#include "combineVectorElements.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
void sum(const ::coder::array<double, 2U> &x, ::coder::array<double, 1U> &y)
{
  combineVectorElements(x, y);
}

double sum(const ::coder::array<double, 1U> &x)
{
  return combineVectorElements(x);
}

} // namespace coder

// End of code generation (sum.cpp)
