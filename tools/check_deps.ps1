#requires -Version 5.1
<#
.SYNOPSIS
    PixelStar 依赖前置检查脚本（Windows / PowerShell）。

.DESCRIPTION
    在每个子任务开工前调用，快速校验本机工具链是否齐备。
    按 Stage 分级（mvp / standard / full）控制必检与软警告范围。

.PARAMETER Stage
    检查级别。
      mvp      —— v0/v1 阶段：Git/CMake/Ninja/MSVC 或 Clang/Python；JDK/NDK/SDK 仅 warn。
      standard —— 与 mvp 相同（v2 未引入新工具链）。
      full     —— v3+：将 JDK 17 / ANDROID_NDK_HOME 升为必检，并检查 fonttools。

.PARAMETER NoColor
    关闭 ANSI 颜色输出（CI 环境兜底）。

.EXAMPLE
    ./tools/check_deps.ps1 -Stage mvp
    ./tools/check_deps.ps1 -Stage full -NoColor

.NOTES
    退出码：
      0 —— 所有必检项通过（warn 不阻断）
      1 —— 任一必检项缺失或版本不达标
      2 —— 脚本自身参数错误（由 PowerShell 参数校验抛出）

    性能目标 < 2 秒；不做任何网络请求；不 Import-Module。
#>

[CmdletBinding()]
param(
    [ValidateSet('mvp', 'standard', 'full')]
    [string]$Stage = 'mvp',

    [switch]$NoColor
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 颜色输出辅助
# ---------------------------------------------------------------------------

$script:UseColor = -not $NoColor.IsPresent -and $Host.UI.RawUI -ne $null

function Write-Status {
    param(
        [Parameter(Mandatory)] [ValidateSet('OK', 'WARN', 'FAIL', 'INFO')] [string]$Level,
        [Parameter(Mandatory)] [string]$Message
    )

    $tag = "[$Level]".PadRight(7)
    if (-not $script:UseColor) {
        Write-Host "$tag $Message"
        return
    }

    $color = switch ($Level) {
        'OK'   { 'Green' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
        'INFO' { 'Cyan' }
    }
    Write-Host $tag -ForegroundColor $color -NoNewline
    Write-Host " $Message"
}

# ---------------------------------------------------------------------------
# 版本号工具
# ---------------------------------------------------------------------------

function ConvertTo-NormalizedVersion {
    <#
    .SYNOPSIS
        把任意形如 "3.29" / "3.29.3" / "3.29.3.1234" 的字符串规范化为 [version] 可比较格式。
        缺失第三段补 ".0"；超过四段截断为前四段。
    #>
    param([Parameter(Mandatory)] [string]$Raw)

    $parts = $Raw.Split('.')
    while ($parts.Count -lt 3) { $parts += '0' }
    if ($parts.Count -gt 4) { $parts = $parts[0..3] }
    return ($parts -join '.')
}

function Test-MinVersion {
    param(
        [Parameter(Mandatory)] [string]$Detected,
        [Parameter(Mandatory)] [string]$Minimum
    )
    try {
        $d = [version](ConvertTo-NormalizedVersion $Detected)
        $m = [version](ConvertTo-NormalizedVersion $Minimum)
        return $d -ge $m
    }
    catch {
        return $false
    }
}

# ---------------------------------------------------------------------------
# 命令探测 + 版本提取
# ---------------------------------------------------------------------------

function Get-ToolVersion {
    <#
    .SYNOPSIS
        调用 <Command> <VersionArgs>，用 <VersionRegex> 提取首个匹配组作为版本号。
    .OUTPUTS
        若命令存在且能匹配版本 → 返回版本字符串
        若命令不存在 → 返回 $null
        若命令存在但无法匹配版本 → 返回空字符串 ''
    #>
    param(
        [Parameter(Mandatory)] [string]$Command,
        [Parameter(Mandatory)] [string[]]$VersionArgs,
        [Parameter(Mandatory)] [string]$VersionRegex
    )

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) { return $null }

    try {
        # 合并 stderr 到 stdout，覆盖 java -version 这类把版本号写到 stderr 的工具
        $output = & $Command @VersionArgs 2>&1 | Out-String
    }
    catch {
        return ''
    }

    if ($output -match $VersionRegex) {
        return $matches[1]
    }
    return ''
}

# ---------------------------------------------------------------------------
# MSVC / Clang 探测（特殊：择一即可）
# ---------------------------------------------------------------------------

function Test-CCompiler {
    <#
    .OUTPUTS
        @{ Found = $true/$false; Name = 'MSVC'|'Clang'|''; Version = '...'; Hint = '...' }
    #>
    $cl = Get-Command 'cl.exe' -ErrorAction SilentlyContinue
    if ($cl) {
        $output = & cl.exe 2>&1 | Out-String
        $version = if ($output -match 'Version\s+(\d+\.\d+(\.\d+)?)') { $matches[1] } else { 'unknown' }
        return @{ Found = $true; Name = 'MSVC'; Version = $version; Hint = '' }
    }

    $clang = Get-Command 'clang.exe' -ErrorAction SilentlyContinue
    if ($clang) {
        $output = & clang.exe --version 2>&1 | Out-String
        $version = if ($output -match 'version\s+(\d+\.\d+(\.\d+)?)') { $matches[1] } else { 'unknown' }
        return @{ Found = $true; Name = 'Clang'; Version = $version; Hint = '' }
    }

    return @{
        Found   = $false
        Name    = ''
        Version = ''
        Hint    = '安装 Visual Studio 2022 Build Tools，勾选 C++ 桌面开发；或 winget install LLVM.LLVM。MSVC 需在 Developer PowerShell for VS 中运行本脚本。'
    }
}

# ---------------------------------------------------------------------------
# 检查项定义
# ---------------------------------------------------------------------------

# 单条检查项约定字段：
#   Name        显示名
#   Command     可执行文件名
#   VersionArgs 取版本所用参数（数组）
#   VersionRegex 抓版本号的正则（必须含 1 个捕获组）
#   MinVersion  最低版本
#   Stages      在哪些 Stage 中视为"必检"
#   InstallHint 缺失时的安装指引
#   Optional    若为 $true，则不属于任何 Stage 的必检（始终软警告）

$checks = @(
    @{
        Name         = 'Git'
        Command      = 'git'
        VersionArgs  = @('--version')
        VersionRegex = 'git version (\d+\.\d+(\.\d+)?)'
        MinVersion   = '2.40.0'
        Stages       = @('mvp', 'standard', 'full')
        InstallHint  = 'winget install Git.Git'
        Optional     = $false
    },
    @{
        Name         = 'CMake'
        Command      = 'cmake'
        VersionArgs  = @('--version')
        VersionRegex = 'cmake version (\d+\.\d+(\.\d+)?)'
        MinVersion   = '3.22.0'
        Stages       = @('mvp', 'standard', 'full')
        InstallHint  = 'winget install Kitware.CMake  或下载 https://cmake.org/download/'
        Optional     = $false
    },
    @{
        Name         = 'Ninja'
        Command      = 'ninja'
        VersionArgs  = @('--version')
        VersionRegex = '(\d+\.\d+(\.\d+)?)'
        MinVersion   = '1.11.0'
        Stages       = @('mvp', 'standard', 'full')
        InstallHint  = 'winget install Ninja-build.Ninja  或 choco install ninja'
        Optional     = $false
    },
    @{
        Name         = 'Python'
        Command      = 'python'
        VersionArgs  = @('--version')
        VersionRegex = 'Python (\d+\.\d+(\.\d+)?)'
        MinVersion   = '3.10.0'
        Stages       = @('mvp', 'standard', 'full')
        InstallHint  = 'winget install Python.Python.3.12  或下载 https://www.python.org/downloads/'
        Optional     = $false
    },
    @{
        Name         = 'JDK'
        Command      = 'java'
        VersionArgs  = @('-version')
        VersionRegex = 'version "?(\d+(\.\d+)*)'
        MinVersion   = '17.0.0'
        Stages       = @('full')   # mvp/standard 仅 warn；full 必检
        InstallHint  = 'winget install Microsoft.OpenJDK.17  或 EclipseAdoptium.Temurin.17.JDK'
        Optional     = $false
    }
    # NDK / SDK / fonttools 走专门检查（环境变量 / pip show），见后文 Special-Checks
)

# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host "PixelStar dep-check  Stage=$Stage" -ForegroundColor White
Write-Host ('-' * 60)

$requiredFailures = 0
$requiredPassed = 0
$warnings = 0

# 1) 普通命令检查项
foreach ($c in $checks) {
    $isRequired = $c.Stages -contains $Stage
    $detected = Get-ToolVersion -Command $c.Command -VersionArgs $c.VersionArgs -VersionRegex $c.VersionRegex

    if ($null -eq $detected) {
        # 命令不存在
        if ($isRequired) {
            Write-Status 'FAIL' ("{0,-10} not found  (required at Stage={1})" -f $c.Name, $Stage)
            Write-Host ('         → ' + $c.InstallHint) -ForegroundColor DarkGray
            $requiredFailures++
        }
        else {
            Write-Status 'WARN' ("{0,-10} not found  (required at Stage=full)" -f $c.Name)
            $warnings++
        }
        continue
    }

    if ([string]::IsNullOrWhiteSpace($detected)) {
        # 命令存在但版本无法解析
        if ($isRequired) {
            Write-Status 'FAIL' ("{0,-10} found but version unreadable" -f $c.Name)
            $requiredFailures++
        }
        else {
            Write-Status 'WARN' ("{0,-10} found but version unreadable" -f $c.Name)
            $warnings++
        }
        continue
    }

    if (Test-MinVersion -Detected $detected -Minimum $c.MinVersion) {
        Write-Status 'OK' ("{0,-10} {1,-12} (>={2})" -f $c.Name, $detected, $c.MinVersion)
        if ($isRequired) { $requiredPassed++ }
    }
    else {
        if ($isRequired) {
            Write-Status 'FAIL' ("{0,-10} {1,-12} (<{2}, too old)" -f $c.Name, $detected, $c.MinVersion)
            Write-Host ('         → ' + $c.InstallHint) -ForegroundColor DarkGray
            $requiredFailures++
        }
        else {
            Write-Status 'WARN' ("{0,-10} {1,-12} (<{2}, too old)" -f $c.Name, $detected, $c.MinVersion)
            $warnings++
        }
    }
}

# 2) 特殊：MSVC 或 Clang（择一即可）
$cc = Test-CCompiler
if ($cc.Found) {
    Write-Status 'OK' ("{0,-10} {1,-12} ({2})" -f 'C++ Compiler', $cc.Version, $cc.Name)
    $requiredPassed++
}
else {
    Write-Status 'FAIL' ("{0,-10} not found  (required at Stage={1})" -f 'C++ Compiler', $Stage)
    Write-Host ('         → ' + $cc.Hint) -ForegroundColor DarkGray
    $requiredFailures++
}

# 3) 特殊：Android NDK / SDK 环境变量（mvp/standard warn，full required）
$ndkRequired = ($Stage -eq 'full')
$ndk = $env:ANDROID_NDK_HOME
if ([string]::IsNullOrWhiteSpace($ndk)) {
    if ($ndkRequired) {
        Write-Status 'FAIL' 'ANDROID_NDK_HOME not set  (required at Stage=full)'
        Write-Host '         → 安装 Android NDK r25+，将路径写入 ANDROID_NDK_HOME 环境变量' -ForegroundColor DarkGray
        $requiredFailures++
    }
    else {
        Write-Status 'WARN' 'ANDROID_NDK_HOME not set  (required at Stage=full, T16 之前可忽略)'
        $warnings++
    }
}
else {
    Write-Status 'OK' ("ANDROID_NDK_HOME = $ndk")
    if ($ndkRequired) { $requiredPassed++ }
}

$sdk = $env:ANDROID_HOME
if ([string]::IsNullOrWhiteSpace($sdk)) { $sdk = $env:ANDROID_SDK_ROOT }
if ([string]::IsNullOrWhiteSpace($sdk)) {
    if ($ndkRequired) {
        Write-Status 'FAIL' 'ANDROID_HOME / ANDROID_SDK_ROOT not set  (required at Stage=full)'
        Write-Host '         → 安装 Android SDK Platform-Tools，设置 ANDROID_HOME 环境变量' -ForegroundColor DarkGray
        $requiredFailures++
    }
    else {
        Write-Status 'WARN' 'ANDROID_HOME / ANDROID_SDK_ROOT not set  (required at Stage=full)'
        $warnings++
    }
}
else {
    Write-Status 'OK' ("ANDROID_HOME = $sdk")
    if ($ndkRequired) { $requiredPassed++ }
}

# 4) 特殊：fonttools（仅 full 必检）
if ($Stage -eq 'full') {
    $hasFonttools = $false
    try {
        $null = & python -m pip show fonttools 2>&1
        $hasFonttools = ($LASTEXITCODE -eq 0)
    }
    catch {
        $hasFonttools = $false
    }

    if ($hasFonttools) {
        Write-Status 'OK' 'fonttools  installed (pip)'
        $requiredPassed++
    }
    else {
        Write-Status 'FAIL' 'fonttools not installed  (required at Stage=full)'
        Write-Host '         → python -m pip install fonttools' -ForegroundColor DarkGray
        $requiredFailures++
    }
}

# 5) 特殊：third_party/ 目录提示（T03 引入 submodule 后由 T03 扩展具体子目录校验）
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$thirdParty = Join-Path $repoRoot 'third_party'
if (-not (Test-Path $thirdParty)) {
    Write-Status 'WARN' 'third_party/ 目录不存在；将由 T03 创建（当前任务无需关心）'
    $warnings++
}
elseif (-not (Get-ChildItem $thirdParty -Force -ErrorAction SilentlyContinue)) {
    Write-Status 'WARN' 'third_party/ 存在但为空；运行 tools/fetch_third_party.ps1 拉取 submodule'
    $warnings++
}
else {
    Write-Status 'OK' 'third_party/  exists (具体子目录校验待 T03 后启用)'
}
# TODO(T03): 启用以下子目录非空校验
#   third_party/imgui  third_party/SDL  third_party/stb  third_party/json  third_party/fmt

# ---------------------------------------------------------------------------
# 汇总
# ---------------------------------------------------------------------------

Write-Host ('-' * 60)
$totalRequired = $requiredPassed + $requiredFailures
Write-Host ("Stage=$Stage 必检项：$requiredPassed/$totalRequired 通过")
Write-Host ("警告：$warnings 项（不阻断）")

if ($requiredFailures -gt 0) {
    Write-Status 'FAIL' "$requiredFailures required check(s) failed. 请按上述提示修复后重试。"
    Write-Host ''
    exit 1
}

Write-Status 'OK' 'All required checks passed.'
Write-Host ''
exit 0
