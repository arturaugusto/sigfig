-- test_sigfig.lua
local function assertEqual(a, b, message)
    if a ~= b then
        error(message .. ": expected " .. tostring(b) .. ", got " .. tostring(a))
    else
        print("✅ " .. message)
    end
end

-- Formatting tests
assertEqual(sigfig.format(1234.5678, 5), "1234.6", "Format 1234.5678 to 5 sigfigs")
assertEqual(sigfig.format(1234.5678, 3), "1230", "Format 1234.5678 to 3 sigfigs")
assertEqual(sigfig.format(12.34, 5), "12.340", "Format 12.34 to 5 sigfigs (preserve zeros)")
assertEqual(sigfig.format(0.0123456, 2), "0.012", "Format 0.0123456 to 2 sigfigs")
assertEqual(sigfig.format(0.00012345, 2), "0.00012", "Format 0.00012345 to 2 sigfigs")
assertEqual(sigfig.format(1200, 4), "1200", "Format 1200 to 4 sigfigs")
assertEqual(sigfig.format(0, 4), "0.000", "Format 0 to 4 sigfigs (zero case)")

-- Scientific notation tests
assertEqual(sigfig.format(1234567, 4, {force_sci=true}), "1.235e+06", "Force scientific notation big number")
assertEqual(sigfig.format(0.000123456, 3, {force_sci=true}), "1.23e-04", "Force scientific notation small number")
assertEqual(sigfig.format(1234567, 4, {auto_sci=true}), "1.235e+06", "Auto scientific notation big number")
assertEqual(sigfig.format(0.000123, 2, {auto_sci=true}), "1.2e-04", "Auto scientific notation small number")

-- Significant figures detection tests
assertEqual(sigfig.detect_significant_figures("0.01230"), 4, "Detect sigfigs 0.01230")
assertEqual(sigfig.detect_significant_figures("1234000"), 4, "Detect sigfigs 1234000")
assertEqual(sigfig.detect_significant_figures("1.230e+3"), 4, "Detect sigfigs 1.230e+3")

-- Resolution detection tests (return string)
assertEqual(sigfig.detect_resolution("123.450"), "0.01", "Detect resolution 123.450")
assertEqual(sigfig.detect_resolution("1.23e-4"), "0.000001", "Detect resolution 1.23e-4")

-- Round to resolution tests (return string)
assertEqual(sigfig.round_to_resolution(123.456, 0.01), "123.46", "Round to resolution 0.01")
assertEqual(sigfig.round_to_resolution(123.456, 10), "120", "Round to resolution 10")

-- Round to same resolution tests (return string)
assertEqual(sigfig.round_to_same_resolution(9.8765, "2.34"), "9.88", "Round to same resolution as '2.34'")
assertEqual(sigfig.round_to_same_resolution(9.8765, "12300"), "10", "Round to same resolution as '12300'")

print("🎉 All tests passed successfully!")
