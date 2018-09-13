# **2.** Getting Started

There are two ways to interact with the package manager: the REPL mode and the Julia API.
In the manual we show the REPL mode, but everything is also possible to do with the
Julia API, see the [API Reference](@ref) section.

This section gives a short overview of how to use Pkg. For more advanced usage refer to
the other sections of the manual.

Let's get started! To enter the Pkg REPL mode, press `]`.

```
(v1.0) pkg>
```

The prompt have now changed to `pkg>`. Inside the parenthesis, before the prompt, we see the
name of the current project. Since we haven't created our own project yet we are in the default
project, which depends on the Julia version, here 1.0. This default environment is located at
`~/.julia/environments/v1.0`.

To access some basic help you can run `pkg> help` and to return to the `julia>` prompt,
either press backspace when the input line is empty or press Ctrl+C.

To add the `Example` package we use the `add` command:

```
(v1.0) pkg> add Example
   Cloning default registries into /home/user/.julia/registries
   Cloning registry General from "https://github.com/JuliaRegistries/General.git"
  Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
 Resolving package versions...
 Installed Example ─ v0.5.1
  Updating `~/.julia/environments/v1.0/Project.toml`
  [7876af07] + Example v0.5.1
  Updating `~/.julia/environments/v1.0/Manifest.toml`
  [7876af07] + Example v0.5.1
  [2a0f44e3] + Base64
  ⋮
  [8dfed614] + Test
```

In this example, we are using a fresh Julia installation, and this is our first time adding
a package using Pkg. By default, Pkg therefore clones Julia's General registry,
and uses this registry to look up packages requested for inclusion in the current environment.

To view the status of the current project
