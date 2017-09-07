# Publish to gallery with a few restrictions
if(
    $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -ne 'Unknown' -and
    $env:BHBranchName -eq 'stable' -and
    $env:BHCommitMessage -match '!deploy'
)
{
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }
}

# Publish to AppVeyor if we're in AppVeyor
if(
    $env:BHProjectName -and $ENV:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -eq 'AppVeyor'
   )
{
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $ENV:BHProjectName
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}

# Publish to user's module folder
if(
    $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -eq 'Unknown'
   )
{
    Deploy DeveloperBuild {
        By FileSystem Modules {
            FromSource $env:BHPSModulePath
            To "$HOME\Documents\WindowsPowerShell\Modules\$env:BHProjectName"
            WithOptions @{
                Mirror = $true
            }
        }
    }
}
