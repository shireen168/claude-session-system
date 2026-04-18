$raw  = $input | Out-String
$data = $raw | ConvertFrom-Json

# --- ANSI colors (PowerShell 5.1 compatible) ---
$ESC       = [char]27
$CYAN      = "$ESC[36m"
$YELLOW    = "$ESC[33m"
$WHITE     = "$ESC[97m"
$DIM       = "$ESC[2m"
$BOLD      = "$ESC[1m"
$RESET     = "$ESC[0m"
# Background colors for solid bars
$BG_GREEN  = "$ESC[42m"
$BG_YELLOW = "$ESC[43m"
$BG_RED    = "$ESC[41m"
$BG_EMPTY  = "$ESC[48;5;238m"  # visible medium gray for unfilled portion

# --- Helpers ---
function Make-Bar($pct, $width = 8) {
    $p      = if ($pct -ne $null) { [int][Math]::Round([double]$pct) } else { 0 }
    $filled = [Math]::Floor($p * $width / 100)
    if ($p -gt 0 -and $filled -eq 0) { $filled = 1 }
    $empty  = $width - $filled
    $bgColor = if ($p -ge 90) { $BG_RED } elseif ($p -ge 70) { $BG_YELLOW } else { $BG_GREEN }
    $filledPart = if ($filled -gt 0) { "${bgColor}$(' ' * $filled)${RESET}" } else { "" }
    $emptyPart  = if ($empty  -gt 0) { "${BG_EMPTY}$(' ' * $empty)${RESET}" } else { "" }
    return "${filledPart}${emptyPart} ${WHITE}${p}%${RESET}"
}

function Format-Reset($epochSecs) {
    if ($epochSecs -eq $null) { return "" }
    $now      = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $diffSecs = [long]$epochSecs - $now
    if ($diffSecs -le 0) { return "${DIM}(now)${RESET}" }
    $d = [Math]::Floor($diffSecs / 86400)
    $h = [Math]::Floor(($diffSecs % 86400) / 3600)
    $m = [Math]::Floor(($diffSecs % 3600) / 60)
    if ($d -gt 0) { return "${DIM}resets ${d}d ${h}h${RESET}" }
    if ($h -gt 0) { return "${DIM}resets ${h}h ${m}m${RESET}" }
    return "${DIM}resets ${m}m${RESET}"
}

function Format-Duration($ms) {
    if ($ms -eq $null -or $ms -eq 0) { return "0m 0s" }
    $total = [long]$ms / 1000
    $h = [Math]::Floor($total / 3600)
    $m = [Math]::Floor(($total % 3600) / 60)
    $s = $total % 60
    if ($h -gt 0) { return "${h}h ${m}m" }
    return "${m}m ${s}s"
}

# --- Extract data ---
$model      = if ($data.model.display_name) { $data.model.display_name } else { "?" }
$cost       = if ($data.cost.total_cost_usd -ne $null) { [double]$data.cost.total_cost_usd } else { 0 }
$durationMs = if ($data.cost.total_duration_ms -ne $null) { [long]$data.cost.total_duration_ms } else { 0 }

$ctxPct     = if ($data.context_window.used_percentage -ne $null) { $data.context_window.used_percentage } else { 0 }
$ctxUsed    = if ($null -ne $data.context_window.total_input_tokens) { [int]$data.context_window.total_input_tokens } else { 0 }
$ctxTotal   = if ($null -ne $data.context_window.context_window_size) { [int]$data.context_window.context_window_size } else { 200000 }
$ctxCache   = if ($null -ne $data.context_window.current_usage.cache_read_input_tokens) { [int]$data.context_window.current_usage.cache_read_input_tokens } else { 0 }

$fiveHPct    = $data.rate_limits.five_hour.used_percentage
$fiveHReset  = $data.rate_limits.five_hour.resets_at
$sevenDPct   = $data.rate_limits.seven_day.used_percentage
$sevenDReset = $data.rate_limits.seven_day.resets_at

# --- Format token counts as e.g. 15k / 200k ---
function Format-Tokens($n) {
    if ($n -ge 1000) { return "$([Math]::Round($n / 1000))k" }
    return "$n"
}
$ctxUsedFmt  = Format-Tokens $ctxUsed
$ctxTotalFmt = Format-Tokens $ctxTotal
$cacheStr    = if ($ctxCache -gt 0) { " ${DIM}cache $(Format-Tokens $ctxCache)${RESET}" } else { "" }

# --- Line 1: model | cost | duration | ctx tokens ---
$costStr     = "$YELLOW`$$($cost.ToString('0.00'))$RESET"
$durStr      = "${DIM}$(Format-Duration $durationMs)${RESET}"
$tokenDetail = $DIM + "ctx " + $ctxUsedFmt + " / " + $ctxTotalFmt + " (" + $ctxPct + "%)" + $cacheStr + $RESET

Write-Host "${CYAN}${BOLD}[$model]${RESET}  $costStr  $durStr  ${DIM}|${RESET}  $tokenDetail"

# --- Line 2: 5hr | 7day rate limits ---
$row2 = ""

if ($fiveHPct -ne $null) {
    $resetLabel = Format-Reset $fiveHReset
    $row2 += $DIM + "5hr" + $RESET + " " + (Make-Bar $fiveHPct) + " " + $resetLabel
}

if ($sevenDPct -ne $null) {
    $resetLabel = Format-Reset $sevenDReset
    if ($row2 -ne "") { $row2 += "  " + $DIM + "|" + $RESET + "  " }
    $row2 += $DIM + "7day" + $RESET + " " + (Make-Bar $sevenDPct) + " " + $resetLabel
}

if ($row2 -ne "") { Write-Host $row2 }
