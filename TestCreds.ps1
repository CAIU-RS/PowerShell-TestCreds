# Import the Active Directory module
Import-Module ActiveDirectory

# Set the path to the input CSV file
$inputFilePath = "C:\path\to\input.csv"

# Set the path to the output CSV file
$outputFilePath = "C:\path\to\output.csv"

# Import the CSV file
$users = Import-Csv $inputFilePath

# Create an array to store the results
$results = @()

# Loop through each user in the CSV file
foreach ($user in $users) {
    # Retrieve the username and password from the CSV
    $username = $user.User
    $password = $user.Password

    # Attempt to authenticate the user
    $authenticated = $false
    try {
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, (ConvertTo-SecureString -String $password -AsPlainText -Force)
        $authenticated = Get-ADUser -Credential $credential -Filter "SamAccountName -eq '$username'" -ErrorAction Stop
    } catch {
        # Catch any errors during authentication
        $errorDetails = $_.Exception.Message
    }

    # Create a custom object with the user, password, and result
    $result = [PSCustomObject]@{
        User = $username
        Password = $password
        Success = $authenticated -ne $false
        Error = if ($authenticated -eq $false) { $errorDetails } else { $null }
    }

    # Add the result to the array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputFilePath -NoTypeInformation
