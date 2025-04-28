-- sigfig.lua - Library for significant figures and half-even rounding with trailing zero preservation and scientific notation support

local sigfig = {}

-- Helper: Half-even rounding to 'n' decimals
local function round_half_even(num, decimals)
    local mult = 10^decimals
    local shifted = num * mult
    local floored = math.floor(shifted)
    local diff = shifted - floored

    if diff > 0.5 then
        floored = floored + 1
    elseif diff == 0.5 then
        if floored % 2 ~= 0 then
            floored = floored + 1
        end
    end

    return floored / mult
end

-- Helper: Format a number into a string with the right number of significant figures
local function format_with_sigfigs(num, n, opts)
    opts = opts or {}
    if num == 0 then
        return "0." .. string.rep("0", n - 1)
    end

    local d = math.ceil(math.log10(math.abs(num)))
    local decimals = n - d
    local rounded = round_half_even(num, decimals)

    local abs_rounded = math.abs(rounded)
    local use_sci = opts.force_sci or (opts.auto_sci and (abs_rounded >= 1e5 or abs_rounded < 1e-3))

    if use_sci then
        local fmt = "%0." .. (n - 1) .. "e"
        return string.format(fmt, rounded)
    else
        if decimals > 0 then
            local fmt = "%0." .. decimals .. "f"
            return string.format(fmt, rounded)
        else
            local fmt = "%0.0f"
            return string.format(fmt, rounded)
        end
    end
end

-- Format number to 'n' significant figures, preserving trailing zeros
-- Options:
--   opts.force_sci = true to always use scientific notation
--   opts.auto_sci = true to auto switch based on magnitude
function sigfig.format(num, n, opts)
    return format_with_sigfigs(num, n, opts)
end

-- Detect number of significant figures in a number string
function sigfig.detect_significant_figures(str)
    -- Remove sign and exponent part
    local base = str:match("^[+-]?([^eE]+)") or str

    -- Remove decimal point temporarily
    local base_clean = base:gsub("%.", "")

    -- Remove leading zeros (only if no decimal point before them)
    if not base:find("%.") then
        base_clean = base_clean:match("^0*(.-)$")
    end

    -- Count digits
    return #base_clean
end

-- Detect resolution (smallest distinguishable unit) of number string
function sigfig.detect_resolution(str)
    -- Normalize string
    local number, exp = str:match("([+-]?[%d%.]+)[eE]([+-]?%d+)")
    exp = tonumber(exp) or 0
    number = number or str

    local dot = number:find("%.")

    if dot then
        local decimals = #number - dot
        return 10^(exp - decimals)
    else
        return 10^exp
    end
end

return sigfig
