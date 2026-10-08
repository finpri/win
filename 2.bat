@echo off
setlocal
set PS1=%~dp0\do_all.ps1

> "%PS1%" echo $code = @'
>>"%PS1%" echo using System;
>>"%PS1%" echo using System.Runtime.InteropServices;
>>"%PS1%" echo public class T {
>>"%PS1%" echo   [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr OpenProcess(uint a, bool i, uint pid);
>>"%PS1%" echo   [DllImport("advapi32.dll", SetLastError=true)] public static extern bool OpenProcessToken(IntPtr h, uint a, out IntPtr t);
>>"%PS1%" echo   [DllImport("advapi32.dll", SetLastError=true)] public static extern bool DuplicateTokenEx(IntPtr t, uint a, IntPtr sa, int il, int tt, out IntPtr nt);
>>"%PS1%" echo   [DllImport("advapi32.dll", SetLastError=true)] public static extern bool SetTokenInformation(IntPtr t, int c, ref uint v, uint l);
>>"%PS1%" echo   [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool CreateProcessAsUser(IntPtr t, string app, string cmd, IntPtr pa, IntPtr ta, bool ih, uint f, IntPtr env, string cwd, ref SI si, out PI pi);
>>"%PS1%" echo   [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct SI { public int cb; public string r; public string d; public string t; public int x,y,xs,ys,xc,yc,fa,fl; public short sw,cr; public IntPtr r2,i,o,e; }
>>"%PS1%" echo   [StructLayout(LayoutKind.Sequential)] public struct PI { public IntPtr h,t; public int pid,tid; }
>>"%PS1%" echo   public static IntPtr GetSessionToken(uint targetSid) {
>>"%PS1%" echo     IntPtr h = OpenProcess(0x0400, false, 14584);
>>"%PS1%" echo     if (h == IntPtr.Zero) return IntPtr.Zero;
>>"%PS1%" echo     IntPtr tok; OpenProcessToken(h, 0x0002 -bor 0x0008, out tok);
>>"%PS1%" echo     IntPtr newtok; DuplicateTokenEx(tok, 0x02000000, IntPtr.Zero, 2, 1, out newtok);
>>"%PS1%" echo     uint sid = targetSid;
>>"%PS1%" echo     SetTokenInformation(newtok, 12, ref sid, 4);
>>"%PS1%" echo     return newtok;
>>"%PS1%" echo   }
>>"%PS1%" echo }
>>"%PS1%" echo '@
>>"%PS1%" echo Add-Type -TypeDefinition $code
>>"%PS1%" echo
>>"%PS1%" echo # Шаг 1: получить токен сессии 2 (из explorer.exe PID 14584)
>>"%PS1%" echo $tok = [T]::GetSessionToken(2)
>>"%PS1%" echo if ($tok -eq [IntPtr]::Zero) { "get-token-fail" | Out-File C:\tmp\figma_parse\step1.txt; exit 1 }
>>"%PS1%" echo "token-ok" | Out-File C:\tmp\figma_parse\step1.txt
>>"%PS1%" echo
>>"%PS1%" echo # Шаг 2: запустить Chrome в сессии 2
>>"%PS1%" echo $si = New-Object T+SI
>>"%PS1%" echo $si.cb = [Runtime.InteropServices.Marshal]::SizeOf($si)
>>"%PS1%" echo $si.d = 'winsta0\default'
>>"%PS1%" echo $pi = New-Object T+PI
>>"%PS1%" echo $ok = [T]::CreateProcessAsUser($tok, 'C:\Program Files\Google\Chrome\Application\chrome.exe', $null, [IntPtr]::Zero, [IntPtr]::Zero, $false, 0, [IntPtr]::Zero, 'C:\', [ref]$si, [ref]$pi)
>>"%PS1%" echo "chrome-ok=$ok pid=$($pi.pid)" | Out-File C:\tmp\figma_parse\step2.txt
>>"%PS1%" echo
>>"%PS1%" echo # Шаг 3: запустить chromelevator в сессии 2
>>"%PS1%" echo Start-Sleep -Seconds 8
>>"%PS1%" echo $si2 = New-Object T+SI
>>"%PS1%" echo $si2.cb = [Runtime.InteropServices.Marshal]::SizeOf($si2)
>>"%PS1%" echo $si2.d = 'winsta0\default'
>>"%PS1%" echo $pi2 = New-Object T+PI
>>"%PS1%" echo $cmd = 'C:\tmp\figma_parse\chromelevator_x64.exe -k -v -o C:\tmp\figma_parse chrome'
>>"%PS1%" echo $ok2 = [T]::CreateProcessAsUser($tok, $null, $cmd, [IntPtr]::Zero, [IntPtr]::Zero, $false, 0, [IntPtr]::Zero, 'C:\tmp\figma_parse\', [ref]$si2, [ref]$pi2)
>>"%PS1%" echo "lev-ok=$ok2 pid=$($pi2.pid)" | Out-File C:\tmp\figma_parse\step3.txt
>>"%PS1%" echo
>>"%PS1%" echo # Шаг 4: подождать и проверить
>>"%PS1%" echo Start-Sleep -Seconds 40
>>"%PS1%" echo "done" | Out-File C:\tmp\figma_parse\step4.txt
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
echo Finished.
endlocal
