#requires -Version 5.1
<#
.SYNOPSIS
    PixelStar 第三方库拉取/更新脚本：包装 git submodule update --init --recursive。

.DESCRIPTION
    在 .gitmodules 不存在时优雅 no-op（exit 0），打印友好提示。
    .gitmodules 存在时执行递归 submodule 更新。
    不预拉任何具体库；具体库列表由 T03 引入 .gitmodules 时定义。

.PARAMETER Force
    传给 `git submodule update` 的 --force 标志（覆盖本地修改）。慎用。

.NOTES
    退出码：
      0 —— .gitmodules 不存在（no-op）或所有 submodule 更新成功
      非 0 —— git 命令失败，原样转发 $LASTEXITCODE
#>

[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 1) 仓库根定位（脚本所在目录的父级）
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

Write-Host "PixelStar fetch_third_party  (cwd=$repoRoot)" -ForegroundColor White
Write-Host ('-' * 60)

# 2) git 可用性
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host '[FAIL]  git 未找到。请先 winget install Git.Git。' -ForegroundColor Red
    exit 1
}

# 3) .gitmodules 检查（T03 之前优雅 no-op）
if (-not (Test-Path '.gitmodules')) {
    Write-Warning '.gitmodules 不存在；T03 引入 submodule 后此脚本才会真正拉取依赖。'
    Write-Host '[INFO]  当前无操作，exit 0。' -ForegroundColor Cyan
    exit 0
}

# 4) 执行 submodule 更新
$args = @('submodule', 'update', '--init', '--recursive')
if ($Force.IsPresent) { $args += '--force' }

Write-Host "[INFO]  执行: git $($args -join ' ')" -ForegroundColor Cyan
& git @args
$code = $LASTEXITCODE

if ($code -eq 0) {
    Write-Host '[OK]    所有 submodule 已更新到目标提交。' -ForegroundColor Green
}
else {
    Write-Host "[FAIL]  git submodule update 失败 (exit=$code)。" -ForegroundColor Red
}

exit $code
