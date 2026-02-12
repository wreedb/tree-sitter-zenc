default: regen

regen:
    tree-sitter generate

build: regen
    tree-sitter build


play: build
    tree-sitter build --wasm
    tree-sitter playground

clean:
    -rm -rf .zig-cache zig-out
    -rm -rf stage build .build .bld bld
    -rm -rf *.wasm *.so *.a *.o *.out

commit:
    convco commit -i

build-zig:
    zig build --release=safe
