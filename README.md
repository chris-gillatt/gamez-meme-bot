# [![CI](https://github.com/chris-gillatt/gamez-meme-bot/actions/workflows/main.yml/badge.svg)](https://github.com/chris-gillatt/gamez-meme-bot/actions/workflows/main.yml) gamez-meme-bot

Meme bot to post to the Gamez Discord server. 

Posts a meme four times per day, every six hours.

## Workflow

The GitHub Actions workflow runs on a six-hour schedule and also supports manual dispatch.

Configure the `WEBHOOK` repository secret with the Discord webhook URL before enabling the workflow.

If the repository is inactive for long enough, GitHub may automatically disable scheduled runs. Re-enable the workflow from the Actions tab if that happens.

