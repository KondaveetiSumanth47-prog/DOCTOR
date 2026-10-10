const fs = require('fs');
const filePath = 'frontend/src/PatientDashboard.jsx';
let content = fs.readFileSync(filePath, 'utf8');

const target = '<td>{appointment.status === "PENDING" ? <button className="dashboard-row-action" type="button" onClick={() => void cancelAppointment(appointment.id)}>Cancel</button> : "—"}</td>';
const replacement = '<td>{["PENDING", "CONFIRMED"].includes(appointment.status) ? <button className="dashboard-row-action dashboard-row-danger" type="button" disabled={cancellingId === appointment.id} onClick={() => void cancelAppointment(appointment.id)}>{cancellingId === appointment.id ? "Cancelling…" : "Cancel"}</button> : "—"}</td>';

if (content.includes(target)) {
    content = content.replace(target, replacement);
    fs.writeFileSync(filePath, content, 'utf8');
    console.log("Success: PatientDashboard.jsx updated!");
} else {
    console.log("Not found by exact match, doing regex replacement...");
    content = content.replace(/<td>\{appointment\.status === "PENDING" \? <button className="dashboard-row-action"[^>]*>Cancel<\/button> : "[^"]*"\}<\/td>/g, replacement);
    fs.writeFileSync(filePath, content, 'utf8');
    console.log("Regex replacement applied!");
}
