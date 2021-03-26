unit UnitCOM;

interface

procedure OpenCOM;
procedure CloseCOM;
function WriteCOM(p:pchar; len:integer): integer;
function ReadCOM(p:pchar; len:integer): integer;

implementation

uses Windows, SysUtils;

const
  ConfigStr1 = 'COM1:';
//  ConfigStr2 = 'baud=115200 parity=n data=8 stop=1';

var
  COMFile: THandle = INVALID_HANDLE_VALUE;

procedure OpenCOM;
const
   RxBufferSize = 4096;
   TxBufferSize = 4096;
var
  DCB: TDCB;
  CommTimeouts : TCommTimeouts;
begin
  COMFile := CreateFile(pchar(ConfigStr1), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if ComFile=INVALID_HANDLE_VALUE then raise Exception.Create('Cannot open '+ConfigStr1+' port');

  if not(SetupComm(ComFile, RxBufferSize, TxBufferSize)) then raise Exception.Create('Unable to set the COM buffer sizes');
  if not(GetCommState(ComFile, DCB)) then raise Exception.Create('Unable to GetCommState');
//  if not(BuildCommDCB(pchar(ConfigStr2), DCB)) then raise Exception.Create('Unable to BuildCommDCB');
  DCB.BaudRate := 115200;
  DCB.Flags := $0001 or (DTR_CONTROL_DISABLE shl 4) or (RTS_CONTROL_ENABLE shl 12);  // DTR (pin 4)=-9V and RTS (pin 7)=+9V
//  DCB.Flags := $0001 or (DTR_CONTROL_ENABLE shl 4) or (RTS_CONTROL_ENABLE shl 12);
  DCB.ByteSize := 8;
  DCB.Parity := NOPARITY;
  DCB.StopBits := 0;
  if not(SetCommState(ComFile, DCB)) then raise Exception.Create('Unable to SetCommState');

  with CommTimeouts do begin
    ReadIntervalTimeout := MAXDWORD;
    ReadTotalTimeoutMultiplier := 0;
    ReadTotalTimeoutConstant := 0;
    WriteTotalTimeoutMultiplier := 0;
    WriteTotalTimeoutConstant := 0;
  end;
  assert( SetCommTimeouts(ComFile, CommTimeouts) );
end;

function WriteCOM(p:pchar; len:integer): integer;
begin
  assert( WriteFile(ComFile, p^, len, DWORD(result), nil) );
end;

function ReadCOM(p:pchar; len:integer): integer;
begin
  if ComFile=INVALID_HANDLE_VALUE then exit;
  assert( ReadFile(ComFile, p^, len, DWORD(result), nil) );
end;

procedure CloseCOM;
begin
  if ComFile<>INVALID_HANDLE_VALUE then begin
    CloseHandle(ComFile);
    ComFile := INVALID_HANDLE_VALUE;
  end;
end;

end.

