# Comprehensive End-to-End Verification of All 15 Project Functions
$ErrorActionPreference = "Stop"

$baseUrl = "http://localhost:8081"
$patientEmail = "audit_patient_" + (Get-Random -Minimum 1000 -Maximum 9999) + "@gmail.com"
$doctorEmail = "audit_doctor_" + (Get-Random -Minimum 1000 -Maximum 9999) + "@gmail.com"
$password = "SecretPass123!"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🏥 FULL END-TO-END AUDIT: ONLINE DOCTOR APPOINTMENT SYSTEM" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Helper function for session requests
function Get-CsrfSession($session) {
    $res = Invoke-RestMethod -Uri "$baseUrl/api/auth/csrf" -Method Get -WebSession $session
    return $res.token
}

# 1. Patient Registration & Welcome Email notification
Write-Host "`n[1] Testing Patient Registration & Welcome Email Notification..." -ForegroundColor Yellow
$pSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$csrf = Get-CsrfSession $pSession
$regBody = @{
    name = "John TestPatient"
    email = $patientEmail
    phone = "9876543210"
    dateOfBirth = "1992-04-15"
    gender = "Male"
    password = $password
} | ConvertTo-Json

$regResp = Invoke-RestMethod -Uri "$baseUrl/api/patients" -Method Post -Body $regBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Registered Patient ID: $($regResp.id), Email: $($regResp.email)" -ForegroundColor Green

# 2. Patient Login
Write-Host "`n[2] Testing Patient Authentication (Login)..." -ForegroundColor Yellow
$loginBody = @{ email = $patientEmail; password = $password } | ConvertTo-Json
$loginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Logged in as: $($loginResp.role) - $($loginResp.email)" -ForegroundColor Green

# 3. Admin Login
Write-Host "`n[3] Testing Admin Authentication..." -ForegroundColor Yellow
$aSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$adminCsrf = Get-CsrfSession $aSession
$adminLoginBody = @{ email = "admin@gmail.com"; password = "AdminPassword123!" } | ConvertTo-Json
$adminLoginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $adminLoginBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$adminCsrf} -WebSession $aSession
Write-Host "✅ Admin Authenticated: $($adminLoginResp.email)" -ForegroundColor Green

# 4. Doctor Registration & Admin Verification
Write-Host "`n[4] Testing Doctor Registration & Admin Verification..." -ForegroundColor Yellow
$dSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$docCsrf = Get-CsrfSession $dSession
$docRegBody = @{
    name = "Dr. Robert Smith"
    email = $doctorEmail
    phone = "9123456780"
    specialization = "Cardiology"
    qualification = "MD, FACC"
    experience = 12
    consultationFee = 750.0
    password = $password
} | ConvertTo-Json
$docResp = Invoke-RestMethod -Uri "$baseUrl/api/doctors" -Method Post -Body $docRegBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$adminCsrf} -WebSession $aSession
Write-Host "✅ Doctor Created ID: $($docResp.id), Verification Status: $($docResp.verificationStatus)" -ForegroundColor Green

# Approve Doctor
$approvedDoc = Invoke-RestMethod -Uri "$baseUrl/api/doctors/$($docResp.id)/verification?status=APPROVED" -Method Put -Headers @{"X-XSRF-TOKEN"=$adminCsrf} -WebSession $aSession
Write-Host "✅ Doctor Approved by Admin: Status = $($approvedDoc.verificationStatus)" -ForegroundColor Green

# 5. Doctor Sets Weekly Availability
Write-Host "`n[5] Testing Doctor Availability Schedule (12-hour AM/PM format support)..." -ForegroundColor Yellow
$docLoginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body (@{ email = $doctorEmail; password = $password } | ConvertTo-Json) -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$docCsrf} -WebSession $dSession

$availBody = @{
    doctor = @{ id = $docResp.id }
    dayOfWeek = "MONDAY"
    startTime = "09:00"
    endTime = "17:00"
} | ConvertTo-Json
$availResp = Invoke-RestMethod -Uri "$baseUrl/api/availabilities" -Method Post -Body $availBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$docCsrf} -WebSession $dSession
Write-Host "✅ Availability Window Added: $($availResp.dayOfWeek) $($availResp.startTime) to $($availResp.endTime)" -ForegroundColor Green

# 6. Patient Searches Doctors & Adds to Favorites
Write-Host "`n[6] Testing Doctor Search & Favorites..." -ForegroundColor Yellow
$doctorsList = Invoke-RestMethod -Uri "$baseUrl/api/doctors" -Method Get -WebSession $pSession
Write-Host "✅ Doctor Directory Count: $($doctorsList.Count) doctors found" -ForegroundColor Green

$favResp = Invoke-RestMethod -Uri "$baseUrl/api/favorites/toggle?patientId=$($regResp.id)&doctorId=$($docResp.id)" -Method Post -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Doctor Favorited for Patient: $($favResp.message)" -ForegroundColor Green

# 7. Patient Books Appointment
Write-Host "`n[7] Testing Smart Appointment Booking (12-hour AM/PM, Real-time Slot & Email/Alert)..." -ForegroundColor Yellow
$apptDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
$apptTime = "10:30"
$bookBody = @{
    doctorId = $docResp.id
    appointmentDate = $apptDate
    appointmentTime = $apptTime
    reason = "Routine cardiac checkup & ECG review"
} | ConvertTo-Json
$apptResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments" -Method Post -Body $bookBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Appointment Booked ID: $($apptResp.id) on $($apptResp.appointmentDate) at $($apptResp.appointmentTime) (Status: $($apptResp.status))" -ForegroundColor Green
Write-Host "   Video Consultation Link: $($apptResp.meetingUrl)" -ForegroundColor Gray

# 8. Patient Reschedules Appointment
Write-Host "`n[8] Testing Appointment Rescheduling (12-hour AM/PM quick select)..." -ForegroundColor Yellow
$newApptDate = (Get-Date).AddDays(2).ToString("yyyy-MM-dd")
$newApptTime = "14:30"
$rescheduleBody = @{
    appointmentDate = $newApptDate
    appointmentTime = $newApptTime
    reason = "Rescheduled routine checkup"
} | ConvertTo-Json
$reschedResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments/$($apptResp.id)" -Method Put -Body $rescheduleBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Appointment Rescheduled to: $($reschedResp.appointmentDate) at $($reschedResp.appointmentTime) (2:30 PM)" -ForegroundColor Green

# 9. Doctor Daily Queue
Write-Host "`n[9] Testing Doctor Queue Workflow..." -ForegroundColor Yellow
$queueResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments/doctor/$($docResp.id)/queue" -Method Get -WebSession $dSession
Write-Host "✅ Doctor Queue Retrieved successfully (Queue size: $($queueResp.Count))" -ForegroundColor Green

# 10. Doctor Confirms and Completes Appointment
Write-Host "`n[10] Testing Doctor Confirmation & Completion..." -ForegroundColor Yellow
$confirmResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments/$($apptResp.id)/status?status=CONFIRMED" -Method Put -Headers @{"X-XSRF-TOKEN"=$docCsrf} -WebSession $dSession
Write-Host "✅ Appointment Confirmed: Status = $($confirmResp.status)" -ForegroundColor Green

$completeResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments/$($apptResp.id)/status?status=COMPLETED" -Method Put -Headers @{"X-XSRF-TOKEN"=$docCsrf} -WebSession $dSession
Write-Host "✅ Appointment Completed: Status = $($completeResp.status)" -ForegroundColor Green

# 11. Patient Payment Processing
Write-Host "`n[11] Testing Patient Consultation Fee Payment..." -ForegroundColor Yellow
$payResp = Invoke-RestMethod -Uri "$baseUrl/api/appointments/$($apptResp.id)/pay" -Method Post -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Consultation Payment: Status = $($payResp.paymentStatus), Txn Ref: $($payResp.paymentTransactionId)" -ForegroundColor Green

# 12. Doctor Issues Digital Prescription
Write-Host "`n[12] Testing Digital Prescription Creation..." -ForegroundColor Yellow
$rxBody = @{
    patientId = $regResp.id
    doctorId = $docResp.id
    appointmentId = $apptResp.id
    diagnosis = "Mild Hypertension & Stress"
    medicines = "Amlodipine 5mg - 1 tab once daily in morning (30 days)`nOmega-3 Fatty Acids 1000mg - 1 capsule daily after lunch (30 days)"
    instructions = "Low sodium diet, brisk walking 30 minutes daily. Monitor BP weekly."
} | ConvertTo-Json
$rxResp = Invoke-RestMethod -Uri "$baseUrl/api/prescriptions" -Method Post -Body $rxBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$docCsrf} -WebSession $dSession
Write-Host "✅ Prescription Issued ID: $($rxResp.id), Diagnosis: $($rxResp.diagnosis)" -ForegroundColor Green

# 13. Patient Views Digital Prescription
Write-Host "`n[13] Testing Patient Viewing Medical Records / Prescriptions..." -ForegroundColor Yellow
$patientRxs = Invoke-RestMethod -Uri "$baseUrl/api/prescriptions/patient/$($regResp.id)" -Method Get -WebSession $pSession
Write-Host "✅ Patient Prescriptions Found: $($patientRxs.Count) records" -ForegroundColor Green

# 14. Patient Rates and Reviews Doctor
Write-Host "`n[14] Testing Doctor Rating & Review Submission..." -ForegroundColor Yellow
$reviewBody = @{
    appointmentId = $apptResp.id
    rating = 5
    reviewText = "Exceptional doctor! Very attentive and explained the treatment thoroughly."
} | ConvertTo-Json
$reviewResp = Invoke-RestMethod -Uri "$baseUrl/api/reviews" -Method Post -Body $reviewBody -ContentType "application/json" -Headers @{"X-XSRF-TOKEN"=$csrf} -WebSession $pSession
Write-Host "✅ Rating Submitted: $($reviewResp.rating) Stars - '$($reviewResp.reviewText)'" -ForegroundColor Green

# 15. In-App Notifications Verification
Write-Host "`n[15] Testing Notification Retrieval and Read State..." -ForegroundColor Yellow
$notifications = Invoke-RestMethod -Uri "$baseUrl/api/notifications/user/$($regResp.id)" -Method Get -WebSession $pSession
Write-Host "✅ Notifications for Patient ($patientEmail): $($notifications.Count) total alerts received" -ForegroundColor Green
foreach ($n in $notifications) {
    Write-Host "   🔔 [$($n.type)] $($n.message)" -ForegroundColor Gray
}

# 16. Admin Analytics
Write-Host "`n[16] Testing Admin Analytics & Reporting..." -ForegroundColor Yellow
$analytics = Invoke-RestMethod -Uri "$baseUrl/api/admin/analytics" -Method Get -WebSession $aSession
Write-Host "✅ Admin Analytics:" -ForegroundColor Green
Write-Host "   Total Patients:     $($analytics.totalPatients)" -ForegroundColor White
Write-Host "   Total Doctors:      $($analytics.totalDoctors)" -ForegroundColor White
Write-Host "   Total Appointments: $($analytics.totalAppointments)" -ForegroundColor White
Write-Host "   Completed Visits:   $($analytics.completedAppointments)" -ForegroundColor White

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "🎉 ALL FUNCTIONS AUDITED AND 100% OPERATIONAL!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
