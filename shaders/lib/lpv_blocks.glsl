/*
    lightColor  3*8=24
    lightRange  8=8
    tintColor   3*8=24
    lightMask   6=8
*/

#ifdef RENDER_SETUP
    layout(rg32ui) uniform writeonly uimage2D imgBlockData;
#else
    layout(rg32ui) uniform readonly uimage2D imgBlockData;
#endif
