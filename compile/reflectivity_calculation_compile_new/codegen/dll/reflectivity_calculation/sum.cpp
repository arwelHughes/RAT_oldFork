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
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
double sum(const ::coder::array<double, 1U> &x)
{
  double y;
  int vlen;
  vlen = x.size(0);
  if (x.size(0) == 0) {
    y = 0.0;
  } else {
    int firstBlockLength;
    int k;
    int lastBlockLength;
    int nblocks;
    if (x.size(0) <= 1024) {
      firstBlockLength = x.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x.size(0) / 1024;
      lastBlockLength = x.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y = x[0];
    for (k = 2; k <= firstBlockLength; k++) {
      if (vlen >= 2) {
        y += x[k - 1];
      }
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      double bsum;
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum = x[firstBlockLength];
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (k = 2; k <= hi; k++) {
        if (vlen >= 2) {
          bsum += x[(firstBlockLength + k) - 1];
        }
      }
      y += bsum;
    }
  }
  return y;
}

} // namespace coder

// End of code generation (sum.cpp)
