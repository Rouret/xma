local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new(states)
    return setmetatable(
        {
            states = states,
            current = nil
        },
        self
    )
end

function StateMachine:change(state, ...)
    assert(self.states[state], "État inconnu : " .. state)
    if self.current and self.states[self.current].exit then
        self.states[self.current].exit(self, ...)
    end
    self.current = state
    if self.states[self.current].enter then
        self.states[self.current].enter(self, ...)
    end
end

function StateMachine:update(dt)
    if self.states[self.current].update then
        self.states[self.current].update(self, dt)
    end
end

function StateMachine:draw()
    if self.states[self.current].draw then
        self.states[self.current].draw(self)
    end
end

return StateMachine
