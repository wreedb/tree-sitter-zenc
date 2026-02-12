<div align="center">
    <h1>Tree-sitter Zen-C</h1>
</div>
<hr>

<div align="center">
    <p>
        <a href="#">
            <img src="https://www.gnu.org/graphics/lgplv3-with-text-154x68.png", alt="license">
        </a>
    </p>
</div>

### A [Tree Sitter](https://tree-sitter.github.io) grammar for [Zen-C](https://zenc-lang.org).

## Building
There are a few ways you can build the grammar:

With Make:
```bash
make PREFIX=/path/to/somewhere
make PREFIX=/path/to/somewhere install
```

With CMake:
```bash
cmake -B .build -DCMAKE_INSTALL_PREFIX=/path/to/somewhere
cmake --build .build
cmake --install .build
```
With Zig:
```bash
zig build --release=safe --prefix /path/to/somewhere
```

With the `tree-sitter` cli (mostly for development purposes):
```bash
tree-sitter build
# optionally, for use with 'tree-sitter playground'
tree-sitter build --wasm
```
---
## License
This repositor is licensed under the terms of the [GNU Lesser General Public License](https://gnu.org/licenses/lgpl-3.0.html), version 3.0 or later.  
See the [license file](LICENSE.md) for more information.  

This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.
