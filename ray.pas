UNIT Ray;

INTERFACE

USES
  Vector;

{$IFDEF SSE}
  {$CODEALIGN RECORDMIN=16}
{$ENDIF}
TYPE
  TRay = RECORD
    Origin    : TVector;
    Direction : TVector;
  END;

PROCEDURE Ray_Init(VAR Result : TRay; Origin, Direction : TVector);

IMPLEMENTATION

PROCEDURE Ray_Init(VAR Result : TRay; Origin, Direction : TVector);
BEGIN
  Result.Origin    := Origin;
  Result.Direction := Direction;
END;

END.
