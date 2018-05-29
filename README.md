<p align="center">
  <img alt="logo" src="https://avatars2.githubusercontent.com/u/39745392?s=200&v=4" width="120">
  <br>
  <a href="https://github.com/explosivegaming/scenario/tags">
    <img src="https://img.shields.io/github/tag/explosivegaming/scenario.svg?label=tag" alt="Tag">
  </a>
  <a href="https://github.com/explosivegaming/scenario/stargazers">
    <img src="http://github-svg-buttons.herokuapp.com/star.svg?user=explosivegaming&repo=scenario&style=flat&background=007ec6" alt="Star">
  </a>
  <a href="http://github.com/explosivegaming/scenario/fork">
    <img src="http://github-svg-buttons.herokuapp.com/fork.svg?user=explosivegaming&repo=scenario&style=flat&background=007ec6" alt="Fork">
  </a>
  <a href="https://www.codefactor.io/repository/github/badgamernl/explosivegaming-main">
    <img src="https://www.codefactor.io/repository/github/badgamernl/explosivegaming-main/badge" alt="CodeFactor">
  </a>
  <a href="https://discord.me/explosivegaming">
    <img src="https://discordapp.com/api/guilds/260843215836545025/widget.png?style=shield" alt="Discord">
  </a>
</p>
<h2 align="center">ExpGaming Scenario Repository</h2>

#### Using The Core Files
1. Copy the core folder and the StdLib File 
2. Copy the control.lua and edit the load.lua in each file
3. The require order is important in the control.lua
4. Use playerRanks.lua to edit the rank system
5. Add your own files to the addons folder and require them in the load.lua

#### Using The Addons
1. Copy the addons folder
2. Remove any you do not wish to have
3. Remove the require inside the addons load.lua

#### Making Your Own Addons
* You must have the core files and StdLib
* The load.lua is the only file outside your own you need to edit
* Keep the core files updated with the core branch
* Try not to edit StdLib or the core files
* There is many comments inside the core files to describe how to use them.

#### Stand Alone File
* This file contains a few scripts from else where which don't require any lib
* StdLib and ExpLib are the only exceptions as these are very basic functions
* Any files added to this folder must be given proper sources
* Each file must be self contained with no _G variables

#### Forks and Pull Requests
* We are happy for people to make pull requets if you wish to help make our server better
* You can add a comment at the start of the file to mark any changes you make, for the credit
* Your server is a comunity server, it is all about the people and feedback is good
* Dont make small changes to the core files, please only big meaniful changes
* Dont be afraid to make a pull request as if it fixes something then its a good change
