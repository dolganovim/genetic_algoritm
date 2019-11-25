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

function GetFitness(Gens: TArrOfDouble; target, eps: double; var  fitness: double; var success: boolean): double;
begin
  Success:=false;
  result:=abs(Gens[0]+2*Gens[1]+3*Gens[2]+4*Gens[3] - target);  // ��� ������
  fitness:=result;
  if result<=eps then Success:=true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Population: TPopulation;
  _Bot: TBot;
  i: integer;
  s: string;
begin
  Population:= TPopulation.Create(1000, 100, 4, 30, 0, 199, 30, 0.0001, GetFitness);
  _Bot:=Population.Execute;
  s:='';
  for i:=0 to Length(_Bot.Gens)-1 do
    s:=s+FloatTostr(_Bot.Gens[i])+'; ';
  s:=s+FloatTostr(_Bot._MyGetFit);
  ShowMessage(s);
end;

end.
 