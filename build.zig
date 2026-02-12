const std = @import("std");
const semver = std.SemanticVersion;
const fmt = std.fmt;


pub fn build(b: *std.Build) !void {
    const project_version = try semver.parse("0.1.0");
    const treesitter_abi_version = try semver.parse("15.0.0");
    
    var buffer: [6]u8 = undefined;
    const soversionstr = try fmt.bufPrint(&buffer, "{d}.{d}.{d}", .{
        treesitter_abi_version.major,
        project_version.major,
        0
    });

    const soversion = try semver.parse(soversionstr);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const reuse_alloc = b.option(bool, "reuse-allocator", "Reuse the library allocator") orelse false;

    const library_name = "tree-sitter-zenc";

    // var pcbuffer: [300]u8 = undefined;

    const pcdesc = "Tree-sitter grammar for Zen-C";
    const pcurl = "https://codeberg.org/wreedb/tree-sitter-zenc";

    // const pctext = try fmt.bufPrint(
    //     &pcbuffer,
    //     "prefix=${{pcfiledir}}/../..\nlibdir=${{prefix}}/lib\nincludedir=${{prefix}}/include\n\nname: {s}\ndescription: {s}\nurl: {s}\nversion: {d}.{d}.{d}\nlibs: -L${{libdir}} -ltree-sitter-zenc\ncflags: -I${{includedir}}", .{
    //     library_name,
    //     pcdesc,
    //     pcurl,
    //     project_version.major,
    //     project_version.minor,
    //     project_version.patch
    // });

    const pctext = b.fmt(
        \\prefix=${{pcfiledir}}/../..
        \\exec_prefix=${{prefix}}
        \\libdir=${{prefix}}/lib
        \\includedir=${{prefix}}/include
        \\
        \\name: {s}
        \\description: {s}
        \\url: {s}
        \\version: {d}.{d}.{d}
        \\libs: -L${{libdir}} -l{s}
        \\cflags: -I${{includedir}}
    , .{
        library_name,
        pcdesc,
        pcurl,
        project_version.major,
        project_version.minor,
        project_version.patch,
        library_name
    });

    const cwd = std.fs.cwd();
    var generatedpc = try cwd.createFile("tree-sitter-zenc.pc", .{ .truncate = true });
    try generatedpc.writeAll(pctext);
    generatedpc.close();

    const pkgconfigfile_step = b.addInstallFileWithDir(
        b.path("tree-sitter-zenc.pc"),
        .lib,
        "pkgconfig/tree-sitter-zenc.pc"
    );

    b.getInstallStep().dependOn(&pkgconfigfile_step.step);


    // const pkgconfig_file = b.addWriteFile("tree-sitter-zenc.pc", pctext);
    // b.getInstallStep().dependOn(&pkgconfig_file.step);
    //
    // //std.debug.print("{any}\n", .{pkgconfig_file.getDirectory().generated.sub_path});
    // const install_pc = b.addInstallFileWithDir(
    //     pkgconfig_file.step,
    //     .lib,
    //     "pkgconfig/tree-sitter-zenc.pc"
    // );
    //
    // b.getInstallStep().dependOn(&install_pc.step);


    const libdynamic: *std.Build.Step.Compile = b.addLibrary(.{
        .name = library_name,
        .linkage = .dynamic,
        .version = soversion,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = true,
        }),
        .use_llvm = true,
    });

    const libstatic: *std.Build.Step.Compile = b.addLibrary(.{
        .name = library_name,
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = true,
        }),
        .use_llvm = true,
    });

    libstatic.addCSourceFile(.{
        .file = b.path("src/parser.c"),
        .flags = &.{"-std=c11"},
    });
    
    libdynamic.addCSourceFile(.{
        .file = b.path("src/parser.c"),
        .flags = &.{"-std=c11"},
    });
    
    if (fileExists(b, "src/scanner.c")) {
        
        libstatic.addCSourceFile(.{
            .file = b.path("src/scanner.c"),
            .flags = &.{"-std=c11"},
        });
        
        libdynamic.addCSourceFile(.{
            .file = b.path("src/scanner.c"),
            .flags = &.{"-std=c11"},
        });
    
    }

    if (reuse_alloc) {
        libstatic.root_module.addCMacro("TREE_SITTER_REUSE_ALLOCATOR", "");
        libdynamic.root_module.addCMacro("TREE_SITTER_REUSE_ALLOCATOR", "");
    }
    if (optimize == .Debug) {
        libstatic.root_module.addCMacro("TREE_SITTER_DEBUG", "");
        libdynamic.root_module.addCMacro("TREE_SITTER_DEBUG", "");
    }

    libdynamic.addIncludePath(b.path("src"));
    libstatic.addIncludePath(b.path("src"));

    libdynamic.installHeader(
        b.path("bindings/c/tree_sitter/tree-sitter-zenc.h"),
        "tree_sitter/tree-sitter-zenc.h"
    );

    b.installArtifact(libdynamic);
    b.installArtifact(libstatic);


    // b.installFile("src/node-types.json", "node-types.json");

    if (fileExists(b, "queries")) {
        b.installDirectory(.{
            .source_dir = b.path("queries"),
            .install_dir = .prefix,
            .install_subdir = "share/tree-sitter/queries/zenc",
            .include_extensions = &.{"scm"},
        });
    }

    const module = b.addModule(library_name, .{
        .root_source_file = b.path("bindings/zig/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.linkLibrary(libstatic);
    module.linkLibrary(libdynamic);

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("bindings/zig/test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    
    tests.root_module.addImport(library_name, module);

    // HACK: fetch tree-sitter dependency only when testing this module
    if (b.pkg_hash.len == 0) {
        var args = try std.process.argsWithAllocator(b.allocator);
        defer args.deinit();
        while (args.next()) |a| {
            if (std.mem.eql(u8, a, "test")) {
                const ts_dep = b.lazyDependency("tree_sitter", .{}) orelse continue;
                tests.root_module.addImport("tree-sitter", ts_dep.module("tree-sitter"));
                break;
            }
        }
    }

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}




inline fn fileExists(b: *std.Build, filename: []const u8) bool {
    const dir = b.build_root.handle;
    dir.access(filename, .{}) catch return false;
    return true;
}
