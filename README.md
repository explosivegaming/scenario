## ExpGaming Repository [![CodeFactor](https://www.codefactor.io/repository/github/badgamernl/explosivegaming-main/badge)](https://www.codefactor.io/repository/github/badgamernl/explosivegaming-main) [![dev chat](https://discordapp.com/api/guilds/260843215836545025/widget.png?style=shield)](https://discord.me/explosivegaming)

#### Using The Core Files
1. Copy the core folder and the StdLib File 
2. Copy the control.lua and edit the load.lua in each file
3. The require order is imporant in the control.lua
4. Use playerRanks.lua to edit the rank system
5. Add your own files to the addons folder and require them in the load.lua

#### Using The Addons
1. Copy the addons folder
2. Remove any you do not wish to have
3. Remove the require inside the addons load.lua

#### Making Your Own Addons
* You must have the core files and StdLib
* The load.lua is the only file outside your own you need to edit
* Keep the core files upto data with the core branch
* Try not to edit StdLib or the core files
* There is many comments inside the core files to descripe how to use them.

#### Stand Alone File
* This file ocntains a few scripts from else where which dont require any lib
* StdLib and ExpLib are the only exceptions as these are very basic functions
* Any files added to this folder must be given proper sourses
* Each file must be self contained with no _G varibles

#### Forks and Pull Requests
* We are happy for people to make pull requests if you wish to help make our server better
* You can add comments at the start of files to mark any changes you make, so you are credited
* Don't make small changes to the core files, please only big meaningful changes
* Don't be afraid to make a pull request as if it fixes something then it's a good change
