$mysqlExe = 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
$passwords = @('sumanth', 'Sumanth', 'sumanth47', 'Sumanth47', 'Sumanth@47', 'sumanth123', 'Sumanth123', 'Sumanth@123', 'nani', 'nanisumanth', 'nanisumanth59', '12345', '123', 'mysql', 'Dell', 'dell')

foreach ($pass in $passwords) {
    $output = & $mysqlExe -u root "-p$pass" -e "SHOW DATABASES;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ">>> SUCCESSFUL CONNECTION TO MYSQL WITH PASSWORD: '$pass' <<<"
        Write-Host $output
        exit 0
    }
}
Write-Host "None matched in this batch."
