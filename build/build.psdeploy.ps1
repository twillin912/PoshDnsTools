# Publish to gallery with a few restrictions
if ( $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -ne 'Unknown' -and $env:BHBranchName -eq 'stable' -and
    $env:BHCommitMessage -match '!deploy' ) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $env:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $env:NugetApiKey
            }
        }
    }
}

# Publish to AppVeyor if we're in AppVeyor
if ( $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -eq 'AppVeyor' ) {
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $env:BHProjectName
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}

# Publish to internal gallery
if ( $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -eq 'Unknown' ) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $env:BHPSModulePath
            To CambiumGallery
            WithOptions @{
                ApiKey = $env:NugetApiKey
            }
        }
    }
}
