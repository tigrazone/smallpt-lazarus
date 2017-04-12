UNIT common;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

INTERFACE

USES vector, windows;

CONST
  Tile_Width = 64;
  Tile_Height = 64;

CONST
  wm_app = 32678;
  MSG_NEWLINE = WM_APP + 0;

TYPE
  TVectorLine = ARRAY[0..Tile_Width - 1] OF TVector;
  TVectorLinePtr = ^TVectorLine;

TYPE
  PTileLine = ^TTileLine;
  TTileLine = RECORD
    x, y : INTEGER;
    width : INTEGER;
    line : TVectorLine;
  END;

var sCtr,sDif,fc:double;

  Bitmap: TBitmap;
  Resolution: Longword = 512;
  Reso2: Longword = 512;
  RecursionDepth: Longword = 12;
  ThreadCount: Longword;
  Time, Freq,time_before_pause: Int64;
  app_name:string;
  scene_f:string;
  samples_old,min_speed,max_speed:double;

  
  Running: Boolean = False;
  started: Boolean = False;
  arrr:array of byte;
  
  cosineAccumulation_mul:single;

IMPLEMENTATION

END.
