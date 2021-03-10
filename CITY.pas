{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  CITY hash calculation - main unit

    This library is only a naive reimplementation of reference code that can be
    found in this repository:

      https://github.com/google/cityhash

    Because individual historical versions can produce different hashes for the
    same message, all versions were implemented, each in its own unit (for
    example version 1.0.3 of the hash is implemented in unit CITY_1_0_3.pas).
    This allows you to choose which version to use, if you happen to need a
    specific older implementation.

    Currently implemented versions are:

        1.0.0 ... in CITY_1_0_0.pas
        1.0.1 ... in CITY_1_0_1.pas, CITY_1_0_1_Test.pas
        1.0.2 ... in CITY_1_0_2.pas, CITY_1_0_2_Test.pas
        1.0.3 ... in CITY_1_0_3.pas, CITY_1_0_3_Test.pas
        1.1.0 ... in CITY_1_1_0.pas, CITY_1_1_0_Test.pas
        1.1.1 ... in CITY_1_1_1.pas, CITY_1_1_1_Test.pas

    Functions provided in this unit are only redirecting to latest version,
    which is currently 1.1.1.

    WARNING - version of this library does not correlate with version of
              implemented and used version of the CITY hash!

  Version 2.0 (2021-03-10) [WIP]

  Last change 2021-03-10

  ©2016-2021 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/Lib.CityHash

  Dependencies:
    AuxTypes    - github.com/TheLazyTomcat/Lib.AuxTypes
    BitOps      - github.com/TheLazyTomcat/Lib.BitOps
  * SimpleCPUID - github.com/TheLazyTomcat/Lib.SimpleCPUID

  SimpleCPUID is required only when PurePascal symbol is not defined.
  Also, it might be needed by BitOps library, see there for details

===============================================================================}
unit CITY;

{$INCLUDE 'CITY_defs.inc'}

interface

uses
  AuxTypes,
  CITY_Common,
  CITY_1_1_1; // must be here for inlining in delphi

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
