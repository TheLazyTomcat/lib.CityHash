{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  CITY hash calculation - defines

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

// do not change following lines
{$IF defined(CPUX86_64) or defined(CPUX64)}
  {$DEFINE x64}
{$ELSEIF defined(CPU386)}
  {$DEFINE x86}
{$ELSE}
  {$DEFINE PurePascal}
{$IFEND}

{$IFDEF FPC}
  {$MODE Delphi}
  {$INLINE ON}
  {$DEFINE CanInline}
  {$IFNDEF PurePascal}
    {$ASMMODE Intel}
  {$ENDIF}
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ELSE}
  {$IF CompilerVersion >= 17 then}  // Delphi 2005+
    {$DEFINE CanInline}
  {$ELSE}
    {$UNDEF CanInline}
  {$IFEND}
  {$IFNDEF x64}
    {$DEFINE ASM_MachineCode}
  {$ENDIF}
{$ENDIF}
{$H+}

{$Q-} // turn off overflow checks
{$R-} // turn off range checks
