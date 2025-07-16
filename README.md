# Scriptorio

**Intro**:

Allows for in game running of user defined code. Fully open environemnt and no sandboxing (as much as Factorio's api allows). Also comes with my custom API/utilities, which makes scripting much better.

---

**Dependencies**: 

- [Murk Core](https://github.com/murk108/murk-core)
- [Murk Wire System](https://github.com/murk108/murk-wire-system)

---

**In Game Controls**:

- **G** to open the **Script Terminal**, and the **Wire Selector**.
- **Click** on entities to open the marker renamer GUI.
- **Shift + Click** to connect entities with wire.
- **Shift + Right Click** to deselect the current entity.

---

**Usage of the scheduler and hooker**:

Let's say we wanted to simulate notifications. One guy notifies every second, and another guy receives it, but responds 2 seconds late everytime.

``` lua
-- 60 ticks in one second
local initial_delay = 1 -- 1 tick delay aka 1/60th of a second

Scheduler:schedule(initial_delay, function ()
    Hooker:trigger_hook("notify", "I notified you at tick " .. Scheduler.tick .. ", I'll notify you again in 1 second")
    return 60 -- 1 second delay
end)

Hooker:add_hook("notify", function(message)
    local response_delay = 120 -- 2 second delay
    Scheduler:schedule(response_delay, function ()
        print("I've received your message.")
        print("You said: " .. message)
        print("I responded 2 seconds late at tick " .. Scheduler.tick .. ", sorry for the delay!")
        return false -- return false to remove the callback
    end)
end)

```

outputs:
- I notified you at tick 1, I'll notify you again in 1 second
- I notified you at tick 61, I'll notify you again in 1 second

- **I've received your message.**
- **You said: I notified you at tick 1, I'll notify you again in 1 second**
- **I responded 2 seconds late at tick 121, sorry for the delay!**

- I notified you at tick 121, I'll notify you again in 1 second

- **I've received your message.**
- **You said: I notified you at tick 61, I'll notify you again in 1 second**
- **I responded 2 seconds late at tick 181, sorry for the delay!**

- I notified you at tick 181, I'll notify you again in 1 second

- cycle keeps going...

It's quite simple, but quite powerful.

---

**Usage of the wire system**:

![Wire Marker Image](images/wire_marker.png)

Let's say we had this wire network. By itself, it doesn't do much. It only defines the topology, but no logic. That's where the scripting part comes in.

``` lua
Markers.set_marker_name(1, "circles") -- the marker name is set ingame via a gui, but we do this for now since it's an example.

local markers = Markers.get_markers("circles") -- multiple markers can have the same name, hence get_markers
local red_graph = Wires.get_graph("red")

-- marker_id = 1 here, since we just set it earlier
local marker_id = markers[1] -- for this example, theres only 1 marker named "circles"

local network = red_graph:get_network(marker_id)

for i = 1, #network do
    local id = network[i]
    print(id)

    -- can do more fancy stuff...
end
```

outputs:
- 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

This basically gives you an elegant way to seperate topology from logic. Just a very simple scenario.

---

**In game usage**:

![Entity Group](images/entity_group.png)

Let's say we wanted to add 1 iron plate every 10 seconds into all of these chests.

``` lua
local red_graph = Wires.get_graph("red")

Scheduler:schedule(1, function ()
    -- gets all the entities in the group "entity_group", using the red_graph
    local entities = Markers.get_entities_from_graph("entity_group", red_graph)

    for i = 1, #entities do
        local entity = entities[i]
        local inventory = entity.get_inventory(defines.inventory.chest)
        inventory.insert{name = "iron-plate", count = 1} -- adds 1 iron plate into the chest
    end

    return 600 -- waits for 10 seconds before running again
end)
```

---

**Optional In-Terminal File System**:

Since the terminal only runs code, and Factorio doesn't allow file reading/writing, I made a tool to handle that issue. This tool basically allows you to write modular code in different files with `require` capabilitites, and still be able to run it all inside the terminal, in one paste. Just a quality of life thing. It's kind of like a mod loader, but done in-game at runtime.

[Lua Virtual Filesystem](https://github.com/murk108/lua-vfs)

---

**Documentation**:

All of the available documentation is inside the `luaserver` folder in any of my mods. The source code also acts as documentation if the `luaserver` folder isn't enough.

This is also useful if you want to interact with the game [Factorio Lua API Docs](https://lua-api.factorio.com/)

---

**VS Code Intellisense**:

To get intellisense working with my mods, you need the **Lua Language Server** plugin in VS Code. After, you need to add the `luaserver` folders into the **Lua.workspace.library** field inside `.vscode/settings.json`.

For example, like this:

``` json
"Lua.workspace.library": [
    "${env:APPDATA}\\Factorio\\mods\\murk-core_1.0.0\\luaserver",
    "${env:APPDATA}\\Factorio\\mods\\murk-wire-system_1.0.0\\luaserver"
]
```

It's also highly recommended to get [Factorio Modding Toolkit Plugin](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug).

---

**Final Words**:

Using all these building blocks, you can theoretically automate your entire factory. Please don't cheat or troll ;). You can do anything you want with this really.