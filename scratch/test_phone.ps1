$base = 'http://localhost:8081/api'

function Invoke-Api {
    param(
        [string]$Uri,
        [string]$Method = 'GET',
        [object]$Body = $null,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session
    )
    $csrf = Invoke-RestMethod -Uri "$base/auth/csrf" -Method GET -WebSession $Session
    $headers = @{ 'X-XSRF-TOKEN' = $csrf.token }
    if ($Body) {
        $json = $Body | ConvertTo-Json -Depth 5
        return Invoke-RestMethod -Uri $Uri -Method $Method -Body $json -ContentType 'application/json' -Headers $headers -WebSession $Session
    } else {
        return Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -WebSession $Session
    }
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "--- Test 1: 9-digit phone (Should be REJECTED with 400 Bad Request) ---"
try {
    $badData = @{
        name = "Nine Digit"
        email = "ninedigit@gmail.com"
        phone = "123456789" # 9 digits
        dateOfBirth = "2000-01-01"
        gender = "Male"
        password = "Password123!"
    }
    $r = Invoke-Api -Uri "$base/patients" -Method POST -Body $badData -Session $session
    Write-Host "Result: FAILED TO REJECT! Response: $($r | ConvertTo-Json)"
} catch {
    Write-Host "Result: REJECTED AS EXPECTED! StatusCode: $($_.Exception.Response.StatusCode.value__)"
}

Write-Host "`n--- Test 2: 11-digit phone (Should be REJECTED with 400 Bad Request) ---"
try {
    $badData2 = @{
        name = "Eleven Digit"
        email = "elevendigit@gmail.com"
        phone = "12345678901" # 11 digits
        dateOfBirth = "2000-01-01"
        gender = "Male"
        password = "Password123!"
    }
    $r2 = Invoke-Api -Uri "$base/patients" -Method POST -Body $badData2 -Session $session
    Write-Host "Result: FAILED TO REJECT! Response: $($r2 | ConvertTo-Json)"
} catch {
    Write-Host "Result: REJECTED AS EXPECTED! StatusCode: $($_.Exception.Response.StatusCode.value__)"
}

Write-Host "`n--- Test 3: Non-numeric characters (Should be REJECTED with 400 Bad Request) ---"
try {
    $badData3 = @{
        name = "Alpha Phone"
        email = "alphaphone@gmail.com"
        phone = "98765abcd0" # 10 chars with alpha
        dateOfBirth = "2000-01-01"
        gender = "Male"
        password = "Password123!"
    }
    $r3 = Invoke-Api -Uri "$base/patients" -Method POST -Body $badData3 -Session $session
    Write-Host "Result: FAILED TO REJECT! Response: $($r3 | ConvertTo-Json)"
} catch {
    Write-Host "Result: REJECTED AS EXPECTED! StatusCode: $($_.Exception.Response.StatusCode.value__)"
}

Write-Host "`n--- Test 4: Exactly 10 digits (Should be ACCEPTED with 200/201) ---"
try {
    $randNum = Get-Random -Minimum 1000 -Maximum 9999
    $goodData = @{
        name = "Ten Digit Patient"
        email = "tendigit$randNum@gmail.com"
        phone = "9876543210" # Exactly 10 digits
        dateOfBirth = "2000-01-01"
        gender = "Male"
        password = "Password123!"
    }
    $r4 = Invoke-Api -Uri "$base/patients" -Method POST -Body $goodData -Session $session
    Write-Host "Result: ACCEPTED AS EXPECTED! Patient ID: $($r4.id), Phone: $($r4.phone)"
} catch {
    Write-Host "Result: FAILED! $($_.Exception.Message)"
}
