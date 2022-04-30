UNIT main;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

INTERFACE

USES
{$IFNDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, Windows,
{$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Engine, common;

TYPE

  { TfrmMain }

  { Tmainform }

  Tmainform = CLASS(TForm)
    cmdSave : TButton;
    cmdRender : TButton;
    Label1 : TLabel;
    Label2 : TLabel;
    Label3 : TLabel;
    Label4 : TLabel;
    sd : TSaveDialog;
    strWidth : TEdit;
    strHeight : TEdit;
    strThreadCount : TEdit;
    strSampleCount : TEdit;
    imgRender : TImage;
    lblTime : TLabel;
    tmr_update: TTimer;
    PROCEDURE cmdRenderClick(Sender : TObject);
    PROCEDURE cmdSaveClick(Sender : TObject);
    PROCEDURE FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
    PROCEDURE FormCreate(Sender : TObject);
    procedure tmr_updateTimer(Sender: TObject);
  PRIVATE
    { Private declarations }
    engine : TEngine;
  PUBLIC
    { Public declarations }
    startTime : LONGINT;

    {$IFDEF FPC}
  PROCEDURE MSGNewLine(VAR Message : TMessage); MESSAGE MSG_NEWLINE;
  {$ELSE}{$ENDIF}
  END;

VAR
  mainform : Tmainform;

IMPLEMENTATION

{$R *.dfm}

USES
  utils;

FUNCTION MSecToTime(MSec:INTEGER):STRING;
BEGIN
  Result:=Format('%d:%.2d.%.3d',[MSec div 60000,(MSec div 1000) mod 60,MSec mod 1000]);
END;

    {$IFDEF FPC}
PROCEDURE Tmainform.MSGNewLine(VAR Message : TMessage);
VAR
  LNewLine : PTileLine;
  i : INTEGER;
BEGIN
  LNewLine := Pointer(Message.LParam);

  //imgRender.picture.bitmap.BeginUpdate(true);

  FOR i := 0 TO LNewLine^.width - 1 DO
    imgRender.Canvas.Pixels[LNewLine^.x + i, LNewLine^.y] := (Utils_toInt(LNewLine^.line[i].x)) + (Utils_toInt(LNewLine^.line[i].y) SHL 8) + (Utils_toInt(LNewLine^.line[i].z) SHL 16);

  //imgRender.picture.bitmap.EndUpdate();

  lblTime.Caption := 'Time Taken: ' + MSecToTime((GetTickCount - startTime));

  Message.Result := 0;
  INHERITED;
END;
  {$ELSE}{$ENDIF}

PROCEDURE Tmainform.cmdRenderClick(Sender : TObject);
BEGIN
  startTime := GetTickCount;
  imgRender.Width := strtoint(strWidth.Text);
  imgRender.Height := strtoint(strHeight.Text);
  imgRender.Canvas.Brush.Color := clBlack;
  imgRender.Canvas.FillRect(0,0, imgRender.Width, imgRender.Height);

  ClientWidth := imgRender.Left + 5 + imgRender.Width;
  ClientHeight := imgRender.Top + 5 + imgRender.Height;
  engine.Free;
  engine := TEngine.Create;
  engine.Render(self.Handle, imgRender.Width, imgRender.Height, strtoint(strSampleCount.Text), strtoint(strThreadCount.Text));
END;

PROCEDURE Tmainform.cmdSaveClick(Sender : TObject);
BEGIN
  IF (sd.Execute) THEN
    imgRender.Picture.SaveToFile(sd.FileName);
END;

PROCEDURE Tmainform.FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
BEGIN
  engine.Free;
END;

PROCEDURE Tmainform.FormCreate(Sender : TObject);
BEGIN
  DoubleBuffered := TRUE;
  Left           := 10;
  Top            := 10;

  //settings_frm.UpdRateComboChange(sender);
END;

procedure Tmainform.tmr_updateTimer(Sender: TObject);
Var
 I: Integer;
 P: TPoint;
 Q: Int64;
 c,c_mx,c_mn: string;
 s,sps,m,k,k_mx,m_mx,k_mn,m_mn,s_mx,s_mn: double;
begin

end;

END.
