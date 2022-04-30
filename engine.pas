UNIT Engine;

INTERFACE
{$IFDEF SSE}
  {$CODEALIGN LOCALMIN=16}
  {$CODEALIGN VARMIN=16}
{$ENDIF}
USES
  Utils, Sphere, Vector, Ray, common, classes;

TYPE
  TEngine = CLASS
  PROTECTED
    spheres       : TList;
    threads       : TList;
    pictureWidth  : INTEGER;
    pictureHeight : INTEGER;
    sampleCount   : INTEGER;
    reportTo      : THandle;
    tileCountX    : INTEGER;
    tileCountY    : INTEGER;
    maxThreads    : INTEGER;
    tileX, tileY  : INTEGER;
  PROTECTED
    FUNCTION intersect(VAR Ray : TRay; VAR Distance : FloatType; VAR Id : INTEGER) : BOOLEAN;
    PROCEDURE radiance(VAR Result : TVector; Ray : TRay; Depth : INTEGER; VAR Xi : ErandArray);
    PROCEDURE threadDone(Sender : TObject);
  PUBLIC
    CONSTRUCTOR Create;
    DESTRUCTOR Destroy; OVERRIDE;

    PROCEDURE Render(ReportTo : THandle; Width, Height, SampleCount, MaxThreads : INTEGER);
    PROCEDURE RenderTile(ReportTo : THandle; width, height, startX, startY, stopX, stopY : INTEGER);
  END;

IMPLEMENTATION

USES sysutils, windows, math;

TYPE
  TRenderThread = CLASS(TThread)
  PRIVATE
    { Private declarations }
  PROTECTED
    _width, _height, _startX, _startY, _stopX, _stopY : INTEGER;
    _reportTo : THandle;
    _engine   : TEngine;
    PROCEDURE Execute; OVERRIDE;
  PUBLIC
    CONSTRUCTOR create(Engine : TEngine; ReportTo : THandle; width, height : INTEGER; startX, startY, stopX, stopY : INTEGER);

  END;

CONSTRUCTOR TRenderThread.Create(Engine : TEngine; ReportTo : THandle; width, height : INTEGER; startX, startY, stopX, stopY : INTEGER);
BEGIN
  INHERITED Create(TRUE);
  _engine   := Engine;
  _reportTo := ReportTo;
  _width    := width;
  _height   := height;
  _stopX    := stopX;
  _stopY    := stopY;
  _startX   := startX;
  _startY   := startY;
END;

PROCEDURE TRenderThread.Execute;
BEGIN
  _engine.renderTile(_reportTo, _width, _height, _startX, _startY, _stopX, _stopY);
END;


FUNCTION TEngine.Intersect(VAR Ray : TRay; VAR Distance : FloatType; VAR Id : INTEGER) : BOOLEAN;
VAR
  infinity : FloatType;
  index    : INTEGER;
  d        : FloatType;
  sphere   : TSphere;
BEGIN
  infinity := 1e20;
  Distance := infinity;

  FOR index := spheres.Count - 1 DOWNTO 0 DO
  BEGIN
    sphere := TSphere(spheres[index]);
    d      := sphere.Intersect(Ray);
    IF (d <> 0) AND (d < Distance) THEN
    BEGIN
      Distance := d;
      Id       := index;
    END;
  END;
  Result := Distance < infinity;
END;

PROCEDURE TEngine.Radiance(VAR Result : TVector; Ray : TRay;
  Depth : INTEGER; VAR Xi : ErandArray);
VAR
  distance : FloatType;
  id       : INTEGER;
  sphere   : TSphere;
  x        : TVector;
  n        : TVector;
  nl       : TVector;
  f        : TVector;
  p        : FloatType;
  lll, m1  : FloatType;

  r1       : FloatType;
  r2       : FloatType;
  r2s      : FloatType;

  w        : TVector;
  u        : TVector;
  v        : TVector;
  d        : TVector;

  newRay   : TRay;
  into     : BOOLEAN;
  tdirr    : BOOLEAN;

  nc       : FloatType;
  nt       : FloatType;
  nnt      : FloatType;
  ddn      : FloatType;
  cos2t    : FloatType;
  dot_n_dir: FloatType;

  a        : FloatType;
  b        : FloatType;
  c        : FloatType;
  R0       : FloatType;
  Re       : FloatType;
  Tr       : FloatType;
  RP       : FloatType;
  TP       : FloatType;
  tdir     : TVector;
  mult     : FloatType;
  foo      : TVector;

  cl       : TVector;
  clTemp   : TVector;
  cf       : TVector;
  r        : TRay;

  ss,cc    : FloatType;

BEGIN
  Id       := 0;
  distance := 0;
  cl       := Vector_Init(0, 0, 0);
  cf       := Vector_Init(1, 1, 1);
  r        := Ray;

  Result   := Vector_Init(0, 0, 0);

  WHILE (TRUE) DO
  BEGIN
    IF (NOT Intersect(r, distance, Id)) THEN
    BEGIN
      Result := cl;
      exit;
    END;

    sphere := spheres[id];        { the hit object }
    Vector_MultiplyFloat(x, r.Direction, distance);
    Vector_Add(x, x, r.Origin);
    Vector_Sub(n, x, sphere.Position);
    Vector_Normalise(n, n);
    nl := n;
	
	dot_n_dir := Vector_Dot(n, r.Direction);
	
    IF (dot_n_dir >= 0) THEN
      Vector_MultiplyFloat(nl, nl, -1);
    f := sphere.Colour;

    IF (f.x > f.y) AND (f.x > f.z) THEN
      p := f.x
    ELSE
    IF (f.y > f.z) THEN
      p := f.y
    ELSE
      p := f.z;

    Vector_MultiplyVec(clTemp, cf, sphere.Emission);
    Vector_Add(cl, cl, clTemp);

    Depth := Depth + 1;
    IF (Depth > 5) OR (p = 0) THEN
      IF (Utils_erand48(Xi) < p) THEN
      BEGIN
        Vector_MultiplyFloat(f, f, 1 / p);
        IF (p = 1) AND (f.x = 1) AND (f.y = 1) AND (f.z = 1) THEN
        BEGIN
          Result := cl;
          exit;
        END;
      END ELSE
      BEGIN
        Result := cl;
        exit;
      END;

    Vector_MultiplyVec(cf, cf, f);

    IF (sphere.SurfaceType = SurfaceType_Diffuse) THEN
    BEGIN
      r1  := M_PI2 * Utils_erand48(Xi);
      r2  := Utils_erand48(Xi);
      r2s := sqrt(r2);
      w   := nl;

      IF (Utils_fabs(w.x) > 0.1) THEN
        begin
             //u := Vector_Init(0, 1, 0);
             {
			 lll:=w.z*w.z+w.x*w.x;
			 lll:=sqrt(lll);
			 }
			 m1 := 1/sqrt(w.z*w.z+w.x*w.x);
			 
			 {
			 u.x := u.x * m1;
			 u.z := u.z * m1;
			 }
			 
			 u := Vector_Init(w.z*m1, 0, -w.x*m1);
	
	v := Vector_Init(w.y*u.z, w.z*u.x-w.x*u.z, -w.y*u.x); //4* vs 6*
        end
      ELSE
      begin
        //u := Vector_Init(1, 0, 0);
	{
			 lll:=w.z*w.z+w.y*w.y;
			 lll:=sqrt(lll);
			 }
			 m1 := 1/sqrt(w.z*w.z+w.y*w.y);
			 {
    u.y := u.y * m1;
    u.z := u.z * m1;
			}
	
        u := Vector_Init(0, -w.z*m1, w.y*m1);
	
	v := Vector_Init(w.y*u.z-w.z*u.y, -w.x*u.z, w.x*u.y); //4* vs 6*

	//4* 1/ 1sqrt
      end;

      //Vector_Cross(u, u, w);  //6*
      //Vector_Normalise(u, u); //6* 1sqrt 1/

      //Vector_Cross(v, w, u);  //6*


      sincos(r1,ss,cc);

      Vector_MultiplyFloat(u, u, cc * r2s); //4* cos
      Vector_MultiplyFloat(v, v, ss * r2s); //4* sin

      {
      Vector_MultiplyFloat(u, u, cos(r1) * r2s); //4* cos
      Vector_MultiplyFloat(v, v, sin(r1) * r2s); //4* sin
      }
      Vector_MultiplyFloat(w, w, sqrt(1 - r2));  //3* sqrt

      Vector_Add3(d, u, v, w);

      //Vector_Normalise(d, d);
      Ray_Init(r, x, d);
      continue; //Skip_Rest := TRUE;
    END ELSE
    IF (sphere.SurfaceType = SurfaceType_Specular) THEN
    BEGIN
      newRay.Origin := x;
      //Vector_MultiplyFloat(newRay.Direction, n, 2);

      Vector_Add(newRay.Direction, n, n);

      Vector_MultiplyFloat(newRay.Direction, newRay.Direction, dot_n_dir);
      Vector_Sub(newRay.Direction, r.Direction, newRay.Direction);
      r := newRay;
      continue; //skipRest := TRUE;
    END;

    //IF (NOT skipRest) THEN
    BEGIN
      newRay.Origin := x;
      //Vector_MultiplyFloat(newRay.Direction, n, 2);

      Vector_Add(newRay.Direction, n, n);

      Vector_MultiplyFloat(newRay.Direction, newRay.Direction, dot_n_dir);
      Vector_Sub(newRay.Direction, r.Direction, newRay.Direction);
      into := Vector_Dot(n, nl) > 0;
      nc   := 1;
      nt   := 1.5;
      IF (into) THEN
      BEGIN
        nnt  := nc / nt;
        //mult := 1.0;
      END ELSE
      BEGIN
        nnt  := nt / nc;
        //mult := -1.0;
      END;
      ddn   := Vector_Dot(r.Direction, nl);
      cos2t := 1 - nnt * nnt * (1 - ddn * ddn);
      IF (cos2t < 0) THEN
      BEGIN
        r := newRay;
        continue; //skipRest := TRUE;
      END;

      //IF (NOT skipRest) THEN
      BEGIN
		tdirr:=false;
        //Vector_Normalise(tdir, tdir);
        a := nt - nc;
        b := nt + nc;
        R0 := a * a / (b * b);
        IF (into) THEN
          c := 1 + ddn
        ELSE
          begin
		  
	  
        Vector_MultiplyFloat(foo, n,  (ddn * nnt + sqrt(cos2t)));
		if not into then
		begin
			foo.x:=-foo.x;
			foo.y:=-foo.y;
			foo.Z:=-foo.z;
		end;
		
        Vector_MultiplyFloat(tdir, r.Direction, nnt);
        Vector_Sub(tdir, tdir, foo);
		  c := 1 - Vector_Dot(tdir, n);
		  tdirr:=true;
		 end;

        Re := R0 + (1 - R0) * c * c * c * c * c;
        Tr := 1 - Re;
        P := 0.25 + 0.5 * Re;

        IF (Utils_erand48(Xi) < p) THEN
        BEGIN
        RP := Re / P;
          Vector_MultiplyFloat(cf, cf, RP);
          r := newRay;
        END ELSE
        BEGIN
        TP := Tr / (1 - P);
		
		
		if not tdirr then  
		begin
        Vector_MultiplyFloat(foo, n,  (ddn * nnt + sqrt(cos2t)));
		if not into then
		begin
			foo.x:=-foo.x;
			foo.y:=-foo.y;
			foo.Z:=-foo.z;
		end;
		
        Vector_MultiplyFloat(tdir, r.Direction, nnt);
        Vector_Sub(tdir, tdir, foo);
		end;
		
          Vector_MultiplyFloat(cf, cf, TP);
          Ray_Init(r, x, tdir);
        END;
      END;
    END;
  END;
END;

CONSTRUCTOR TEngine.Create;
BEGIN
  spheres := TList.Create;
  threads := TList.Create;

  {


Sphere spheres[] = {//Scene: radius, position, emission, color, material
  Sphere(1e5, Vec( 1e5+1,40.8,81.6), Vec(),Vec(.75,.25,.25),DIFF),//Left
  Sphere(1e5, Vec(-1e5+99,40.8,81.6),Vec(),Vec(.25,.25,.75),DIFF),//Rght
  Sphere(1e5, Vec(50,40.8, 1e5),     Vec(),Vec(.75,.75,.75),DIFF),//Back
  Sphere(1e5, Vec(50,40.8,-1e5+170), Vec(),Vec(),           DIFF),//Frnt
  Sphere(1e5, Vec(50, 1e5, 81.6),    Vec(),Vec(.75,.75,.75),DIFF),//Botm
  Sphere(1e5, Vec(50,-1e5+81.6,81.6),Vec(),Vec(.75,.75,.75),DIFF),//Top
  Sphere(16.5,Vec(27,16.5,47),       Vec(),Vec(1,1,1)*.999, SPEC),//Mirr
  Sphere(16.5,Vec(73,16.5,78),       Vec(),Vec(1,1,1)*.999, REFR),//Glas
  Sphere(1.5, Vec(50,81.6-16.5,81.6),Vec(4,4,4)*100,  Vec(), DIFF),//Lite
}

// большой источник света
  
  spheres.Add(TSphere.Create(1e5, Vector_Init(1e5 + 1.0, 40.8, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.25, 0.25), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(-1e5 + 99, 40.8, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.25, 0.25, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 40.8, 1e5), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 40.8, -1e5 + 170), Vector_Init(0, 0, 0), Vector_Init(0, 0, 0), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 1e5, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, -1e5 + 81.6, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(16.5, Vector_Init(27, 16.5, 47), Vector_Init(0, 0, 0), Vector_Init(1, 1, 1), SurfaceType_Specular));
  spheres.Add(TSphere.Create(16.5, Vector_Init(73, 16.5, 78), Vector_Init(0, 0, 0), Vector_Init(0.999, 0.999, 0.999), SurfaceType_Refractive));
  spheres.Add(TSphere.Create(600, Vector_Init(50, 681.6 - 0.27, 81.6), Vector_Init(12, 12, 12), Vector_Init(0, 0, 0), SurfaceType_Diffuse));
  

  {
  // мелкий источник света - тяжелее попасть и долго просчитывает но сходимость херовая всё равно. на explicit должно быть быстрее
  // дописать также importance+direct, ptmnee
  spheres.Add(TSphere.Create(1e5, Vector_Init(1e5 + 1.0, 40.8, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.25, 0.25), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(-1e5 + 99.0, 40.8, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.25, 0.25, 0.25), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 40.8, 1e5), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 40.8, -1e5 + 170.0), Vector_Init(0, 0, 0), Vector_Init(0, 0, 0), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, 1e5, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(1e5, Vector_Init(50, -1e5 + 81.6, 81.6), Vector_Init(0, 0, 0), Vector_Init(0.75, 0.75, 0.75), SurfaceType_Diffuse));
  spheres.Add(TSphere.Create(16.5, Vector_Init(27, 16.5, 47), Vector_Init(0, 0, 0), Vector_Init(0.999, 0.999, 0.999), SurfaceType_Specular));
  spheres.Add(TSphere.Create(16.5, Vector_Init(73, 16.5, 78), Vector_Init(0, 0, 0), Vector_Init(0.999, 0.999, 0.999), SurfaceType_Refractive));
  spheres.Add(TSphere.Create(1.5, Vector_Init(50, 81.6-16.5, 81.6), Vector_Init(400, 400, 400), Vector_Init(0, 0, 0), SurfaceType_Diffuse));
}
END;

DESTRUCTOR TEngine.Destroy;
VAR
  sphere : TSphere;
  thread : TRenderThread;
  index : INTEGER;
BEGIN
  FOR index := 0 TO threads.Count - 1 DO
  BEGIN
    thread := threads[index];
    thread.Suspend;
    thread.Terminate;
  END;
  threads.Destroy;

  FOR index := 0 TO spheres.Count - 1 DO
  BEGIN
    sphere := spheres[index];
    sphere.Destroy;
  END;
  spheres.Destroy;

  INHERITED;
END;

PROCEDURE TEngine.threadDone(Sender : TObject);
VAR
  thread : TRenderThread;
BEGIN
  IF (tileY < tileCountY) THEN
  BEGIN
    thread := TRenderThread(Sender);
    thread := TRenderThread.Create(self, ReportTo, pictureWidth, pictureHeight, tileX * Tile_Width, tileY * Tile_Height, tileX * Tile_Width + Tile_Width, tileY * Tile_Height + Tile_Height);
    thread.OnTerminate := threadDone;
    thread.Resume;
  END;

  tileX := tileX + 1;
  IF (tileX >= tileCountX) THEN
  BEGIN
    tileX := 0;
    tileY := tileY + 1;
  END;
END;

PROCEDURE TEngine.Render(ReportTo : THandle; Width, Height, SampleCount, MaxThreads : INTEGER);
VAR
  thread : TRenderThread;
  threadCount : INTEGER;
BEGIN
  self.pictureWidth  := Width;
  self.pictureHeight := Height;
  self.SampleCount   := SampleCount;
  self.ReportTo      := ReportTo;
  self.MaxThreads    := MaxThreads;

  threadCount        := 0;
  tileX              := 0;
  tileY              := 0;
  tileCountX         := (Width DIV Tile_Width) + 1;
  tileCountY         := (Height DIV Tile_Height) + 1;

  WHILE (threadCount < maxThreads) DO
  BEGIN
    thread := TRenderThread.Create(self, ReportTo, Width, Height, tileX * Tile_Width, tileY * Tile_Height, tileX * Tile_Width + Tile_Width, tileY * Tile_Height + Tile_Height);
    thread.OnTerminate := threadDone;
    thread.Resume;
    tileX := tileX + 1;
    IF (tileX >= tileCountX - 1) THEN
    BEGIN
      tileX := 0;
      tileY := tileY + 1;
    END;
    IF (tileY >= tileCountY - 1) THEN
      break;

    threadCount := threadCount + 1;
  END;
END;

PROCEDURE TEngine.renderTile(ReportTo : THandle; width, height, startX, startY, stopX, stopY : INTEGER);
VAR
  y            : INTEGER;
  x            : WORD;
  sx           : INTEGER;
  sy           : INTEGER;
  i            : INTEGER;
  Xi           : ErandArray;
  s            : INTEGER;
  lines        : ARRAY[0..Tile_Height - 1] OF TVectorLinePtr;
  w            : INTEGER;
  h            : INTEGER;
  samps        : INTEGER;
  temp         : TVector;
  r1           : FloatType;
  r2           : FloatType;
  d            : TVector;
  dx           : FloatType;
  dy           : FloatType;
  cam          : TRay;
  tempRay      : TRay;
  cx           : TVector;
  cy           : TVector;
  camPosition  : TVector;
  camDirection : TVector;
  r            : TVector;

  LNewLine     : TTileLine;
BEGIN

  w     := width;
  h     := height;
  samps := samplecount div 4;

  FOR y := 0 TO Tile_Height - 1 DO
  BEGIN
    New(lines[y]);
    FOR x := 0 TO Tile_Width - 1 DO
      lines[y]^[x] := Vector_Init(0, 0, 0);
  END;

  camPosition  := Vector_Init(50, 52, 295.6);
  camDirection := Vector_Init(0, -0.042612, -1);
  Vector_Normalise(camDirection, camDirection);
  Ray_Init(cam, camPosition, camDirection);
  cx := Vector_Init(w * 0.5135 / h, 0, 0);
  Vector_Cross(cy, cx, cam.Direction);
  Vector_Normalise(cy, cy);
  Vector_MultiplyFloat(cy, cy, 0.5135);

  BEGIN
    IF (stopY > h) THEN
      stopY := h;

    BEGIN
      stopX := (startX + Tile_Width);
      IF (stopX > w) THEN
        stopX := w;

      FOR y := 0 TO Tile_Height - 1 DO
        FOR x := 0 TO Tile_Width - 1 DO
        BEGIN
          lines[y]^[x] := Vector_Init(0, 0, 0);
          LNewLine.line[x] := Vector_Init(0, 0, 0);
        END;

      FOR y := startY TO stopY - 1 DO
      BEGIN
        Xi[0] := 0;
        Xi[1] := 0;
        Xi[2] := y * y * y;
        FOR x := startX TO stopX - 1 DO
        BEGIN
          i := y;
          FOR sy := 0 TO 1 DO
          BEGIN
            r := Vector_Init(0, 0, 0);
            FOR sx := 0 TO 1 DO
            BEGIN
              FOR s := 0 TO samps - 1 DO
              BEGIN
                r1 := 2 * Utils_erand48(Xi);
                IF (r1 < 1) THEN
                  dx := sqrt(r1) - 1
                ELSE
                  dx := 1 - sqrt(2 - r1);

                r2 := 2 * Utils_erand48(Xi);
                IF (r2 < 1) THEN
                  dy := sqrt(r2) - 1
                ELSE
                  dy := 1 - sqrt(2 - r2);

                Vector_MultiplyFloat(temp, cx, ((sx + 0.5 + dx) / 2 + x) / w - 0.5);
                Vector_MultiplyFloat(d, cy, ((sy + 0.5 + dy) / 2 + (h - y - 1)) / h - 0.5);
                Vector_Add(d, d, temp);
                Vector_Add(d, d, cam.Direction);

                Vector_Normalise(d, d);
                Vector_MultiplyFloat(tempRay.Origin, d, 140);
                Vector_Add(tempRay.Origin, tempRay.Origin, cam.Origin);
                tempRay.Direction := d;
                Radiance(temp, tempRay, 0, Xi);
                Vector_MultiplyFloat(temp, temp, (1.0 / samps));
                Vector_Add(r, r, temp);
              END;
              temp.x := Utils_clamp(r.x);
              temp.y := Utils_clamp(r.y);
              temp.z := Utils_clamp(r.z);
              Vector_MultiplyFloat(temp, temp, 0.24);
              Vector_Add(lines[i - startY]^[x - startX], lines[i - startY]^[x - startX], temp);
              r := Vector_Init(0, 0, 0);
              LNewLine.line[x - startX] := lines[i - startY]^[x - startX];
            END;
          END;
        END;
        LNewLine.x := startX;
        LNewLine.y := y;
        LNewLine.width := Tile_Width;
        SendMessage(ReportTo, MSG_NEWLINE, 0, LONGINT(@LNewLine));
      END;
    END;
  END;

  FOR y := 0 TO Tile_Height - 1 DO
    Dispose(lines[y]);
END;

END.
