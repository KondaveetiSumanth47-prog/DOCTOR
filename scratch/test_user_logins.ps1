$base = 'http://localhost:8081/api'

function Test-Login($email, $pass) {
    try {
        $csrf = Invoke-RestMethod -Uri "$base/auth/csrf" -Method GET
        $headers = @{ 'X-XSRF-TOKEN' = $csrf.token }
        $body = @{ email = $email; password = $pass } | ConvertTo-Json
        $res = Invoke-RestMethod -Uri "$base/auth/login" -Method POST -Body $body -ContentType 'application/json' -Headers $headers
        Write-Host "SUCCESS for $email with pass '$pass'! Role: $($res.role)"
        return $true
    } catch {
        return $false
    }
}

$candidates = @('12345678', '123456789', 'Password123!', 'AdminPassword123!', 'DocPassword123!', '12345', '1234', '123456', 'admin', 'password', 'Sumanth@123', 'veeru800', 'akhil567', 'rudra245')

Write-Host "--- Testing veeru800@gmail.com ---"
foreach ($c in $candidates) {
    if (Test-Login 'veeru800@gmail.com' $c) { break }
}

Write-Host "--- Testing akhil567@gmail.com ---"
foreach ($c in $candidates) {
    if (Test-Login 'akhil567@gmail.com' $c) { break }
}

Write-Host "--- Testing rudra245@gmail.com ---"
foreach ($c in $candidates) {
    if (Test-Login 'rudra245@gmail.com' $c) { break }
}
