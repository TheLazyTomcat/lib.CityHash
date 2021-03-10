{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  CITY hash calculation

  ©František Milt 2017-07-19

  Version 1.0.1

  This is only naive reimplementation of reference code that can be found in
  this repository:

    https://github.com/google/cityhash

  Version 1.1.1 of the hash is implemented, but you can switch to version 1.0.3
  by activating VER_1_0_3 define in the CITY_defs.inc file.

  Dependencies:
    AuxTypes    - github.com/ncs-sniper/Lib.AuxTypes
    BitOps      - github.com/ncs-sniper/Lib.BitOps
  * SimpleCPUID - github.com/ncs-sniper/Lib.SimpleCPUID

  SimpleCPUID is required only when both AllowCRCExtension and CRC_Functions
  symbols are defined and PurePascal symbol is not defined.
  Also, it might be needed by BitOps library, depending whether ASM extensions
  are allowed there.

===============================================================================}
unit CITY;

{$INCLUDE 'CITY_defs.inc'}

interface

uses
  AuxTypes,
  CITY_Common,
  CITY_1_1_1; // must be hero for inlining in delphi

{===============================================================================
--------------------------------------------------------------------------------
                        Backward compatibility functions
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Utility functions - declaration
===============================================================================}

const
  CITY_VersionMajor   = 1;
  CITY_VersionMinor   = 1;
  CITY_VersionRelease = 1;
  CITY_VersionFull    = UInt64($0001000100010000);
  CITY_VersionStr     = '1.1.1';

Function Hash128to64(x: UInt128): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
    Main hash functions - declaration
===============================================================================}

Function CityHash32(s: Pointer; len: TMemSize): UInt32;{$IFDEF CanInline} inline;{$ENDIF}

Function CityHash64(s: Pointer; len: TMemSize): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

Function CityHash64WithSeed(s: Pointer; len: TMemSize; seed: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}
Function CityHash64WithSeeds(s: Pointer; len: TMemSize; seed0,seed1: UInt64): UInt64;{$IFDEF CanInline} inline;{$ENDIF}

Function CityHash128(s: Pointer; len: TMemSize): UInt128;{$IFDEF CanInline} inline;{$ENDIF}
Function CityHash128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
    CRC hash functions - declaration
===============================================================================}

procedure CityHashCrc256(s: Pointer; len: TMemSize; out result: UInt256);{$IFDEF CanInline} inline;{$ENDIF}

Function CityHashCrc128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;{$IFDEF CanInline} inline;{$ENDIF}
Function CityHashCrc128(s: Pointer; len: TMemSize): UInt128;{$IFDEF CanInline} inline;{$ENDIF}

implementation

{===============================================================================
--------------------------------------------------------------------------------
                        Backward compatibility functions
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Utility functions - implementation
===============================================================================}

Function Hash128to64(x: UInt128): UInt64;
begin
Result := CITY_1_1_1.Hash128to64(x);
end;

{===============================================================================
    Main hash functions - implementation
===============================================================================}
{-------------------------------------------------------------------------------
    Main hash functions - public functions
-------------------------------------------------------------------------------}

Function CityHash32(s: Pointer; len: TMemSize): UInt32;
begin
Result := CITY_1_1_1.CityHash32(s,len);
end;

//------------------------------------------------------------------------------

Function CityHash64(s: Pointer; len: TMemSize): UInt64;
begin
Result := CITY_1_1_1.CityHash64(s,len);
end;

//------------------------------------------------------------------------------

Function CityHash64WithSeed(s: Pointer; len: TMemSize; seed: UInt64): UInt64;
begin
Result := CITY_1_1_1.CityHash64WithSeed(s,len,seed);
end;

//------------------------------------------------------------------------------

Function CityHash64WithSeeds(s: Pointer; len: TMemSize; seed0,seed1: UInt64): UInt64;
begin
Result := CITY_1_1_1.CityHash64WithSeeds(s,len,seed0,seed1);
end;

//------------------------------------------------------------------------------

Function CityHash128(s: Pointer; len: TMemSize): UInt128;
begin
Result := CITY_1_1_1.CityHash128(s,len);
end;

//------------------------------------------------------------------------------

Function CityHash128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;
begin
Result := CITY_1_1_1.CityHash128WithSeed(s,len,seed);
end;

{===============================================================================
    CRC hash functions - implementation
===============================================================================}
{-------------------------------------------------------------------------------
    CRC hash functions - public functions
-------------------------------------------------------------------------------}

procedure CityHashCrc256(s: Pointer; len: TMemSize; out result: UInt256);
begin
CITY_1_1_1.CityHashCrc256(s,len,result);
end;

//------------------------------------------------------------------------------

Function CityHashCrc128WithSeed(s: Pointer; len: TMemSize; seed: UInt128): UInt128;
begin
Result := CITY_1_1_1.CityHashCrc128WithSeed(s,len,seed);
end;

//------------------------------------------------------------------------------

Function CityHashCrc128(s: Pointer; len: TMemSize): UInt128;
begin
Result := CITY_1_1_1.CityHashCrc128(s,len);
end;

end.
