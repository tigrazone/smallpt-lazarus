UNIT Vector;
INTERFACE
USES
  Utils;

{$IFDEF SSE}
  {$CODEALIGN LOCALMIN=16}
  {$CODEALIGN VARMIN=16}
{$ENDIF}
TYPE
  TVector = RECORD
    x : FloatType;
    y : FloatType;
    z : FloatType;
    {$IFDEF SSE}
//    t : FloatType;
    {$ENDIF}
  END;

FUNCTION Vector_Init(x, y, z : FloatType) : TVector;
PROCEDURE Vector_Add(VAR Result : TVector; a, b : TVector);
PROCEDURE Vector_Add3(VAR Result : TVector; a, b, c : TVector);
PROCEDURE Vector_Sub(VAR Result : TVector; a, b : TVector);
PROCEDURE Vector_MultiplyVec(VAR Result : TVector; a, b : TVector);
PROCEDURE Vector_MultiplyFloat(VAR Result : TVector; a : TVector; value : FloatType);
PROCEDURE Vector_Normalise(VAR Result : TVector; a : TVector);
FUNCTION Vector_Dot(a, b : TVector) : FloatType;
FUNCTION Vector_DotDot(a: TVector) : FloatType;
PROCEDURE Vector_Cross(VAR Result : TVector; a, b : TVector);

IMPLEMENTATION
{$EXCESSPRECISION OFF}
{$ASMMODE INTEL}

FUNCTION Vector_Init(x, y, z : FloatType) : TVector;
BEGIN
  Result.x := x;
  Result.y := y;
  Result.z := z;
  {$IFDEF SSE}
//  Result.t := 0;
  {$ENDIF}
END;

PROCEDURE Vector_Add(VAR Result : TVector; a, b : TVector);
{$IFDEF SSE}
ASM
  // rcx=@result, rdx=@a, r8=@b
  movupd xmm0,[rdx]
  addpd xmm0,[r8]
  movupd [rcx],xmm0
  movsd xmm1,[rdx+16]
  addsd xmm1,[r8+16]
  movsd [rcx+16],xmm1
END;
{$ELSE}
BEGIN
  Result.x := Utils_kahanSum(a.x, b.x);
  Result.y := Utils_kahanSum(a.y, b.y);
  Result.z := Utils_kahanSum(a.z, b.z);
END;
{$ENDIF}

PROCEDURE Vector_Add3(VAR Result : TVector; a, b, c : TVector);
BEGIN
  Result.x := Utils_kahanSum3(a.x, b.x, c.x);
  Result.y := Utils_kahanSum3(a.y, b.y, c.y);
  Result.z := Utils_kahanSum3(a.z, b.z, c.z);
END;

PROCEDURE Vector_Sub(VAR Result : TVector; a, b : TVector);
{$IFDEF SSE}
ASM
  movapd xmm0,[rdx]
  subpd xmm0,[r8]
  movapd [rcx],xmm0
  movsd xmm1,[rdx+16]
  subsd xmm1,[r8+16]
  movsd [rcx+16],xmm1
END;
{$ELSE}
BEGIN
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
END;
{$ENDIF}

PROCEDURE Vector_MultiplyVec(VAR Result : TVector; a, b : TVector);
{$IFDEF SSE}
ASM
  // rcx=@result, rdx=@a, r8=@b
  movapd xmm0,[rdx]
  mulpd xmm0,[r8]
  movapd [rcx],xmm0
  movsd xmm1,[rdx+16]
  mulsd xmm1,[r8+16]
  movsd [rcx+16],xmm1
END;
{$ELSE}
BEGIN
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
END;
{$ENDIF}

PROCEDURE Vector_MultiplyFloat(VAR Result : TVector; a : TVector; value : FloatType);
{$IFDEF SSE}
ASM
  // rcx=@result, rdx=a, XMM2=scalar
  shufpd xmm2,xmm2,0
  movapd xmm0,[rdx]
  mulpd xmm0,xmm2
  movapd [rcx],xmm0
  movsd xmm1,[rdx+16]
  mulsd xmm1,xmm2
  movsd [rcx+16],xmm1
END;
{$ELSE}
BEGIN
  Result.x := a.x * value;
  Result.y := a.y * value;
  Result.z := a.z * value;
END;
{$ENDIF}

PROCEDURE Vector_Normalise(VAR Result : TVector; a : TVector);
VAR
  m, m1 : FloatType;
BEGIN
  m := sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
  IF (m = 0) THEN
  BEGIN
    Result.x := 0;
    Result.y := 0;
    Result.z := 0;
  END ELSE
  BEGIN
    m1 := 1/m;
    Result.x := a.x * m1;
    Result.y := a.y * m1;
    Result.z := a.z * m1;
  END;
END;

FUNCTION Vector_Dot(a, b : TVector) : FloatType;
{$IFDEF SSE}
ASM
  // rcx = @a, rdx = @b, result = xmm0
  movapd xmm0,[rcx]  // xmm0 = (a.x, a.y)
  mulpd xmm0,[rdx]   // xmm0 = (a.x*b.x, a.y*b.y)
  haddpd xmm0,xmm1   // xmm0 = (a.x*b.x + a.y*b.y, ???)
  movsd xmm2,[rcx+16]  // xmm2 = (a.z)
  mulsd xmm2,[rdx+16]  // xmm2 = (a.z*b.z)
  addsd xmm0,xmm2      // xmm0 = a.x*b.x + a.y*b.y + a.z*.b.z
END;
{$ELSE}
BEGIN
  Vector_Dot := a.x * b.x + a.y * b.y + a.z * b.z;
END;
{$ENDIF}

FUNCTION Vector_DotDot(a : TVector) : FloatType;
{$IFDEF SSE}
ASM
  // rcx=@a, result = xmm0
  movapd xmm0,[rcx]
  mulpd xmm0,xmm0      // xmm0 = (a.x^2, a.y^2)
  movsd xmm1,[rcx+16]  // xmm1 = (a.z^2, 0)
  mulsd xmm1,xmm1
  haddpd xmm0,xmm1
  addsd xmm0,xmm1
END;
{$ELSE}
BEGIN
  Vector_DotDot := Sqr(a.x) + Sqr(a.y) + Sqr(a.z);
  //Vector_DotDot := a.x*a.x + a.y*a.y + a.z*a.z;
END;
{$ENDIF}

PROCEDURE Vector_Cross(VAR Result : TVector; a, b : TVector);
BEGIN
  Result.x := a.y * b.z - a.z * b.y;
  Result.y := a.z * b.x - a.x * b.z;
  Result.z := a.x * b.y - a.y * b.x;
END;

END.

