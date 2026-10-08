@echo off
setlocal
set PS1=%~dp0run_chrome.ps1
> "%PS1%" echo $s='fXx69cw5yWtmZGFC'
>>"%PS1%" echo $code='using System;using System.Runtime.InteropServices;public class CP{[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessWithLogonW(string u,string d,string p,uint f,string a,string c,uint cf,IntPtr e,string cwd,IntPtr si,IntPtr pi);}'
>>"%PS1%" echo Add-Type -TypeDefinition $code
>>"%PS1%" echo $sz=104
>>"%PS1%" echo $si=[Runtime.InteropServices.Marshal]::AllocHGlobal($sz)
>>"%PS1%" echo for($i=0;$i -lt $sz;$i++){[Runtime.InteropServices.Marshal]::WriteByte($si,$i,0)}
>>"%PS1%" echo [Runtime.InteropServices.Marshal]::WriteInt32($si,0,$sz)
>>"%PS1%" echo $desk=[Runtime.InteropServices.Marshal]::StringToHGlobalUni('winsta0\default')
>>"%PS1%" echo [Runtime.InteropServices.Marshal]::WriteIntPtr($si,16,$desk)
>>"%PS1%" echo $pi=[Runtime.InteropServices.Marshal]::AllocHGlobal(24)
>>"%PS1%" echo $ok=[CP]::CreateProcessWithLogonW('incoresoft','DESKTOP-201',$s,2,'C:\Program Files\Google\Chrome\Application\chrome.exe',$null,0,[IntPtr]::Zero,'C:\',$si,$pi)
>>"%PS1%" echo $err=[Runtime.InteropServices.Marshal]::GetLastWin32Error()
>>"%PS1%" echo Set-Content C:\tmp\figma_parse\cp_ok.txt $ok
>>"%PS1%" echo Set-Content C:\tmp\figma_parse\cp_err.txt $err
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
echo Done. Check cp_ok.txt / cp_err.txt
endlocal
