Outburst
========

## Requirements

To run this project, you should have a recent stable version of [NodeJS](http://nodejs.org) 
(f.ex. 0.4.11) as well as the [npm package manager](https://github.com/isaacs/npm).

## Setup

Enter the folder of this repo and install dependencies with ``npm``. Then use ``make`` to 
start the server.

    npm update
    make

That's it! Then visit [http://localhost:8000/game/]() to play.

## Project structure

The game server is in `/gameserver`. The code for the game itself is in `/public/game/scripts`.

Some of the gameplay is done in shared code in `/public/game/shared`. The rest is done only on the
server, with the state transferred to dumb clients.

## Game loop

Look at `/public/game/shared/constants.coffee` to see that currently the game processes inputs
and calculates world changes 50 times per second, and sends input and world packets 25 times per second.

The game server uses setInterval to run a onTick function in `/gameserver/main.coffee` while the game
requests an animation frame from the browser to run the onFrame function in `/public/game/scripts/main.coffee`.