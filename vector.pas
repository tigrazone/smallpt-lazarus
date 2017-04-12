UNIT Vector;

INTERFACE

USES
  Utils;

TYPE
  TVector = RECORD
    x : FloatType;
    y : FloatType;
    z : FloatType;
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

FUNCTION Vector_Init(x, y, z : FloatType) : TVector;
BEGIN
  Result.x := x;
  Result.y := y;
  Result.z := z;
END;

PROCEDURE Vector_Add(VAR Result : TVector; a, b : TVector);
BEGIN
  Result.x := Utils_kahanSum(a.x, b.x);
  Result.y := Utils_kahanSum(a.y, b.y);
  Result.z := Utils_kahanSum(a.z, b.z);
END;

PROCEDURE Vector_Add3(VAR Result : TVector; a, b, c : TVector);
BEGIN
  Result.x := Utils_kahanSum3(a.x, b.x, c.x);
  Result.y := Utils_kahanSum3(a.y, b.y, c.y);
  Result.z := Utils_kahanSum3(a.z, b.z, c.z);
END;

PROCEDURE Vector_Sub(VAR Result : TVector; a, b : TVector);
BEGIN
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
END;

PROCEDURE Vector_MultiplyVec(VAR Result : TVector; a, b : TVector);
BEGIN
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
END;

PROCEDURE Vector_MultiplyFloat(VAR Result : TVector; a : TVector; value : FloatType);
BEGIN
  Result.x := a.x * value;
  Result.y := a.y * value;
  Result.z := a.z * value;
END;

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
BEGIN
  Vector_Dot := a.x * b.x + a.y * b.y + a.z * b.z;
END;

FUNCTION Vector_DotDot(a : TVector) : FloatType;
BEGIN
  Vector_DotDot := Sqr(a.x) + Sqr(a.y) + Sqr(a.z);
  //Vector_DotDot := a.x*a.x + a.y*a.y + a.z*a.z;
END;

PROCEDURE Vector_Cross(VAR Result : TVector; a, b : TVector);
BEGIN
  Result.x := a.y * b.z - a.z * b.y;
  Result.y := a.z * b.x - a.x * b.z;
  Result.z := a.x * b.y - a.y * b.x;
END;

END.

