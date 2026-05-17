@echo off
:: Batch wrapper for resolution adjustment using PowerShell with argument parsing
:: No complex multi-line symbols to ensure maximum compatibility with CMD

set "MODE=default"
if "%~1"=="--start" set "MODE=start"
if "%~1"=="-s"      set "MODE=start"
if "%~1"=="--end"   set "MODE=end"
if "%~1"=="-e"      set "MODE=end"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$q=Get-Command qres.exe -ErrorAction SilentlyContinue; if(!$q){$q=Join-Path '%~dp0' 'qres.exe'}; if(!(Test-Path $q)){Write-Host 'QRes.exe not found'; exit}; $m=(&$q /L)[-1]; if($m -match '(\d+)x(\d+)') { $oW=$matches[1]; $oH=$matches[2]; $v=Get-WmiObject Win32_VideoController|Select -First 1; $cW=$v.CurrentHorizontalResolution; $cH=$v.CurrentVerticalResolution; $r=$cW/$cH; $s=16/9; $t=0.01; $mode='%MODE%'; if($mode -eq 'end'){Start-Process $q \"/x:$oW /y:$oH\"; exit}; if($mode -eq 'start'){ if([math]::Abs($r-$s) -lt $t -or [math]::Abs($r-1/$s) -lt $t){ exit } elseif($r -ge 1){ if($r -gt $s){ $nW=[math]::Round($cH*16/9); Start-Process $q \"/x:$nW /y:$cH\" } else { $nH=[math]::Round($cW*9/16); Start-Process $q \"/x:$cW /y:$nH\" } } else { $nH=[math]::Round($cW*16/9); Start-Process $q \"/x:$cW /y:$nH\" }; exit }; if([math]::Abs($r-$s) -lt $t){Start-Process $q \"/x:$oW /y:$oH\"} elseif($r -lt 9/16){$nH=[math]::Round($cW*16/9);Start-Process $q \"/x:$cW /y:$nH\"} elseif($r -lt 1){$nW=[math]::Round($cH*9/16);Start-Process $q \"/x:$nW /y:$cH\"} elseif($r -lt 16/9){$nH=[math]::Round($cW*9/16);Start-Process $q \"/x:$cW /y:$nH\"} else{$nW=[math]::Round($cH*16/9);Start-Process $q \"/x:$nW /y:$cH\"} } else {Write-Host 'Parse Error'}"

@REM pause