---LayoutMode determines how child components are laid out in the UI
---@class LayoutMode: class
---@field direction "horizontal" | "vertical"
local LayoutMode = require("class"):extend("LayoutMode")

---Creates a new layout mode from the given options
---Options are compatible with layout modes, meaning they can be used to create extensions
---@param options table
function LayoutMode:new(options)
    self.direction = options.direction
end

---Updates the position of the UI's next component in relation to its previous component,
---wrapping around if its container cannot contain it.
---@param ui UI
---@param component Rectangle
function LayoutMode:updatePosition(ui, component)
    -- TODO: wait, won't this allow content to overflow?
    -- Maybe position should be calculated before drawing
    if self.direction == "horizontal" then
        ui.px = ui.px + component.width
        if ui.px >= ui.container.width then
            ui.py = ui.py + component.height
            ui.px = ui.container.x
        end
    else
        ui.py = ui.py + component.height
        if ui.py >= ui.container.height then
            ui.px = ui.px + component.width
            ui.py = ui.container.y
        end
    end
end

LayoutMode.vertical = LayoutMode:new({ direction = "vertical" })
LayoutMode.horizontal = LayoutMode:new({ direction = "horizontal" })

return LayoutMode