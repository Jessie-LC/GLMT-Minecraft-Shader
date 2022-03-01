struct complexFloat {
	float r;
	float i;
};

complexFloat complexAdd(complexFloat a, complexFloat b) {
	complexFloat c;
	c.r=a.r+b.r;
	c.i=a.i+b.i;
	return c;
}

complexFloat complexAdd(float a, complexFloat b) {
	complexFloat c;
	c.r=a+b.r;
	c.i= +b.i;
	return c;
}

complexFloat complexAdd(complexFloat a, float b) {
	complexFloat c;
	c.r=a.r+b;
	c.i=  a.i;
	return c;
}

complexFloat complexSub(complexFloat a, complexFloat b) {
	complexFloat c;
	c.r=a.r-b.r;
	c.i=a.i-b.i;
	return c;
}

complexFloat complexSub(complexFloat a, float b) {
	complexFloat c;
	c.r=a.r-b;
	c.i=  a.i;
	return c;
}

complexFloat complexSub(float a, complexFloat b) {
	complexFloat c;
	c.r=a-b.r;
	c.i= -b.i;
	return c;
}

complexFloat complexMul(complexFloat a, complexFloat b) {
	complexFloat c;
	c.r=a.r*b.r-a.i*b.i;
	c.i=a.i*b.r+a.r*b.i;
	return c;
}

complexFloat complexMul(float x, complexFloat a) {
	complexFloat c;
	c.r=x*a.r;
	c.i=x*a.i;
	return c;
}

complexFloat complexMul(complexFloat x, float a) {
	complexFloat c;
	c.r=x.r*a;
	c.i=x.i*a;
	return c;
}

complexFloat complexSquare(complexFloat x) {
    return complexMul(x, x);
}

complexFloat complexConjugate(complexFloat z) {
	complexFloat c;
	c.r=z.r;
	c.i = -z.i;
	return c;
}

complexFloat complexDiv(complexFloat a, complexFloat b) {
	complexFloat c;
	float r,den;
	if (abs(b.r) >= abs(b.i)) {
		r=b.i/b.r;
		den=b.r+r*b.i;
		c.r=(a.r+r*a.i)/(den);
		c.i=(a.i-r*a.r)/(den);
	} else {
		r=b.r/b.i;
		den=b.i+r*b.r;
		c.r=(a.r*r+a.i)/(den);
		c.i=(a.i*r-a.r)/(den);
	}
	return c;
}

float complexAbs(complexFloat z) {
	return sqrt(z.r*z.r + z.i*z.i);
}

complexFloat complexSqrt(complexFloat z) {
	complexFloat c;
	float x,y,w,r;
	if ((z.r == 0.0) && (z.i == 0.0)) {
		c.r=0.0;
		c.i=0.0;
		return c;
	} else {
		x=abs(z.r);
		y=abs(z.i);
		if (x >= y) {
			r=y/x;
			w=sqrt(x)*sqrt(0.5*(1.0+sqrt(1.0+r*r)));
		} else {
			r=x/y;
			w=sqrt(y)*sqrt(0.5*(r+sqrt(1.0+r*r)));
		}
		if (z.r >= 0.0) {
			c.r=w;
			c.i=z.i/(2.0*w);
		} else {
			c.i=(z.i >= 0.0) ? w : -w;
			c.r=z.i/(2.0*c.i);
		}
		return c;
	}
}

complexFloat complexExp(complexFloat z) {
	return complexMul(exp(z.r), complexFloat(cos(z.i), sin(z.i)));
}

complexFloat complexLog(complexFloat z) {
    return complexFloat(0.5 * log(z.r * z.r + z.i * z.i), atan(z.i, z.r));
}

complexFloat complexSinh(complexFloat z) {
    return complexFloat(sinh(z.r) * cos(z.i), cosh(z.r) * sin(z.i));
}
complexFloat complexCosh(complexFloat z) {
    return complexFloat(cosh(z.r) * cos(z.i), sinh(z.r) * sin(z.i));
}

complexFloat complexSin(complexFloat z) {
	z = complexDiv(complexSub(complexExp(complexMul(complexFloat(0.0, 1.0), z)), complexExp(complexMul(complexFloat(0.0, -1.0), z))), complexFloat(0.0, 2.0));
    return z;
}
complexFloat complexCos(complexFloat z) {
	z = complexDiv(complexAdd(complexExp(complexMul(complexFloat(0.0, 1.0), z)), complexExp(complexMul(complexFloat(0.0, -1.0), z))), complexFloat(2.0, 0.0));
    return z;
}
complexFloat complexArgument(complexFloat z) {
  return complexFloat(atan(z.i, z.r), 0.0);
}
complexFloat complexArcsin(complexFloat z) {
  return complexDiv(
	  complexLog(
		  complexAdd(
			  complexMul(complexFloat(0.0, 1.0), z), 
			  complexMul(
				  sqrt(
					  complexAbs(
						  complexSub(1.0, complexSquare(z))
						)
					),
			  complexExp(
				  complexMul(
					  complexFloat(0.0, 0.5), 
					  complexArgument(
						  complexSub(1.0, complexSquare(z))
					  	)
					)
				)
				)
			)
		), 
		complexFloat(0.0, 1.0)
	);
}

complexFloat vectorToComplex(vec2 z) {
	return complexFloat(z.x, z.y);
}