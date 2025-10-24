# Script to get CPU information
# (c) 2019. Dimitri Delopoulos
# v2.6, 26/01/2022 

<########## Release history ##########
Version 1.0 (19-Mar-2018)
Initial release

Version 1.5 (31-Aug-2018)
Added currently running microcode revision and BIOS/UEFI CPU microcode revision

Version 2.0 (15-Feb-2019)
1. Updated "CPU Family" and "Upgrade Method" to include new products, according to the latest DMTF version CIM_schema_2.51.0
2. Changed microcode prompts to more meaningful ones:
    - Running microcode revision
    - BIOS/UEFI CPU microcode revision *** Removed in Version 2.2 ***
3. Added check for microcode revision and outputs if the microcode is loaded by the current OS or BIOS/UEFI. *** Removed in Version 2.2 ***
4. Added check for boot mode (Legacy BIOS or UEFI)
5. Added BIOS/UEFI information 

Version 2.1 (06-Mar-2019) 
1. Added Computer model
2. Added DisplayFamily and DisplayModel signatures, to accomodate verification of Retpoline mitigation
3. Fixed bug, on Legacy BIOS systems

Version 2.2 (25-Mar-2019) 
To avoid misconceptions and unreliable/confusing results in some devices and since there is no accurate process, to get via PowerShell, the BIOS/UEFI firmware 
microcode revision, the script will only output the currently Running microcode revision, which is loaded at boot time, either by BIOS/UEFI or by Windows 10.

Version 2.3 (29-May-2019) 
Fixed a bug, which was causing microcode revision to be read incorrectly.

Version 2.4 (06-Jun-2019) 
1. Changed the way "Display Family", "Display Model" and "Stepping' are read, based on Intel and AMD CPUID algorithm (0FFM0FMS).
   (F+F+F to HEX, to accomodate AMD "Display Family" notation)
2. Fixed a bug, which was causing AMD processors "Display Family" to be read incorrectly.
3. Added Processor signature, for selecting the correct microcode update file, in case the user wants to apply microcode updates manually.
4. Reverted the change of v2.2 and added Disclaimer when Registry value is incorrectly updated, to notify the user of BIOS/UEFI microcode revision validity.

Version 2.5 (03-Mar-2020)
1. Fixed an issue with the detection of firmware type (BIOS/UEFI). Thanks to Mike (mta3006) for his help.
2. Fixed microcode loader and disclaimer presentation algorithm.
3. Fixed output of firmware data.

Version 2.5.1 (04-Mar-2020)
Fixed an issue of microcode revision in AMD systems and/or Windows 7

Version 2.6 (26-Jan-2022)
1. Verified compatibility to Windows 11
2. Updated CPU Family and Upgrade Method lists from the latest (v.2.53.0) DMTF schema

#>

# 'ProcessorType' value from: https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-processor

$CPU_Type = DATA {ConvertFrom-StringData -StringData @’
1 = Other
2 = Unknown
3 = Central Processor
4 = Math Processor
5 = DSP Processor
6 = Video Processor
‘@}

# 'Architecture' value from: https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/win32-processor

$CPU_Architecture = DATA {ConvertFrom-StringData -StringData @’
0 = x86
1 = MIPS
2 = Alpha
3 = PowerPC
5 = ARM
6 = ia64
9 = x64
‘@}

# 'Family' value from: http://schemas.dmtf.org/wbem/cim-html/2.53.0/CIM_ArchitectureCheck.html

$CPU_Family = DATA {ConvertFrom-StringData -StringData @’
1 = Other
2 = Unknown
3 = 8086
4 = 80286
5 = 80386
6 = 80486
7 = 8087
8 = 80287
9 = 80387
10 = 80487
11 = Pentium(R) brand
12 = Pentium(R) Pro
13 = Pentium(R) II
14 = Pentium(R) processor with MMX(TM) technology
15 = Celeron(TM)
16 = Pentium(R) II Xeon(TM)
17 = Pentium(R) III
18 = M1 Family
19 = M2 Family
20 = Intel(R) Celeron(R) M processor
21 = Intel(R) Pentium(R) 4 HT processor
24 = K5 Family
25 = K6 Family
26 = K6-2
27 = K6-3
28 = AMD Athlon(TM) Processor Family
29 = AMD(R) Duron(TM) Processor
30 = AMD29000 Family
31 = K6-2+
32 = Power PC Family
33 = Power PC 601
34 = Power PC 603
35 = Power PC 603+
36 = Power PC 604
37 = Power PC 620
38 = Power PC X704
39 = Power PC 750
40 = Intel(R) Core(TM) Duo processor
41 = Intel(R) Core(TM) Duo mobile processor
42 = Intel(R) Core(TM) Solo mobile processor
43 = Intel(R) Atom(TM) processor
44 = Intel(R) Core(TM) M processor
45 = Intel(R) Core(TM) m3 processor
46 = Intel(R) Core(TM) m5 processor
47 = Intel(R) Core(TM) m7 processor
48 = Alpha Family
49 = Alpha 21064
50 = Alpha 21066
51 = Alpha 21164
52 = Alpha 21164PC
53 = Alpha 21164a
54 = Alpha 21264
55 = Alpha 21364
56 = AMD Turion(TM) II Ultra Dual-Core Mobile M Processor Family
57 = AMD Turion(TM) II Dual-Core Mobile M Processor Family
58 = AMD Athlon(TM) II Dual-Core Mobile M Processor Family
59 = AMD Opteron(TM) 6100 Series Processor
60 = AMD Opteron(TM) 4100 Series Processor
61 = AMD Opteron(TM) 6200 Series Processor
62 = AMD Opteron(TM) 4200 Series Processor
63 = AMD FX(TM) Series Processor
64 = MIPS Family
65 = MIPS R4000
66 = MIPS R4200
67 = MIPS R4400
68 = MIPS R4600
69 = MIPS R10000
70 = AMD C-Series Processor
71 = AMD E-Series Processor
72 = AMD A-Series Processor
73 = AMD G-Series Processor
74 = AMD Z-Series Processor
75 = AMD R-Series Processor
76 = AMD Opteron(TM) 4300 Series Processor
77 = AMD Opteron(TM) 6300 Series Processor
78 = AMD Opteron(TM) 3300 Series Processor
79 = AMD FirePro(TM) Series Processor
80 = SPARC Family
81 = SuperSPARC
82 = microSPARC II
83 = microSPARC IIep
84 = UltraSPARC
85 = UltraSPARC II
86 = UltraSPARC IIi
87 = UltraSPARC III
88 = UltraSPARC IIIi
96 = 68040
97 = 68xxx Family
98 = 68000
99 = 68010
100 = 68020
101 = 68030
102 = AMD Athlon(TM) X4 Quad-Core Processor Family
103 = AMD Opteron(TM) X1000 Series Processor
104 = AMD Opteron(TM) X2000 Series APU
105 = AMD Opteron(TM) A-Series Processor
106 = AMD Opteron(TM) X3000 Series APU
107 = AMD Zen Processor Family
112 = Hobbit Family
120 = Crusoe(TM) TM5000 Family
121 = Crusoe(TM) TM3000 Family
122 = Efficeon(TM) TM8000 Family
128 = Weitek
130 = Itanium(TM) Processor
131 = AMD Athlon(TM) 64 Processor Family
132 = AMD Opteron(TM) Processor Family
133 = AMD Sempron(TM) Processor Family
134 = AMD Turion(TM) 64 Mobile Technology
135 = Dual-Core AMD Opteron(TM) Processor Family
136 = AMD Athlon(TM) 64 X2 Dual-Core Processor Family
137 = AMD Turion(TM) 64 X2 Mobile Technology
138 = Quad-Core AMD Opteron(TM) Processor Family
139 = Third-Generation AMD Opteron(TM) Processor Family
140 = AMD Phenom(TM) FX Quad-Core Processor Family
141 = AMD Phenom(TM) X4 Quad-Core Processor Family
142 = AMD Phenom(TM) X2 Dual-Core Processor Family
143 = AMD Athlon(TM) X2 Dual-Core Processor Family
144 = PA-RISC Family
145 = PA-RISC 8500
146 = PA-RISC 8000
147 = PA-RISC 7300LC
148 = PA-RISC 7200
149 = PA-RISC 7100LC
150 = PA-RISC 7100
160 = V30 Family
161 = Quad-Core Intel(R) Xeon(R) processor 3200 Series
162 = Dual-Core Intel(R) Xeon(R) processor 3000 Series
163 = Quad-Core Intel(R) Xeon(R) processor 5300 Series
164 = Dual-Core Intel(R) Xeon(R) processor 5100 Series
165 = Dual-Core Intel(R) Xeon(R) processor 5000 Series
166 = Dual-Core Intel(R) Xeon(R) processor LV
167 = Dual-Core Intel(R) Xeon(R) processor ULV
168 = Dual-Core Intel(R) Xeon(R) processor 7100 Series
169 = Quad-Core Intel(R) Xeon(R) processor 5400 Series
170 = Quad-Core Intel(R) Xeon(R) processor
171 = Dual-Core Intel(R) Xeon(R) processor 5200 Series
172 = Dual-Core Intel(R) Xeon(R) processor 7200 Series
173 = Quad-Core Intel(R) Xeon(R) processor 7300 Series
174 = Quad-Core Intel(R) Xeon(R) processor 7400 Series
175 = Multi-Core Intel(R) Xeon(R) processor 7400 Series
176 = Pentium(R) III Xeon(TM)
177 = Pentium(R) III Processor with Intel(R) SpeedStep(TM) Technology
178 = Pentium(R) 4
179 = Intel(R) Xeon(TM)
180 = AS400 Family
181 = Intel(R) Xeon(TM) processor MP
182 = AMD Athlon(TM) XP Family
183 = AMD Athlon(TM) MP Family
184 = Intel(R) Itanium(R) 2
185 = Intel(R) Pentium(R) M processor
186 = Intel(R) Celeron(R) D processor
187 = Intel(R) Pentium(R) D processor
188 = Intel(R) Pentium(R) Processor Extreme Edition
189 = Intel(R) Core(TM) Solo Processor
190 = K7
191 = Intel(R) Core(TM)2 Duo Processor
192 = Intel(R) Core(TM)2 Solo processor
193 = Intel(R) Core(TM)2 Extreme processor
194 = Intel(R) Core(TM)2 Quad processor
195 = Intel(R) Core(TM)2 Extreme mobile processor
196 = Intel(R) Core(TM)2 Duo mobile processor
197 = Intel(R) Core(TM)2 Solo mobile processor
198 = Intel(R) Core(TM) i7 processor
199 = Dual-Core Intel(R) Celeron(R) Processor
200 = S/390 and zSeries Family
201 = ESA/390 G4
202 = ESA/390 G5
203 = ESA/390 G6
204 = z/Architectur base
205 = Intel(R) Core(TM) i5 processor
206 = Intel(R) Core(TM) i3 processor
207 = Intel(R) Core(TM) i9 processor
210 = VIA C7(TM)-M Processor Family
211 = VIA C7(TM)-D Processor Family
212 = VIA C7(TM) Processor Family
213 = VIA Eden(TM) Processor Family
214 = Multi-Core Intel(R) Xeon(R) processor
215 = Dual-Core Intel(R) Xeon(R) processor 3xxx Series
216 = Quad-Core Intel(R) Xeon(R) processor 3xxx Series
217 = VIA Nano(TM) Processor Family
218 = Dual-Core Intel(R) Xeon(R) processor 5xxx Series
219 = Quad-Core Intel(R) Xeon(R) processor 5xxx Series
221 = Dual-Core Intel(R) Xeon(R) processor 7xxx Series
222 = Quad-Core Intel(R) Xeon(R) processor 7xxx Series
223 = Multi-Core Intel(R) Xeon(R) processor 7xxx Series
224 = Multi-Core Intel(R) Xeon(R) processor 3400 Series
228 = AMD Opteron(TM) 3000 Series Processor
229 = AMD Sempron(TM) II Processor Family
230 = Embedded AMD Opteron(TM) Quad-Core Processor Family
231 = AMD Phenom(TM) Triple-Core Processor Family
232 = AMD Turion(TM) Ultra Dual-Core Mobile Processor Family
233 = AMD Turion(TM) Dual-Core Mobile Processor Family
234 = AMD Athlon(TM) Dual-Core Processor Family
235 = AMD Sempron(TM) SI Processor Family
236 = AMD Phenom(TM) II Processor Family
237 = AMD Athlon(TM) II Processor Family
238 = Six-Core AMD Opteron(TM) Processor Family
239 = AMD Sempron(TM) M Processor Family
250 = i860
251 = i960
254 = Reserved (SMBIOS Extension)
255 = Reserved (Un-initialized Flash Content - Lo)
256 = ARMv7
257 = ARMv8
260 = SH-3
261 = SH-4
280 = ARM
281 = StrongARM
300 = 6x86
301 = MediaGX
302 = MII
320 = WinChip
350 = DSP
500 = Video Processor
512 = RISC-V RV32
513 = RISC-V RV64
514 = RISC-V RV128
65534 = Reserved (For Future Special Purpose Assignment)
65535 = Reserved (Un-initialized Flash Content - Hi)
‘@}

# 'UpgradeMethod' value from: http://schemas.dmtf.org/wbem/cim-html/2.53.0/CIM_Processor.html

$CPU_UpgradeMethod = DATA {ConvertFrom-StringData -StringData @’
1 = Other
2 = Unknown
3 = Daughter Board
4 = ZIF Socket
5 = Replacement/Piggy Back
6 = None
7 = LIF Socket
8 = Slot 1
9 = Slot 2
10 = 370 Pin Socket
11 = Slot A
12 = Slot M
13 = Socket 423
14 = Socket A (Socket 462)
15 = Socket 478
16 = Socket 754
17 = Socket 940
18 = Socket 939
19 = Socket mPGA604
20 = Socket LGA771
21 = Socket LGA775
22 = Socket S1
23 = Socket AM2
24 = Socket F (1207)
25 = Socket LGA1366
26 = Socket G34
27 = Socket AM3
28 = Socket C32
29 = Socket LGA1156
30 = Socket LGA1567
31 = Socket PGA988A
32 = Socket BGA1288
33 = rPGA988B
34 = BGA1023
35 = BGA1224
36 = LGA1155
37 = LGA1356
38 = LGA2011
39 = Socket FS1
40 = Socket FS2
41 = Socket FM1
42 = Socket FM2
43 = Socket LGA2011-3
44 = Socket LGA1356-3
45 = Socket LGA1150
46 = Socket BGA1168
47 = Socket BGA1234
48 = Socket BGA1364
49 = Socket AM4
50 = Socket LGA1151
51 = Socket BGA1356
52 = Socket BGA1440
53 = Socket BGA1515
54 = Socket LGA3647-1
55 = Socket SP3
56 = Socket SP3r2
57 = Socket LGA2066
58 = Socket BGA1392
59 = Socket BGA1510
60 = Socket BGA1528
‘@}

Write-Output "`nCPU-info [Version 2.6] © 2022 Dimitri Delopoulos"

$PCModel = (Get-CimInstance -Class Win32_ComputerSystem).Model

$CIMCPU = Get-CimInstance -Class CIM_Processor | Select-Object SystemName, Manufacturer, Name, 
Description, NumberOfCores, NumberOfLogicalProcessors, CurrentClockSpeed, SocketDesignation, 
@{L=”ProcessorType”;E={$CPU_Type["$($_.ProcessorType)"]}}, 
@{L=”CPUFamily”;E={$CPU_Family["$($_.Family)"]}}, 
@{L=”CPUArchitecture”;E={$CPU_Architecture["$($_.Architecture)"]}},
@{L=”UpgradeMethod”;E={$CPU_UpgradeMethod["$($_.UpgradeMethod)"]}},
@{L="CPUID"; E={$_.ProcessorID.substring(8,8)}},
@{L="DisplayFamily"; E={([String]::Format("{0:x2}", ([Convert]::ToInt64(($_.ProcessorID.substring(8,8)).Substring(1,1),16) + 
                                                     [Convert]::ToInt64(($_.ProcessorID.substring(8,8)).Substring(2,1),16) + 
                                                     [Convert]::ToInt64(($_.ProcessorID.substring(8,8)).Substring(5,1),16)))).ToUpper()}}, ### 0FFM0FMS (F+F+F)

@{L="DisplayModel";  E={($_.ProcessorID.substring(8,8)).Substring(3,1), ($_.ProcessorID.substring(8,8)).Substring(6,1) -join ''}},         ### 0FFM0FMS 
@{L="Stepping";      E={($_.ProcessorID.substring(8,8)).Substring(7,1)}}                                                                   ### 0FFM0FMS

$CPUInfo = [PSCustomObject]@{
    "Computer Model" = $PCModel
    "Computer Name" = $CIMCPU.SystemName
    "Processor Type" = $CIMCPU.ProcessorType
    "Manufacturer" = $CIMCPU.Manufacturer
    "CPU Family" = $CIMCPU.CPUFamily
    "CPU Architecture" = $CIMCPU.CPUArchitecture
    "Name" = $CIMCPU.Name
    "Description" = $CIMCPU.Description
    "Number of Cores" = $CIMCPU.NumberOfCores
    "Number of Logical Processors" = $CIMCPU.NumberOfLogicalProcessors
    "Current Clock Speed" = $CIMCPU.CurrentClockSpeed
    "Socket Designation" = $CIMCPU.SocketDesignation
    "Upgrade Method" = $CIMCPU.UpgradeMethod
    "CPUID" = $CIMCPU.CPUID
    "Display Family" = $CIMCPU.DisplayFamily, "H" -join ''
    "Display Model" = $CIMCPU.DisplayModel, "H" -join ''
    "Processor Signature" = $CIMCPU.DisplayFamily, $CIMCPU.DisplayModel, $CIMCPU.Stepping -join '-'
    }

$CPUInfo

# Find the system's firmware type
$bcdeditOutput = & "$env:windir\System32\bcdedit.exe"
if ($bcdeditOutput -like "*winload.efi*") { $FirmwareType = "UEFI" }
else { $FirmwareType = "Legacy BIOS" }

<# Find the system's firmware type - Method 2
if ($env:Firmware_Type -eq "UEFI") { $FirmwareType = "UEFI" }
else { $FirmwareType = "Legacy BIOS" }
#>

# Find the currently running CPU microcode revision
$CPURegistryPath = "Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0\"

$RunningMicrocode = ((Get-ItemProperty -Path $CPURegistryPath)."Update Revision")[0..4] -join ''
$RunningMicrocodeHEX = ([String]::Format("{0:x2}", [int]($RunningMicrocode.ToString()).TrimStart('0'))).ToUpper()

# Find the BIOS/UEFI CPU microcode revision (not reliable for all devices)
$BIOSMicrocode = ((Get-ItemProperty -Path $CPURegistryPath)."Previous Update Revision")[0..4] -join ''
$BIOSMicrocodeHEX = ([String]::Format("{0:x2}", [int]($BIOSMicrocode.ToString()).TrimStart('0'))).ToUpper()

# Get the BIOS information
$BIOSInfo = Get-CimInstance Win32_BIOS | select Name, Manufacturer, SerialNumber, ReleaseDate

# Decide if the the currently running microcode is loaded by the OS or by the firmware
$OS = (Get-CimInstance Win32_OperatingSystem).Caption
$BIOSUpdateDate = $BIOSInfo.ReleaseDate
if ($CIMCPU.Name -like "*Intel*") { 
    $OSMicrocodeUpdateDate = (Get-ChildItem $env:windir\System32\mcupdate_GenuineIntel.dll).LastWriteTime
}
else { 
    $OSMicrocodeUpdateDate = (Get-ChildItem $env:windir\System32\mcupdate_AuthenticAMD.dll).LastWriteTime
}

$MicrocodeLoader = "(loaded by $OS)"
$Disclaimer = $false
if ($RunningMicrocodeHEX -eq $BIOSMicrocodeHEX) { 
    if ($BIOSUpdateDate -gt (Get-Date "2018-01-01")) { 
        $MicrocodeLoader = "(loaded by $FirmwareType)"
    }
    else {
        $Disclaimer = $true
        if ($BIOSUpdateDate -gt $OSMicrocodeUpdateDate) {
            $MicrocodeLoader = "(loaded by $FirmwareType)"
            $Disclaimer = $false
        }
    }
}

# Output the CPU Microcode currently running on the system
Write-Output "$('Running microcode revision'.PadRight(29)): 0x$RunningMicrocodeHEX $MicrocodeLoader"

# Output the CPU microcode provided by the Manufacturer with a BIOS/UEFI update
if ($Disclaimer) { Write-Output "$(($FirmwareType.Substring($FirmwareType.Length-4,4) + " CPU microcode revision*").PadRight(29)): 0x$BIOSMicrocodeHEX" }
else { Write-Output "$(($FirmwareType.Substring($FirmwareType.Length-4,4) + " CPU microcode revision").PadRight(29)): 0x$BIOSMicrocodeHEX" }

$BIOSAge = ((Get-Date) - $BIOSUpdateDate).Days
$FirmwareOutput1 = "Boot Mode".PadRight(29) + ": " + $FirmwareType
$FirmwareOutput2 = "$FirmwareType Version".PadRight(29) + ": " + $BIOSInfo.Name
$FirmwareOutput3 = "$FirmwareType Manufacturer".PadRight(29) + ": " + $BIOSInfo.Manufacturer
$FirmwareOutput4 = "$FirmwareType Serial Number".PadRight(29) + ": " + $BIOSInfo.SerialNumber
$FirmwareOutput5 = "$FirmwareType Release Date".PadRight(29) + ": " + $(Get-Date ($BIOSUpdateDate) -Format d) + $(" ($BIOSAge", "days ago)")

Write-Output ""
$FirmwareOutput1
$FirmwareOutput2
$FirmwareOutput3
$FirmwareOutput4
$FirmwareOutput5

$DisclaimerText = "* DISCLAIMER: 
  The $($FirmwareType.Substring($FirmwareType.Length-4,4)) CPU microcode revision shown, is the value retrieved from the 
  system's Registry, FOR INFORMATIONAL PURPOSES ONLY. 
  The actual $($FirmwareType.Substring($FirmwareType.Length-4,4)) microcode revision is stored in the firmware's MSR, at 
  address 08BH (IA32_BIOS_SIGN_ID). The RDMSR command, needed to read the 
  actual value from the EDX register, cannot be run from within Windows. 
  So if, for any reason, the Registry value has been set incorrectly, the 
  shown firmware microcode revision will be different from the actual one."

if ($Disclaimer) { Write-Output ("-" * 74)"$DisclaimerText" }
