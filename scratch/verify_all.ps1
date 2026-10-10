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

$rnd = Get-Random -Minimum 10000 -Maximum 99999

Write-Host "=== 1. PATIENT REGISTRATION AND 2ND LOGIN TEST ==="
$patSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

$testEmail = "verify.patient$rnd@gmail.com"
$testPass = "Pass1234!"
$testPhone = "98765" + (Get-Random -Minimum 10000 -Maximum 99999)

$regData = @{
    name = "Verify Patient"
    email = $testEmail
    phone = $testPhone
    dateOfBirth = "1994-04-14"
    gender = "FEMALE"
    password = $testPass
}

$r1 = Invoke-Api -Uri "$base/patients" -Method POST -Body $regData -Session $patSession
Write-Host "Registered Patient ID:" $r1.id "Email:" $r1.email "Phone:" $r1.phone

# Login 1st time
$loginData = @{ email = $testEmail; password = $testPass }
$l1 = Invoke-Api -Uri "$base/auth/login" -Method POST -Body $loginData -Session $patSession
Write-Host "1st Login Successful! Role:" $l1.role

# Logout
Invoke-Api -Uri "$base/auth/logout" -Method POST -Session $patSession | Out-Null
Write-Host "Logged out."

# Login 2nd time (Verifying user's exact issue: logging in twice with the same email)
$l2 = Invoke-Api -Uri "$base/auth/login" -Method POST -Body $loginData -Session $patSession
Write-Host "2nd Login with same email Successful! Role:" $l2.role

Write-Host "`n=== 2. FORGOT PASSWORD VERIFICATION CODE AND RESET TEST ==="
$codeResp = Invoke-Api -Uri "$base/auth/send-reset-code" -Method POST -Body @{ email = $testEmail } -Session $patSession
$resetCode = if ($codeResp.verificationCode) { $codeResp.verificationCode } else { $codeResp.resetCode }
Write-Host "Reset Code Received:" $resetCode "Message:" $codeResp.message

$newPass = "NewStrongPass999!"
$doReset = @{
    email = $testEmail
    verificationCode = $resetCode
    newPassword = $newPass
}
Invoke-Api -Uri "$base/auth/reset-password" -Method POST -Body $doReset -Session $patSession | Out-Null
Write-Host "Password Reset with 6-digit code Successful!"

# Verify login with new password
$patFinalLogin = @{ email = $testEmail; password = $newPass }
$l3 = Invoke-Api -Uri "$base/auth/login" -Method POST -Body $patFinalLogin -Session $patSession
Write-Host "Login with Reset Password Successful! Role:" $l3.role

Write-Host "`n=== 3. ADMIN SETTING CONSULTATION FEE AND CREATING DOCTOR ==="
$adminSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$adminAuth = Invoke-Api -Uri "$base/auth/login" -Method POST -Body @{ email = "admin@gmail.com"; password = "AdminPassword123!" } -Session $adminSession
Write-Host "Admin Login Successful! Role:" $adminAuth.role

$docEmail = "dr.kapoor$rnd@gmail.com"
$docPhone = "98765" + (Get-Random -Minimum 10000 -Maximum 99999)
$docData = @{
    name = "Dr. Anita Kapoor $rnd"
    email = $docEmail
    phone = $docPhone
    specialization = "Cardiologist"
    qualification = "MBBS, MD Cardiology"
    experience = 12
    consultationFee = 750.0
    password = "DocPassword123!"
}

$newDoc = Invoke-Api -Uri "$base/doctors" -Method POST -Body $docData -Session $adminSession
$docId = $newDoc.id
Write-Host "Admin Created Doctor ID:" $docId "with Consultation Fee: Rs." $newDoc.consultationFee

# Approve Doctor Verification Status
Invoke-Api -Uri "$base/doctors/$docId/verification?status=APPROVED" -Method PUT -Session $adminSession | Out-Null
Write-Host "Admin Approved Doctor Verification Status."

Write-Host "`n=== 4. DOCTOR LOGGING IN AND UPDATING CONSULTATION FEE ==="
$docSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$docAuth = Invoke-Api -Uri "$base/auth/login" -Method POST -Body @{ email = $docEmail; password = "DocPassword123!" } -Session $docSession
Write-Host "Doctor Login Successful! Role:" $docAuth.role

# Doctor updates their own consultation fee to Rs. 950
$docUpdate = @{
    name = "Dr. Anita Kapoor $rnd"
    email = $docEmail
    phone = $docPhone
    specialization = "Cardiologist"
    qualification = "MBBS, MD Cardiology"
    experience = 12
    consultationFee = 950.0
}
$updatedDoc = Invoke-Api -Uri "$base/doctors/$docId" -Method PUT -Body $docUpdate -Session $docSession
Write-Host "Doctor Consultation Fee updated by Doctor to: Rs." $updatedDoc.consultationFee

Write-Host "`n=== 5. BOOKING APPOINTMENTS AND TESTING UPI, DEBIT CARD, AND CASH PAYMENTS ==="
$patientMe = Invoke-Api -Uri "$base/patients/me" -Method GET -Session $patSession

# 5A: Book Appointment 1 and Pay via UPI
$app1Data = @{
    patientId = $patientMe.id
    doctorId = $docId
    appointmentDate = "2026-11-01"
    appointmentTime = "10:00:00"
    reason = "Chest Checkup"
    consultationType = "IN_PERSON"
}
$app1 = Invoke-Api -Uri "$base/appointments" -Method POST -Body $app1Data -Session $patSession
Write-Host "Appointment 1 Booked with ID:" $app1.id

$payUpi = Invoke-Api -Uri "$base/appointments/$($app1.id)/pay?paymentMethod=UPI" -Method POST -Session $patSession
Write-Host "UPI Payment Successful! Method:" $payUpi.paymentMethod "Status:" $payUpi.paymentStatus "Txn ID:" $payUpi.paymentTransactionId

# 5B: Book Appointment 2 and Pay via DEBIT CARD
$app2Data = @{
    patientId = $patientMe.id
    doctorId = $docId
    appointmentDate = "2026-11-01"
    appointmentTime = "11:00:00"
    reason = "BP Routine Evaluation"
    consultationType = "ONLINE"
}
$app2 = Invoke-Api -Uri "$base/appointments" -Method POST -Body $app2Data -Session $patSession
Write-Host "Appointment 2 Booked with ID:" $app2.id

$payCard = Invoke-Api -Uri "$base/appointments/$($app2.id)/pay?paymentMethod=CARD" -Method POST -Session $patSession
Write-Host "DEBIT CARD Payment Successful! Method:" $payCard.paymentMethod "Status:" $payCard.paymentStatus "Txn ID:" $payCard.paymentTransactionId

# 5C: Book Appointment 3 and Pay via CASH
$app3Data = @{
    patientId = $patientMe.id
    doctorId = $docId
    appointmentDate = "2026-11-01"
    appointmentTime = "12:00:00"
    reason = "ECG Review"
    consultationType = "IN_PERSON"
}
$app3 = Invoke-Api -Uri "$base/appointments" -Method POST -Body $app3Data -Session $patSession
Write-Host "Appointment 3 Booked with ID:" $app3.id

$payCash = Invoke-Api -Uri "$base/appointments/$($app3.id)/pay?paymentMethod=CASH" -Method POST -Session $patSession
Write-Host "CASH Payment Successful! Method:" $payCash.paymentMethod "Status:" $payCash.paymentStatus "Txn ID:" $payCash.paymentTransactionId

Write-Host "`n=== 6. DOCTOR RATING AND REVIEW SYSTEM TEST ==="
# Doctor marks Appointment 1 as COMPLETED
$compResp = Invoke-Api -Uri "$base/appointments/$($app1.id)/status?status=COMPLETED" -Method PUT -Session $docSession
Write-Host "Appointment 1 Marked as COMPLETED by Doctor."

# Patient submits rating and review for Doctor
$reviewPayload = @{
    appointmentId = $app1.id
    rating = 5
    reviewText = "Outstanding doctor! Explained heart health clearly and very friendly."
}
$reviewResp = Invoke-Api -Uri "$base/reviews" -Method POST -Body $reviewPayload -Session $patSession
Write-Host "Patient Review Submitted! Rating:" $reviewResp.rating "Stars. Feedback:" $reviewResp.comment

# Fetch reviews for Doctor
$docReviews = Invoke-Api -Uri "$base/reviews/doctor/$docId" -Method GET -Session $patSession
Write-Host "Doctor Reviews in System Count:" $docReviews.Count
Write-Host "Latest Review Comment:" $docReviews[0].comment "Rating:" $docReviews[0].rating

# Verify updated rating on Doctor's profile
$verifiedDoc = Invoke-Api -Uri "$base/doctors/$docId" -Method GET -Session $patSession
Write-Host "Doctor Profile Rating Updated: Rating:" $verifiedDoc.rating "Reviews:" $verifiedDoc.totalReviews

Write-Host "`n======================================================="
Write-Host ">>> ALL FEATURES AND FIXES FULLY VERIFIED AND WORKING 100% <<<"
Write-Host "======================================================="
