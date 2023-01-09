unit mlcon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, JLabeledIntegerEdit, JLabeledFloatEdit, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, fphttpclient,
  fpjson, jsonparser, opensslsockets;

type

  { TF_MLC }

  TF_MLC = class(TForm)
    b_get: TBitBtn;
    can: TJLabeledIntegerEdit;
    pma: TJLabeledFloatEdit;
    jres: TMemo;
    Label1: TLabel;
    pclave: TLabeledEdit;
    jquery: TLabeledEdit;
    cjson: TMemo;
    Label2: TLabel;
    jtotal: TLabel;
    pme: TJLabeledFloatEdit;
    ppro: TJLabeledFloatEdit;
    Shape1: TShape;
    Shape2: TShape;
    procedure b_getClick(Sender: TObject);
    procedure canClick(Sender: TObject);
    procedure canEditingDone(Sender: TObject);
  private
    { private declarations }
    procedure ML_API();
    procedure parse_json();
    procedure limpia();
  public
    { public declarations }
  end;

var
  F_MLC: TF_MLC;

implementation

{$R *.lfm}

{ TF_MLC }

// Se debe configurar los separator en las unidades main

procedure TF_MLC.b_getClick(Sender: TObject);
begin
  if pclave.Text <> '' then
  begin
    ML_API();
    parse_json();
  end else begin
    showmessage('Indique las palabras clave de búsqueda!');
    limpia();
  end;
end;

procedure TF_MLC.ML_API();
var
  qapi,nprod: string;
begin
  qapi:= trim(jquery.Text);
  nprod:= stringreplace(trim(pclave.Text),' ','%20',[rfReplaceAll]);
  if (qapi <> '') and (nprod <> '') then {Control vacios}
  begin
    pclave.Text:= nprod;
    with TFPHTTPClient.Create(nil) do
    try
      cjson.Text:= Get(qapi+nprod);  {se puede agregar +'#json' a la cadena del query}
    finally
      Free;
    end;
  end;
end;

procedure TF_MLC.parse_json();
var
  JC: TJSONData;
  max, min, pprom: real;
  nro, i, pcan: byte;
  precios: array of real;
begin
  // Iniciales
  max:= 0;
  min:= 100000000 {forzado};
  pprom:= 0;
  pcan:= can.Value-1;
  nro:= 1;
  SetLength(precios,pcan);
  // Comienzo del Ciclo/ json inicia en 0 -----------------
  if cjson.Text <> '' then
  begin
    try
      JC:= GetJSON(cjson.Text);
      jtotal.Caption:= JC.FindPath('paging.total').AsString;
      //Memo1.Text:= JC.FormatJSON();
      // TITULOS
      for i:= 0 to pcan do
      begin
        jres.Lines.Add(inttostr(nro)+'. '+JC.FindPath('results['+inttostr(i)+'].title').AsString+
        ' $ '+JC.FindPath('results['+inttostr(i)+'].price').AsString);
        pprom:= pprom + JC.FindPath('results['+inttostr(i)+'].price').AsFloat;
        precios[i]:= JC.FindPath('results['+inttostr(i)+'].price').AsFloat;
        nro:= nro+1;
      end;
      // PRECIOS
      for i:= 1 to high(precios) do
      begin
        if precios[i] > max then max:= precios[i];
        if precios[i] < min then min:= precios[i];
      end;
      pma.Value:= max;
      pme.Value:= min;
      ppro.Value:= (pprom/pcan);
    except
        on E:Exception do begin
          ShowMessage('Ha ocurrido un Error!'+#13+E.Message);
        end;
    end;
  end;
end;

procedure TF_MLC.limpia();
begin
  cjson.Clear;
  jres.Clear;
  jtotal.Caption:= '0';
  pma.Value:= 0;
  pme.Value:= 0;
  ppro.Value:= 0;
  b_get.Enabled:= true;
  pclave.SetFocus;
end;

procedure TF_MLC.canClick(Sender: TObject);
begin
  can.SelectAll;
end;

procedure TF_MLC.canEditingDone(Sender: TObject);
begin
  if can.CurrentValue > 255 then
    can.Value:= 255;                    {valor maximo!}
end;

end.

