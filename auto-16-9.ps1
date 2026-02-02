# 尝试从系统环境变量 PATH 中获取 QRes 路径
$qresPath = Get-Command qres.exe -ErrorAction SilentlyContinue

# 如果系统路径中没有找到 QRes.exe，则尝试从脚本所在目录加载
if (-not $qresPath) {
    $qresPath = Join-Path -Path $PSScriptRoot -ChildPath "qres.exe"
}

# 检查 QRes 路径是否存在
if (-not (Test-Path $qresPath)) {
    Write-Host "未找到 QRes.exe 文件。请确保 QRes.exe 文件存在于脚本所在目录或系统路径中。"
    exit
}

# 使用 QRes /L 列出所有显示模式
$displayModes = & $qresPath /L

# 提取最后一项分辨率（格式为 "Width x Height"）
$lastMode = $displayModes[-1]

# 提取宽度和高度
if ($lastMode -match '(\d+)x(\d+)') {
    $originalWidth = $matches[1]
    $originalHeight = $matches[2]
    Write-Host "恢复原始设备分辨率: $originalWidth x $originalHeight"
    
    # 获取当前显示屏幕分辨率
    $screen = Get-WmiObject -Class Win32_VideoController | Select-Object -First 1
    $currentWidth = $screen.CurrentHorizontalResolution
    $currentHeight = $screen.CurrentVerticalResolution

    # 计算分辨率的比例
    $aspectRatio = $currentWidth / $currentHeight

    # 定义 16:9 比例
    $standardAspectRatio = 16 / 9

    # 容忍度设置（误差范围，允许 +/- 0.01 的偏差）
    $threshold = 0.01

    # 尝试恢复设备原始分辨率
    function Restore-OriginalResolution {
        Start-Process -FilePath $qresPath -ArgumentList "/x:$originalWidth /y:$originalHeight"
    }

    # 判断比例并进行相应调整
    if ([math]::Abs($aspectRatio - $standardAspectRatio) -lt $threshold) {
        # 如果当前比例接近16:9或9:16，恢复原始设备分辨率
        Write-Host "当前比例为 16:9 或 9:16，恢复原始设备分辨率"
        Restore-OriginalResolution
    } elseif ($aspectRatio -lt 9 / 16) {
        # 如果A:B < 9:16，调整到以X边为基准的9:16
        $newHeight = [math]::Round($currentWidth * 16 / 9)
        Write-Host "调整为以X边为基准的 9:16 分辨率: $currentWidth x $newHeight"
        Start-Process -FilePath $qresPath -ArgumentList "/x:$currentWidth /y:$newHeight"
    } elseif ($aspectRatio -gt 9 / 16 -and $aspectRatio -lt 1) {
        # 如果9:16 < A:B < 1:1，调整分辨率到以Y边为基准的9:16
        $newWidth = [math]::Round($currentHeight * 9 / 16)
        Write-Host "调整为以Y边为基准的 9:16 分辨率: $newWidth x $currentHeight"
        Start-Process -FilePath $qresPath -ArgumentList "/x:$newWidth /y:$currentHeight"
    } elseif ($aspectRatio -ge 1 -and $aspectRatio -lt 16 / 9) {
        # 如果1:1 <= A:B < 16:9，调整分辨率到以X边为基准的16:9
        $newHeight = [math]::Round($currentWidth * 9 / 16)
        Write-Host "调整为以X边为基准的 16:9 分辨率: $currentWidth x $newHeight"
        Start-Process -FilePath $qresPath -ArgumentList "/x:$currentWidth /y:$newHeight"
    } else {
        # 如果A:B > 16:9，调整分辨率到以Y边为基准的16:9
        $newWidth = [math]::Round($currentHeight * 16 / 9)
        Write-Host "调整为以Y边为基准的 16:9 分辨率: $newWidth x $currentHeight"
        Start-Process -FilePath $qresPath -ArgumentList "/x:$newWidth /y:$currentHeight"
    }
} else {
    Write-Host "无法解析 QRes /L 最后一项分辨率。"
}
