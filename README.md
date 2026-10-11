# Online Doctor Appointment System

A modern, full-stack healthcare platform powered by **Spring Boot (Java 25)**, **React + Vite**, and **MySQL**. The system supports complete end-to-end workflows for patients, doctors, and hospital administrators.

---

## 🚀 Live Deployment Links

| Component | Platform | Deployment URL | Status |
| :--- | :--- | :--- | :--- |
| **Frontend Application** | **Vercel** | [https://doctor-appointment-frontend-gxfk.vercel.app](https://doctor-appointment-frontend-gxfk.vercel.app) | **Live** ✅ |
| **Full Project Application** | **Vercel + Cloud** | [https://doctor-appointment-frontend-gxfk.vercel.app](https://doctor-appointment-frontend-gxfk.vercel.app) | **Live** ✅ |
| **Backend REST API** | **Railway / Cloud** | `https://<your-railway-domain>.up.railway.app/api` | Ready to deploy via Railway |
| **Database** | **Railway MySQL** | Managed MySQL 8 container | Provisioned via Railway |
| **GitHub Repository** | **GitHub** | [https://github.com/KondaveetiSumanth47-prog/Online-Doctor-Appointment-System](https://github.com/KondaveetiSumanth47-prog/Online-Doctor-Appointment-System) | **Main Branch** ✅ |

---

## 🌟 Key Features & Capabilities

### 1. 🛡️ Authentication & Security
- **Role-Based Access Control**: Separate, secure workspaces for **Patients**, **Doctors**, and **Administrators**.
- **Domain Validation**: Strict policy restricting account registration to verified `@gmail.com` addresses.
- **Admin Self-Registration**: Direct sign-up for authorized hospital administrators.
- **Forgot Password Workflow**: Multi-step password reset with email verification codes.
- **CSRF & Session Security**: Server-side HTTP-only session cookies with dynamic CSRF protection and BCrypt password encryption.

### 2. 📅 Smart Appointment Booking
- **Doctor Directory**: Search doctors by name or specialization with interactive filters.
- **Real-Time Availability**: Configurable weekly availability windows with strict 12-hour AM/PM time formatting.
- **Double-Booking Prevention**: High-concurrency conflict detection preventing slot collisions.
- **Consultation Modes**: Support for **In-Person Clinic Visits** and **Virtual Video Consultations** with integrated call links.
- **Booking Lifecycle**: Transitions across `PENDING` ➔ `CONFIRMED` ➔ `COMPLETED` (or `CANCELLED`).
- **Cancellation**: Patients and doctors can cancel appointments with real-time slot release.

### 3. 💳 Consultation Fees & Payment
- **Simulated Payment Processing**: One-click consultation fee payment (`₹500` default) generating official transaction IDs.
- **Receipt Generation**: Automatic in-app payment confirmation receipt sent to the patient.

### 4. 📋 Digital Prescriptions & Medical Records
- **Prescription Creation**: Doctors can issue digital prescriptions linked to specific appointments with diagnosis, medicine schedules, and dosage instructions.
- **Printable Medical Layout**: Professional clinic-branded printable view with `window.print()` support.
- **Patient Health History**: Full history of all past prescriptions accessible directly in the patient dashboard.

### 5. 🔢 Live Doctor Queue Management
- **Daily Clinic Queue**: Chronological queue of all today's patient visits.
- **Queue Positions**: Clear status tags (`#1 Current`, `#2 Next`, `#3`) for efficient clinic workflow.
- **One-Click Actions**: Join video call, complete visit, and issue Rx directly from the queue.

### 6. ⭐ Doctor Ratings & Reviews
- **Patient Feedback**: Patients can submit 1 to 5-star ratings and written reviews upon visit completion.
- **Automatic Aggregation**: Real-time recalculation of doctor average star rating and review count.
- **Doctor Badges**: Ratings displayed prominently on doctor profiles in the search directory.

### 7. 🔔 In-App Notifications
- **Real-Time Notification Bell**: Interactive notification dropdown on Patient and Doctor topbars.
- **Unread Counter & Quick Read**: Instant updates on booking status changes, reminders, and payment receipts.

### 8. ❤️ Favorite Doctors
- **Personalized Shortlist**: Patients can mark doctors as favorites using the heart toggle (`❤️` / `🤍`).
- **Filtered Search**: One-click toggle to view only favorited doctors.

### 9. 📊 Admin Analytics & Reporting
- **KPI Summary Cards**: Real-time stats on registered patients, verified doctors, appointments, and cancellations.
- **Specialty Distribution**: Visual breakdown of bookings across medical specialties.
- **Monthly Booking Trends**: Volume tracking across calendar months.
- **Doctor Verification Workflow**: Administrators can review and toggle doctor credential verification (`Approve ✅` / `Revoke 🚫`).
- **CSV Data Export**: Download complete appointment records as CSV (`appointments_report.csv`).

### 10. 🎨 UI/UX & Dark Mode
- **Dual Themes**: Instant switching between Light Mode and Dark Mode with persistent local storage.
- **Responsive Layout**: Mobile-friendly navigation with collapsible menus.

---

## 🛠️ Technology Stack

- **Backend**: Spring Boot 4.1.x, Spring Security, Spring Data JPA, Java 25
- **Frontend**: React 18, Vite 8, Modern CSS (Responsive + Dark Mode variables)
- **Database**: MySQL 8 (Production/Local), H2 (In-memory test suite)
- **Build Tools**: Apache Maven (`mvnw`), npm

---

## 🚀 Getting Started

### Prerequisites

- **Java 25** (JDK installed and configured in `PATH`)
- **Node.js 22.12+** and npm
- **MySQL 8** running locally or in a container

---

### Step 1: Database Setup (MySQL)

Create the database:

```sql
CREATE DATABASE IF NOT EXISTS doctor_appointment
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

Optionally, create a dedicated user:

```sql
CREATE USER IF NOT EXISTS 'doctor_app'@'localhost' IDENTIFIED BY 'LocalPassword123!';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, REFERENCES ON doctor_appointment.* TO 'doctor_app'@'localhost';
```

---

### Step 2: Running the Backend

From PowerShell in the project root:

```powershell
cd backend
$env:DB_URL = "jdbc:mysql://localhost:3306/doctor_appointment"
$env:DB_USERNAME = "root"
$env:DB_PASSWORD = "YourMySQLPassword"
$env:SERVER_PORT = "8081"
$env:FRONTEND_ORIGIN = "http://localhost:5173"
$env:ADMIN_EMAIL = "admin@gmail.com"
$env:ADMIN_PASSWORD = "AdminPassword123!"
.\mvnw.cmd spring-boot:run
```

*(Note: `ADMIN_EMAIL` must end in `@gmail.com` to satisfy the email domain validation policy.)*

---

### Step 3: Running the Frontend

In a second terminal:

```powershell
cd frontend
npm install
npm run dev -- --host localhost --port 5173
```

Open your browser at **`http://localhost:5173`**.

---

## 🧪 Testing & Verification

Run the full automated backend test suite (isolated H2 memory database):

```powershell
cd backend
.\mvnw.cmd test
```

Run the frontend build verification:

```powershell
cd frontend
npm run build
```

---

## 📡 REST API Summary

| Endpoint | Method | Role | Description |
|---|---|---|---|
| `/api/auth/register` | POST | Public | Register patient account |
| `/api/auth/login` | POST | Public | Sign in (Patient / Doctor / Admin) |
| `/api/auth/register-admin` | POST | Public | Register administrator account |
| `/api/auth/forgot-password/request` | POST | Public | Send reset code to email |
| `/api/auth/forgot-password/reset` | POST | Public | Reset password with code |
| `/api/doctors` | GET | Public | List all doctors |
| `/api/doctors/{id}/verification` | PUT | Admin | Approve or revoke doctor verification |
| `/api/appointments` | POST | Patient | Book an appointment |
| `/api/appointments/{id}/status` | PUT | Patient/Doctor/Admin | Update status (Confirm, Complete, Cancel) |
| `/api/appointments/{id}/pay` | POST | Patient | Process consultation fee payment |
| `/api/appointments/doctor/{id}/queue` | GET | Doctor | Retrieve live daily queue |
| `/api/prescriptions` | POST | Doctor | Issue digital prescription |
| `/api/prescriptions/patient/{id}` | GET | Patient | Retrieve patient prescriptions |
| `/api/reviews` | POST | Patient | Submit star rating and review |
| `/api/reviews/doctor/{id}` | GET | Public | Get doctor reviews |
| `/api/favorites/toggle` | POST | Patient | Toggle doctor favorite status |
| `/api/notifications/unread-count` | GET | Authenticated | Get unread notification count |
| `/api/admin/analytics` | GET | Admin | Retrieve practice KPI metrics |
| `/api/appointments/export/csv` | GET | Admin | Download appointments as CSV |

---

## 📄 License
This project is open-source under the MIT License.
