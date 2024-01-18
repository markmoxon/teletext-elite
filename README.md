# Fully documented source code for Teletext Elite

[BBC Micro cassette Elite](https://github.com/markmoxon/cassette-elite-beebasm) | [BBC Micro disc Elite](https://github.com/markmoxon/disc-elite-beebasm) | [6502 Second Processor Elite](https://github.com/markmoxon/6502sp-elite-beebasm) | [BBC Master Elite](https://github.com/markmoxon/master-elite-beebasm) | [Acorn Electron Elite](https://github.com/markmoxon/electron-elite-beebasm) | [NES Elite](https://github.com/markmoxon/nes-elite-beebasm) | [Elite-A](https://github.com/markmoxon/elite-a-beebasm) | **Teletext Elite** | [Elite Universe Editor](https://github.com/markmoxon/elite-universe-editor) | [Elite Compendium](https://github.com/markmoxon/elite-compendium) | [Elite over Econet](https://github.com/markmoxon/elite-over-econet) | [Flicker-free C64 Elite](https://github.com/markmoxon/c64-elite-flicker-free) | [Aviator](https://github.com/markmoxon/aviator-beebasm) | [Revs](https://github.com/markmoxon/revs-beebasm)

![Screenshot of the Teletext Elite title screen](https://www.bbcelite.com/images/teletext_elite/title.png)

This repository contains source code for Teletext Elite on the BBC Micro and BBC Master 128.

Teletext Elite is the full version of BBC Micro disc Elite, but all graphics have been converted to use the BBC's teletext mode 7. For more information, see the [bbcelite.com website](https://www.bbcelite.com/hacks/teletext_elite.html).

This repository contains the full source code for Teletext Elite, which you can build yourself on a modern computer. See below for more details on [browsing the source code](#browsing-the-source-in-an-ide) and [building Teletext Elite from the source](#building-teletext-elite-from-the-source).

![Screenshot of the station in the rear view in Teletext Elite](https://www.bbcelite.com/images/teletext_elite/station_view.png)

## Contents

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Browsing the source in an IDE](#browsing-the-source-in-an-ide)

* [Folder structure](#folder-structure)

* [Elite Compendium](#elite-compendium)

* [Building Teletext Elite from the source](#building-teletext-elite-from-the-source)

  * [Requirements](#requirements)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Build options](#build-options)

## Acknowledgements

Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1984.

The code on this site has been reconstructed from a disassembly of the version released on [Ian Bell's personal website](http://www.elitehomepage.org/).

The commentary and Teletext conversion code are copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

The Teletext routines are by Kieran Connell and Simon Morris of the Bitshifters, and were adapted from Bresenham routines by Rich Talbot-Watkins. See the [Bitshifters teletextr](https://github.com/bitshifters/teletextr/tree/master/lib) repository for the original code.

Huge thanks are due to the original authors for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://www.bbcelite.com/about_site/about_this_project.html).

Thanks to the Bitshifters for their help in building the [musical version of BBC Micro Elite](#bbc-micro-elite-with-music), and in particular Kieran Connell, Simon Morris and Negative Charge for the music player and ported music files. Thanks also to Tricky and J.G.Harston for their sideways RAM utilities.

The following archive from Ian Bell's personal website forms the basis for this project:

* [BBC Elite, disc version](http://www.elitehomepage.org/archive/a/a4100000.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that Teletext Elite is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Browsing the source in an IDE

If you want to browse the source in an IDE, you might find the following useful.

* The most interesting files are in the [main-sources](1-source-files/main-sources) folder:

  * The main game's source code is in the [elite-source-flight.asm](1-source-files/main-sources/elite-source-flight.asm) and [elite-source-docked.asm](1-source-files/main-sources/elite-source-docked.asm) files (for when we're in-flight or docked) - this is the motherlode and probably contains all the stuff you're interested in.

  * The game's loader is in the [elite-loader1.asm](1-source-files/main-sources/elite-loader1.asm), [elite-loader2.asm](1-source-files/main-sources/elite-loader2.asm) and [elite-loader3.asm](1-source-files/main-sources/elite-loader3.asm) files - these are mainly concerned with setup and copy protection. The last file contains the source for the Saturn loading screen.

  * The following source files contain Teletext-specific routines and macros, and are included in the main source files as required: [elite-teletext-docked.asm](1-source-files/main-sources/elite-teletext-docked.asm), [elite-teletext-flight.asm](1-source-files/main-sources/elite-teletext-flight.asm), [elite-teletext-lines.asm](1-source-files/main-sources/elite-teletext-lines.asm), [elite-teletext-macros.asm](1-source-files/main-sources/elite-teletext-macros.asm), [elite-teletext-sixels.asm](1-source-files/main-sources/elite-teletext-sixels.asm) and [elite-teletext-text.asm](1-source-files/main-sources/elite-teletext-text.asm)

* It's probably worth skimming through the [notes on terminology and notations](https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html) on the accompanying website, as this explains a number of terms used in the commentary, without which it might be a bit tricky to follow at times (in particular, you should understand the terminology I use for multi-byte numbers).

* The annotated source files contain both the original Acornsoft code and all of the modifications made to convert the original into Teletext Elite, so you can look through the source to see exactly what's changed in order to convert it to mode 7. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the Teletext Elite binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

* Teletext Elite incorporates the flicker-free algorithm from BBC Master Elite, which reduces the amount of flicker in the ship-drawing routines, and it also includes flicker-free planet-drawing routines. For more information on flicker-free Elite, see the [hacks section of the accompanying website](https://www.bbcelite.com/hacks/flicker-free_elite.html).

* There are loads of routines and variables in Elite - literally hundreds. You can find them in the source files by searching for the following: `Type: Subroutine`, `Type: Variable`, `Type: Workspace` and `Type: Macro`.

* If you know the name of a routine, you can find it by searching for `Name: <name>`, as in `Name: SCAN` (for the 3D scanner routine) or `Name: LL9` (for the ship-drawing routine).

* The source code is designed to be read at an 80-column width and with a monospaced font, just like in the good old days.

I hope you enjoy exploring the inner workings of Teletext Elite as much as I've enjoyed writing it.

## Folder structure

There are three main folders in this repository, which reflect the order of the build process.

* [1-source-files](1-source-files) contains all the different source files, such as the main assembler source files, image binaries, fonts, boot files and so on.

* [2-build-files](2-build-files) contains build-related scripts, such as the checksum and encryption script.

* [3-assembled-output](3-assembled-output) contains the output from the assembly process, when the source files are assembled and the results processed by the build files.

The source files in the first folder are heavily based on the repositories containing the [fully documented source code for the disc version of Elite on the BBC Micro](https://github.com/markmoxon/disc-elite-beebasm).

## Elite Compendium

This repository also includes a version of Teletext Elite for the Elite Compendium, which incorporates all the available hacks in one game. The Compendium version is in a separate branch called `elite-compendium`, which is included in the [Elite Compendium](https://github.com/markmoxon/elite-compendium) repository as a submodule.

The annotated source files in the `elite-compendium` branch contain both the original Acornsoft code and all of the modifications for the Elite Compendium, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the Compendium binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on the Elite Compendium, see the [hacks section of the accompanying website](https://www.bbcelite.com/hacks/elite_compendium.html).

## Building Teletext Elite from the source

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

### Requirements

You will need the following to build Elite from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.

* Python. Both versions 2.7 and 3.x should work.

* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

For details of how the build process works, see the [build documentation on bbcelite.com](https://www.bbcelite.com/about_site/building_elite.html).

Let's look at how to build Elite from the source.

### Windows

For Windows users, there is a batch file called `make.bat` which you can use to build the game. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.bat`).

All being well, entering the following into a command window:

```
make.bat
```

will produce a file called `teletext-elite.ssd` in the project folder that contains Teletext Elite, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, entering the following into a terminal window:

```
make
```

will produce a file called `teletext-elite.ssd` in the project folder that contains Teletext Elite, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Build options

By default the build process will create a typical Elite game disc with a standard commander. There is one argument you can pass to the build to change how it works. It is:

* `commander=max` - Start with a maxed-out commander (specifically, this is the test commander file from the original source, which is almost but not quite maxed-out)

So, for example:

`make commander=max`

will build Teletext Elite with a maxed-out commander.

---

Right on, Commanders!

_Mark Moxon_
