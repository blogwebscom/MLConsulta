unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, fphttpclient, fpjson, jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  cli: TFPHTTPClient;

implementation

{$R *.lfm}

{ TForm1 }

procedure ProcessContent;
var
  qapi,nprod: string;
begin
  with TFPHTTPClient.Create(nil) do
  try
    qapi:= trim(Form1.jquery.Text);
    nprod:= stringreplace(trim(Form1.jnom.Text),' ','%20',[rfReplaceAll]);
    Form1.jnom.Text:= nprod;
    Form1.cjson.Text:= Get(qapi+nprod+'#json');
  finally
    Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if jnom.Text <> '' then
    BeginThread(TThreadFunc(@ProcessContent))
  else
    showmessage('Indique las palabras clave para usar el API query');
end;

procedure TForm1.Button2Click(Sender: TObject);
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
      Button3.SetFocus;
    except
        on E:Exception do begin
          ShowMessage('Error: '+E.Message);
        end;
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  cjson.Clear;
  cjsonf.Clear;
  jres.Clear;
  jtotal.Caption:= '0';
  jpma.Text:= '0';
  jpme.Text:= '0';
  jpp.Text:= '0';
  jnom.SetFocus;
end;

end.

