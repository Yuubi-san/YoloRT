# YoloRT

*It's not just a crutch, it's a legit wheelchair!*

## What this is

Patches and scripts to make the C++ "binding" of Windows Runtime (WinRT) more
C++ and less microsoft. In particular, to make it usable with MinGW. Little
effort (if any) has been put into keeping the code consumable by MSVC (I'm not
*against* the idea, but have neither MSVC nor the time).


## Why this exists

'Cause life is too short to upstream the fixes (again, not because I'm against
it) or maintain a fork.


## Building

These instructions assume you (1) don't have the original (MSVC-specific) winrt
headers to apply the patches to and (2) want to generate said headers.

### Dependencies

`make`, `cppwinrt`, coreutils, `grep`, `patch`, `sed`, `xargs`. On MSYS2, this
would be:

`# pacman --sync --needed make coreutils grep patch sed findutils`

#### `cppwinrt` (the generator)
If you don't have (the desired version of) `cppwinrt` and don't want to / cannot
build from [source](https://github.com/microsoft/cppwinrt), you can obtain it by
invoking

`$ make bin/cppwinrt.exe`

This will download the latest build
[from nuget.org](https://www.nuget.org/packages/Microsoft.Windows.CppWinRT/).
You'll need `curl` and `unzip` (if using MSYS2: `# pacman --sync --needed curl
unzip`). If latest doesn't work for you in the end, try

`$ make CPPWINRT_VERSION=2.0.210122.3 bin/cppwinrt.exe`

This will get you the latest (and currently the only) version the patches are
known to be compatible with.

### Actual building

```
$ make originals
$ make --jobs=$(nproc)
```

The fist command generates original (MSVC-specific) winrt headers from [windows
metadata (.winmd)](https://docs.microsoft.com/en-us/uwp/winrt-cref/winmd-files)
files. By default it looks for them in `$WINDIR/SysNative/WinMetadata` or maybe
in `$WINDIR/System32/WinMetadata` or thereabouts. If needed, override this using
the `CPPWINRT_INPUT` variable (see also `cppwinrt -help` for possible special
values to use here).

The second command populates the `include` directory with the final output:
patched/wrapped winrt headers usable with MinGW. It can take some time.

### Testing

It is highly recommended to run tests if you have some other combination than
windows 8.1 x86-64 & cppwinrt 2.0.210122.3 & g++ 10:

`$ (cd test && make --jobs=$(nproc))`

You'll actually need MinGW for this. The package names in MSYS2 repo are
`mingw-w64-{i686,x86_64}-gcc`.

Right now, the testing procedure comprises, mostly: including each of the API
headers into separate hello-world-ish programs, compiling and running them. It
takes a while. Also, the XAML headers will eat all your RAM and ask for
seconds; reduce `--jobs` then.

### Installation

Finally,

`# make install`

to copy the headers to `$PREFIX/include`, where `$PREFIX` is `/usr/local` by
default.


## Usage

Currently requires a hacky incantation in the form of an option added to your
preprocessor flags (`CPPFLAGS`):

`-iquote /usr/local/include/winrt/yolort_impl`

This assumes `/usr/local/include` is where you have the headers installed. If
you have them in an unusual or project-specific place, don't forget to also add
that place to `CPLUS_INCLUDE_PATH` or specify via the `-I` option.

Otherwise, `#include <winrt/Windows.Foo.h>` as usual.


## What works

The module unit (`winrt/winrt.ixx`) likely doesn't and, thus, isn't present in
the final output. (Meh, GCC doesn't yet really have modules support anyway.)

A tiny piece (don't know how important) of `winrt/Windows.System.h` has been
YOLO-cut to make compilable the version of it generated from windows 8.1
metadata files, which, I presume, lack some things present in windows 10
metadata, and I presume the generator assumes only w10 exists. Or it's a bug in
w8.1 metadata.


## Examples

See the [`example`](example/) subdir. Currently only a minimal working example
of sending toast notifications is provided. To build, run `$ make` from within
the directory.


## License

[MIT](LICENSE.md)


## Contributing

The most useful thing right now is to try this on as many projects, systems,
architectures, cppwinrt versions and compilers as possible, and report any
issues, including compiler warnings and deficiencies in good developer
experience (DX?).
