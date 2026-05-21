#!/usr/bin/env bash
# PixelStar 依赖前置检查脚本（Linux / macOS · Bash 对等版）。
# 与 check_deps.ps1 语义对齐：Stage=mvp/standard/full 控制必检与软警告范围。
#
# 用法:
#   ./tools/check_deps.sh --stage mvp
#   ./tools/check_deps.sh --stage full --no-color
#
# 退出码:
#   0  所有必检项通过（warn 不阻断）
#   1  任一必检项缺失或版本不达标
#   2  脚本自身参数错误

set -uo pipefail

# ---------- 参数解析 ----------
STAGE="mvp"
NO_COLOR=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stage)
            STAGE="${2:-}"
            shift 2
            ;;
        --no-color)
            NO_COLOR=1
            shift
            ;;
        -h|--help)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown arg: $1" >&2
            exit 2
            ;;
    esac
done

case "$STAGE" in
    mvp|standard|full) ;;
    *)
        echo "Invalid --stage: $STAGE (expect mvp|standard|full)" >&2
        exit 2
        ;;
esac

# ---------- 颜色 ----------
if [[ $NO_COLOR -eq 0 ]] && [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
    C_OK=$(tput setaf 2)
    C_WARN=$(tput setaf 3)
    C_FAIL=$(tput setaf 1)
    C_DIM=$(tput setaf 8 2>/dev/null || tput setaf 7)
    C_RST=$(tput sgr0)
else
    C_OK="" ; C_WARN="" ; C_FAIL="" ; C_DIM="" ; C_RST=""
fi

status() {
    local lvl="$1" ; shift
    local msg="$*"
    case "$lvl" in
        OK)   printf '%s[OK]  %s %s\n'   "$C_OK"   "$C_RST" "$msg" ;;
        WARN) printf '%s[WARN]%s %s\n'   "$C_WARN" "$C_RST" "$msg" ;;
        FAIL) printf '%s[FAIL]%s %s\n'   "$C_FAIL" "$C_RST" "$msg" ;;
        INFO) printf '[INFO] %s\n' "$msg" ;;
    esac
}

hint() {
    printf '%s         → %s%s\n' "$C_DIM" "$*" "$C_RST"
}

# ---------- 版本比较: $1 >= $2 ? ----------
version_ge() {
    # 用 sort -V：若 min 排在 detected 前或相等，则 detected >= min
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]
}

# 提取首个形如 N.N(.N)? 的串
extract_version() {
    grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' <<<"$1" | head -n1
}

# ---------- 单条检查 ----------
# 用法: check_tool <name> <command> <min_version> <required:0|1> <install_hint> <version_args...>
required_pass=0
required_fail=0
warnings=0

check_tool() {
    local name="$1" cmd="$2" min="$3" required="$4" install_hint="$5"
    shift 5
    local args=("$@")

    if ! command -v "$cmd" >/dev/null 2>&1; then
        if [[ $required -eq 1 ]]; then
            status FAIL "$(printf '%-12s not found  (required at Stage=%s)' "$name" "$STAGE")"
            hint "$install_hint"
            ((required_fail++)) || true
        else
            status WARN "$(printf '%-12s not found  (required at Stage=full)' "$name")"
            ((warnings++)) || true
        fi
        return
    fi

    local raw
    raw="$("$cmd" "${args[@]}" 2>&1 | head -n2 || true)"
    local ver
    ver="$(extract_version "$raw")"

    if [[ -z "$ver" ]]; then
        if [[ $required -eq 1 ]]; then
            status FAIL "$(printf '%-12s found but version unreadable' "$name")"
            ((required_fail++)) || true
        else
            status WARN "$(printf '%-12s found but version unreadable' "$name")"
            ((warnings++)) || true
        fi
        return
    fi

    if version_ge "$ver" "$min"; then
        status OK "$(printf '%-12s %-12s (>=%s)' "$name" "$ver" "$min")"
        [[ $required -eq 1 ]] && ((required_pass++)) || true
    else
        if [[ $required -eq 1 ]]; then
            status FAIL "$(printf '%-12s %-12s (<%s, too old)' "$name" "$ver" "$min")"
            hint "$install_hint"
            ((required_fail++)) || true
        else
            status WARN "$(printf '%-12s %-12s (<%s, too old)' "$name" "$ver" "$min")"
            ((warnings++)) || true
        fi
    fi
}

# ---------- 主流程 ----------
echo
echo "PixelStar dep-check  Stage=$STAGE"
printf -- '-%.0s' {1..60} ; echo

# 通用工具
check_tool "Git"    "git"    "2.40.0" 1 "apt install git  /  brew install git"                       --version
check_tool "CMake"  "cmake"  "3.22.0" 1 "apt install cmake  /  brew install cmake"                   --version
check_tool "Ninja"  "ninja"  "1.11.0" 1 "apt install ninja-build  /  brew install ninja"             --version
check_tool "Python" "python3" "3.10.0" 1 "apt install python3  /  brew install python@3.12"          --version

# JDK：仅 full 必检
jdk_required=0
[[ "$STAGE" == "full" ]] && jdk_required=1
check_tool "JDK" "java" "17.0.0" "$jdk_required" "apt install openjdk-17-jdk  /  brew install openjdk@17" -version

# C++ 编译器：Unix 下 clang 或 g++ 任一即可
cc_found=0
if command -v clang >/dev/null 2>&1; then
    cc_ver="$(extract_version "$(clang --version 2>&1 | head -n1)")"
    status OK "$(printf '%-12s %-12s (Clang)' "C++ Compiler" "${cc_ver:-unknown}")"
    cc_found=1
elif command -v g++ >/dev/null 2>&1; then
    cc_ver="$(extract_version "$(g++ --version 2>&1 | head -n1)")"
    status OK "$(printf '%-12s %-12s (GCC)' "C++ Compiler" "${cc_ver:-unknown}")"
    cc_found=1
else
    status FAIL "$(printf '%-12s not found  (required at Stage=%s)' "C++ Compiler" "$STAGE")"
    hint "apt install clang  /  brew install llvm  /  apt install build-essential"
fi
if [[ $cc_found -eq 1 ]]; then
    ((required_pass++)) || true
else
    ((required_fail++)) || true
fi

# MSVC: 跳过（非 Windows）
status INFO "MSVC         skipped on non-Windows"

# Android NDK / SDK：mvp/standard warn，full required
ndk_required=0
[[ "$STAGE" == "full" ]] && ndk_required=1

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
    if [[ $ndk_required -eq 1 ]]; then
        status FAIL "ANDROID_NDK_HOME not set  (required at Stage=full)"
        hint "安装 Android NDK r25+，export ANDROID_NDK_HOME=/path/to/ndk"
        ((required_fail++)) || true
    else
        status WARN "ANDROID_NDK_HOME not set  (required at Stage=full, T16 之前可忽略)"
        ((warnings++)) || true
    fi
else
    status OK "ANDROID_NDK_HOME = $ANDROID_NDK_HOME"
    [[ $ndk_required -eq 1 ]] && ((required_pass++)) || true
fi

sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$sdk" ]]; then
    if [[ $ndk_required -eq 1 ]]; then
        status FAIL "ANDROID_HOME / ANDROID_SDK_ROOT not set  (required at Stage=full)"
        ((required_fail++)) || true
    else
        status WARN "ANDROID_HOME / ANDROID_SDK_ROOT not set  (required at Stage=full)"
        ((warnings++)) || true
    fi
else
    status OK "ANDROID_HOME = $sdk"
    [[ $ndk_required -eq 1 ]] && ((required_pass++)) || true
fi

# fonttools：仅 full 必检
if [[ "$STAGE" == "full" ]]; then
    if python3 -m pip show fonttools >/dev/null 2>&1; then
        status OK "fonttools    installed (pip)"
        ((required_pass++)) || true
    else
        status FAIL "fonttools not installed  (required at Stage=full)"
        hint "python3 -m pip install fonttools"
        ((required_fail++)) || true
    fi
fi

# third_party/
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ ! -d "$repo_root/third_party" ]]; then
    status WARN "third_party/ 目录不存在；将由 T03 创建（当前任务无需关心）"
    ((warnings++)) || true
elif [[ -z "$(ls -A "$repo_root/third_party" 2>/dev/null)" ]]; then
    status WARN "third_party/ 存在但为空；运行 tools/fetch_third_party.ps1 拉取 submodule"
    ((warnings++)) || true
else
    status OK "third_party/  exists (具体子目录校验待 T03 后启用)"
fi
# TODO(T03): 启用 imgui/SDL/stb/json/fmt 五个子目录非空校验

# ---------- 汇总 ----------
printf -- '-%.0s' {1..60} ; echo
total=$((required_pass + required_fail))
echo "Stage=$STAGE 必检项：$required_pass/$total 通过"
echo "警告：$warnings 项（不阻断）"

if [[ $required_fail -gt 0 ]]; then
    status FAIL "$required_fail required check(s) failed. 请按上述提示修复后重试。"
    echo
    exit 1
fi

status OK "All required checks passed."
echo
exit 0
