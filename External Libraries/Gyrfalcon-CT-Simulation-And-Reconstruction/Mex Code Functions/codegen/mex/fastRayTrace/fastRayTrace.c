/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * fastRayTrace.c
 *
 * Code generation for function 'fastRayTrace'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "fastRayTrace.h"
#include "norm.h"
#include "fastRayTrace_data.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 102,   /* lineNo */
  "fastRayTrace",                      /* fcnName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m"                               /* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 108, /* lineNo */
  "fastRayTrace",                      /* fcnName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m"                               /* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 13,  /* lineNo */
  "min",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2017a\\toolbox\\eml\\lib\\matlab\\datafun\\min.m"/* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 19,  /* lineNo */
  "minOrMax",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2017a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pathName */
};

static emlrtDCInfo emlrtDCI = { 115,   /* lineNo */
  47,                                  /* colNo */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo emlrtBCI = { -1,    /* iFirst */
  -1,                                  /* iLast */
  115,                                 /* lineNo */
  47,                                  /* colNo */
  "phantomData",                       /* aName */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo b_emlrtDCI = { 115, /* lineNo */
  59,                                  /* colNo */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  115,                                 /* lineNo */
  59,                                  /* colNo */
  "phantomData",                       /* aName */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo c_emlrtDCI = { 115, /* lineNo */
  71,                                  /* colNo */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  1                                    /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  115,                                 /* lineNo */
  71,                                  /* colNo */
  "phantomData",                       /* aName */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo b_emlrtRTEI = { 39,/* lineNo */
  27,                                  /* colNo */
  "minOrMax",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2017a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pName */
};

static emlrtRTEInfo c_emlrtRTEI = { 121,/* lineNo */
  27,                                  /* colNo */
  "minOrMax",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2017a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax.m"/* pName */
};

static emlrtECInfo emlrtECI = { -1,    /* nDims */
  152,                                 /* lineNo */
  5,                                   /* colNo */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m"                               /* pName */
};

static emlrtECInfo b_emlrtECI = { -1,  /* nDims */
  153,                                 /* lineNo */
  5,                                   /* colNo */
  "fastRayTrace",                      /* fName */
  "C:\\Users\\MPRadmin\\Git Repos\\RITE-Dos\\External Libraries\\Gyrfalcon-CT-Simulation-And-Reconstruction\\Mex Code Functions\\fastRayTra"
  "ce.m"                               /* pName */
};

/* Function Declarations */
static void getLattices(const emlrtStack *sp, const real_T point[3], const
  real_T invVoxelDims[3], const boolean_T isVoxelDim0[3], boolean_T isDeltaNeg[3],
  const boolean_T isDelta0[3], real_T lattices[3]);

/* Function Definitions */
static void getLattices(const emlrtStack *sp, const real_T point[3], const
  real_T invVoxelDims[3], const boolean_T isVoxelDim0[3], boolean_T isDeltaNeg[3],
  const boolean_T isDelta0[3], real_T lattices[3])
{
  int32_T trueCount;
  int32_T k;
  int32_T i;
  real_T unroundedVals[3];
  static const int8_T iv1[3] = { 1, -1, -1 };

  int32_T tmp_data[3];
  real_T floorVals_data[3];
  int32_T b_trueCount;
  int32_T b_tmp_data[3];
  real_T ceilVals_data[3];

  /*  ** HELPER FUNCTIONS ** */
  /*  first need to kill off any rounding errors */
  /*  no round to get lattice/index values */
  isDeltaNeg[0] = !isDeltaNeg[0];

  /*  ceiling if delta is positive ONLY */
  trueCount = 0;
  for (k = 0; k < 3; k++) {
    if (isDeltaNeg[k] || isDelta0[k]) {
      trueCount++;
    }

    unroundedVals[k] = muDoubleScalarFloor((real_T)iv1[k] * (point[k] *
      invVoxelDims[k]) * 1.0E+10 + 0.5) * 1.0E-10;
  }

  k = 0;
  for (i = 0; i < 3; i++) {
    if (isDeltaNeg[i] || isDelta0[i]) {
      tmp_data[k] = i + 1;
      k++;
    }
  }

  for (k = 0; k < trueCount; k++) {
    floorVals_data[k] = unroundedVals[tmp_data[k] - 1];
  }

  for (k = 0; k + 1 <= trueCount; k++) {
    floorVals_data[k] = muDoubleScalarFloor(floorVals_data[k]);
  }

  b_trueCount = 0;
  for (i = 0; i < 3; i++) {
    if (!(isDeltaNeg[i] || isDelta0[i])) {
      b_trueCount++;
    }
  }

  k = 0;
  for (i = 0; i < 3; i++) {
    if (!(isDeltaNeg[i] || isDelta0[i])) {
      b_tmp_data[k] = i + 1;
      k++;
    }
  }

  for (k = 0; k < b_trueCount; k++) {
    ceilVals_data[k] = unroundedVals[b_tmp_data[k] - 1];
  }

  for (k = 0; k + 1 <= b_trueCount; k++) {
    ceilVals_data[k] = muDoubleScalarCeil(ceilVals_data[k]);
  }

  k = 0;
  for (i = 0; i < 3; i++) {
    lattices[i] = 0.0;
    if (isDeltaNeg[i] || isDelta0[i]) {
      k++;
    }
  }

  if (k != trueCount) {
    emlrtSizeEqCheck1DR2012b(k, trueCount, &emlrtECI, sp);
  }

  k = 0;
  trueCount = 0;
  for (i = 0; i < 3; i++) {
    if (isDeltaNeg[i] || isDelta0[i]) {
      lattices[i] = floorVals_data[k];
      k++;
    }

    if (!(isDeltaNeg[i] || isDelta0[i])) {
      trueCount++;
    }
  }

  if (trueCount != b_trueCount) {
    emlrtSizeEqCheck1DR2012b(trueCount, b_trueCount, &b_emlrtECI, sp);
  }

  k = 0;
  for (i = 0; i < 3; i++) {
    if (!(isDeltaNeg[i] || isDelta0[i])) {
      lattices[i] = ceilVals_data[k];
      k++;
    }

    if (isVoxelDim0[i]) {
      lattices[i] = 0.0;
    }
  }
}

void fastRayTrace(const emlrtStack *sp, const real_T pointSourceCoords[3], const
                  real_T pointDetectorCoords[3], const real_T
                  phantomLocationInM[3], const real_T phantomDims[3], const
                  real_T voxelDimsInM[3], const emxArray_real_T *phantomData,
                  real_T sourceToAxisInM, real_T axisToEpidInM, real_T
                  *waterEquivDoseSourceToIso, real_T *waterEquivDoseIsoToEpid)
{
  real_T bounds1[3];
  real_T bounds2[3];
  int32_T partialTrueCount;
  int32_T ixstart;
  int32_T trueCount;
  real_T sourceToDetectorInM;
  real_T tCrossover;
  real_T tMins[3];
  real_T deltas[3];
  real_T tMaxs[3];
  real_T invDeltas[3];
  int32_T tmp_data[3];
  real_T currentLattices[3];
  int32_T b_tmp_data[3];
  real_T tMin;
  real_T tMax;
  boolean_T isVoxelDim0[3];
  boolean_T isDeltaNeg;
  boolean_T latticeToIndex[3];
  boolean_T b_isDeltaNeg[3];
  real_T nextLatticeAdder[3];
  static const int8_T iv0[3] = { 1, -1, -1 };

  boolean_T c_isDeltaNeg[3];
  boolean_T b_deltas[3];
  int32_T c_tmp_data[3];
  boolean_T exitg1;
  real_T b_tMins[3];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;

  /*  rawDetectorValue = fastRayTrace(pointSourceCoords, pointDetectorCoords, phantomLocationInM, phantomDims, voxelDimsInM, phantomData, startingIntensity) */
  bounds1[0] = phantomLocationInM[0];
  bounds2[0] = phantomLocationInM[0] + voxelDimsInM[0] * phantomDims[0];
  for (partialTrueCount = 0; partialTrueCount < 2; partialTrueCount++) {
    bounds1[partialTrueCount + 1] = phantomLocationInM[1 + partialTrueCount] -
      voxelDimsInM[1 + partialTrueCount] * phantomDims[1 + partialTrueCount];
    bounds2[partialTrueCount + 1] = phantomLocationInM[1 + partialTrueCount];
  }

  /*  [deltas, point] = createLineEquation(point1, point2) */
  /*  creates a description of a line in 3-space to satisfy the equation: */
  /*  newPoint = point + t*deltas */
  for (ixstart = 0; ixstart < 3; ixstart++) {
    sourceToDetectorInM = pointDetectorCoords[ixstart] -
      pointSourceCoords[ixstart];
    tCrossover = 1.0 / sourceToDetectorInM;
    tMins[ixstart] = (bounds1[ixstart] - pointSourceCoords[ixstart]) *
      tCrossover;
    tMaxs[ixstart] = (bounds2[ixstart] - pointSourceCoords[ixstart]) *
      tCrossover;
    deltas[ixstart] = sourceToDetectorInM;
    invDeltas[ixstart] = tCrossover;
  }

  trueCount = 0;
  for (ixstart = 0; ixstart < 3; ixstart++) {
    if (deltas[ixstart] < 0.0) {
      trueCount++;
    }
  }

  partialTrueCount = 0;
  for (ixstart = 0; ixstart < 3; ixstart++) {
    if (deltas[ixstart] < 0.0) {
      tmp_data[partialTrueCount] = ixstart + 1;
      partialTrueCount++;
    }

    currentLattices[ixstart] = (bounds2[ixstart] - pointSourceCoords[ixstart]) *
      invDeltas[ixstart];
  }

  for (partialTrueCount = 0; partialTrueCount < trueCount; partialTrueCount++) {
    tMins[tmp_data[partialTrueCount] - 1] =
      currentLattices[tmp_data[partialTrueCount] - 1];
  }

  trueCount = 0;
  for (ixstart = 0; ixstart < 3; ixstart++) {
    if (deltas[ixstart] < 0.0) {
      trueCount++;
    }
  }

  partialTrueCount = 0;
  for (ixstart = 0; ixstart < 3; ixstart++) {
    if (deltas[ixstart] < 0.0) {
      b_tmp_data[partialTrueCount] = ixstart + 1;
      partialTrueCount++;
    }

    currentLattices[ixstart] = (bounds1[ixstart] - pointSourceCoords[ixstart]) *
      invDeltas[ixstart];
  }

  for (partialTrueCount = 0; partialTrueCount < trueCount; partialTrueCount++) {
    tMaxs[b_tmp_data[partialTrueCount] - 1] =
      currentLattices[b_tmp_data[partialTrueCount] - 1];
  }

  tMin = rtMinusInf;
  tMax = rtInf;
  if (deltas[0] != 0.0) {
    if (tMins[0] > rtMinusInf) {
      tMin = tMins[0];
    }

    if (tMaxs[0] < rtInf) {
      tMax = tMaxs[0];
    }
  } else {
    if ((pointSourceCoords[0] > bounds2[0]) || (pointSourceCoords[0] < bounds1[0]))
    {
      tMin = rtInf;
      tMax = rtMinusInf;
    }
  }

  if (deltas[1] != 0.0) {
    if (tMins[1] > tMin) {
      tMin = tMins[1];
    }

    if (tMaxs[1] < tMax) {
      tMax = tMaxs[1];
    }
  } else {
    if ((pointSourceCoords[1] > bounds2[1]) || (pointSourceCoords[1] < bounds1[1]))
    {
      tMin = rtInf;
      tMax = rtMinusInf;
    }
  }

  if (deltas[2] != 0.0) {
    if (tMins[2] > tMin) {
      tMin = tMins[2];
    }

    if (tMaxs[2] < tMax) {
      tMax = tMaxs[2];
    }
  } else {
    if ((pointSourceCoords[2] > bounds2[2]) || (pointSourceCoords[2] < bounds1[2]))
    {
      tMin = rtInf;
      tMax = rtMinusInf;
    }
  }

  if (tMax < tMin) {
    *waterEquivDoseSourceToIso = 0.0;
    *waterEquivDoseIsoToEpid = 0.0;
  } else {
    /*  run through the voxels */
    *waterEquivDoseSourceToIso = 0.0;
    *waterEquivDoseIsoToEpid = 0.0;

    /*  calc what t value represents being past isocentre */
    for (ixstart = 0; ixstart < 3; ixstart++) {
      currentLattices[ixstart] = pointSourceCoords[ixstart] -
        pointDetectorCoords[ixstart];
      tCrossover = pointSourceCoords[ixstart] - phantomLocationInM[ixstart];
      tMins[ixstart] = tCrossover + tMin * deltas[ixstart];
      isVoxelDim0[ixstart] = (voxelDimsInM[ixstart] == 0.0);
      isDeltaNeg = (deltas[ixstart] < 0.0);
      tMaxs[ixstart] = 1.0 / voxelDimsInM[ixstart];
      latticeToIndex[ixstart] = isDeltaNeg;
      bounds2[ixstart] = tCrossover;
      b_isDeltaNeg[ixstart] = isDeltaNeg;
      nextLatticeAdder[ixstart] = muDoubleScalarSign(deltas[ixstart]) * (real_T)
        iv0[ixstart];
    }

    sourceToDetectorInM = norm(currentLattices);
    tCrossover = tMin + sourceToAxisInM / ((sourceToAxisInM + axisToEpidInM) /
      sourceToDetectorInM) / sourceToDetectorInM * (tMax - tMin);

    /* shift over so corner is at origin */
    /*  have starting point and end point, now will find which voxels and with */
    /*  what distances across each voxel the ray travels */
    latticeToIndex[0] = !b_isDeltaNeg[0];
    for (ixstart = 0; ixstart < 3; ixstart++) {
      if (deltas[ixstart] == 0.0) {
        latticeToIndex[ixstart] = true;
      }
    }

    /* needs to be, since we always floor to find the lattice for delta == 0 */
    while (tMax - tMin > 1.0E-9) {
      for (partialTrueCount = 0; partialTrueCount < 3; partialTrueCount++) {
        c_isDeltaNeg[partialTrueCount] = b_isDeltaNeg[partialTrueCount];
        b_deltas[partialTrueCount] = (deltas[partialTrueCount] == 0.0);
      }

      st.site = &emlrtRSI;
      getLattices(&st, tMins, tMaxs, isVoxelDim0, c_isDeltaNeg, b_deltas,
                  currentLattices);
      trueCount = 0;
      for (ixstart = 0; ixstart < 3; ixstart++) {
        bounds1[ixstart] = ((currentLattices[ixstart] + nextLatticeAdder[ixstart])
                            * voxelDimsInM[ixstart] * (real_T)iv0[ixstart] -
                            bounds2[ixstart]) * invDeltas[ixstart];
        if (!(deltas[ixstart] == 0.0)) {
          trueCount++;
        }
      }

      partialTrueCount = 0;
      for (ixstart = 0; ixstart < 3; ixstart++) {
        if (!(deltas[ixstart] == 0.0)) {
          c_tmp_data[partialTrueCount] = ixstart + 1;
          partialTrueCount++;
        }
      }

      st.site = &b_emlrtRSI;
      b_st.site = &c_emlrtRSI;
      c_st.site = &d_emlrtRSI;
      if ((trueCount == 1) || (trueCount != 1)) {
        isDeltaNeg = true;
      } else {
        isDeltaNeg = false;
      }

      if (!isDeltaNeg) {
        emlrtErrorWithMessageIdR2012b(&c_st, &b_emlrtRTEI,
          "Coder:toolbox:autoDimIncompatibility", 0);
      }

      if (!(trueCount > 0)) {
        emlrtErrorWithMessageIdR2012b(&c_st, &c_emlrtRTEI,
          "Coder:toolbox:eml_min_or_max_varDimZero", 0);
      }

      ixstart = 1;
      tMin = bounds1[c_tmp_data[0] - 1];
      if (trueCount > 1) {
        if (muDoubleScalarIsNaN(bounds1[c_tmp_data[0] - 1])) {
          partialTrueCount = 2;
          exitg1 = false;
          while ((!exitg1) && (partialTrueCount <= trueCount)) {
            ixstart = partialTrueCount;
            if (!muDoubleScalarIsNaN(bounds1[c_tmp_data[partialTrueCount - 1] -
                 1])) {
              tMin = bounds1[c_tmp_data[partialTrueCount - 1] - 1];
              exitg1 = true;
            } else {
              partialTrueCount++;
            }
          }
        }

        if (ixstart < trueCount) {
          while (ixstart + 1 <= trueCount) {
            if (bounds1[c_tmp_data[ixstart] - 1] < tMin) {
              tMin = bounds1[c_tmp_data[ixstart] - 1];
            }

            ixstart++;
          }
        }
      }

      for (partialTrueCount = 0; partialTrueCount < 3; partialTrueCount++) {
        sourceToDetectorInM = bounds2[partialTrueCount] + tMin *
          deltas[partialTrueCount];
        b_tMins[partialTrueCount] = tMins[partialTrueCount] -
          sourceToDetectorInM;
        bounds1[partialTrueCount] = sourceToDetectorInM;
        currentLattices[partialTrueCount] += (real_T)
          latticeToIndex[partialTrueCount];
      }

      sourceToDetectorInM = norm(b_tMins);
      if (currentLattices[1] != (int32_T)muDoubleScalarFloor(currentLattices[1]))
      {
        emlrtIntegerCheckR2012b(currentLattices[1], &emlrtDCI, sp);
      }

      partialTrueCount = phantomData->size[0];
      ixstart = (int32_T)currentLattices[1];
      if (!((ixstart >= 1) && (ixstart <= partialTrueCount))) {
        emlrtDynamicBoundsCheckR2012b(ixstart, 1, partialTrueCount, &emlrtBCI,
          sp);
      }

      if (currentLattices[0] != (int32_T)muDoubleScalarFloor(currentLattices[0]))
      {
        emlrtIntegerCheckR2012b(currentLattices[0], &b_emlrtDCI, sp);
      }

      partialTrueCount = phantomData->size[1];
      ixstart = (int32_T)currentLattices[0];
      if (!((ixstart >= 1) && (ixstart <= partialTrueCount))) {
        emlrtDynamicBoundsCheckR2012b(ixstart, 1, partialTrueCount, &b_emlrtBCI,
          sp);
      }

      if (currentLattices[2] != (int32_T)muDoubleScalarFloor(currentLattices[2]))
      {
        emlrtIntegerCheckR2012b(currentLattices[2], &c_emlrtDCI, sp);
      }

      partialTrueCount = phantomData->size[2];
      ixstart = (int32_T)currentLattices[2];
      if (!((ixstart >= 1) && (ixstart <= partialTrueCount))) {
        emlrtDynamicBoundsCheckR2012b(ixstart, 1, partialTrueCount, &c_emlrtBCI,
          sp);
      }

      for (partialTrueCount = 0; partialTrueCount < 3; partialTrueCount++) {
        tMins[partialTrueCount] = bounds1[partialTrueCount];
      }

      if (tMin <= tCrossover) {
        /*  in the source-to-iso area */
        *waterEquivDoseSourceToIso += sourceToDetectorInM * phantomData->data
          [(((int32_T)currentLattices[1] + phantomData->size[0] * ((int32_T)
              currentLattices[0] - 1)) + phantomData->size[0] *
            phantomData->size[1] * ((int32_T)currentLattices[2] - 1)) - 1];
      } else {
        /*  in the iso-to-EPID area */
        *waterEquivDoseIsoToEpid += sourceToDetectorInM * phantomData->data
          [(((int32_T)currentLattices[1] + phantomData->size[0] * ((int32_T)
              currentLattices[0] - 1)) + phantomData->size[0] *
            phantomData->size[1] * ((int32_T)currentLattices[2] - 1)) - 1];
      }

      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b(sp);
      }
    }
  }
}

/* End of code generation (fastRayTrace.c) */
