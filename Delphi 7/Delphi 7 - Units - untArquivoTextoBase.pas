{
  Exemplo de uso desta classe:

  procedure TForm1.EscreveLog(Conteudo: String);
  var
    Obj: TLog;

  begin
    Obj := TLog.Create;
    try
      Obj.EscreveNoArquivo(Conteudo);
    finally
      FreeAndNil(Obj);
    end;
  end;
}

//********************************************************
//********************************************************
//********************************************************


unit untArquivoTextoBase;

interface

type

  TLog = class
  private
    FFH: Integer;
    FConteudo: String;
    FNomeDoLog: String;
    FLinhas: Integer;
    FTamanho: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property FH: Integer read FFH;
    property NomeDoLog: String read FNomeDoLog write FNomeDoLog;
    property Conteudo: String read FConteudo;
    property Linhas: Integer read FLinhas;

    procedure PosicionaNoInicio;
    procedure PosicionaNoFim;
    procedure Abre;
    procedure Cria;
    procedure Le;
    procedure Fecha;
    function StatusOK: Boolean;
    procedure Escreve(Linha: String);
    procedure EscreveNoArquivo(Conteudo: String);
    procedure TamanhoDoArquivoLog;
  end;


implementation

uses SysUtils;

const
  cstCR = chr(13);
  cstLF = chr(10);
  cstCRLF = cstCR + cstLF;

{ TLog }

procedure TLog.Abre;
begin
  FFH := FileOpen(FNomeDoLog, fmOpenReadWrite);
  FileSeek(FFH, 0, 2);
end;

constructor TLog.Create;
begin
  FFH := -1;
  FConteudo := '';
  FNomeDoLog := '_log.txt';
end;

procedure TLog.Cria;
begin
  FFH := FileCreate(FNomeDoLog, fmOpenReadWrite);
end;

destructor TLog.Destroy;
begin
  inherited Destroy;
end;

procedure TLog.Escreve(Linha: String);
begin
  if StatusOK then
    FileWrite(FFH, Linha[1], Length(Linha));
end;

procedure TLog.EscreveNoArquivo(Conteudo: String);

  function ArquivoExiste: Boolean;
  begin
    Result := FileExists(FNomeDoLog);
  end;

begin
  if ArquivoExiste then
    Abre
  else
    Cria;
  Escreve(Conteudo);
  Fecha;
end;

procedure TLog.Fecha;
begin
  if StatusOK then
  begin
    FileClose(FFH);
    FFH := -1;
  end;
end;

procedure TLog.Le;
var
  Buffer: Pchar;
  I, BytesRead: Integer;
begin
  FLinhas := 0;
  FConteudo := '';
  if FileExists(FNomeDoLog) = False then
  begin
    {...}
  end
  else
  begin
    Abre;
    if StatusOK then
    begin
      PosicionaNoFim;
      PosicionaNoInicio;
      Buffer := PChar(AllocMem(FTamanho + 1));
      try
        BytesRead := FileRead(FFH, Buffer^, FTamanho);
        for I := 0 to BytesRead - 1 do
        begin
          FConteudo := FConteudo + Buffer[I];
          if Buffer[I] = cstCRLF then
            FLinhas := FLinhas + 1;
        end;
      finally
        FreeMem(Buffer);
      end;
    end;
  end;
end;

procedure TLog.PosicionaNoFim;
begin
  FTamanho := FileSeek(FFH, 0, 2);
end;

procedure TLog.PosicionaNoInicio;
begin
  FileSeek(FFH, 0, 0);
end;

function TLog.StatusOK: Boolean;
begin
  Result := (FFH <> -1);
end;

procedure TLog.TamanhoDoArquivoLog;
var
  SR: TSearchRec;
  I: integer;
begin
  try
    I := FindFirst(FNomeDoLog, faArchive, SR);
    if SR.Size <= 3230480 then
      { n�o faz nada, o arquivo � menor que 3 mb }
    else
      DeleteFile(FNomeDoLog);
  finally
    FindClose(SR);
  end;
end;

end.
