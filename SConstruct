#!/usr/bin/env python
import os
import sys

def _detect_emsdk():
    """Find Emscripten SDK and return (root, node_bin) paths, or (None, None)."""
    candidates = [
        "D:/Software/emsdk",
        os.path.expanduser("~/emsdk"),
        "C:/emsdk",
    ]
    for root in candidates:
        if os.path.isdir(root):
            node_base = os.path.join(root, "node")
            node_bin = None
            if os.path.isdir(node_base):
                for d in os.listdir(node_base):
                    p = os.path.join(node_base, d, "bin")
                    if os.path.isfile(os.path.join(p, "node.exe")):
                        node_bin = p
                        break
            return root, node_bin
    return None, None

def _setup_path():
    """Inject Emscripten paths into PATH for web builds."""
    emsdk_root, node_bin = _detect_emsdk()
    if emsdk_root is None:
        return
    paths = [emsdk_root, os.path.join(emsdk_root, "upstream", "emscripten")]
    if node_bin:
        paths.append(node_bin)
    paths.append(os.environ.get("PATH", ""))
    os.environ["PATH"] = os.pathsep.join(paths)

if ARGUMENTS.get("platform") == "web":
    _setup_path()

env = SConscript("godot-cpp/SConstruct")

# Strip "template_" from target names (e.g. "template_release" -> "release")
env["suffix"] = env["suffix"].replace(".template_", ".")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

libname = "project/addons/chladni_pattern/bin/libchladni{}{}".format(env["suffix"], env["SHLIBSUFFIX"])
library = env.SharedLibrary(libname, source=sources)

Default(library)
