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
    local base = str:match("^[+-]?([^eE]+)") or str
    local base_clean = base:gsub("%.", "")
    if not base:find("%.") then
        base_clean = base_clean:gsub("0*$", "")
    end
    base_clean = base_clean:gsub("^0*", "")
    if base_clean == "" then return 1 end
    return #base_clean
end

-- Detect resolution (smallest distinguishable unit) of number string
-- Returns a string without floating-point errors
function sigfig.detect_resolution(str)
    -- Parse mantissa and exponent
    local number_str, exp_str = str:match("^%s*([+-]?[%d%.]+)[eE]([+-]?%d+)")
    local exp = tonumber(exp_str) or 0
    local num_part = number_str or str

    -- Determine exponent of resolution
    local dot_index = num_part:find("%.")
    local exponent
    if dot_index then
        local fraction = num_part:sub(dot_index + 1)
        local trimmed = fraction:gsub("0*$", "")
        local eff_dec = #trimmed
        exponent = exp - eff_dec
    else
        local zeros = num_part:match("0*$") or ""
        local tz = #zeros
        if tz > 0 then
            exponent = tz - 1
        else
            exponent = 0
        end
    end

    -- Build resolution string
    if exponent >= 0 then
        return "1" .. string.rep("0", exponent)
    else
        return "0." .. string.rep("0", -exponent - 1) .. "1"
    end
end

-- Round a number to a specified resolution using half-even rounding
-- Returns a string without floating-point issues
function sigfig.round_to_resolution(num, resolution)
    -- Accept numeric or string resolution
    local res_str = (type(resolution) == "string") and resolution or tostring(resolution)
    local resolution_num = tonumber(res_str)
    if not resolution_num or resolution_num <= 0 then
        error("invalid resolution: " .. tostring(resolution))
    end

    -- Determine number of decimals for output
    local dot = res_str:find("%.")
    local decimals = dot and (#res_str - dot) or 0

    -- Perform rounding
    local quotient = num / resolution_num
    local r_q = round_half_even(quotient, 0)
    local result = r_q * resolution_num

    if decimals > 0 then
        return string.format("%0." .. decimals .. "f", result)
    else
        return tostring(math.floor(result + 0.5))
    end
end

-- Round a number to have the same resolution as another number string
-- Returns a string without floating-point issues
function sigfig.round_to_same_resolution(num, ref_str)
    local res_str = sigfig.detect_resolution(ref_str)
    return sigfig.round_to_resolution(num, res_str)
end

return sigfig
