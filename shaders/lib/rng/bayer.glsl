#if !defined RNG_BAYER
#define RNG_BAYER
    //https://www.shadertoy.com/view/4ssfWM
    float Bayer32(vec2 a) {
        uvec2 b = uvec2(a);
        uint x = ((b.x^b.y)&0x1fu) | b.y<<5;

        x = (x & 0x048u)
        | ((x & 0x024u) << 3)
        | ((x & 0x002u) << 6)
        | ((x & 0x001u) << 9)
        | ((x & 0x200u) >> 9)
        | ((x & 0x100u) >> 6)
        | ((x & 0x090u) >> 3); // 22 ops
    
        return float(
            x
        )/32./32.;
    }
#endif