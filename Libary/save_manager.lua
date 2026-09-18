local httpService = game:GetService('HttpService')

local SaveManager = {} do
    SaveManager.Folder = 'LunarSettings'
    SaveManager.Ignore = {}
    SaveManager.Library = nil

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local toggleObj = SaveManager.Library:GetObjectByFlag(idx)
                    if toggleObj then toggleObj:SetValue(data.value) end
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local sliderObj = SaveManager.Library:GetObjectByFlag(idx)
                    if sliderObj then sliderObj:SetValue(tonumber(data.value)) end
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local dropObj = SaveManager.Library:GetObjectByFlag(idx)
                    if dropObj then dropObj:SetValue(data.value) end
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = 'ColorPicker', idx = idx, r = object.Value.R, g = object.Value.G, b = object.Value.B }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local colObj = SaveManager.Library:GetObjectByFlag(idx)
                    if colObj then colObj:SetValue(Color3.fromRGB(data.r * 255, data.g * 255, data.b * 255)) end
                end
            end,
        },
        Keybind = {
            Save = function(idx, object)
                return { type = 'Keybind', idx = idx, key = object.Value.Name }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local kbObj = SaveManager.Library:GetObjectByFlag(idx)
                    if kbObj and Enum.KeyCode[data.key] then kbObj:SetValue(Enum.KeyCode[data.key]) end
                end
            end,
        },
        Textbox = {
            Save = function(idx, object)
                return { type = 'Textbox', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Flags[idx] ~= nil then
                    local txtObj = SaveManager.Library:GetObjectByFlag(idx)
                    if txtObj then txtObj:SetValue(data.text) end
                end
            end,
        },
    }

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:Save(name)
        if not name or name:gsub(' ', '') == '' then
            return false, 'invalid config name'
        end

        local fullPath = self.Folder .. '/settings/' .. name .. '.json'
        local data = { objects = {} }

        for idx, val in next, self.Library.Flags do
            if self.Ignore[idx] then continue end
            
            local obj = self.Library:GetObjectByFlag(idx)
            if obj and obj.Type and self.Parser[obj.Type] then
                table.insert(data.objects, self.Parser[obj.Type].Save(idx, obj))
            end
        end

        local success, encoded = pcall(httpService.JSONEncode, httpService, data)
        if not success then return false, 'encode error' end

        writefile(fullPath, encoded)
        return true
    end

    function SaveManager:Load(name)
        if not name then return false, 'no config selected' end
        
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if not isfile(file) then return false, 'file not found' end

        local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
        if not success then return false, 'decode error' end

        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                task.spawn(function() 
                    self.Parser[option.type].Load(option.idx, option) 
                end)
            end
        end

        return true
    end

    function SaveManager:BuildFolderTree()
        local paths = { self.Folder, self.Folder .. '/themes', self.Folder .. '/settings' }
        for i = 1, #paths do
            if not isfolder(paths[i]) then makefolder(paths[i]) end
        end
    end

    function SaveManager:RefreshConfigList()
        local list = listfiles(self.Folder .. '/settings')
        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == '.json' then
                local pos = file:find('.json', 1, true)
                local start = pos
                local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end
                if char == '/' or char == '\\' then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end
        return out
    end

    function SaveManager:LoadAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then
            local name = readfile(self.Folder .. '/settings/autoload.txt')
            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify('Autoload Failed', err, 3)
            end
            self.Library:Notify('Auto Loaded', string.format('Config %q loaded', name), 3)
        end
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, 'Must set SaveManager.Library first')

        local section = self.Library:AddSection(tab, "Configuration")

        self.Library:AddTextbox(section, {
            Name = "Config Name",
            Placeholder = "Enter config name...",
            Flag = "SM_ConfigName",
        })

        local configDropdown = self.Library:AddDropdown(section, {
            Name = "Config List",
            Options = self:RefreshConfigList(),
            Default = "",
            Flag = "SM_ConfigList",
        })

        self.Library:AddButton(section, {
            Name = "Create Config",
            Callback = function()
                local name = self.Library.Flags["SM_ConfigName"]
                if not name or name:gsub(' ', '') == '' then
                    return self.Library:Notify("Error", "Invalid config name", 3)
                end
                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify("Error", err, 3)
                end
                self.Library:Notify("Success", string.format("Created %q", name), 3)
                configDropdown:SetOptions(self:RefreshConfigList())
                configDropdown:SetValue("")
            end
        })

        self.Library:AddButton(section, {
            Name = "Load Config",
            Callback = function()
                local name = self.Library.Flags["SM_ConfigList"]
                if not name or name == "" then
                    return self.Library:Notify("Error", "Select a config", 3)
                end
                local success, err = self:Load(name)
                if not success then
                    return self.Library:Notify("Error", err, 3)
                end
                self.Library:Notify("Success", string.format("Loaded %q", name), 3)
            end
        })

        self.Library:AddButton(section, {
            Name = "Overwrite Config",
            Callback = function()
                local name = self.Library.Flags["SM_ConfigList"]
                if not name or name == "" then
                    return self.Library:Notify("Error", "Select a config", 3)
                end
                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify("Error", err, 3)
                end
                self.Library:Notify("Success", string.format("Overwrote %q", name), 3)
            end
        })

        self.Library:AddButton(section, {
            Name = "Refresh List",
            Callback = function()
                configDropdown:SetOptions(self:RefreshConfigList())
                configDropdown:SetValue("")
            end
        })

        self.Library:AddButton(section, {
            Name = "Set Autoload",
            Callback = function()
                local name = self.Library.Flags["SM_ConfigList"]
                if not name or name == "" then
                    return self.Library:Notify("Error", "Select a config", 3)
                end
                writefile(self.Folder .. '/settings/autoload.txt', name)
                self.Library:Notify("Autoload", string.format("%q set as autoload", name), 3)
            end
        })

        self:SetIgnoreIndexes({ "SM_ConfigName", "SM_ConfigList" })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager