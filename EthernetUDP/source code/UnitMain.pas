unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, CRC32, UnitCOM;

const
  Protocol_IP  = $0800;  // Internet Protocol (IP)
  Protocol_ARP = $0806;  // Address Resolution Protocol (ARP)

type
  IPv4 = array[0..3] of byte;
  IP_header = record  // 20 bytes
    verlen:      byte;  // IP version & length		//    45
    tos:         byte;  // IP type of service		//    00
    totallength: word;  // Total length
    id:          word;  // Unique identifier		// 00 00
    offset:      word;  // Fragment offset field	// 00 00
    ttl:         byte;  // Time to live			//    80
    protocol:    byte;  // Protocol(TCP, UDP, etc.)	//    11
    checksum:    word;  // IP checksum
    srcaddr :    IPv4;  // Source IP	   
    destaddr:    IPv4;  // Destination IP
  end;

  UDP_header = record  // 8 bytes
    src_portno:   word;    // Source port number
    dst_portno:   word;    // Destination port number
    udp_length:   word;    // UDP packet length
    udp_checksum: word;    // UDP checksum (optional)
  end;

  EthernetIIframe = record
    DestinationMAC_Address: array[0..5] of byte;
    SourceMAC_Address     : array[0..5] of byte;
    Protocol: word;
    Data: array[0..1499] of byte;
    Checksum: dword;
  end;

  EthernetUDP_packet = record
    DestinationMAC_Address: array[0..5] of byte;
    SourceMAC_Address     : array[0..5] of byte;
    Protocol: word;
    IP: IP_header;
    UDP: UDP_header;
    Data: array[0..1499-20-8] of byte;
    Checksum: dword;
  end;

type
  TFormMain = class(TForm)
    EditDestinationMAC_Address: TEdit;
    EditSourceMAC_Address: TEdit;
    ButtonSend: TButton;
    SpinEditPayloadLength: TSpinEdit;
    EditSourceIP: TEdit;
    EditDestinationIP: TEdit;
    Memo: TMemo;
    SpinEditSourcePort: TSpinEdit;
    SpinEditDestinationPort: TSpinEdit;
    LabelSourceMAC: TLabel;
    LabelDestinationMAC: TLabel;
    LabelSourceIP: TLabel;
    LabelDestinationIP: TLabel;
    LabelPayloadLenght: TLabel;
    LabelSourcePort: TLabel;
    LabelDestinationPort: TLabel;
    ButtonClear: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
  private
    pkt: EthernetUDP_packet;
    EthernetPacketLen: integer;
    procedure SendPacket;
  public
    nMessage: integer;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.DFM}

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then close;
end;

procedure DecodeASCII_IP(const IPstr:string; var IP:IPv4);
var
  i, v, IPindex: integer;
  s: string;
begin
  v := -1;
  IPindex := 0;
  s := trim(IPstr) + '.';
  for i:=1 to length(s) do begin
    case s[i] of
      '0'..'9': if v<0 then v:=byte(s[i])-byte('0') else v:=v*10+byte(s[i])-byte('0');
      '.': begin
        if IPindex>3 then raise Exception.Create('Too many dots in IP "'+IPstr+'"');
        if v<0 then raise Exception.Create('Value missing in IP "'+IPstr+'"');
        if v>255 then raise Exception.Create('Value in IP "'+IPstr+'" out of 0..255 range');
        IP[IPindex] := v;
        inc(IPindex);
        if (IPindex=4) and (i<length(s)) then raise Exception.Create('IP "'+IPstr+'" too long');
        v := -1;
      end;
      else raise Exception.Create('Invalid character in IP "'+IPstr+'"');
    end;
  end;
  if IPindex<4 then raise Exception.Create('IP "'+IPstr+'" too short');
end;

function IPchecksum(v: integer): word;
begin
  v := integer(LongRec(v).Lo) + integer(LongRec(v).Hi);
  result := not(LongRec(v).Lo + LongRec(v).Hi);
end;

function IPchecksum_BufSum(buf: pbyte; buflen: integer): integer;
begin
  result := 0;
  while buflen>1 do begin
    inc(result, pword(buf)^);
    inc(buf, 2);
    dec(buflen, 2);
  end;
  if buflen>0 then inc(result, buf^);
end;

procedure TFormMain.SendPacket;
var
  buf: array[0..1999] of char;
//  buf2: array[0..1999] of char;
  i, ibuf: integer;
  s: string;

  procedure Add(c:char);
  begin
    buf[ibuf] := c;
    inc(ibuf);
  end;
begin
  ibuf := 0;
  for i:=1 to 7 do Add(#$55); // Ethernet preamble
  Add(#$D5);                  // Ethernet SFD

  move(pkt, buf[ibuf], EthernetPacketLen);
  inc(ibuf, EthernetPacketLen);

  WriteCOM(@buf, ibuf);

  for i:=0 to ibuf-1 do s:=s+IntToHex(byte(buf[i]), 2);
  Memo.Lines.Add('Sending:' + s);

(*
repeat
  Sleep(20);
  ii := ReadCOM(@buf2, sizeof(buf2));
if ii=0 then break;
//  Memo.Lines.Add('Sent '+IntToStr(ibuf)+', received '+IntToStr(ii));
  s := '';
  for i:=0 to ii-1 do s:=s+IntToHex(byte(buf2[i]), 2);
//  Memo.Lines.Add(s);

  if ii=ibuf then begin
    i := 0;
    while (i<ibuf) and (buf[i]=buf2[i]) do inc(i);
    if i<ibuf then Memo.Lines.Add('ERROR') else Memo.Lines.Add('MATCH');
  end;
until false;
*)
end;

procedure TFormMain.ButtonSendClick(Sender: TObject);
var
  i, code, payloadlen, payloadlen_ethernet: integer;
  CRC: LongWord;
//  s: string;
begin
  payloadlen := SpinEditPayloadLength.Value;

  payloadlen_ethernet := payloadlen;
  if payloadlen_ethernet<18 then payloadlen_ethernet:=18;
  EthernetPacketLen := 6+6+2+sizeof(IP_header)+sizeof(UDP_header)+payloadlen_ethernet+4;

  for i:=0 to 5 do begin
    val('$'+copy(EditDestinationMAC_Address.Text, i*2+1, 2), pkt.DestinationMAC_Address[i], code);  assert(code=0);
    val('$'+copy(EditSourceMAC_Address.Text, i*2+1, 2), pkt.SourceMAC_Address[i], code);  assert(code=0);
  end;
  pkt.Protocol := swap(Protocol_IP);

  with pkt.IP do begin
    verlen := $40 or (sizeof(IP_header) shr 2);
    tos := 0;
    totallength := swap(sizeof(IP_header)+sizeof(UDP_header)+payloadlen);
    id := $FEB3; // I believe "id" can be anything (MS Windows uses an incrementing value)
    offset := 0;
    ttl := $80;
    protocol := $11;  // "0x11" is UDP
    checksum := 0;
    DecodeASCII_IP(EditSourceIP.Text, srcaddr);
    DecodeASCII_IP(EditDestinationIP.Text, destaddr);
    checksum := IPchecksum(IPchecksum_BufSum(@pkt.IP, sizeof(pkt.IP)));
  end;

  with pkt.UDP do begin
    src_portno := swap(SpinEditSourcePort.Value);
    dst_portno := swap(SpinEditDestinationPort.Value);
    udp_length := swap(sizeof(UDP_header)+payloadlen);
    udp_checksum := 0;
  end;

  FillChar(pkt.Data, payloadlen_ethernet, 0);
  for i:=0 to payloadlen-1 do pkt.Data[i]:=i;

  pkt.UDP.udp_checksum := IPchecksum(
    integer(pkt.IP.protocol)*$100 +
    integer(pkt.UDP.udp_length) +
    IPchecksum_BufSum(@pkt.IP.srcaddr, 8+sizeof(UDP_header)+payloadlen)
  );

  CRC := 0;
  GetCRC32(CRC, pkt, EthernetPacketLen-4);
  pdword(integer(@pkt)+EthernetPacketLen-4)^ := CRC;

(*
  s := '';
  for i:=0 to EthernetPacketLen-1 do s:=s+IntToHex(pbyte(integer(@pkt)+i)^, 2);
  insert('.', s, 1+12+12+4+20+4+16+16+payloadlen_ethernet*2);
  insert('.', s, 1+12+12+4+20+4+16+16);
  insert('.', s, 1+12+12+4+20+4+16);
  insert('.', s, 1+12+12+4+20+4);
  insert('.', s, 1+12+12+4+20);
  insert('.', s, 1+12+12+4);
  insert('.', s, 1+12+12);
  insert('.', s, 1+12);
  Memo.Lines.Add(IntToStr(nMessage) + ': ' + s);
*)

  SendPacket;

//  CRC := 0;  GetCRC32(CRC, pkt, EthernetPacketLen);  Memo.Lines.Add(IntToHex(CRC, 8));
  inc(nMessage);
end;

// 18 bytes UDP
//0007950BAF0B.0010A47BEA80.0800.4500002EB3C800008011.05A0.C0A80004C0A80002.04000400001A2E12.000102030405060708090A0B0C0D0E0F1011.0318EA
//0007950BAF0B.0010A47BEA80.0800.4500002EB3C800008011.05A0.C0A80004C0A80002.04000400001A2E12.000102030405060708090A0B0C0D0E0F1011.0318EAE0

// 17 bytes UDP
//0007950BAF0B.0010A47BEA80.0800.4500002DB3FE00008011.056B.C0A80004C0A80002.0400040000192E25.000102030405060708090A0B0C0D0E0F1000.8DE636
//0007950BAF0B.0010A47BEA80.0800.4500002DB3FE00008011.056B.C0A80004C0A80002.0400040000192E25.000102030405060708090A0B0C0D0E0F1000.8DE63602

procedure TFormMain.ButtonClearClick(Sender: TObject);
begin
  nMessage := 0;
  Memo.Clear;
  ButtonSend.SetFocus;
end;

initialization
  OpenCOM;

finalization
  CloseCom;

//192.168.0.2	0007950BAF0B
//192.168.0.4	0010A47BEA80
end.

