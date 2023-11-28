unit menu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  MaskEdit, IdHTTP, IdSSLOpenSSL, fpjson, jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    Buscar: TButton;
    buscarCEPGroup: TGroupBox;
    quitBtn: TButton;
    passwordInput: TEdit;
    loginBtn: TButton;
    usernameInput: TEdit;
    fetchBtn: TButton;
    CEPInput: TEdit;
    CEPInputLabel: TLabel;
    usernameLabel: TLabel;
    passwordLabel: TLabel;
    loginGroup: TGroupBox;
    output: TMemo;
    procedure fetchBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loginBtnClick(Sender: TObject);
    procedure quitBtnClick(Sender: TObject);


  private

  public

  end;

var
  Form1: TForm1;
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStream: TStringStream;
  ResponseContent: string;
  url:string;
  json:TJSONData;
  passwordIsValid: Boolean = true;



implementation
procedure fetchCEPData(CEP:string); forward;
procedure isAlphaNumeric(password:string); forward;

{$R *.lfm}

{ TForm1 }

// Eventos

procedure TForm1.fetchBtnClick(Sender: TObject);
var CEP : string;
begin
  CEP := Trim(CEPInput.Text);
   //limpar TMemo
   output.Lines.Clear;

   // validar se CEP foi inserido
   if (CEP = '') then
       ShowMessage('Por favor, insira o CEP que deseja buscar.')
   else
       //validar se CEP foi inserido corretamente
          if not(Length(CEP) = 8) then
               ShowMessage('O CEP deve ter 8 caracteres entre 0 e 9.')
   else
       begin
       // buscar dados
        fetchCEPData(CEP);

        if (json.FindPath('erro') = nil) then
           begin
             //exibir dados
             output.Lines.Add('Resultado: ');
             output.Lines.Add('');
             output.Lines.Add('CEP: ' + json.FindPath('cep').AsString);
             output.Lines.Add('Localidade: ' + json.FindPath('localidade').AsString);
             output.Lines.Add('Bairro: ' + json.FindPath('bairro').AsString);
             output.Lines.Add('Logradouro: ' + json.FindPath('logradouro').AsString);
             output.Lines.Add('Complemento: ' + json.FindPath('complemento').AsString);
             output.Lines.Add('UF: ' + json.FindPath('uf').AsString);
             output.Lines.Add('DDD: ' + json.FindPath('ddd').AsString);
             output.Lines.Add('IBGE: ' + json.FindPath('ibge').AsString);
             output.Lines.Add('SIAFI: ' + json.FindPath('siafi').AsString);
             output.Lines.Add('GIA: ' + json.FindPath('gia').AsString);
           end
        else
            output.Lines.Add('Ops... Parece que algo deu errado... Por favor, tente novamente.');
       end;

   // limpar TEdit
   CEPInput.Text := '';

end;

procedure TForm1.loginBtnClick(Sender: TObject);
var username:string;
 password:string;
begin
  username := Trim(usernameInput.Text);
  password:=Trim(passwordInput.Text);

   //validar se dados foram inseridos
  if (username = '') or (password = '') then

     ShowMessage('Por favor, digite o nome de usuário e a senha.')
  else
  //validar senha tem no mínimo 6 caracteres
      if Length(password) < 6 then
         ShowMessage('A senha deve conter no mínimo 6 caracteres.')
  else
    begin
      //validar senha
       isAlphanumeric(password);
       if not(passwordIsValid) then

          ShowMessage('A senha deve conter letras e números apenas.')
       else
       begin

          ShowMessage('Login realizado com sucesso. Olá, ' + username + '.')
       end;
     end;

   // limpar TEdit
  passwordInput.Text := '';

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // limpar TMemo
  output.Lines.Clear;
end;

procedure TForm1.quitBtnClick(Sender: TObject);
begin
  Close;
end;

//Funções
procedure fetchCEPData(CEP:string);
begin
    // Instanciando
    HTTP := TIdHTTP.Create(nil);
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    ResponseStream := TStringStream.Create('');

    try
      // Configuração do IOHandler SSL
      HTTP.IOHandler := SSLHandler;
      SSLHandler.SSLOptions.Method := sslvTLSv1_2; // Use a versão apropriada do SSL/TLS
      SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2]; // Use a versão apropriada do SSL/TLS

      // montar url com CEP inserido pelo usuário
      url := 'http://viacep.com.br/ws/' + CEP + '/json/';

      // Realizando Requisição
      HTTP.Get(url, ResponseStream);
      ResponseContent := UTF8Encode(ResponseStream.DataString);

      //armazenar resultado como json
      json:= GetJSON(ResponseContent);

    finally
      HTTP.Free;
      SSLHandler.Free;

    end;

end;

procedure isAlphaNumeric(password:string);
var
 i:integer;
 numberCount:integer = 0;
 letterCount:integer = 0;

begin
//resetar variável global para que a validação possa ocorrer novamente
  passwordIsValid := true;

  //iterando pela senha e avaliando se a senha contém algum caracter especial
  for i:= 1 to length(password) do
  begin
    if not (password[i] in ['a'..'z','A'..'Z','0'..'9']) then
       begin
        //se a senha contiver algum caracter especial ela será invalida
        passwordIsValid := false;
        Break;
       end
    else
        begin
         //se o caracter não for especial contá-lo como letra ou número para averiguar
         //se existem tanto letras quanto números na senha
         if (password[i] in ['a'..'z','A'..'Z']) then
            begin
             letterCount := letterCount + 1
            end
         else
             begin
             if(password[i] in ['0'..'9']) then
                 numberCount := numberCount + 1;
             end
         end;
  end;

  // se senha ainda for válida após o loop
  if (passwordIsValid) then
     begin
      //checar se contém tanto letras quanto números
      if (letterCount = 0) or (numberCount = 0) then
         begin
           passwordIsValid := false;
         end;
     end;

end;

end.

