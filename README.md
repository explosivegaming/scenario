<p align="center">
  <img alt="logo" src="https://avatars2.githubusercontent.com/u/39745392?s=200&v=4" width="120">
  <br>
  <a href="https://github.com/explosivegaming/scenario/tags">
    <img src="https://img.shields.io/github/tag/explosivegaming/scenario.svg?label=Release" alt="Release">
  </a>
  <a href="https://github.com/explosivegaming/scenario/archive/master.zip">
    <img src="https://img.shields.io/github/downloads/explosivegaming/scenario/total.svg?label=Downloads" alt="Downloads">
  </a>
  <a href="https://github.com/explosivegaming/scenario/stargazers">
    <img src="https://img.shields.io/github/stars/explosivegaming/scenario.svg?label=Stars" alt="Star">
  </a>
  <a href="http://github.com/explosivegaming/scenario/fork">
    <img src="https://img.shields.io/github/forks/explosivegaming/scenario.svg?label=Forks" alt="Fork">
  </a>
  <a href="https://www.codefactor.io/repository/github/explosivegaming/scenario">
    <img src="https://www.codefactor.io/repository/github/explosivegaming/scenario/badge" alt="CodeFactor">
  </a>
  <a href="https://discord.explosivegaming.nl">
    <img src="https://discordapp.com/api/guilds/260843215836545025/widget.png?style=shield" alt="Discord">
  </a>
</p>
<h1 align="center">ExpGaming Scenario Repository</h2>

## Explosive Gaming

Explosive Gaming (often ExpGaming) is a server hosting community with a strong focus on Factorio and games that follow similar ideas. Our Factorio server are known for hosting large maps with the main goal of being a "mega base" which can produce as much as possible within our reset schedule. Although these servers tend to attract the more experienced players, our servers are open to everyone. You can find us through our [website], [discord], [wiki], or in the public games tab in Factorio (ExpGaming S1, ExpGaming S2, etc.).

## Use and Installation

1) Download this [git repository](https://github.com/explosivegaming/scenario/archive/master.zip) for the stable release. The dev branch can be found [here](https://github.com/explosivegaming/scenario/archive/dev.zip) for those who want the latest features. See [releases](#releases) for other release branches.

2) Extract the downloaded zip file from the branch you downloaded into Factorio's scenario directory:
    * Windows: `%appdata%\Factorio\scenarios`
    * Linux: `~/.factorio/scenarios`

3) Within the scenario you can find `./config/_file_loader.lua` which contains a list of all the modules that will be loaded by the scenario; simply comment out (or remove) features you do not want but note that some modules may load other modules as dependencies even when removed from the list.

4) More advanced users may want to play with the other configs files within `./config` but please be aware that some of the config files will require a basic understanding of lua while others may just be a list of values.

5) Once you have made any config changes that you wish to make open Factorio, select play, then start scenario (or host scenario from within multiplayer tab), and select the scenario which will be called `scenario-master` if you have downloaded the latest stable release and have not changed the folder name.

6) The scenario will now load all the selected modules and start the map, any errors or exceptions raised in the scenario should not cause a game/server crash, so if any features do not work as expected then it may be returning an error in the log.
Please report these errors to [the issues page](issues).

## Contributing

All are welcome to make pull requests and issues for this scenario, if you are in any doubt, please ask someone in our [discord]. If you do not know lua and don't feel like learning you can always make a [feature request]. To find out what we already have please read our [docs]. Please keep in mind while making code changes:

* New features should have the branch names: `feature/feature-name`
* New features are merged into `dev` after it has been completed, this can be done through a pull request.
* After a number of features have been added a release branch is made: `release/X.Y.0`
* Bug fixes and localization can be made to the release branch with a pull request rather than into dev.
* A release is merged into `master` on the following friday after it is considered stable.
* Patches may be named `patch/X.Y.Z` and will be merged into `dev` and then `master` when appropriate.

## Releases

| Scenario Version* | Version Name | Factorio Version** |
|---|---|---|
| [v6.1][s6.1] | External Data Overhaul | [v1.0.0][f1.0.0] |
| [v6.0][s6.0] | Gui / 0.18 Overhaul | [v0.18.17][f0.18.17] |
| [v5.10][s5.10] | Data Store Rewrite | [v0.17.71][f0.17.71] |
| [v5.9][s5.9] | Control Modules and Documentation | [v0.17.63][f0.17.63] |
| [v5.8][s5.8] | Home and Chat Bot | [v0.17.47][f0.17.49] |
| [v5.7][s5.7] | Warp System | [v0.17.47][f0.17.47] |
| [v5.6][s5.6] | Information Guis | [v0.17.44][f0.17.44] |
| [v5.5][s5.5] | Gui System | [v0.17.43][f0.17.43] |
| [v5.4][s5.4] | Admin Controls | [v0.17.32][f0.17.32] |
| [v5.3][s5.3] | Custom Roles | [v0.17.28][f0.17.28] |
| [v5.2][s5.2] | Quality of life | [v0.17.22][f0.17.22] |
| [v5.1][s5.1] | Permission Groups | [v0.17.13][f0.17.13] |
| [v5.0][s5.0] | 0.17 Overhaul| [v0.17][f0.17.9] |
| [v4.0][s4.0] | Softmod Manager | [v0.16.51][f0.16.51] |
| [v3.0][s3.0] | 0.16 Overhaul | [v0.16][f0.16] |
| [v2.0][s2.0] | Localization and clean up | [v0.15][f0.15] |
| [v1.0][s1.0] | Modulation | [v0.15][f0.15] |
| [v0.1][s0.1] | First Tracked Version | [v0.14][f0.14] |

\* Scenario patch versions have been omitted.

\*\* Factorio versions show the version they were made for, often the minimum requirement.

[s6.1]: https://github.com/explosivegaming/scenario/releases/tag/6.1.0
[s6.0]: https://github.com/explosivegaming/scenario/releases/tag/6.0.0
[s5.10]: https://github.com/explosivegaming/scenario/releases/tag/5.10.0
[s5.9]: https://github.com/explosivegaming/scenario/releases/tag/5.9.0
[s5.8]: https://github.com/explosivegaming/scenario/releases/tag/5.8.0
[s5.7]: https://github.com/explosivegaming/scenario/releases/tag/5.7.0
[s5.6]: https://github.com/explosivegaming/scenario/releases/tag/5.6.0
[s5.5]: https://github.com/explosivegaming/scenario/releases/tag/5.5.0
[s5.4]: https://github.com/explosivegaming/scenario/releases/tag/5.4.0
[s5.3]: https://github.com/explosivegaming/scenario/releases/tag/5.3.0
[s5.2]: https://github.com/explosivegaming/scenario/releases/tag/5.2.0
[s5.1]: https://github.com/explosivegaming/scenario/releases/tag/5.1.0
[s5.0]: https://github.com/explosivegaming/scenario/releases/tag/5.0.0
[s4.0]: https://github.com/explosivegaming/scenario/releases/tag/v4.0
[s3.0]: https://github.com/explosivegaming/scenario/releases/tag/v3.0
[s2.0]: https://github.com/explosivegaming/scenario/releases/tag/v2.0
[s1.0]: https://github.com/explosivegaming/scenario/releases/tag/v1.0
[s0.1]: https://github.com/explosivegaming/scenario/releases/tag/v0.1

[f1.0.0]: https://wiki.factorio.com/Version_history/1.0.0#1.0.0
[f0.18.17]: https://wiki.factorio.com/Version_history/0.18.0#0.18.17
[f0.17.71]: https://wiki.factorio.com/Version_history/0.17.0#0.17.71
[f0.17.63]: https://wiki.factorio.com/Version_history/0.17.0#0.17.63
[f0.17.49]: https://wiki.factorio.com/Version_history/0.17.0#0.17.49
[f0.17.47]: https://wiki.factorio.com/Version_history/0.17.0#0.17.47
[f0.17.44]: https://wiki.factorio.com/Version_history/0.17.0#0.17.44
[f0.17.43]: https://wiki.factorio.com/Version_history/0.17.0#0.17.43
[f0.17.32]: https://wiki.factorio.com/Version_history/0.17.0#0.17.32
[f0.17.28]: https://wiki.factorio.com/Version_history/0.17.0#0.17.28
[f0.17.22]: https://wiki.factorio.com/Version_history/0.17.0#0.17.22
[f0.17.13]: https://wiki.factorio.com/Version_history/0.17.0#0.17.13
[f0.17.9]: https://wiki.factorio.com/Version_history/0.17.0#0.17.9
[f0.16.51]: https://wiki.factorio.com/Version_history/0.16.0#0.16.51
[f0.16]: https://wiki.factorio.com/Version_history/0.16.0
[f0.15]: https://wiki.factorio.com/Version_history/0.15.0
[f0.14]: https://wiki.factorio.com/Version_history/0.14.0

## License

The Explosive Gaming codebase is licensed under the [GNU General Public License v3.0](LICENSE)

[docs]: https://explosivegaming.github.io/scenario/
[issues]: https://github.com/explosivegaming/scenario/issues/new/choose
[website]: https://explosivegaming.nl
[discord]: https://discord.explosivegaming.nl
[wiki]: https://wiki.explosivegaming.nl
