unit CITY_Common;

{$INCLUDE 'CITY_defs.inc'}

interface

uses
  AuxTypes;

type
  UInt128 = packed record
    case Integer of
      0:(QWords:  array[0..1] of UInt64);
      1:(First:   UInt64;
         Second:  UInt64);
      2:(Low:     UInt64;
         High:    UInt64);
  end;
  PUInt128 = ^UInt128;

Function UInt128Make(Low,High: UInt64): UInt128;{$IFDEF CanInline} inline;{$ENDIF}

Function UInt128Low64(x: UInt128): UInt64;{$IFDEF CanInline} inline;{$ENDIF}
Function UInt128High64(x: UInt128): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

Function Hash128to64(const x: UInt128): UInt64;

type
  UInt256 = array[0..3] of UInt64;
  PUInt256 = ^UInt256;
  
//------------------------------------------------------------------------------

Function UNALIGNED_LOAD32(Ptr: Pointer): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function UNALIGNED_LOAD32(Ptr: Pointer; Offset: PtrUInt): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function UNALIGNED_LOAD64(Ptr: Pointer): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function UNALIGNED_LOAD64(Ptr: Pointer; Offset: PtrUInt): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function uint32_in_expected_order(x: UInt32): UInt32;{$IFDEF CanInline} inline;{$ENDIF}
Function uint64_in_expected_order(x: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

Function Fetch32(Ptr: Pointer): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function Fetch32(Ptr: Pointer; Offset: PtrUInt): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function Fetch64(Ptr: Pointer): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function Fetch64(Ptr: Pointer; Offset: PtrUInt): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

procedure SWAP(var a,b: UInt64);

Function PTR_ADVANCE(const Ptr: Pointer; Offset: PtrUInt): Pointer;{$IFDEF CanInline} inline;{$ENDIF}

procedure PTR_ADVANCEVAR(var Ptr: Pointer; Offset: PtrUInt);{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

// Some primes between 2^63 and 2^64 for various uses.
const
  k0 = UInt64($c3a5c85c97cb3127);
  k1 = UInt64($b492b66fbe98f273);
  k2 = UInt64($9ae16a3b2f90404f);
  k3 = UInt64($c949d7c7509e6557);

// Bitwise right rotate.  Normally this will compile to a single
// instruction, especially if the shift is a manifest constant.
Function Rotate(val: UInt64; shift: Integer): UInt64;

//------------------------------------------------------------------------------

// Equivalent to Rotate(), but requires the second arg to be non-zero.
// On x86-64, and probably others, it's possible for this to compile
// to a single instruction if both args are already in registers.
Function RotateByAtLeast1(val: UInt64; shift: Integer): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

Function ShiftMix(val: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

Function HashLen16(u,v: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}


Function _mm_crc32_u64(crc,v: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

implementation

uses
  BitOps;

Function UInt128Make(Low,High: UInt64): UInt128;
begin
Result.Low := Low;
Result.High := High;
end;

//------------------------------------------------------------------------------

Function UInt128Low64(x: UInt128): UInt64;
begin
Result := x.Low;
end;

//------------------------------------------------------------------------------

Function UInt128High64(x: UInt128): UInt64;
begin
Result := x.High;
end;

//------------------------------------------------------------------------------

Function Hash128to64(const x: UInt128): UInt64;
const
  kMul: UInt64 = UInt64($9ddfea08eb382d69);
var
  a,b:  UInt64;
begin
a := (UInt128Low64(x) xor UInt128High64(x)) * kMul;
a := a xor (a shr 47);
b := (UInt128High64(x) xor a) * kMul;
b := b xor (b shr 47);
b := b * kMul;
Result := b;
end;

//==============================================================================

Function UNALIGNED_LOAD32(Ptr: Pointer): UInt32;
begin
Move(Ptr^,Result,SizeOf(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function UNALIGNED_LOAD32(Ptr: Pointer; Offset: PtrUInt): UInt32;
begin
Move(PTR_ADVANCE(Ptr,Offset)^,Result,SizeOf(Result));
end;

//------------------------------------------------------------------------------

Function UNALIGNED_LOAD64(Ptr: Pointer): UInt64;
begin
Move(Ptr^,Result,SizeOf(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function UNALIGNED_LOAD64(Ptr: Pointer; Offset: PtrUInt): UInt64;
begin
Move(PTR_ADVANCE(Ptr,Offset)^,Result,SizeOf(Result));
end;

//------------------------------------------------------------------------------

Function uint32_in_expected_order(x: UInt32): UInt32;
begin
{$IFDEF ENDIAN_BIG}
Result := EndianSwap(x);
{$ELSE}
Result := x;
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function uint64_in_expected_order(x: UInt64): UInt64;
begin
{$IFDEF ENDIAN_BIG}
Result := EndianSwap(x);
{$ELSE}
Result := x;
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function Fetch32(Ptr: Pointer): UInt32;
begin
Result := uint32_in_expected_order(UNALIGNED_LOAD32(Ptr));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function Fetch32(Ptr: Pointer; Offset: PtrUInt): UInt32;
begin
Result := uint32_in_expected_order(UNALIGNED_LOAD32(Ptr,Offset));
end;

//------------------------------------------------------------------------------

Function Fetch64(Ptr: Pointer): UInt64;
begin
Result := uint64_in_expected_order(UNALIGNED_LOAD64(Ptr));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function Fetch64(Ptr: Pointer; Offset: PtrUInt): UInt64;
begin
Result := uint64_in_expected_order(UNALIGNED_LOAD64(Ptr,Offset));
end;

//==============================================================================

procedure SWAP(var a,b: UInt64);
var
  Temp: UInt64;
begin
Temp := a;
a := b;
b := Temp;
end;

//------------------------------------------------------------------------------

Function PTR_ADVANCE(const Ptr: Pointer; Offset: PtrUInt): Pointer;
begin
Result := Pointer(PtrUInt(Ptr) + Offset);
end;

//------------------------------------------------------------------------------

procedure PTR_ADVANCEVAR(var Ptr: Pointer; Offset: PtrUInt);
begin
Ptr := Pointer(PtrUInt(Ptr) + Offset);
end;

//==============================================================================

Function Rotate(val: UInt64; shift: Integer): UInt64;
begin
// Avoid shifting by 64: doing so yields an undefined result.
If shift = 0 then
  Result := val
else
  Result := ROR(val,Byte(Shift));
end;

//------------------------------------------------------------------------------

Function RotateByAtLeast1(val: UInt64; shift: Integer): UInt64;
begin
Result := ROR(val,Byte(Shift));
end;

//------------------------------------------------------------------------------

Function ShiftMix(val: UInt64): UInt64;
begin
Result := val xor (val shr 47);
end;

//------------------------------------------------------------------------------

Function HashLen16(u,v: UInt64): UInt64;
begin
Result := Hash128to64(UInt128Make(u,v));
end;

//==============================================================================

// Software implemntation of the SSE4.2 intrinsic
Function _mm_crc32_u64_pas(crc,v: UInt64): UInt64;
const
  CRCTable: array[Byte] of UInt32 = (
    $00000000, $F26B8303, $E13B70F7, $1350F3F4, $C79A971F, $35F1141C, $26A1E7E8, $D4CA64EB,
    $8AD958CF, $78B2DBCC, $6BE22838, $9989AB3B, $4D43CFD0, $BF284CD3, $AC78BF27, $5E133C24,
    $105EC76F, $E235446C, $F165B798, $030E349B, $D7C45070, $25AFD373, $36FF2087, $C494A384,
    $9A879FA0, $68EC1CA3, $7BBCEF57, $89D76C54, $5D1D08BF, $AF768BBC, $BC267848, $4E4DFB4B,
    $20BD8EDE, $D2D60DDD, $C186FE29, $33ED7D2A, $E72719C1, $154C9AC2, $061C6936, $F477EA35,
    $AA64D611, $580F5512, $4B5FA6E6, $B93425E5, $6DFE410E, $9F95C20D, $8CC531F9, $7EAEB2FA,
    $30E349B1, $C288CAB2, $D1D83946, $23B3BA45, $F779DEAE, $05125DAD, $1642AE59, $E4292D5A,
    $BA3A117E, $4851927D, $5B016189, $A96AE28A, $7DA08661, $8FCB0562, $9C9BF696, $6EF07595,
    $417B1DBC, $B3109EBF, $A0406D4B, $522BEE48, $86E18AA3, $748A09A0, $67DAFA54, $95B17957,
    $CBA24573, $39C9C670, $2A993584, $D8F2B687, $0C38D26C, $FE53516F, $ED03A29B, $1F682198,
    $5125DAD3, $A34E59D0, $B01EAA24, $42752927, $96BF4DCC, $64D4CECF, $77843D3B, $85EFBE38,
    $DBFC821C, $2997011F, $3AC7F2EB, $C8AC71E8, $1C661503, $EE0D9600, $FD5D65F4, $0F36E6F7,
    $61C69362, $93AD1061, $80FDE395, $72966096, $A65C047D, $5437877E, $4767748A, $B50CF789,
    $EB1FCBAD, $197448AE, $0A24BB5A, $F84F3859, $2C855CB2, $DEEEDFB1, $CDBE2C45, $3FD5AF46,
    $7198540D, $83F3D70E, $90A324FA, $62C8A7F9, $B602C312, $44694011, $5739B3E5, $A55230E6,
    $FB410CC2, $092A8FC1, $1A7A7C35, $E811FF36, $3CDB9BDD, $CEB018DE, $DDE0EB2A, $2F8B6829,
    $82F63B78, $709DB87B, $63CD4B8F, $91A6C88C, $456CAC67, $B7072F64, $A457DC90, $563C5F93,
    $082F63B7, $FA44E0B4, $E9141340, $1B7F9043, $CFB5F4A8, $3DDE77AB, $2E8E845F, $DCE5075C,
    $92A8FC17, $60C37F14, $73938CE0, $81F80FE3, $55326B08, $A759E80B, $B4091BFF, $466298FC,
    $1871A4D8, $EA1A27DB, $F94AD42F, $0B21572C, $DFEB33C7, $2D80B0C4, $3ED04330, $CCBBC033,
    $A24BB5A6, $502036A5, $4370C551, $B11B4652, $65D122B9, $97BAA1BA, $84EA524E, $7681D14D,
    $2892ED69, $DAF96E6A, $C9A99D9E, $3BC21E9D, $EF087A76, $1D63F975, $0E330A81, $FC588982,
    $B21572C9, $407EF1CA, $532E023E, $A145813D, $758FE5D6, $87E466D5, $94B49521, $66DF1622,
    $38CC2A06, $CAA7A905, $D9F75AF1, $2B9CD9F2, $FF56BD19, $0D3D3E1A, $1E6DCDEE, $EC064EED,
    $C38D26C4, $31E6A5C7, $22B65633, $D0DDD530, $0417B1DB, $F67C32D8, $E52CC12C, $1747422F,
    $49547E0B, $BB3FFD08, $A86F0EFC, $5A048DFF, $8ECEE914, $7CA56A17, $6FF599E3, $9D9E1AE0,
    $D3D3E1AB, $21B862A8, $32E8915C, $C083125F, $144976B4, $E622F5B7, $F5720643, $07198540,
    $590AB964, $AB613A67, $B831C993, $4A5A4A90, $9E902E7B, $6CFBAD78, $7FAB5E8C, $8DC0DD8F,
    $E330A81A, $115B2B19, $020BD8ED, $F0605BEE, $24AA3F05, $D6C1BC06, $C5914FF2, $37FACCF1,
    $69E9F0D5, $9B8273D6, $88D28022, $7AB90321, $AE7367CA, $5C18E4C9, $4F48173D, $BD23943E,
    $F36E6F75, $0105EC76, $12551F82, $E03E9C81, $34F4F86A, $C69F7B69, $D5CF889D, $27A40B9E,
    $79B737BA, $8BDCB4B9, $988C474D, $6AE7C44E, $BE2DA0A5, $4C4623A6, $5F16D052, $AD7D5351);
var
  Input:  array[0..7] of Byte absolute v;
  Temp:   UInt32;
  i:      Integer;
begin
Temp := UInt32(crc);
For i := Low(Input) to High(Input) do
  Temp := CRCTable[Byte(Temp xor UInt32(Input[i]))] xor (Temp shr 8);
Result := UInt64(Temp);
end;

//------------------------------------------------------------------------------

{$IFNDEF PurePascal}

Function _mm_crc32_u64_asm(crc,v: UInt64): UInt64; register; assembler;
asm
{$IFDEF x64}
    CRC32   crc,  v
    MOV     RAX,  crc
{$ELSE}
    MOV     EAX,  dword ptr [CRC]

  {$IFDEF ASM_MachineCode}
    DB  $F2, $0F, $38, $F1, $45, $08    // CRC32   EAX,  dword ptr [EBP + 8]
    DB  $F2, $0F, $38, $F1, $45, $0C    // CRC32   EAX,  dword ptr [EPB + 12]
  {$ELSE}
    CRC32   EAX,  dword ptr [v]
    CRC32   EAX,  dword ptr [v + 4]
  {$ENDIF}

    XOR     EDX,  EDX
{$ENDIF}
end;

{$ENDIF}

//------------------------------------------------------------------------------

var
  _mm_crc32_u64_var:  Function(crc,v: UInt64): UInt64;

Function _mm_crc32_u64(crc,v: UInt64): UInt64;
begin
Result := _mm_crc32_u64_var(crc,v);
end;

initialization
  _mm_crc32_u64_var := _mm_crc32_u64_pas; {$message 'todo'}

end.