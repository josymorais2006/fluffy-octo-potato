# Read and convert the password from the encrypted file
$Password = Get-Content "<YOUR_PATH>" | ConvertTo-SecureString -ErrorAction Stop

# Convert SecureString to PlainText (required for SQL Server connection strings)
$PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
)

# Define the username and construct the connection string
$User = "<YOUR_DATABASE_USERNAME>"
$connString = "Data Source=<YOUR_DATABASE_HOST>;Database=<YOUR_DATABASE_NAME>;User ID=$User;Password=$PlainTextPassword"

# Create SQL Connection
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = $connString

# Open the connection
try {
    $sqlConnection.Open()

    # Create a SQL command
    $sqlcmd = $sqlConnection.CreateCommand()
    $sqlcmd.Connection = $sqlConnection
    $query = "SELECT * FROM dbo.LABTABLE;"
    $sqlcmd.CommandText = $query
    $sqlcmd.CommandTimeout = 600

    # Execute the query and fetch the data
    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null

    # Display results in PowerShell console
    Write-Output "Query Results:"
    $data.Tables[0] | Format-Table -AutoSize

    # Save results to a file
    $filenameAndPath = "<YOUR_PATH>"
    $data.Tables[0] | Format-Table -AutoSize | Out-File $filenameAndPath

    Write-Host "Query executed successfully. Results saved to: $filenameAndPath" -ForegroundColor Green
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Ensure the connection is closed
    if ($sqlConnection.State -eq "Open") {
        $sqlConnection.Close()
    }
}

# Clean up plain text password from memory
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
)
