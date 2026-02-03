@echo off
:: Batch wrapper for resolution adjustment using PowerShell
:: No complex multi-line symbols to ensure maximum compatibility with CMD

powershell -NoProfile -ExecutionPolicy Bypass -Command "$q=Get-Command qres.exe -ErrorAction SilentlyContinue; if(!$q){$q=Join-Path '%~dp0' 'qres.exe'}; if(!(Test-Path $q)){Write-Host 'QRes.exe not found'; exit}; $m=(&$q /L)[-1]; if($m -match '(\d+)x(\d+)') { $oW=$matches[1]; $oH=$matches[2]; $v=Get-WmiObject Win32_VideoController|Select -First 1; $cW=$v.CurrentHorizontalResolution; $cH=$v.CurrentVerticalResolution; $r=$cW/$cH; $s=16/9; $t=0.01; if([math]::Abs($r-$s) -lt $t){Start-Process $q \"/x:$oW /y:$oH\"} elseif($r -lt 9/16){$nH=[math]::Round($cW*16/9);Start-Process $q \"/x:$cW /y:$nH\"} elseif($r -lt 1){$nW=[math]::Round($cH*9/16);Start-Process $q \"/x:$nW /y:$cH\"} elseif($r -lt 16/9){$nH=[math]::Round($cW*9/16);Start-Process $q \"/x:$cW /y:$nH\"} else{$nW=[math]::Round($cH*16/9);Start-Process $q \"/x:$nW /y:$cH\"} } else {Write-Host 'Parse Error'}"

@REM pause