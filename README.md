# ps-cpuinfo v2.5.1 - CPU Info like microcode by Powershell

#### I made a few modificitions:
- Add tenforums URL in the description of the script.
- Rewritten the registry code for make it work on Win7 / WinServer 2008 R2 onwards.
- Add a pause to the end of the script so you could use "run with powershell" (right-click).
- Check current microcode version via [github api](https://github.com/platomav/CPUMicrocodes/tree/master/Intel).
  (actually intel only - I don't have an AMD to test)
- Color current bios state. (green=new / red=old).
- Trim zeros in front of CPUID.

#### On Powershell Execution Policy Error
`powershell -ExecutionPolicy bypass .\CPU-info.ps1`


## All Credits to Dimitri Delopoulos !
https://www.tenforums.com/drivers-hardware/106331-powershell-script-cpu-information-incl-cpuid.html
