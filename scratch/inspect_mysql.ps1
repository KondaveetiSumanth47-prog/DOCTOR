$mysqlExe = 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
$proc = Start-Process -FilePath $mysqlExe -ArgumentList "-u", "root", "-pSumanth@123", "-e", "USE doctor_appointment; SHOW TABLES; SELECT id, email, role FROM users; SELECT id, name, specialization FROM doctors;" -NoNewWindow -Wait -PassThru -RedirectStandardOutput ".\scratch\mysql_out.txt" -RedirectStandardError ".\scratch\mysql_err.txt"

Get-Content ".\scratch\mysql_out.txt"
