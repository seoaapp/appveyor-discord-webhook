# License: MIT

$STATUS = $args[0]
$WEBHOOK_URL = $args[1]

if (!$WEBHOOK_URL) {
  Write-Output "WARNING!!"
  Write-Output "You need to pass the WEBHOOK_URL environment variable as the second argument to this script."
  Write-Output "For details & guide, visit: https://github.com/seoaapp/appveyor-discord-webhook"
  Exit
}

Write-Output "[Webhook]: Sending webhook to Discord..."

Switch ($STATUS) {
  "success" {
    $EMBED_COLOR = 3066993
    $STATUS_MESSAGE = "Passed"
    Break
  }
  "failure" {
    $EMBED_COLOR = 15158332
    $STATUS_MESSAGE = "Failed"
    Break
  }
  default {
    Write-Output "Default!"
    Break
  }
}
$AVATAR = "https://avatars0.githubusercontent.com/u/49084888?s=280&v=4"

if (!$env:APPVEYOR_REPO_COMMIT) {
  $env:APPVEYOR_REPO_COMMIT = "$(git log -1 --pretty="%H")"
}

$AUTHOR_NAME = "$(git log -1 "$env:APPVEYOR_REPO_COMMIT" --pretty="%aN")"
$COMMITTER_NAME = "$(git log -1 "$env:APPVEYOR_REPO_COMMIT" --pretty="%cN")"
$COMMIT_SUBJECT = "$(git log -1 "$env:APPVEYOR_REPO_COMMIT" --pretty="%s")"
$COMMIT_MESSAGE = "$(git log -1 "$env:APPVEYOR_REPO_COMMIT" --pretty="%b")"

if ($AUTHOR_NAME -eq $COMMITTER_NAME) {
  $CREDITS = "$AUTHOR_NAME authored & committed"
}
else {
  $CREDITS = "$AUTHOR_NAME authored & $COMMITTER_NAME committed"
}

if ($env:APPVEYOR_PULL_REQUEST_NUMBER) {
  $COMMIT_SUBJECT = "PR #$env:APPVEYOR_PULL_REQUEST_NUMBER - $env:APPVEYOR_PULL_REQUEST_TITLE"
  $URL = "https://github.com/$env:APPVEYOR_REPO_NAME/pull/$env:APPVEYOR_PULL_REQUEST_NUMBER"
}
else {
  $URL = ""
}

$BUILD_VERSION = [uri]::EscapeDataString($env:APPVEYOR_BUILD_VERSION)
$TIMESTAMP = "$(Get-Date -format s)Z"
$WEBHOOK_DATA = "{
  ""username"": """",
  ""avatar_url"": ""$AVATAR"",
  ""embeds"": [ {
    ""color"": $EMBED_COLOR,
    ""author"": {
      ""name"": ""Job #$env:APPVEYOR_JOB_NUMBER (Build #$env:APPVEYOR_BUILD_NUMBER) $STATUS_MESSAGE - $env:APPVEYOR_REPO_NAME"",
      ""url"": ""https://ci.appveyor.com/project/$env:APPVEYOR_ACCOUNT_NAME/$env:APPVEYOR_PROJECT_SLUG/build/$BUILD_VERSION"",
      ""icon_url"": ""$AVATAR""
    },
    ""title"": ""$COMMIT_SUBJECT"",
    ""url"": ""$URL"",
    ""description"": ""$COMMIT_MESSAGE $CREDITS"",
    ""fields"": [
      {
        ""name"": ""Commit"",
        ""value"": ""[``$($env:APPVEYOR_REPO_COMMIT.substring(0, 7))``](https://github.com/$env:APPVEYOR_REPO_NAME/commit/$env:APPVEYOR_REPO_COMMIT)"",
        ""inline"": true
      },
      {
        ""name"": ""Branch"",
        ""value"": ""[``$env:APPVEYOR_REPO_BRANCH``](https://github.com/$env:APPVEYOR_REPO_NAME/tree/$env:APPVEYOR_REPO_BRANCH)"",
        ""inline"": true
      }
    ],
    ""timestamp"": ""$TIMESTAMP""
  } ]
}"

Invoke-RestMethod -Uri "$WEBHOOK_URL" -Method "POST" -UserAgent "Seoa test Build" `
  -ContentType "application/json" -Header @{"X-Author" = "ttakkku#6166" } `
  -Body $WEBHOOK_DATA

Write-Output "[Webhook]: Successfully sent the webhook."