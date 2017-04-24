unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, fphttpclient, fpjson, jsonparser;

type

  { TF_MLC }

  TF_MLC = class(TForm)
    b_get: TButton;
    b_parse: TButton;
    b_new: TButton;
    cjsonf: TMemo;
    jpma: TLabeledEdit;
    jpme: TLabeledEdit;
    jres: TMemo;
    jnom: TLabeledEdit;
    jpp: TLabeledEdit;
    jquery: TLabeledEdit;
    Label1: TLabel;
    cjson: TMemo;
    Label2: TLabel;
    jtotal: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    procedure b_getClick(Sender: TObject);
    procedure b_parseClick(Sender: TObject);
    procedure b_newClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { private declarations }
    procedure ML_API();
  public
    { public declarations }
  end;

var
  F_MLC: TF_MLC;

implementation

{$R *.lfm}

{ TF_MLC }

procedure TF_MLC.FormActivate(Sender: TObject);
begin
  jnom.SetFocus;
end;

procedure TF_MLC.ML_API();
var
  qapi,nprod: string;
begin
  qapi:= trim(jquery.Text);
  nprod:= stringreplace(trim(jnom.Text),' ','%20',[rfReplaceAll]);
  if (qapi <> '') and (nprod <> '') then {Control vacios}
  begin
    jnom.Text:= nprod;
    with TFPHTTPClient.Create(nil) do
    try
      cjson.Text:= Get(qapi+nprod+'#json');
    finally
      Free;
      b_get.Enabled:= false;
      b_parse.Enabled:= true;
    end;
  end;
end;

procedure TF_MLC.b_getClick(Sender: TObject);
begin
  if jnom.Text <> '' then
    ML_API()
  else
    showmessage('Indique las palabras clave para usar el API query');
end;

procedure TF_MLC.b_parseClick(Sender: TObject);
var
  JC: TJSONData;
  max, min, pprom: real;
  i: byte;
  precios: array[1..5] of real;
begin
  // Iniciales
  max:= 0; min:= 100000000 {forzado}; pprom:= 0;
  if cjson.Text <> '' then
  begin
    try
      JC:= GetJSON(cjson.Text);
      jtotal.Caption:= JC.FindPath('paging.total').AsString;
      cjsonf.Text:= JC.FormatJSON();
      // TITULOS
      for i:= 1 to 5 do
      begin
        jres.Lines.Add(inttostr(i)+'. '+JC.FindPath('results['+inttostr(i)+'].title').AsString+
        ' $ '+JC.FindPath('results['+inttostr(i)+'].price').AsString);
        pprom:= pprom + JC.FindPath('results['+inttostr(i)+'].price').AsFloat;
        precios[i]:= JC.FindPath('results['+inttostr(i)+'].price').AsFloat;
      end;
      // PRECIOS
      for i:= 1 to high(precios) do
      begin
        if precios[i] > max then max:= precios[i];
        if precios[i] < min then min:= precios[i];
      end;
      jpma.Text:= formatfloat('0.00',max);
      jpme.Text:= formatfloat('0.00',min);
      pprom:= (pprom/5);
      jpp.Text:= formatfloat('0.00',pprom);
      b_new.SetFocus;
    except
        on E:Exception do begin
          ShowMessage('Ha ocurrido un Error!'+#13+E.Message);
        end;
    end;
  end;
end;

procedure TF_MLC.b_newClick(Sender: TObject);
begin
  cjson.Clear;
  cjsonf.Clear;
  jres.Clear;
  jtotal.Caption:= '0';
  jpma.Text:= '0';
  jpme.Text:= '0';
  jpp.Text:= '0';
  b_get.Enabled:= true;
  b_parse.Enabled:= false;
  jnom.SetFocus;
end;

end.

