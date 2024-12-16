
# ESX_RPCHAT

## Overview

This project is a text-based roleplay chat system built on the FiveM platform, utilizing the ESX framework. It provides a variety of chat commands for role-playing interactions, including proximity-based messaging, private messaging, and administrative tools for managing player reports and help requests.

## Features

- **Roleplay Commands**: Includes `/me`, `/my`, `/do`, and their low proximity variants for immersive roleplay actions.
- **Communication Commands**: Commands like `/say`, `/whisper`, `/shout`, and their targeted variants allow players to communicate in different proximities.
- **Administrative Tools**: Commands for reporting issues, accepting or trashing reports, and listing pending reports.
- **Player Interaction**: Commands to find players by ID or name, flip a coin, and roll dice.
- **Chat Management**: Ability to clear chat and manage chat suggestions dynamically.

## Usage

### Commands

#### Roleplay Commands
- **`/me [action]`**: Describes an action performed by the player.
- **`/my [action]`**: Describes an action related to the player's character.
- **`/do [description]`**: Describes a scene or action.
- **`/melow [action]`**: Low proximity roleplay action.
- **`/mylow [action]`**: Low proximity roleplay action.
- **`/dolow [description]`**: Low proximity roleplay action.

#### Communication Commands
- **`/say [message]`**: Sends a message to nearby players.
- **`/sayto [Player ID] [message]`**: Sends a message to a specific player.
- **`/b [message]`**: Local out of character chat.
- **`/blow [message]`**: Low proximity local out of character chat.
- **`/bto [Player ID] [message]`**: Local out of character chat to a specific player.
- **`/blowto [Player ID] [message]`**: Low proximity local out of character chat to a specific player.
- **`/low [message]`**: Say something in a low proximity.
- **`/lowto [Player ID] [message]`**: Say something in a low proximity to a specific player.
- **`/whisper [message]`**: Whisper something.
- **`/whisperto [Player ID] [message]`**: Whisper something to a specific player.
- **`/shout [message]`**: Shout something.
- **`/shoutto [Player ID] [message]`**: Shout something to a specific player.
- **`/pm [Player ID or Name] [message]`**: Send a private message to a specific player.

#### Administrative Commands
- **`/report [message]`**: Submits a report to the admins.
- **`/acceptreport [report ID]`**: Accepts a pending report.
- **`/trashreport [report ID]`**: Trashes a pending report.
- **`/listreports`**: Lists all pending reports.
- **`/helpme [question]`**: Request help from testers.
- **`/accepthelpme [request ID]`**: Accept a help request.
- **`/trashhelpme [request ID]`**: Trash a help request.
- **`/listhelpmes`**: List all pending help requests.

#### Player Interaction
- **`/id [Player ID or Name]`**: Finds a player by ID or name.
- **`/flipcoin`**: Flips a coin and displays the result.
- **`/dice [1-3]`**: Rolls up to three dice and displays the result.

#### Chat Management
- **`/clearchat`**: Clears the player's chat.

#### Miscellaneous
- **`/stats`**: Show your character statistics.

### Proximity Messaging

Commands like `/me`, `/my`, `/do`, `/flipcoin`, and `/dice` use proximity-based messaging, ensuring that only players within a certain range can see the messages. This enhances the role-playing experience by maintaining realism.

## Configuration

### ESX Identity

The system supports ESX Identity for player names. Ensure the following configurations are set in your ESX setup:

- `Config.EnableESXIdentity`: Set to `true` to enable ESX Identity.
- `Config.OnlyFirstname`: Set to `true` to use only the player's first name.

### Text Range

The default text range for proximity-based messages is set to 15.0 units. This can be adjusted in the `server.lua` file if needed.
