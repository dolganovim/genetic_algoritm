unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GenMethod, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Population: TPopulation;
  _Bot: TBot;
  i: integer;
  s: string;
begin
  Population:= TPopulation.Create(1000, 100, 4, 30, 0, 199, 30, 0.0001);
  _Bot:=Population.Execute;
  s:='';
  for i:=0 to Length(_Bot.Gens)-1 do
    s:=s+FloatTostr(_Bot.Gens[i])+'; ';
  s:=s+FloatTostr(_Bot.GetFitness);
  ShowMessage(s);
end;

end.
 