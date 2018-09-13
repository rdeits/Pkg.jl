# **1.** Introduction

Pkg is the standard package manager for Julia 1.0 and newer. Unlike traditional
package managers, which install and manage a single global set of packages, Pkg
is designed around “environments”: independent sets of packages that can be
local to an individual project or shared and selected by name. The exact set of
packages and versions in an environment is captured in a _manifest file_ which
can be checked into a project repository and tracked in version control,
significantly improving reproducibility of projects. If you’ve ever tried to run
code you haven’t used in a while only to find that you can’t get anything to
work because you’ve updated or uninstalled some of the packages your project was
using, you’ll understand the motivation for this approach. In Pkg, since each
project maintains its own independent set of package versions, you’ll never have
this problem again. Moreover, if you check out a project on a new system, you
can simply materialize the environment described by its manifest file and
immediately be up and running with a known-good set of dependencies.

Since environments are managed and updated independently from each other,
“dependency hell” is significantly alleviated in Pkg. If you want to use the
latest and greatest version of some package in a new project but you’re stuck on
an older version in a different project, that’s no problem – since they have
separate environments they can just use different versions, which are both
installed at the same time in different locations on your system. The location
of each package version is canonical, so when environments use the same versions
of packages, they can share installations, avoiding unnecessary duplication of
the package. Old package versions that are no longer used by any environments
are periodically “garbage collected” by the package manager.

Pkg’s approach to local environments may be familiar to people who have used
Python’s `virtualenv` or Ruby’s `bundler`. In Julia, instead of hacking the
language’s code loading mechanisms to support environments, we have the benefit
that Julia natively understands them. In addition, Julia environments are
“stackable”: you can overlay one environment with another and thereby have
access to additional packages outside of the primary environment. This makes it
easy to work on a project, which provides the primary environment, while still
having access to all your usual dev tools like profilers, debuggers, and so on,
just by having an environment including these dev tools later in the load path.

Last but not least, Pkg is designed to support federated package registries.
This means that it allows multiple registries managed by different parties to
interact seamlessly. In particular, this includes private registries which can
live behind corporate firewalls. You can install and update your own packages
from a private registry with exactly the same tools and workflows that you use
to install and manage official Julia packages. If you urgently need to apply a
hotfix for a public package that’s critical to your company’s product, you can
tag a private version of it in your company’s internal registry and get a fix to
your developers and ops teams quickly and easily without having to wait for an
upstream patch to be accepted and published. Once an official fix is published,
however, you can just upgrade your dependencies and you'll be back on an
official release again.

## Getting Started

If you are in an environment that does not have access to a REPL you can still use the REPL mode commands using
the string macro `pkg` available after `using Pkg`. The command `pkg"cmd"` would be equivalent to executing `cmd`
in the REPL mode.

### Adding packages

There are two ways of adding packages, either using the `add` command or the `dev` command.
The most frequently used one is `add` and its usage is described first.

#### Adding registered packages

In the Pkg REPL packages can be added with the `add` command followed by the name of the package, for example:

```
(v1.0) pkg> add Example
   Cloning default registries into /Users/kristoffer/.julia/registries
   Cloning registry General from "https://github.com/JuliaRegistries/General.git"
  Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] + Example v0.5.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] + Example v0.5.1
  [8dfed614] + Test
```

Here we added the package Example to the current project. In this example, we are using a fresh Julia installation,
and this is our first time adding a package using Pkg. By default, Pkg clones Julia's General registry,
and uses this registry to look up packages requested for inclusion in the current environment.
The status update shows a short form of the package UUID to the left, then the package name, and the version.
Since standard libraries (e.g. `Test`) are shipped with Julia, they do not have a version. The project status contains the packages
you have added yourself, in this case, `Example`:

```
(v1.0) pkg> st
    Status `Project.toml`
  [7876af07] Example v0.5.1
```

The manifest status, in addition, includes the dependencies of explicitly added packages.

```
(v1.0) pkg> st --manifest
    Status `Manifest.toml`
  [7876af07] Example v0.5.1
  [8dfed614] Test
```

It is possible to add multiple packages in one command as `pkg> add A B C`.

After a package is added to the project, it can be loaded in Julia:

```
julia> using Example

julia> Example.hello("User")
"Hello, User"
```

A specific version can be installed by appending a version after a `@` symbol, e.g. `@v0.4`, to the package name:

```
(v1.0) pkg> add Example@0.4
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] + Example v0.4.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] + Example v0.4.1
```

If the master branch (or a certain commit SHA) of `Example` has a hotfix that has not yet included in a registered version,
we can explicitly track a branch (or commit) by appending `#branch` (or `#commit`) to the package name:

```
(v1.0) pkg> add Example#master
  Updating git-repo `https://github.com/JuliaLang/Example.jl.git`
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] ~ Example v0.5.1 ⇒ v0.5.1+ #master (https://github.com/JuliaLang/Example.jl.git)
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] ~ Example v0.5.1 ⇒ v0.5.1+ #master (https://github.com/JuliaLang/Example.jl.git)
```

The status output now shows that we are tracking the `master` branch of `Example`.
When updating packages, we will pull updates from that branch.

To go back to tracking the registry version of `Example`, the command `free` is used:

```
(v1.0) pkg> free Example
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] ~ Example v0.5.1+ #master (https://github.com/JuliaLang/Example.jl.git) ⇒ v0.5.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] ~ Example v0.5.1+ #master )https://github.com/JuliaLang/Example.jl.git) ⇒ v0.5.1
```


#### Adding unregistered packages

If a package is not in a registry, it can still be added by instead of the package name giving the URL to the repository to `add`.

```
(v1.0) pkg> add https://github.com/fredrikekre/ImportMacros.jl
  Updating git-repo `https://github.com/fredrikekre/ImportMacros.jl`
 Resolving package versions...
Downloaded MacroTools ─ v0.4.1
  Updating `~/.julia/environments/v1.0/Project.toml`
  [e6797606] + ImportMacros v0.0.0 # (https://github.com/fredrikekre/ImportMacros.jl)
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [e6797606] + ImportMacros v0.0.0 # (https://github.com/fredrikekre/ImportMacros.jl)
  [1914dd2f] + MacroTools v0.4.1
```

The dependencies of the unregistered package (here `MacroTools`) got installed.
For unregistered packages we could have given a branch (or commit SHA) to track using `#`, just like for registered packages.


#### Adding a local package

Instead of giving a URL of a git repo to `add` we could instead have given a local path to a git repo.
This works similarly to adding a URL. The local repository will be tracked (at some branch) and updates
from that local repo are pulled when packages are updated.
Note that changes to files in the local package repository will not immediately be reflected when loading that package.
The changes would have to be committed and the packages updated in order to pull in the changes.

#### Developing packages

By only using `add` your Manifest will always have a "reproducible state", in other words, as long as the repositories and registries used are still accessible
it is possible to retrieve the exact state of all the dependencies in the project. This has the advantage that you can send your project (`Project.toml`
and `Manifest.toml`) to someone else and they can "instantiate" that project in the same state as you had it locally.
However, when you are developing a package, it is more convenient to load packages at their current state at some path. For this reason, the `dev` command exists.

Let's try to `dev` a registered package:

```
(v1.0) pkg> dev Example
  Updating git-repo `https://github.com/JuliaLang/Example.jl.git`
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] + Example v0.5.1+ [`~/.julia/dev/Example`]
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] + Example v0.5.1+ [`~/.julia/dev/Example`]
```

The `dev` command fetches a full clone of the package to `~/.julia/dev/` (the path can be changed by setting the environment variable `JULIA_PKG_DEVDIR`).
When importing `Example` julia will now import it from `~/.julia/dev/Example` and whatever local changes have been made to the files in that path are consequently
reflected in the code loaded. When we used `add` we said that we tracked the package repository, we here say that we track the path itself.
Note that the package manager will never touch any of the files at a tracked path. It is therefore up to you to pull updates, change branches etc.
If we try to `dev` a package at some branch that already exists at `~/.julia/dev/` the package manager we will simply use the existing path.
For example:

```
(v1.0) pkg> dev Example
  Updating git-repo `https://github.com/JuliaLang/Example.jl.git`
[ Info: Path `/Users/kristoffer/.julia/dev/Example` exists and looks like the correct package, using existing path instead of cloning
```

Note the info message saying that it is using the existing path. As a general rule, the package manager will
never touch files that are tracking a path.

If `dev` is used on a local path, that path to that package is recorded and used when loading that package.
The path will be recorded relative to the project file, unless it is given as an absolute path.

To stop tracking a path and use the registered version again, use `free`

```
(v1.0) pkg> free Example
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] ↓ Example v0.5.1+ [`~/.julia/dev/Example`] ⇒ v0.5.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] ↓ Example v0.5.1+ [`~/.julia/dev/Example`] ⇒ v0.5.1
```

It should be pointed out that by using `dev` your project is now inherently stateful.
Its state depends on the current content of the files at the path and the manifest cannot be "instantiated" by someone else without
knowing the exact content of all the packages that are tracking a path.

Note that if you add a dependency to a package that tracks a local path, the Manifest (which contains the whole dependency graph) will become
out of sync with the actual dependency graph. This means that the package will not be able to load that dependency since it is not recorded
in the Manifest. To update sync the Manifest, use the REPL command `resolve`.

### Removing packages

Packages can be removed from the current project by using `pkg> rm Package`.
This will only remove packages that exist in the project, to remove a package that only
exists as a dependency use `pkg> rm --manifest DepPackage`.
Note that this will remove all packages that depends on `DepPackage`.

### Updating packages

When new versions of packages the project is using are released, it is a good idea to update. Simply calling `up` will try to update *all* the dependencies of the project
to the latest compatible version. Sometimes this is not what you want. You can specify a subset of the dependencies to upgrade by giving them as arguments to `up`, e.g:

```
(v1.0) pkg> up Example
```

The version of all other packages direct dependencies will stay the same. If you only want to update the minor version of packages, to reduce the risk that your project breaks, you can give the `--minor` flag, e.g:

```
(v1.0) pkg> up --minor Example
```

Packages that track a repository are not updated when a minor upgrade is done.
Packages that track a path are never touched by the package manager.

### Pinning a package

A pinned package will never be updated. A package can be pinned using `pin` as for example

```
(v1.0) pkg> pin Example
 Resolving package versions...
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] ~ Example v0.5.1 ⇒ v0.5.1 ⚲
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] ~ Example v0.5.1 ⇒ v0.5.1 ⚲
```

Note the pin symbol `⚲` showing that the package is pinned. Removing the pin is done using `free`

```
(v1.0) pkg> free Example
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] ~ Example v0.5.1 ⚲ ⇒ v0.5.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] ~ Example v0.5.1 ⚲ ⇒ v0.5.1
```

### Testing packages

The tests for a package can be run using `test`command:

```
(v1.0) pkg> test Example
   Testing Example
   Testing Example tests passed
```

### Building packages

The build step of a package is automatically run when a package is first installed.
The output of the build process is directed to a file.
To explicitly run the build step for a package the `build` command is used:

```
(v1.0) pkg> build MbedTLS
  Building MbedTLS → `~/.julia/packages/MbedTLS/h1Vu/deps/build.log`

shell> cat ~/.julia/packages/MbedTLS/h1Vu/deps/build.log
┌ Warning: `wait(t::Task)` is deprecated, use `fetch(t)` instead.
│   caller = macro expansion at OutputCollector.jl:63 [inlined]
└ @ Core OutputCollector.jl:63
...
[ Info: using prebuilt binaries
```

## Creating your own projects

So far we have added packages to the default project at `~/.julia/environments/v1.0`, it is, however, easy to create other, independent, projects.
It should be pointed out if two projects uses the same package at the same version, the content of this package is not duplicated.
In order to create a new project, create a directory for it and then activate that directory to make it the "active project" which package operations manipulate:

```
shell> mkdir MyProject

shell> cd MyProject
/Users/kristoffer/MyProject

(v1.0) pkg> activate .

(MyProject) pkg> st
    Status `Project.toml`
```

Note that the REPL prompt changed when the new project is activated. Since this is a newly created project, the status command show it contains no packages, and in fact, it has no project or manifest file until we add a package to it:

```
shell> ls -l
total 0

(MyProject) pkg> add Example
  Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
 Resolving package versions...
  Updating `Project.toml`
  [7876af07] + Example v0.5.1
  Updating `Manifest.toml`
  [7876af07] + Example v0.5.1
  [8dfed614] + Test

shell> ls -l
total 8
-rw-r--r-- 1 stefan staff 207 Jul  3 16:35 Manifest.toml
-rw-r--r-- 1 stefan staff  56 Jul  3 16:35 Project.toml

shell> cat Project.toml
[deps]
Example = "7876af07-990d-54b4-ab0e-23690620f79a"

shell> cat Manifest.toml
[[Example]]
deps = ["Test"]
git-tree-sha1 = "8eb7b4d4ca487caade9ba3e85932e28ce6d6e1f8"
uuid = "7876af07-990d-54b4-ab0e-23690620f79a"
version = "0.5.1"

[[Test]]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
```

This new environment is completely separate from the one we used earlier.

## Garbage collecting old, unused packages

As packages are updated and projects are deleted, installed packages that were once used will inevitably
become old and not used from any existing project.
Pkg keeps a log of all projects used so it can go through the log and see exactly which projects still exist
and what packages those projects used. The rest can be deleted.
This is done with the `gc` command:

```
(v1.0) pkg> gc
    Active manifests at:
        `/Users/kristoffer/BinaryProvider/Manifest.toml`
        ...
        `/Users/kristoffer/Compat.jl/Manifest.toml`
   Deleted /Users/kristoffer/.julia/packages/BenchmarkTools/1cAj: 146.302 KiB
   Deleted /Users/kristoffer/.julia/packages/Cassette/BXVB: 795.557 KiB
   ...
   Deleted /Users/kristoffer/.julia/packages/WeakRefStrings/YrK6: 27.328 KiB
   Deleted 36 package installations: 113.205 MiB
```

Note that only packages in `~/.julia/packages` are deleted.

## Creating your own packages

A package is a project with a `name`, `uuid` and `version` entry in the `Project.toml` file `src/PackageName.jl` file that defines the module `PackageName`.
This file is executed when the package is loaded.

### Generating files for a package

To generate files for a new package, use `pkg> generate`.

```
(v1.0) pkg> generate HelloWorld
```

This creates a new project `HelloWorld` with the following files (visualized with the external [`tree` command](https://linux.die.net/man/1/tree)):

```jl
shell> cd HelloWorld

shell> tree .
.
├── Project.toml
└── src
    └── HelloWorld.jl

1 directory, 2 files
```

The `Project.toml` file contains the name of the package, its unique UUID, its version, the author and eventual dependencies:

```toml
name = "HelloWorld"
uuid = "b4cd1eb8-1e24-11e8-3319-93036a3eb9f3"
version = "0.1.0"
author = ["Some One <someone@email.com>"]

[deps]
```

The content of `src/HelloWorld.jl` is:

```jl
module HelloWorld

greet() = print("Hello World!")

end # module
```

We can now activate the project and load the package:

```jl
pkg> activate .

julia> import HelloWorld

julia> HelloWorld.greet()
Hello World!
```

### Adding dependencies to the project

Let’s say we want to use the standard library package `Random` and the registered package `JSON` in our project.
We simply `add` these packages (note how the prompt now shows the name of the newly generated project,
since we are inside the `HelloWorld` project directory):

```
(HelloWorld) pkg> add Random JSON
 Resolving package versions...
  Updating "~/Documents/HelloWorld/Project.toml"
 [682c06a0] + JSON v0.17.1
 [9a3f8284] + Random
  Updating "~/Documents/HelloWorld/Manifest.toml"
 [34da2185] + Compat v0.57.0
 [682c06a0] + JSON v0.17.1
 [4d1e1d77] + Nullables v0.0.4
 ...
```

Both `Random` and `JSON` got added to the project’s `Project.toml` file, and the resulting dependencies got added to the `Manifest.toml` file.
The resolver has installed each package with the highest possible version, while still respecting the compatibility that each package enforce on its dependencies.

We can now use both `Random` and `JSON` in our project. Changing `src/HelloWorld.jl` to

```
module HelloWorld

import Random
import JSON

greet() = print("Hello World!")
greet_alien() = print("Hello ", Random.randstring(8))

end # module
```

and reloading the package, the new `greet_alien` function that uses `Random` can be used:

```
julia> HelloWorld.greet_alien()
Hello aT157rHV
```

### Adding a build step to the package.

The build step is executed the first time a package is installed or when explicitly invoked with `build`.
A package is built by executing the file `deps/build.jl`.

```
shell> cat deps/build.log
I am being built...

(HelloWorld) pkg> build
  Building HelloWorld → `deps/build.log`
 Resolving package versions...

shell> cat deps/build.log
I am being built...
```

If the build step fails, the output of the build step is printed to the console

```
shell> cat deps/build.jl
error("Ooops")

(HelloWorld) pkg> build
  Building HelloWorld → `deps/build.log`
 Resolving package versions...
┌ Error: Error building `HelloWorld`:
│ ERROR: LoadError: Ooops
│ Stacktrace:
│  [1] error(::String) at ./error.jl:33
│  [2] top-level scope at none:0
│  [3] include at ./boot.jl:317 [inlined]
│  [4] include_relative(::Module, ::String) at ./loading.jl:1071
│  [5] include(::Module, ::String) at ./sysimg.jl:29
│  [6] include(::String) at ./client.jl:393
│  [7] top-level scope at none:0
│ in expression starting at /Users/kristoffer/.julia/dev/Pkg/HelloWorld/deps/build.jl:1
└ @ Pkg.Operations Operations.jl:938
```

### Adding tests to the package

When a package is tested the file `test/runtests.jl` is executed.

```
shell> cat test/runtests.jl
println("Testing...")
(HelloWorld) pkg> test
   Testing HelloWorld
 Resolving package versions...
Testing...
   Testing HelloWorld tests passed
```

#### Test-specific dependencies

Sometimes one might want to use some packages only at testing time but not
enforce a dependency on them when the package is used. This is possible by
adding dependencies to `[extras]` and a `test` target in `[targets]` to the Project file.
Here we add the `Test` standard library as a test-only dependency by adding the
following to the Project file:

```
[extras]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[targets]
test = ["Test"]
```

We can now use `Test` in the test script and we can see that it gets installed on testing:

```
shell> cat test/runtests.jl
using Test
@test 1 == 1

(HelloWorld) pkg> test
   Testing HelloWorld
 Resolving package versions...
  Updating `/var/folders/64/76tk_g152sg6c6t0b4nkn1vw0000gn/T/tmpPzUPPw/Project.toml`
  [d8327f2a] + HelloWorld v0.1.0 [`~/.julia/dev/Pkg/HelloWorld`]
  [8dfed614] + Test
  Updating `/var/folders/64/76tk_g152sg6c6t0b4nkn1vw0000gn/T/tmpPzUPPw/Manifest.toml`
  [d8327f2a] + HelloWorld v0.1.0 [`~/.julia/dev/Pkg/HelloWorld`]
   Testing HelloWorld tests passed```
```


## Precompiling a project

The REPL command `precompile` can be used to precompile all the dependencies in the project. You can for example do

```
(HelloWorld) pkg> update; precompile
```

to update the dependencies and then precompile them.

## Preview mode

If you just want to see the effects of running a command, but not change your state you can `preview` a command.
For example:

```
(HelloWorld) pkg> preview add Plots
```

or

```
(HelloWorld) pkg> preview up
```

will show you the effects of adding `Plots`, or doing a full upgrade, respectively, would have on your project.
However, nothing would be installed and your `Project.toml` and `Manifest.toml` are untouched.

## Using someone else's project

Simply clone their project using e.g. `git clone`, `cd` to the project directory and call

```
(v1.0) pkg> activate .

(SomeProject) pkg> instantiate
```

If the project contains a manifest, this will install the packages in the same state that is given by that manifest.
Otherwise, it will resolve the latest versions of the dependencies compatible with the project.


