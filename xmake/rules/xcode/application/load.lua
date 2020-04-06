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
-- @file        load.lua
--

-- main entry
function main (target)

    -- get app directory
    local targetdir = target:targetdir()
    local appdir = path.join(targetdir, target:basename() .. ".app")
    target:data_set("xcode.appdir", appdir)

    -- set target info for app 
    target:set("kind", "binary")
    target:set("filename", target:basename())
    if is_plat("macosx") then
        target:set("targetdir", path.join(appdir, "Contents", "MacOS"))
    else
        target:set("targetdir", appdir)
    end

    -- add frameworks
    if is_plat("macosx") then
        target:add("frameworks", "AppKit")
    else
        target:add("frameworks", "UIKit")
    end

    -- register clean files for `xmake clean`
    target:add("cleanfiles", appdir)
end