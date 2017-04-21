program restapi;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='restapi (JSON) by daragor';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TF_MLC, F_MLC);
  Application.Run;
end.

