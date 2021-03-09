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

//------------------------------------------------------------------------------

Function UNALIGNED_LOAD32(Ptr: Pointer): UInt32; overload; {$IFDEF CanInline} inline;{$ENDIF}
Function UNALIGNED_LOAD32(Ptr: Pointer; Offset: PtrUInt): UInt32; overload; {$IFDEF CanInline} inline;{$ENDIF}

Function UNALIGNED_LOAD64(Ptr: Pointer): UInt64; overload; {$IFDEF CanInline} inline;{$ENDIF}
Function UNALIGNED_LOAD64(Ptr: Pointer; Offset: PtrUInt): UInt64; overload; {$IFDEF CanInline} inline;{$ENDIF}

procedure SWAP(var a,b: UInt64);

Function PTR_ADVANCE(const Ptr: Pointer; Offset: PtrUInt): Pointer;{$IFDEF CanInline} inline;{$ENDIF}

procedure PTR_ADVANCEVAR(var Ptr: Pointer; Offset: PtrUInt);{$IFDEF CanInline} inline;{$ENDIF}

implementation

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

end.
