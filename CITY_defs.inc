{
  CITY_AllowCRCExt

  When defined, allows use of CRC32 instruction (part of SSE 4.2 extension) in
  assembly.
  Availability of the instruction is tested at unit initialization, and the
  instruction is used only when properly supported. When it is not supported,
  pascal implementation is called instead.
  Has no meaning when PurePascal symbol is defined.

  Defined by default.
}
{$DEFINE CITY_AllowCRCExt}

//------------------------------------------------------------------------------

// Do not change following lines
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
