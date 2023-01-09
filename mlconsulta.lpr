program mlconsulta;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mlcon
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='MLConsulta by daragor - build 090123';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TF_MLC, F_MLC);
  Application.Run;
end.

