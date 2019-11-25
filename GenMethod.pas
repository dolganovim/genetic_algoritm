unit GenMethod;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math;

type
  TArrOfDouble = array of double;
  TFunc = function(Gens: TArrOfDouble; target, eps: double; var fitness: double; var success: boolean): double;
  TBot = class
    target: double;  //���� ����� ���� �������
    fitness: double;       // ����������������� ��� ������������ � ���������
    Gens: TArrOfDouble;
    Success: boolean;    // ������ �������
    eps: double;        // ��������
    GetFitness: TFunc;                // ���������� �����������������
    constructor Create(_Gens: TArrOfDouble; Func: TFunc); overload;
    constructor Create(NGens: integer; maxV, minV: integer; _target, _eps: double; Func: TFunc); overload;
    function _MyGetFit: double;
    procedure Mutation;                         // ����������
    function Selection(_Parent: TBot): TBot;    //�����������
    procedure AssignBot(_Bot: TBot);           //�������������
    procedure Dead;   // ���������
  end;
  TArrBots = array of TBot;
  TPopulation = class
     Bots: TArrBots;
     MaxAge: integer;
     NGood: integer;  // �� ������ �������� ������� ��������������
     Pobeditel: TBot;
     constructor Create(CounBots, _MaxAge, NGens, maxV, minV, _NGood: integer; _target, _eps: double; Func: TFunc); overload;
     function CalcAge: boolean;     // ���������� ���������
     procedure SortFitness;  // ����������� �� �������� � ��������
     procedure DeadPopul;  // ���������� ���������
     procedure MutantPopul;  // ������� ���������
     procedure ReanimPopul;  // �������������� ���������
     function Execute: TBot;      // ������ �����
  end;
implementation

{ TBot }

constructor TBot.Create(_Gens: TArrOfDouble; Func: TFunc);
var
  i: integer;
begin
  //inherited;
  SetLength(Gens, Length(_Gens));
  for i:=0 to Length(_Gens)-1 do
    Gens[i]:=_Gens[i];
  GetFitness:=Func;
end;

constructor TBot.Create(NGens: integer; maxV, minV: integer; _target, _eps: double; Func: TFunc);
var
  i: integer;
  x: double;
begin
  //inherited;
  randomize;
  eps:=_eps;
  target:=_target;
  Success:=false;

  SetLength(Gens, NGens);
  for i:=0 to NGens-1 do
  begin
    x:=random;
    Gens[i]:=maxV*x+(1-x)*minV;
  end;
  GetFitness:=Func;
end;


procedure TBot.Mutation;
var
  i: integer;
  r, p: integer;

begin
  // ��������� ��������� ����������
  randomize;
  r:=random(10);
  p:=random(100);
  for i:=0 to Length(Gens)-1 do
  begin
    Gens[i]:=Gens[i]*(1-power(-1, r)*p/1000);
  end;
end;

function TBot.Selection(_Parent: TBot): TBot;
var
  r, i: integer;
begin
  result:=TBot.Create(Gens, _Parent.GetFitness);
  r:=random(Length(Gens));
  result.target:=self.target;
  result.eps:=self.eps;
  result.Success:=false;
  if r=0 then r:=1;
  if r=Length(Gens) then r:=Length(Gens)-1;

  for i:=0 to r do
  begin
    result.Gens[i]:=Self.Gens[i];
  end;
  for i:=r+1 to Length(Gens)-1 do
  begin
    result.Gens[i]:=_Parent.Gens[i];
  end;

  //����� �������� � ������ �����������
end;

function TBot._MyGetFit: double;
begin
  result:=GetFitness(Gens, target, eps, fitness, success);
end;

procedure TBot.AssignBot(_Bot: TBot);
var
  i: integer;
begin
  self.target:=_Bot.target;
  self.fitness:=_Bot.fitness;
  self.Success:=_Bot.Success;
  self.eps:=_Bot.eps;
  self.GetFitness:=_Bot.GetFitness;

  SetLength(self.Gens, Length(_Bot.Gens));
  for i:= 0 to Length(_Bot.Gens)-1 do
    self.Gens[i]:=_Bot.Gens[i];


end;

procedure TBot.Dead;
var
  i: integer;
begin
  for i:=0 to Length(Gens)-1 do
    Gens[i]:=-1;
  fitness:=-1;
  Success:=false;
  eps:=0;
end;


{ TPopulation }

function TPopulation.CalcAge: boolean;
var
  i: integer;
  allfitness: double;
  botfitness: TArrOfDouble;
begin
  result:=false;
  allfitness:=0;
  SetLength(botfitness, length(Bots));
  for i:=0 to length(Bots)-1 do
  begin
    botfitness[i]:= Bots[i]._MyGetFit;
  end;
  for i:=0 to length(Bots)-1 do
  begin
    if not Bots[i].Success then // ���� ��� �� ����� � �������
      allfitness:=allfitness+1/botfitness[i]
    else
    begin
      result:=true;    // ���� ����� � �������
      Pobeditel.AssignBot(Bots[i]);
      exit;
    end;
  end;
  for i:=0 to length(Bots)-1 do
  begin
    Bots[i].fitness:=1/botfitness[i]/allfitness;
  end;
  //������������
  SortFitness;
  //���������� ���������
  DeadPopul;
  //�������
  MutantPopul;
  //�������������� ���������
  ReanimPopul;

end;

constructor TPopulation.Create(CounBots, _MaxAge, NGens, maxV, minV, _NGood: integer; _target, _eps: double; Func: TFunc);
var
  i: integer;
begin
  SetLength(Bots, CounBots);
  NGood:=_NGood;
  MaxAge:=_MaxAge;
  for i:=0 to CounBots-1 do
  begin
    Bots[i]:=TBot.Create(NGens, maxV, minV, _target, _eps, Func);
  end;

end;

procedure TPopulation.DeadPopul;
var
  i: integer;
begin
  for i:=NGood to Length(Bots)-1 do
  begin
    Bots[i].Dead;
  end;
end;

function TPopulation.Execute: TBot;
var
  i: integer;
begin
  Pobeditel:=TBot.Create;
  result:=TBot.Create;
  for i:=1 to MaxAge do
    if CalcAge then     //���� ����� � �������
    begin
      result.AssignBot(Pobeditel);
      exit;
    end;
  Pobeditel.AssignBot(Bots[0]);
  result.AssignBot(Pobeditel);
end;

procedure TPopulation.MutantPopul;
var
  i: integer;
begin
  for i := 0 to NGood-1 do
    Bots[i+NGood].AssignBot(Bots[i]);
  for i := NGood to 2*NGood-1 do
    Bots[i].Mutation;

end;

procedure TPopulation.ReanimPopul;
var
  i, x, y: integer;
begin
  randomize;
  for i:= 2*NGood to Length(Bots)-1 do
  begin
    x:=random(NGood-1);
    y:=random(NGood-1);
    Bots[i].AssignBot(Bots[x].Selection(Bots[y]));

  end;
end;

procedure TPopulation.SortFitness;
var
  i, j, m: integer;
  _Bot: TBot;
begin
  // ����� ��������
  _Bot:= TBot.Create;
  m:=Length(Bots);
  for i := 0 to m-1 do
    for j := 0 to m-i-2 do
      if Bots[j].fitness < Bots[j+1].fitness then
      begin
        _Bot.AssignBot(Bots[j]);
        Bots[j].AssignBot(Bots[j+1]);
        Bots[j+1].AssignBot(_Bot);
      end;
end;

end.
