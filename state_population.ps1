# Define the API URL
$apiUrl = "https://datausa.io/api/data?drilldowns=State&measures=Population"

# Make an API request and retrieve the JSON data
$response = Invoke-WebRequest -Uri $apiUrl

# Convert JSON data to a PowerShell object
$jsonData = $response.Content | ConvertFrom-Json

# Extract population data from the JSON object
$populationData = $jsonData.data

# Initialize an empty dictionary to store the CSV data
$csvData = @()

# Loop through the population data for each state
foreach ($stateData in $populationData) {
    $state = $stateData.State
    $year = $stateData.Year
    $population = $stateData.Population

    # Check if the state is already in the dictionary
    if ($csvData.ContainsKey($state)) {
        # Calculate the population change and percentage change
        $prevStateData = $csvData[$state]
        $populationChange = $population - $prevStateData.Population
        $populationChangePercentage = ($populationChange / $prevStateData.Population) * 100

        # Get the prime factors of the population
        $primeFactors = Get-PrimeFactors -Number $population # You need to implement Get-PrimeFactors function

        # Update the CSV data for the state with new values
        $csvData[$state] = @{
            State = $state
            Year = $year
            Population = $population
            PopulationChange = "{0} ({1:P2})" -f $populationChange, $populationChangePercentage
            PrimeFactors = $primeFactors -join ";"
        }
    } else {
        # Add the state data to the dictionary for the first time
        $csvData.Add($state, @{
            State = $state
            Year = $year
            Population = $population
        })
    }
}

# Export the CSV data to a file named "PopulationData.csv"
$csvData.Values | Export-Csv -Path "<LocalPathtoSave>/PopulationData.csv" -NoTypeInformation
