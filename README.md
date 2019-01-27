# dmutil

AssetBundle download tool for CGSS (THE IDOLM@STER CINDERELLA GIRLS STARLIGHT STAGE) and MLTD (THE IDOLM@STER MILLION LIVE THEATER DAYS).

## Prerequisits

- ruby
- bundler (you can install it by `gem install bundler`)

## Usage

At first, clonse the repository and initialize.

```
$ git clone https://github.com/grainrigi/dmutil/
$ cd dmutil
$ bundler install
```

Then launch the shell.

```
$ ./launch.sh
dmutil> 
```

### Commands

- `fetch [filename]`
fetch an AssetBundle from remote.
Tab completion is enabled for filename.

- `exit`
exit the program.


## Acknowledgement

This tool uses [matsurihi.me](https://matsurihi.me/) for fetching the asset version.
