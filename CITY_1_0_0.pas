unit CITY_1_0_0;

{$INCLUDE 'CITY_defs.inc'}

interface

uses
  AuxTypes,
  CITY_Common;

// Hash 128 input bits down to 64 bits of output.
// This is intended to be a reasonably good hash function.
Function Hash128to64(const x: UInt128): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

// Hash function for a byte array.
Function CityHash64(s: Pointer; len: TMemSize): UInt64;

// Hash function for a byte array.  For convenience, a 64-bit seed is also
// hashed into the result.
Function CityHash64WithSeed(s: Pointer; len: TMemSize; seed: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

// Hash function for a byte array.  For convenience, two seeds are also
// hashed into the result.
Function CityHash64WithSeeds(s: Pointer; len: TMemSize; seed0,seed1: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

// Hash function for a byte array.  For convenience, a 128-bit seed is also
// hashed into the result.
Function CityHash128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;

// Hash function for a byte array.
Function CityHash128(s: Pointer; len: TMemSize): UInt128;

implementation

uses
  BitOps;

Function Hash128to64(const x: UInt128): UInt64;
begin
Result := CITY_Common.Hash128to64(x);
end;

//==============================================================================

// Some primes between 2^63 and 2^64 for various uses.
const
  k0 = UInt64($c3a5c85c97cb3127);
  k1 = UInt64($b492b66fbe98f273);
  k2 = UInt64($9ae16a3b2f90404f);
  k3 = UInt64($c949d7c7509e6557);

//------------------------------------------------------------------------------

// Bitwise right rotate.  Normally this will compile to a single
// instruction, especially if the shift is a manifest constant.
Function Rotate(val: UInt64; shift: Integer): UInt64;
begin
// Avoid shifting by 64: doing so yields an undefined result.
If shift = 0 then
  Result := val
else
  Result := ROR(val,Byte(Shift));
end;

//------------------------------------------------------------------------------

// Equivalent to Rotate(), but requires the second arg to be non-zero.
// On x86-64, and probably others, it's possible for this to compile
// to a single instruction if both args are already in registers.
Function RotateByAtLeast1(val: UInt64; shift: Integer): UInt64;{$IFDEF CanInline} inline;{$ENDIF}
begin
Result := ROR(val,Byte(Shift));
end;

//------------------------------------------------------------------------------

Function ShiftMix(val: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}
begin
Result := val xor (val shr 47);
end;

//------------------------------------------------------------------------------

Function HashLen16(u,v: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}
begin
Result := Hash128to64(UInt128Make(u,v));
end;

//------------------------------------------------------------------------------

Function HashLen0to16(const s: Pointer; len: TMemSize): UInt64;
var
  a,b,c:  UInt64;
  y,z:    UInt32;
begin
case len of
  0..3:
    begin
      a := PUInt8(s)^;
      b := PUInt8(PTR_ADVANCE(s,len shr 1))^;
      c := PUInt8(PTR_ADVANCE(s,len - 1))^;
      y := UInt32(a) + (UInt32(b) shl 8);
      z := UInt32(len) + (UInt32(c) shl 2);
      Result := ShiftMix((UInt64(y) * k2) xor (UInt64(z) * k3)) * k2;
    end;
  4..8:
    begin
      a := UNALIGNED_LOAD32(s);
      Result := HashLen16(len + UInt64(a shl 3),UNALIGNED_LOAD32(s,len - 4));
    end;
  9..High(len):
    begin
      a := UNALIGNED_LOAD64(s);
      b := UNALIGNED_LOAD64(s,len - 8);
      Result := HashLen16(a,RotateByAtLeast1(b + len,len)) xor b;
    end;
else
  Result := k2;
end;
end;

//------------------------------------------------------------------------------

// This probably works well for 16-byte strings as well, but it may be overkill
// in that case.
Function HashLen17to32(const s: Pointer; len: TMemSize): UInt64;
var
  a,b,c,d:  UInt64;
begin
a := UNALIGNED_LOAD64(s) * k1;
b := UNALIGNED_LOAD64(s,8);
c := UNALIGNED_LOAD64(s,len - 8) * k2;
d := UNALIGNED_LOAD64(s,len - 16) * k0;
Result := HashLen16(Rotate(a - b,43) + Rotate(c,30) + d,a + Rotate(b xor k3,20) - c + len);
end;

//------------------------------------------------------------------------------

// Return a 16-byte hash for 48 bytes.  Quick and dirty.
// Callers do best to use "random-looking" values for a and b.
Function WeakHashLen32WithSeeds(w,x,y,z,a,b: UInt64): UInt128; overload;
var
  c:  UInt64;
begin
a := a + w;
b := Rotate(b + a + z,21);
c := a;
a := a + x;
a := a + y;
b := b + Rotate(a,44);
Result.First := a + z;
Result.Second := b + c;
end;

//------------------------------------------------------------------------------

// Return a 16-byte hash for s[0] ... s[31], a, and b.  Quick and dirty.
Function WeakHashLen32WithSeeds(const s: Pointer; a,b: UInt64): UInt128; overload;
begin
Result := WeakHashLen32WithSeeds(UNALIGNED_LOAD64(s),
                                 UNALIGNED_LOAD64(s,8),
                                 UNALIGNED_LOAD64(s,16),
                                 UNALIGNED_LOAD64(s,24),a,b);
end;

//------------------------------------------------------------------------------

// Return an 8-byte hash for 33 to 64 bytes
Function HashLen33to64(const s: Pointer; len: TMemSize): UInt64;
var
  a,b,c,z,vf,vs,wf,ws,r:  UInt64;
begin
z := UNALIGNED_LOAD64(s,24);
a := UNALIGNED_LOAD64(s) + (len + UNALIGNED_LOAD64(s,len - 16)) * k0;
b := Rotate(a + z,52);
c := Rotate(a,37);
a := a + UNALIGNED_LOAD64(s,8);
c := c + Rotate(a,7);
a := a + UNALIGNED_LOAD64(s,16);
vf := a + z;
vs := b + Rotate(a,31) + c;
a := UNALIGNED_LOAD64(s,16) + UNALIGNED_LOAD64(s,len - 32);
z := UNALIGNED_LOAD64(s, len - 8);
b := Rotate(a + z,52);
c := Rotate(a,37);
a := a + UNALIGNED_LOAD64(s,len - 24);
c := c + Rotate(a,7);
a := a + UNALIGNED_LOAD64(s,len - 16);
wf := a + z;
ws := b + Rotate(a,31) + c;
r := ShiftMix((vf + ws) * k2 + (wf + vs) * k0);
Result := ShiftMix(r * k0 + vs) * k2;
end;

//==============================================================================

Function CityHash64(s: Pointer; len: TMemSize): UInt64;
var
  x,y,z:  UInt64;
  v,w:    UInt128;
begin
If len <= 64 then
  begin
    case len of
       0..16: Result := HashLen0To16(s,len);
      17..32: Result := HashLen17To32(s,len);
    else
     {33..64}
      Result := HashLen33to64(s,len);
    end;
    Exit;
  end;
// For strings over 64 bytes we hash the end first, and then as we
// loop we keep 56 bytes of state: v, w, x, y, and z.
x := UNALIGNED_LOAD64(s);
y := UNALIGNED_LOAD64(s,len - 16) xor k1;
z := UNALIGNED_LOAD64(s,len - 56) xor k0;
v := WeakHashLen32WithSeeds(PTR_ADVANCE(s,len - 64),len,y);
w := WeakHashLen32WithSeeds(PTR_ADVANCE(s,len - 32),len * k1,k0);
z := z + ShiftMix(v.Second) * k1;
x := Rotate(z + x,39) * k1;
y := Rotate(y,33) * k1;
// Decrease len to the nearest multiple of 64, and operate on 64-byte chunks.
len := (len - 1) and not TMemSize(63);
repeat
  x := Rotate(x + y + v.First + UNALIGNED_LOAD64(s,16),37) * k1;
  y := Rotate(y + v.Second + UNALIGNED_LOAD64(s,48),42) * k1;
  x := x xor w.Second;
  y := y xor v.First;
  z := Rotate(z xor w.First,33);
  v := WeakHashLen32WithSeeds(s,v.Second * k1,x + w.First);
  w := WeakHashLen32WithSeeds(PTR_ADVANCE(s,32),z + w.Second,y);
  SWAP(z,x);
  PTR_ADVANCEVAR(s,64);
  len := len - 64;
until len <= 0;
Result := HashLen16(HashLen16(v.First,w.First) + ShiftMix(y) * k1 + z,
                    HashLen16(v.Second,w.Second) + x);
end;

//------------------------------------------------------------------------------

Function CityHash64WithSeed(s: Pointer; len: TMemSize; seed: UInt64): UInt64;
begin
Result := CityHash64WithSeeds(s,len,k2,seed);
end;

//------------------------------------------------------------------------------

Function CityHash64WithSeeds(s: Pointer; len: TMemSize; seed0,seed1: UInt64): UInt64;
begin
Result := HashLen16(CityHash64(s,len) - seed0,seed1);
end;

//------------------------------------------------------------------------------

// A subroutine for CityHash128().  Returns a decent 128-bit hash for strings
// of any length representable in ssize_t.  Based on City and Murmur.
Function CityMurmur(s: Pointer; len: TMemSize; seed: UInt128): UInt128;
var
  a,b,c,d:  UInt64;
  l:        PtrInt;
begin
a := UInt128Low64(seed);
b := UInt128High64(seed);
l := len - 15;
If l <= 0 then  // len <= 16
  begin
    c := b * k1 + HashLen0to16(s,len);
    If len >= 8 then
      d := Rotate(a + UNALIGNED_LOAD64(s),32)
    else
      d := Rotate(a + c,32);
  end
else
  begin
    c := HashLen16(UNALIGNED_LOAD64(s,len - 8) + k1,a);
    d := HashLen16(b + len,c + UNALIGNED_LOAD64(s,len - 16));
    a := a + d;
    repeat
      a := a xor (ShiftMix(UNALIGNED_LOAD64(s) * k1) * k1);
      a := a * k1;
      b := b xor a;
      c := c xor (ShiftMix(UNALIGNED_LOAD64(s,8) * k1) * k1);
      c := c * k1;
      d := d xor c;
      PTR_ADVANCEVAR(s,16);
      l := l - 16;
    until l <= 0;
  end;
a := HashLen16(a,c);
b := HashLen16(d,b);
Result := UInt128Make(a xor b,HashLen16(b,a));
end;

//------------------------------------------------------------------------------

Function CityHash128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;
var
  v,w:        UInt128;
  x,y,z:      UInt64;
  tail_done:  TMemSize;
begin
If len < 128 then
  begin
    Result := CityMurmur(s,len,seed);
    Exit;
  end;
// We expect len >= 128 to be the common case.  Keep 56 bytes of state:
// v, w, x, y, and z.
x := UInt128Low64(seed);
y := UInt128High64(seed);
z := len * k1;
v.First := Rotate(y xor k1,49) * k1 + UNALIGNED_LOAD64(s);
v.Second := Rotate(v.First,42) * k1 + UNALIGNED_LOAD64(s,8);
w.First := Rotate(y + z,35) * k1 + x;
w.Second := Rotate(x + UNALIGNED_LOAD64(s,88),53) * k1;
// This is the same inner loop as CityHash64(), manually unrolled.
repeat
  x := Rotate(x + y + v.First + UNALIGNED_LOAD64(s,16),37) * k1;
  y := Rotate(y + v.Second + UNALIGNED_LOAD64(s,48),42) * k1;
  x := x xor w.Second;
  y := y xor v.First;
  z := Rotate(z xor w.First,33);
  v := WeakHashLen32WithSeeds(s,v.Second * k1,x + w.First);
  w := WeakHashLen32WithSeeds(PTR_ADVANCE(s,32),z + w.Second,y);
  SWAP(z,x);
  PTR_ADVANCEVAR(s,64);
  x := Rotate(x + y + v.First + UNALIGNED_LOAD64(s,16),37) * k1;
  y := Rotate(y + v.Second + UNALIGNED_LOAD64(s,48),42) * k1;
  x := x xor w.Second;
  y := y xor v.First;
  z := Rotate(z xor w.First,33);
  v := WeakHashLen32WithSeeds(s,v.Second * k1,x + w.First);
  w := WeakHashLen32WithSeeds(PTR_ADVANCE(s,32),z + w.Second,y);
  SWAP(z, x);
  PTR_ADVANCEVAR(s,64);
  len := len - 128;
until len < 128;
y := y + Rotate(w.First,37) * k0 + z;
x := x + Rotate(v.First + z,49) * k0;
// If 0 < len < 128, hash up to 4 chunks of 32 bytes each from the end of s.
tail_done := 0;
while tail_done < len do
  begin
    tail_done := tail_done + 32;
    y := Rotate(y - x,42) * k0 + v.Second;
    w.First := w.First + UNALIGNED_LOAD64(s,len - tail_done + 16);
    x := Rotate(x,49) * k0 + w.First;
    w.First := w.First + v.First;
    v := WeakHashLen32WithSeeds(PTR_ADVANCE(s,len - tail_done),v.First,v.Second);
  end;
// At this point our 48 bytes of state should contain more than
// enough information for a strong 128-bit hash.  We use two
// different 48-byte-to-8-byte hashes to get a 16-byte final result.
x := HashLen16(x,v.First);
y := HashLen16(y,w.First);
Result := UInt128Make(HashLen16(x + v.Second,w.Second) + y,
                      HashLen16(x + w.Second,y + v.Second));
end;

//------------------------------------------------------------------------------

Function CityHash128(s: Pointer; len: TMemSize): UInt128;
begin
If len >= 16 then
  Result := CityHash128WithSeed(PTR_ADVANCE(s,16),len - 16,UInt128Make(UNALIGNED_LOAD64(s) xor k3,UNALIGNED_LOAD64(s,8)))
else If len >= 8 then
  Result := CityHash128WithSeed(nil,0,UInt128Make(UNALIGNED_LOAD64(s) xor (len * k0),UNALIGNED_LOAD64(s,len - 8) xor k1))
else
  Result := CityHash128WithSeed(s,len,UInt128Make(k0,k1));
end;

end.
