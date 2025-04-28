-- test_sigfig.lua
local sigfig = require("sigfig")

local function assertEqual(a, b, message)
    if a ~= b then
        error(message .. ": expected " .. tostring(b) .. ", got " .. tostring(a))
    else
        print("✅ " .. message)
    end
end

-- Test rounding and formatting
assertEqual(sigfig.format(1234.5678, 5), "1234.6", "Format 1234.5678 to 5 sigfigs")
assertEqual(sigfig.format(1234.5678, 3), "1230", "Format 1234.5678 to 3 sigfigs")
assertEqual(sigfig.format(12.34, 5), "12.340", "Format 12.34 to 5 sigfigs (preserve zeros)")
assertEqual(sigfig.format(0.0123456, 2), "0.012", "Format 0.0123456 to 2 sigfigs")
assertEqual(sigfig.format(0.00012345, 2), "0.00012", "Format 0.00012345 to 2 sigfigs")
assertEqual(sigfig.format(1200, 4), "1200", "Format 1200 to 4 sigfigs")
assertEqual(sigfig.format(0, 4), "0.000", "Format 0 to 4 sigfigs (special case)")

-- Test scientific notation forced
assertEqual(sigfig.format(1234567, 4, {force_sci=true}), "1.235e+06", "Force scientific notation big number")
assertEqual(sigfig.format(0.000123456, 3, {force_sci=true}), "1.23e-04", "Force scientific notation small number")

-- Test scientific notation auto
assertEqual(sigfig.format(1234567, 4, {auto_sci=true}), "1.235e+06", "Auto scientific notation big number")
assertEqual(sigfig.format(0.000123, 2, {auto_sci=true}), "1.2e-04", "Auto scientific notation small number")

-- Test detect significant figures
assertEqual(sigfig.detect_significant_figures("0.01230"), 4, "Detect sigfigs 0.01230")
assertEqual(sigfig.detect_significant_figures("1234000"), 4, "Detect sigfigs 1234000")
assertEqual(sigfig.detect_significant_figures("1.230e+3"), 4, "Detect sigfigs 1.230e+3")

-- Test detect resolution
assertEqual(sigfig.detect_resolution("123.450"), 0.01, "Detect resolution 123.450")
assertEqual(sigfig.detect_resolution("1.23e-4"), 1e-6, "Detect resolution 1.23e-4")

print("🎉 All tests passed successfully!")
