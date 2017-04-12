UNIT Utils;

INTERFACE

CONST
  M_PI = 3.14159265358979323846;
  M_PI2 = M_PI + M_PI;
  gamma2_2 = 1.0 / 2.2;

TYPE
  FloatType  = DOUBLE;
  ErandType  = WORD;
  ERandArray = ARRAY[0..3] OF ErandType;

FUNCTION Utils_fabs(value : FloatType) : FloatType;
FUNCTION Utils_clamp(value : FloatType) : FloatType;
FUNCTION Utils_toInt(value : FloatType) : INTEGER;
FUNCTION Utils_power(Number, Exponent : FloatType) : FloatType;
FUNCTION Utils_erand48(VAR xseed : ERandArray) : FloatType;
FUNCTION Utils_kahanSum(a, b : FloatType) : FloatType;
FUNCTION Utils_kahanSum3(a, b, c : FloatType) : FloatType;

IMPLEMENTATION

USES
  math;

CONST
  RAND48_SEED_0 : ErandType = ($330e);
  RAND48_SEED_1 : ErandType = ($abcd);
  RAND48_SEED_2 : ErandType = ($1234);
  RAND48_MULT_0 : ErandType = ($e66d);
  RAND48_MULT_1 : ErandType = ($deec);
  RAND48_MULT_2 : ErandType = ($0005);
  RAND48_ADD    : ErandType = ($000b);

  sErandType8   : integer  = (sizeof(ErandType) * 8);

VAR
  _rand48_seed : ARRAY[0..2] OF ErandType;
  _rand48_mult : ARRAY[0..2] OF ErandType;
  _rand48_add  : ErandType;

FUNCTION Utils_kahanSum3(a, b, c : FloatType) : FloatType;
VAR
  sum : FloatType;
  cc  : FloatType;
  y   : FloatType;
  t   : FloatType;
BEGIN
  sum := a;
  cc  := 0.0;

  y   := b - cc;
  t   := sum + y;
  cc  := (t - sum) - y;
  sum := t;

  y   := c - cc;
  t   := sum + y;
  cc  := (t - sum) - y;
  sum := t;

  Utils_kahanSum3 := sum;
END;

FUNCTION Utils_kahanSum(a, b : FloatType) : FloatType;
VAR
  sum : FloatType;
  c   : FloatType;
  y   : FloatType;
  t   : FloatType;
BEGIN
  sum := a;
  c   := 0.0;
  y   := b - c;
  t   := sum + y;
  c   := (t - sum) - y;
  sum := t;

  Utils_kahanSum := sum;
END;

procedure _dorand48(VAR xseed : ERandArray);
var
  accu : Longint;
  temp : ARRAY[0..1] OF ErandType;
begin
  accu     := longint(_rand48_mult[0]) * LongInt(xseed[0]) + LongInt(_rand48_add);
  temp[0]  := ErandType(accu);
  //accu     := accu SHR (sizeof(ErandType) * 8);
  accu     := accu SHR (sErandType8);
  accu     := accu + (LongInt(_rand48_mult[0]) * LongInt(xseed[1]) + LongInt(_rand48_mult[1]) * LongInt(xseed[0]));
  temp[1]  := ErandType(accu);
  //accu     := accu SHR (sizeof(ErandType) * 8);
  accu     := accu SHR (sErandType8);
  accu     := accu + (_rand48_mult[0] * xseed[2] + _rand48_mult[1] * xseed[1] + _rand48_mult[2] * xseed[0]);
  xseed[0] := temp[0];
  xseed[1] := temp[1];
  xseed[2] := ErandType(accu);
end;

function Utils_erand48(VAR xseed : ERandArray) : FloatType;
begin
  _dorand48(xseed);
  Utils_erand48 := ldexp((xseed[0]), -48) + ldexp((xseed[1]), -32) + ldexp(xseed[2], -16);
end;

FUNCTION Utils_fabs(value : FloatType) : FloatType;
BEGIN
  IF (value < 0) THEN
    Utils_fabs := -value
  ELSE
    Utils_fabs := value;
END;

FUNCTION Utils_clamp(value : FloatType) : FloatType;
BEGIN
  IF value < 0.0 THEN
    Utils_clamp := 0.0
  ELSE
  IF value > 1.0 THEN
    Utils_clamp := 1.0
  ELSE
    Utils_clamp := value;
END;

FUNCTION Utils_power(Number, Exponent : FloatType) : FloatType;
BEGIN
  IF (Number = 0) OR (Exponent = 0) THEN
    Utils_power := 0
  ELSE
    Utils_power := Exp(Exponent * Ln(Number));
END;

FUNCTION Utils_toInt(value : FloatType) : INTEGER;
BEGIN
  Utils_toInt := round(Utils_power(Utils_clamp(value), gamma2_2) * 255.0 + 0.5);
END;

BEGIN
  _rand48_seed[0] := RAND48_SEED_0;
  _rand48_seed[1] := RAND48_SEED_1;
  _rand48_seed[2] := RAND48_SEED_2;

  _rand48_mult[0] := RAND48_MULT_0;
  _rand48_mult[1] := RAND48_MULT_1;
  _rand48_mult[2] := RAND48_MULT_2;

  _rand48_add     := RAND48_ADD;
END.

