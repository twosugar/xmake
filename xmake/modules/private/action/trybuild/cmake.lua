--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015-2020, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        cmake.lua
--

-- imports
import("core.base.option")
import("core.project.config")
import("lib.detect.find_file")

-- get build directory
function _get_buildir()
    return config.buildir() or "build"
end

-- get artifacts directory
function _get_artifacts_dir()
    return path.absolute(path.join(_get_buildir(), "artifacts"))
end

-- detect build-system and configuration file
function detect()
    return find_file("CMakeLists.txt", os.curdir())
end

-- do clean
function clean()
    local buildir = _get_buildir()
    if os.isdir(buildir) then
        local configfile = find_file("[mM]akefile", buildir) or (is_plat("windows") and find_file("*.sln", buildir))
        if configfile then
            local oldir = os.cd(buildir)
            if is_plat("windows") then
                os.exec("msbuild \"%s\" -nologo -t:Clean -p:Configuration=%s -p:Platform=%s", configfile, is_mode("debug") and "Debug" or "Release", is_arch("x64") and "x64" or "Win32")
            else
                os.exec("make clean")
            end
            os.cd(oldir)
        end
    end
end

-- do build
function build()

    -- get artifacts directory
    local artifacts_dir = _get_artifacts_dir()
    if not os.isdir(artifacts_dir) then
        os.mkdir(artifacts_dir)
    end
    os.cd(_get_buildir())

    -- generate makefile
    local configfile = find_file("[mM]akefile", os.curdir()) or (is_plat("windows") and find_file("*.sln", os.curdir()))
    if not configfile then
        local argv = {"-DCMAKE_INSTALL_PREFIX=" .. artifacts_dir, "-DDCMAKE_INSTALL_LIBDIR=" .. path.join(artifacts_dir, "lib")}
        if is_plat("windows") and is_arch("x64") then
            table.insert(argv, "-A")
            table.insert(argv, "x64")
        end
        table.insert(argv, '..')
        os.execv("cmake", argv)
    end

    -- do build
    if is_plat("windows") then
        local slnfile = assert(find_file("*.sln", os.curdir()), "*.sln file not found!")
        os.exec("msbuild \"%s\" -nologo -t:Build -p:Configuration=%s -p:Platform=%s", slnfile, is_mode("debug") and "Debug" or "Release", is_arch("x64") and "x64" or "Win32")
        local projfile = os.isfile("INSTALL.vcxproj") and "INSTALL.vcxproj" or "INSTALL.vcproj"
        if os.isfile(projfile) then
            os.exec("msbuild \"%s\" /property:configuration=%s", projfile, is_mode("debug") and "Debug" or "Release")
        end
    else
        os.exec("make -j" .. option.get("jobs"))
        os.exec("make install")
    end
    cprint("output to ${bright}%s", artifacts_dir)
    cprint("${bright}build ok!")
end

