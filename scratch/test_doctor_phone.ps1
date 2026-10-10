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

$adminSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Log in as admin
$adminLogin = @{ email = "admin@gmail.com"; password = "AdminPassword123!" }
$adminRes = Invoke-Api -Uri "$base/auth/login" -Method POST -Body $adminLogin -Session $adminSession
Write-Host "Admin Logged In. Role: $($adminRes.role)"

Write-Host "`n--- Doctor Test 1: 9-digit phone (Should be REJECTED with 400 Bad Request) ---"
try {
    $badDoc = @{
        name = "Dr. Bad Phone"
        email = "drbadphone@gmail.com"
        phone = "123456789"
        specialization = "Cardiologist"
        qualification = "MBBS, MD"
        experience = 10
        password = "DoctorPass123!"
        consultationFee = 600
    }
    $r = Invoke-Api -Uri "$base/doctors" -Method POST -Body $badDoc -Session $adminSession
    Write-Host "Result: FAILED TO REJECT! Response: $($r | ConvertTo-Json)"
} catch {
    Write-Host "Result: REJECTED AS EXPECTED! StatusCode: $($_.Exception.Response.StatusCode.value__)"
}

Write-Host "`n--- Doctor Test 2: Exactly 10 digits (Should be ACCEPTED with 201) ---"
try {
    $rand = Get-Random -Minimum 1000 -Maximum 9999
    $goodDoc = @{
        name = "Dr. Good Phone"
        email = "drgood$rand@gmail.com"
        phone = "9876543210"
        specialization = "Neurologist"
        qualification = "MBBS, DM"
        experience = 8
        password = "DoctorPass123!"
        consultationFee = 750
    }
    $r2 = Invoke-Api -Uri "$base/doctors" -Method POST -Body $goodDoc -Session $adminSession
    Write-Host "Result: ACCEPTED AS EXPECTED! Doctor ID: $($r2.id), Phone: $($r2.phone), Fee: $($r2.consultationFee)"
} catch {
    Write-Host "Result: FAILED! $($_.Exception.Message)"
}
